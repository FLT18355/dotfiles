#!/usr/bin/env python3
"""
music2video —— 音频 → 中心对称频谱柱状可视化视频

设计参考（mirrored / dual-bar visualizer 这一类）：
  - hathibelagal-dev/musicviz      "Mirrored, centered frequency bars with soft glow"
  - TheMarco/VideoSpectrumAnalyzer "Symmetrical bars that grow both up and down from a center"
  - goph-R/MusicFX                 "mirrored equalizer (centered, vertical bars)" + glow

特点：
  * 柱子从画面**水平中轴**向上下对称展开
  * 柱子数量少、间距大，画面更透气
  * 柱头柱尾是**圆角胶囊形**（用 SDF 有符号距离场，天然抗锯齿）
  * 柱体周围有同色系**光晕**做氛围
  * 颜色可调，默认橙色

做法：
  1. ffmpeg 把音频解成 mono float32 PCM
  2. numpy 做 STFT，按对数频率归并成 N 根柱子
  3. 每帧用 SDF 生成柱子的圆角遮罩和光晕，上下镜像
  4. rgb24 原始像素直接管道喂给 ffmpeg 编码（不落中间图片）

用法：
  python3 music2video.py <输入.mp3> [输出.mp4]
  python3 music2video.py <目录>              # 批量

常用选项：
  --size 1280x720        分辨率，默认 1280x720
  --fps 30               帧率，默认 30
  --bars 40              柱子数量，默认 40
  --color "#FF7A18"      柱子主色，默认橙色
  --color2 "#FFC46B"     柱子渐变副色（柱尖），默认自动由主色生成
  --glow "#FF6A00"       光晕颜色，默认同主色
  --glow-strength 0.55   光晕强度 0~2，默认 0.55
  --gap 0.75             柱间距 / 柱宽 的比值，默认 0.75
  --theme NAME           预设配色：orange(默认) / sunset / fire / mono / neon
  --no-glow              关掉光晕
  --crf 20               画质（越小越清晰），默认 20
"""

import argparse
import colorsys
import os
import subprocess
import sys
import time
from pathlib import Path

import numpy as np

AUDIO_EXT = {".mp3", ".wav", ".flac", ".m4a", ".aac", ".ogg", ".opus", ".wma"}

# ---------------- 预设配色 ----------------
PRESETS = {
    "orange": {"bg": "#07050D", "color": "#FF7A18", "color2": "#FFC46B", "glow": "#FF6A00"},
    "sunset": {"bg": "#0B0508", "color": "#FF5E7A", "color2": "#FFC46B", "glow": "#FF4E6A"},
    "fire":   {"bg": "#080403", "color": "#FF7A18", "color2": "#FFE08A", "glow": "#FF4A00"},
    "mono":   {"bg": "#0A0A0C", "color": "#E8E8EE", "color2": "#FFFFFF", "glow": "#B0B0C0"},
    "neon":   {"bg": "#06070F", "color": "#00C8FF", "color2": "#FF3BD4", "glow": "#8A5CFF"},
    # 不抢画面版：低饱和 + 低亮度，适合当背景衬字/叠加其它素材
    "soft":   {"bg": "#08070A", "color": "#8F5C33", "color2": "#B98A5E", "glow": "#5F3A1E"},
    "ash":    {"bg": "#08080A", "color": "#7E7E86", "color2": "#A8A8B0", "glow": "#5C5C66"},
    # Catppuccin Mocha：沿频段走一圈柔和的粉彩色标
    "catppuccin": {
        "bg": "#11111B",                  # Mocha crust
        "color": "#B4BEFE", "color2": "#F5C2E7",
        "glow": "#CBA6F7",                # Mocha mauve
        "stops": [
            (0.00, "#B4BEFE"),   # lavender
            (0.18, "#89DCEB"),   # sky
            (0.36, "#94E2D5"),   # teal
            (0.54, "#A6E3A1"),   # green
            (0.70, "#F9E2AF"),   # yellow
            (0.85, "#FAB387"),   # peach
            (1.00, "#F5C2E7"),   # pink
        ],
    },
}
DEFAULT_PRESET = "orange"
# 每种风格的默认柱子数（更少 → 更粗、间距更大）
DEFAULT_BARS = {"bars": 36, "scale": 16, "radial": 40}


def parse_color(s, default=None):
    """'#RRGGBB' / 'RRGGBB' / 'r,g,b' → np.array([r,g,b], float32)"""
    if s is None:
        if default is None:
            return None
        return parse_color(default)
    s = str(s).strip()
    if s.startswith("#"):
        s = s[1:]
    if "," in s:
        parts = [p.strip() for p in s.split(",")]
        return np.array([float(p) for p in parts[:3]], np.float32)
    if len(s) == 3:
        s = "".join(c * 2 for c in s)
    if len(s) != 6:
        raise ValueError(f"颜色格式不对: {s}")
    return np.array([int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16)], np.float32)


def clean_text(v):
    """空串、'-'、'无' 都当作「不显示」"""
    if v is None:
        return None
    v = str(v).strip()
    if v in ("", "-", "—", "无", "none", "None", "null"):
        return None
    return v


def stops_to_colors(stops, n):
    """多色标插值成 n 个颜色：stops = [(0.0, '#RRGGBB'), ..., (1.0, '#RRGGBB')]"""
    pos = np.array([s[0] for s in stops], np.float32)
    rgb = np.stack([parse_color(c) for _, c in stops])
    t = np.linspace(0.0, 1.0, n)
    out = np.empty((n, 3), np.float32)
    for ch in range(3):
        out[:, ch] = np.interp(t, pos, rgb[:, ch])
    return out


def resolve_cols(preset, n, color_arg=None, color2_arg=None, sat=1.0, val=1.0):
    """算出每根柱子的基色 (n,3)。主题带 stops 就用多色标，否则两色线性插值。"""
    stops = preset.get("stops")
    if stops and color_arg is None:
        base = stops_to_colors(stops, n)
    else:
        c1 = parse_color(color_arg, preset["color"])
        c2 = parse_color(color2_arg, preset["color2"])
        t = np.linspace(0.0, 1.0, n, dtype=np.float32)[:, None]
        base = c1[None, :] * (1 - t) + c2[None, :] * t
    if sat != 1.0 or val != 1.0:
        base = np.stack([adjust_color(base[i], sat, val) for i in range(n)])
    return base


def adjust_color(rgb, sat=1.0, val=1.0):
    """按 HSL 调整饱和度 / 亮度。sat<1 更灰、val<1 更暗"""
    r, g, b = [float(c) / 255.0 for c in rgb]
    h, l, s_ = colorsys.rgb_to_hls(r, g, b)
    s_ = min(1.0, max(0.0, s_ * sat))
    l = min(1.0, max(0.0, l * val))
    r, g, b = colorsys.hls_to_rgb(h, l, s_)
    return np.array([r * 255, g * 255, b * 255], np.float32)


# ---------------- 音频 ----------------
def decode_audio(path, sr):
    """解成 mono float32"""
    proc = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(path),
         "-f", "f32le", "-ac", "1", "-ar", str(sr), "-"],
        capture_output=True,
    )
    if proc.returncode != 0:
        raise RuntimeError("ffmpeg 解码失败: " + proc.stderr.decode(errors="replace")[:400])
    data = np.frombuffer(proc.stdout, dtype=np.float32)
    if data.size == 0:
        raise RuntimeError("解码得到空音频")
    return data


# ---------------- 频谱 ----------------
def compute_spectrum(samples, sr, fps, n_fft, bars, fmin=30.0, fmax=16000.0, gamma=2.2):
    """
    返回 (n_frames, bars) 的 0~1 能量矩阵

      1. 幅值按 n_fft/2 归一（否则取 log 后全部爆顶）
      2. 每个频段取 max 而不是 mean，瞬态更积极
      3. 加 4 dB/oct 的频谱倾斜，补偿音乐天然的高频滚降
      4. 自适应增益：以 98 分位为参考，不同响度的歌都能满屏
    """
    hop = max(1, int(round(sr / fps)))
    n_frames = max(1, int(np.ceil(len(samples) / hop)))

    pad = n_fft // 2
    padded = np.concatenate([np.zeros(pad, np.float32), samples, np.zeros(pad + n_fft, np.float32)])
    view = np.lib.stride_tricks.sliding_window_view(padded, n_fft)
    idx = np.arange(n_frames) * hop

    window = np.hanning(n_fft).astype(np.float32)
    freqs = np.fft.rfftfreq(n_fft, 1.0 / sr)

    edges = np.geomspace(fmin, min(fmax, sr / 2), bars + 1)
    bin_idx = []
    for b in range(bars):
        sel = np.nonzero((freqs >= edges[b]) & (freqs < edges[b + 1]))[0]
        if sel.size == 0:
            sel = np.array([int(np.argmin(np.abs(freqs - (edges[b] + edges[b + 1]) / 2)))])
        bin_idx.append(sel)

    raw = np.zeros((n_frames, bars), np.float32)
    CHUNK = 512
    for start in range(0, n_frames, CHUNK):
        stop = min(start + CHUNK, n_frames)
        frames = view[idx[start:stop]] * window
        spec = np.abs(np.fft.rfft(frames, axis=1)).astype(np.float32)
        for b in range(bars):
            raw[start:stop, b] = spec[:, bin_idx[b]].max(axis=1)

    db = 20.0 * np.log10(raw / (n_fft / 2.0) + 1e-9)

    centers = np.sqrt(edges[:-1] * edges[1:])
    db = db + 4.0 * np.log2(centers / centers[0])[None, :]

    top = float(np.percentile(db, 98))
    out = np.clip((db - (top - 55.0)) / 55.0, 0.0, 1.0)
    # gamma > 1 拉开对比度：音乐（尤其 EDM）的 dB 分布很窄，
    # 不压一下的话所有柱子都挤在高位，看不出起伏
    out = out ** gamma
    return out.astype(np.float32), n_frames


def smooth_envelope(spec, fps, attack_sec=0.02, decay_sec=0.25):
    """起音快、回落慢"""
    out = np.empty_like(spec)
    prev = np.zeros(spec.shape[1], np.float32)
    a_up = 1.0 - np.exp(-1.0 / max(fps * attack_sec, 1e-6))
    a_dn = 1.0 - np.exp(-1.0 / max(fps * decay_sec, 1e-6))
    for i in range(spec.shape[0]):
        cur = spec[i]
        prev = prev + (cur - prev) * np.where(cur > prev, a_up, a_dn)
        out[i] = prev
    return out


# ---------------- 画面 ----------------
def build_background(w, h, bg_color):
    """竖直渐变 + 中轴附近一圈暖光，静态，只需算一次"""
    ys = np.linspace(0, 1, h, dtype=np.float32)[:, None]
    # 上下略亮、正中略暗，形成一点纵深
    shape = 0.55 + 0.45 * np.abs(ys - 0.5) * 2.0
    bg = np.array(bg_color, np.float32)[None, :] * shape
    img = np.broadcast_to(bg[:, None, :], (h, w, 3)).copy()
    return img


def _finish(raw, buf, out, h, hh, i, n_frames, decor=None):
    """上半缓冲 → 镜像成整帧 → 写管道"""
    top = buf.astype(np.uint8)
    raw[0:hh] = top
    raw[hh:h] = top[::-1][: h - hh]
    if decor is not None:
        decor.apply(raw, i)
    if out is not None:
        out.write(raw.tobytes())
    if i % 30 == 0:
        print(f"\r  渲染 {i}/{n_frames} ({i*100//max(n_frames,1)}%)",
              end="", file=sys.stderr, flush=True)


def render_bars(spec, w, h, fps, bars, cols, glow_cols, bg_color,
                glow_strength=0.65, gap_ratio=0.85, center_gap=18.0, out=None, decor=None):
    """中心对称柱状渲染（只算上半部分，下半靠镜像）"""
    n_frames = spec.shape[0]
    hh = h // 2                    # 上半部分行数，下半靠镜像
    cy = hh - 0.5                  # 中轴（上半部分坐标系里）
    max_half = int(hh * 0.72)      # 柱子最大半高（留出上下呼吸空间）

    # ---- 柱子横向布局 ----
    # 先用假设的柱宽估间距，再反解实际柱宽，保证总宽占画面 ~86%
    usable_w = int(w * 0.86)
    # usable_w = bars*bw + (bars-1)*gap,  gap = bw*gap_ratio
    denom = bars + (bars - 1) * gap_ratio
    bw = max(2.0, usable_w / denom)
    gap = bw * gap_ratio
    total = bars * bw + (bars - 1) * gap
    x_start = (w - total) / 2.0
    centers = x_start + bw / 2.0 + np.arange(bars) * (bw + gap)

    r = bw / 2.0                   # 圆角半径 = 半柱宽 → 两头是半圆（胶囊）
    glow_px = max(8.0, bw * 1.8)   # 光晕扩散半径

    # 每列属于哪根柱子（离柱子外就算 0 影响）
    xs = np.arange(w, dtype=np.float32) + 0.5
    col_bar = np.full(w, -1, np.int32)
    for b in range(bars):
        xa = int(round(centers[b] - bw / 2.0))
        xb = int(round(centers[b] + bw / 2.0))
        col_bar[max(0, xa):min(w, xb)] = b

    xdist = np.full(w, 1e4, np.float32)   # |x-xc| - (bw/2 - r)，r=bw/2 时即 |x-xc|
    valid = col_bar >= 0
    xdist[valid] = np.abs(xs[valid] - centers[col_bar[valid]]) - (bw / 2.0 - r)

    ys = np.arange(hh, dtype=np.float32) + 0.5
    ydist_from_cy = np.abs(ys - cy)       # (hh,) 到中轴的距离

    # 颜色：横向按 cols（每根柱子一个基色），纵向从 0.55 到 1.15 的亮度坡度
    ramp = (0.55 + 0.60 * np.clip(ydist_from_cy / max(max_half, 1), 0, 1))[:, None, None]
    col_w = cols[col_bar.clip(0)]                      # (w,3)
    col_lut = np.clip(ramp * col_w[None, :, :], 0, 255)  # (hh,w,3) 预计算一次

    glow_w = glow_cols[col_bar.clip(0)].astype(np.float32)   # (w,3) 每列的光晕色
    background = build_background(w, hh, bg_color)

    buf = np.empty((hh, w, 3), np.float32)
    raw = np.empty((h, w, 3), np.uint8)

    for i in range(n_frames):
        lengths = np.clip(spec[i] * max_half, 0, max_half)      # (bars,) 柱长
        bar_len = np.zeros(w, np.float32)
        bar_len[valid] = lengths[col_bar[valid]]

        # 柱子从中轴偏移 center_gap 处开始，向外延伸 bar_len
        # 胶囊中心位于 cy - center_gap - bar_len/2
        bar_center = cy - center_gap - bar_len * 0.5          # (w,)

        # ---- SDF：胶囊形 ----
        ydist = np.abs(ys[:, None] - bar_center[None, :]) - (bar_len[None, :] * 0.5 - r)
        dx = np.maximum(xdist, 0.0)[None, :]
        dy = np.maximum(ydist, 0.0)
        d = np.sqrt(dx * dx + dy * dy) + np.minimum(np.maximum(dx, dy), 0.0) - r

        # 柱体遮罩（1px 抗锯齿）
        fill = np.clip(0.5 - d, 0.0, 1.0)

        # 光晕：距离越远越暗
        g = np.exp(-np.maximum(d, 0.0) / glow_px) * glow_strength

        # 合成
        buf[:] = background
        buf += glow_w[None, :, :] * g[:, :, None]
        fa = fill[:, :, None]
        buf *= (1.0 - fa)
        buf += col_lut * fa

        np.clip(buf, 0, 255, out=buf)

        _finish(raw, buf, out, h, hh, i, n_frames, decor)


# ============================================================================
#  其它风格
# ============================================================================

def render_radial(spec, w, h, fps, bars, cols, glow_cols, bg_color,
                  glow_strength=0.65, gap_ratio=0.85, center_gap=0.0, out=None, decor=None):
    """
    环形柱状（circular / radial spectrum）—— 柱子沿圆周向外发散
    参考：Pulseon 的 "Circular Spectrum"、jackPanyj/music-visualizer 的 Ring 模式
    """
    n_frames = spec.shape[0]
    hh = h // 2
    cy = hh - 0.5
    cx = w / 2.0 - 0.5

    xs = np.arange(w, dtype=np.float32) + 0.5
    ys = np.arange(hh, dtype=np.float32) + 0.5
    dx = (xs - cx)[None, :]
    dy = (ys - cy)[:, None]
    R = np.sqrt(dx * dx + dy * dy)
    A = np.arctan2(dy, dx)                       # (hh, w) ∈ [-π, π]

    r_inner = min(w, h) * 0.16                    # 内半径
    max_len = min(w, h) * 0.30                    # 柱子最大长度
    bw = 2 * np.pi * r_inner / bars * (1.0 - gap_ratio / (1.0 + gap_ratio))
    bw = max(bw, 2.0)
    r = min(bw / 2.0, 6.0)                        # 圆角
    glow_px = max(6.0, bw * 1.8)

    # 每个像素属于哪根柱子
    ang01 = (A + np.pi) / (2 * np.pi)             # 0~1
    bidx = np.clip((ang01 * bars).astype(np.int32), 0, bars - 1)
    bar_ang = (bidx + 0.5) / bars * 2 * np.pi - np.pi
    dang = A - bar_ang
    dang = (dang + np.pi) % (2 * np.pi) - np.pi   # 折回 [-π,π]
    arc = np.abs(dang) * np.maximum(R, 1.0)       # 弧长近似

    xdist = arc - (bw / 2.0 - r)
    valid_ang = np.ones_like(xdist)               # 全方向都有柱子

    # 颜色：每根柱子一个基色，直接按角度索引
    pix_cols = cols[bidx]                                            # (hh,w,3)

    background = build_background(w, hh, bg_color)
    glow_pix = glow_cols[bidx].astype(np.float32)   # (hh,w,3)
    buf = np.empty((hh, w, 3), np.float32)
    raw = np.empty((h, w, 3), np.uint8)
    ys_dist = ys - cy

    for i in range(n_frames):
        L = np.clip(spec[i] * max_len, 0.0, max_len)      # (bars,)
        Lpix = L[bidx]                                    # (hh,w)
        radial = R - (r_inner + Lpix * 0.5)               # 到胶囊中心的径向距离
        ydist = np.abs(radial) - (Lpix * 0.5 - r)
        dxq = np.maximum(xdist, 0.0)
        dyq = np.maximum(ydist, 0.0)
        d = np.sqrt(dxq * dxq + dyq * dyq) + np.minimum(np.maximum(dxq, dyq), 0.0) - r
        fill = np.clip(0.5 - d, 0.0, 1.0)
        g = np.exp(-np.maximum(d, 0.0) / glow_px) * glow_strength

        buf[:] = background
        buf += glow_pix * g[:, :, None]
        fa = fill[:, :, None]
        buf *= (1.0 - fa)
        buf += pix_cols * fa
        np.clip(buf, 0, 255, out=buf)

        _finish(raw, buf, out, h, hh, i, n_frames, decor)

def render_scale(spec, w, h, fps, bars, cols, glow_cols, bg_color,
                 glow_strength=0.65, gap_ratio=0.85, out=None, decor=None, **kw):
    """
    缩放柱（scale）—— 柱子锚定在水平中轴，**高度和宽度同时**随幅度缩放

    和 bars 的区别：
      bars  上下两半是镜像（等同倒影），柱宽固定，只有长度变
      scale 每根柱子是一个以中轴为中心的「胶囊」，幅度小的时候缩成小圆点，
            大的时候既变长也变粗 —— 是真的"向两边缩放"而不是"反射"
    """
    n_frames = spec.shape[0]
    hh = h // 2
    cy = hh - 0.5
    max_half = int(hh * 0.52)          # 更短：只占上半高度的 52%

    # 每根柱子占一个固定槽位，实际宽度在槽内缩放
    usable_w = w * 0.80
    pitch = usable_w / bars
    x_start = (w - usable_w) / 2.0
    centers = x_start + pitch * (np.arange(bars) + 0.5)
    base_hw = pitch * 0.33            # 更粗：单根占槽宽的 66%

    xs = np.arange(w, dtype=np.float32) + 0.5
    ys = np.arange(hh, dtype=np.float32) + 0.5

    slot = np.floor((xs - x_start) / pitch).astype(np.int32)
    valid = (slot >= 0) & (slot < bars)
    slot = np.clip(slot, 0, bars - 1)
    xc = np.where(valid, centers[slot], 1e4).astype(np.float32)   # (w,)
    xdist = np.abs(xs - xc)                                        # (w,)

    ramp = (0.55 + 0.60 * np.clip(np.abs(ys - cy) / max(max_half, 1), 0, 1))[:, None, None]
    col_w = cols[slot]                                  # (w,3)
    col_lut = np.clip(ramp * col_w[None, :, :], 0, 255)  # (hh,w,3)

    glow_w = glow_cols[slot].astype(np.float32)   # (w,3) 每列的光晕色
    background = build_background(w, hh, bg_color)
    buf = np.empty((hh, w, 3), np.float32)
    raw = np.empty((h, w, 3), np.uint8)
    ys_d = np.abs(ys - cy)[:, None]                                # (hh,1)

    for i in range(n_frames):
        amp = np.clip(spec[i], 0, 1)
        hw = (base_hw * (0.35 + 0.65 * amp))                       # (bars,)
        hgt = np.maximum(amp * max_half, hw)                       # 至少是个点

        hw_px = np.where(valid, hw[slot], 1.0).astype(np.float32)   # (w,)
        hh_px = np.where(valid, hgt[slot], 1.0).astype(np.float32)  # (w,)

        # 胶囊 SDF：r = hw → x 方向完全由圆角构成，宽度随幅度变
        yd = ys_d - (hh_px[None, :] - hw_px[None, :])
        dxq = np.maximum(xdist, 0.0)[None, :]
        dyq = np.maximum(yd, 0.0)
        d = np.sqrt(dxq * dxq + dyq * dyq) + np.minimum(np.maximum(dxq, yd), 0.0) - hw_px[None, :]
        fill = np.clip(0.5 - d, 0.0, 1.0)

        glow_px = np.maximum(8.0, hw_px * 3.0)[None, :]
        g = np.exp(-np.maximum(d, 0.0) / glow_px) * glow_strength

        buf[:] = background
        buf += glow_w[None, :, :] * g[:, :, None]
        fa = fill[:, :, None]
        buf *= (1.0 - fa)
        buf += col_lut * fa
        np.clip(buf, 0, 255, out=buf)

        _finish(raw, buf, out, h, hh, i, n_frames, decor)
    if out is not None:
        print(f"\r  渲染 {n_frames}/{n_frames} (100%)", file=sys.stderr, flush=True)


STYLES = {
    "bars":  "中心对称柱状（上下镜像）",
    "scale": "从中轴向两边缩放（宽高同时变）",
    "radial": "环形柱状，沿圆周发散",
}



# ============================================================================
#  文字叠加：歌名/作者 + 字幕（SRT / LRC）
# ============================================================================

CJK_FONTS = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]


def load_font(size, path=None):
    from PIL import ImageFont
    for p in ([path] if path else []) + CJK_FONTS:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            continue
    return ImageFont.load_default()


def text_rgba(text, font, fill=(255, 255, 255, 255), stroke=0, stroke_fill=(0, 0, 0, 220)):
    """把一行文字画成 RGBA numpy 数组（带描边，便于压在任何背景上）"""
    from PIL import Image, ImageDraw
    probe = ImageDraw.Draw(Image.new("RGBA", (4, 4)))
    bb = probe.textbbox((0, 0), text, font=font, stroke_width=stroke)
    tw, th = max(bb[2] - bb[0], 1), max(bb[3] - bb[1], 1)
    img = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.text((-bb[0], -bb[1]), text, font=font, fill=fill,
           stroke_width=stroke, stroke_fill=stroke_fill)
    return np.array(img, dtype=np.float32)


def stack_rgba(parts, gap=8):
    """把多行 RGBA 竖直拼起来，左对齐"""
    parts = [p for p in parts if p is not None and p.size]
    if not parts:
        return None
    W = max(p.shape[1] for p in parts)
    H = sum(p.shape[0] for p in parts) + gap * (len(parts) - 1)
    out = np.zeros((H, W, 4), np.float32)
    y = 0
    for p in parts:
        out[y:y + p.shape[0], 0:p.shape[1]] = p
        y += p.shape[0] + gap
    return out


def blend_rgba(raw_u8, ov, x, y):
    """把 RGBA 叠加到 uint8 RGB 整帧上（只动文字那一小块，越界自动裁剪）"""
    if ov is None:
        return
    oh, ow = ov.shape[:2]
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(raw_u8.shape[1], x + ow), min(raw_u8.shape[0], y + oh)
    if x1 <= x0 or y1 <= y0:
        return
    sub = ov[y0 - y:y1 - y, x0 - x:x1 - x]
    a = sub[..., 3:4] / 255.0
    reg = raw_u8[y0:y1, x0:x1].astype(np.float32)
    reg *= (1.0 - a)
    reg += sub[..., :3] * a
    raw_u8[y0:y1, x0:x1] = np.clip(reg, 0, 255).astype(np.uint8)


# ---------------- 字幕解析 ----------------

def _parse_ts(s):
    s = s.strip().replace(",", ".")
    try:
        if ":" in s:
            parts = s.split(":")
            if len(parts) == 3:
                return int(parts[0]) * 3600 + int(parts[1]) * 60 + float(parts[2])
            if len(parts) == 2:
                return int(parts[0]) * 60 + float(parts[1])
        return float(s)
    except Exception:
        return 0.0


def parse_srt(path):
    import re
    raw = open(path, encoding="utf-8", errors="replace").read()
    raw = raw.replace("\r\n", "\n").replace("\r", "\n")
    out = []
    for block in re.split(r"\n\s*\n", raw):
        lines = [l for l in block.split("\n") if l.strip()]
        if not lines:
            continue
        ti = next((i for i, l in enumerate(lines) if "-->" in l), None)
        if ti is None:
            continue
        a, b = lines[ti].split("-->")[:2]
        text = "\n".join(lines[ti + 1:]).strip()
        if text:
            out.append((_parse_ts(a), _parse_ts(b), text))
    return sorted(out, key=lambda x: x[0])


def parse_lrc(path):
    import re
    raw = open(path, encoding="utf-8", errors="replace").read()
    tag = re.compile(r"\[(\d+):(\d+(?:[.:]\d+)?)\]")
    entries = []
    meta = {}
    for line in raw.splitlines():
        m = re.match(r"^\[(ti|ar|al|by):(.*)\]$", line.strip())
        if m:
            meta[m.group(1)] = m.group(2).strip()
            continue
        stamps = list(tag.finditer(line))
        if not stamps:
            continue
        text = line[stamps[-1].end():].strip()
        if not text:
            continue
        for st in stamps:
            t = int(st.group(1)) * 60 + float(st.group(2).replace(":", "."))
            entries.append((t, text))
    entries.sort(key=lambda x: x[0])
    out = []
    for i, (t, txt) in enumerate(entries):
        end = entries[i + 1][0] if i + 1 < len(entries) else t + 5.0
        out.append((t, end, txt))
    return out, meta


# ---------------- 帧装饰器 ----------------

class Decor:
    """负责把标题和字幕画到每帧上"""

    def __init__(self, w, h, hh, fps, title=None, artist=None, subs=None,
                 font_path=None, title_scale=1.0, sub_scale=1.0):
        self.w, self.h, self.hh, self.fps = w, h, hh, fps
        self.title_ov = None
        self.title_xy = (0, 0)
        self.subs = []            # [(f0, f1, rgba, (x,y))]

        # ---- 标题/作者（左上角，柱子够不到的地方）----
        if title or artist:
            sz_t = max(18, int(h * 0.052 * title_scale))
            sz_a = max(12, int(h * 0.030 * title_scale))
            parts = []
            if title:
                parts.append(text_rgba(title, load_font(sz_t, font_path),
                                       (245, 245, 250, 255), stroke=1))
            if artist:
                parts.append(text_rgba(artist, load_font(sz_a, font_path),
                                       (170, 170, 182, 240), stroke=1))
            self.title_ov = stack_rgba(parts, gap=max(4, h // 140))
            if self.title_ov is not None:
                m = int(w * 0.045)
                self.title_xy = (m, m)

        # ---- 字幕（底部居中，提前把每条渲染好）----
        if subs:
            sz_s = max(16, int(h * 0.042 * sub_scale))
            font = load_font(sz_s, font_path)
            for (t0, t1, text) in subs:
                parts = [text_rgba(line, font, (250, 250, 252, 255), stroke=2,
                                   stroke_fill=(0, 0, 0, 235))
                         for line in text.split("\n") if line.strip()]
                ov = stack_rgba(parts, gap=max(2, h // 220))
                if ov is None:
                    continue
                x = (w - ov.shape[1]) // 2
                y = int(h * 0.885) - ov.shape[0] // 2
                f0 = int(round(t0 * fps))
                f1 = max(f0 + 1, int(round(t1 * fps)))
                self.subs.append((f0, f1, ov, (x, y)))
            self.subs.sort(key=lambda z: z[0])

    def apply(self, raw_u8, i):
        """raw_u8 是镜像后的整帧 (h,w,3) uint8；标题和字幕都画在这上面"""
        if self.title_ov is not None:
            blend_rgba(raw_u8, self.title_ov, *self.title_xy)
        if not self.subs:
            return
        for (f0, f1, ov, xy) in self.subs:
            if f0 > i:
                break
            if f0 <= i < f1:
                blend_rgba(raw_u8, ov, *xy)
                break


# ---------------- 主流程 ----------------
def convert(src, dst, w, h, fps, bars, cols, glow_cols, bg_color,
            glow_strength, gap_ratio, crf, gamma=2.2, center_gap=18.0,
            style="bars", decor=None, sr=44100, n_fft=4096):
    t0 = time.time()
    print(f"→ {src.name}  [{style}]")

    samples = decode_audio(src, sr)
    dur = len(samples) / sr
    print(f"  时长 {dur:.1f}s")

    data, n_frames = compute_spectrum(samples, sr, fps, n_fft, bars, gamma=gamma)
    data = smooth_envelope(data, fps)

    cmd = [
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-r", str(fps),
        "-i", "-",
        "-i", str(src),
        "-map", "0:v:0", "-map", "1:a:0",
        "-c:v", "libx264", "-preset", "veryfast", "-crf", str(crf),
        "-pix_fmt", "yuv420p", "-movflags", "+faststart",
        "-c:a", "aac", "-b:a", "192k",
        "-shortest", str(dst),
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    common = dict(glow_strength=glow_strength, out=proc.stdin, decor=decor)
    try:
        if style == "bars":
            render_bars(data, w, h, fps, bars, cols, glow_cols, bg_color,
                        gap_ratio=gap_ratio, center_gap=center_gap, **common)
        elif style == "radial":
            render_radial(data, w, h, fps, bars, cols, glow_cols, bg_color,
                          gap_ratio=gap_ratio, **common)
        elif style == "scale":
            render_scale(data, w, h, fps, bars, cols, glow_cols, bg_color,
                         gap_ratio=gap_ratio, **common)
        else:
            raise RuntimeError(f"未知 style: {style}")
        print("\r" + " " * 40 + "\r", end="", file=sys.stderr, flush=True)
    finally:
        try:
            proc.stdin.close()
        except Exception:
            pass
        rc = proc.wait()
    if rc != 0:
        raise RuntimeError(f"ffmpeg 编码失败（exit {rc}）")

    size = dst.stat().st_size / 1048576 if dst.exists() else 0
    print(f"  ✓ {dst.name}  {size:.1f} MB  用时 {time.time()-t0:.1f}s")



# ============================================================================
#  交互式向导
# ============================================================================

def _hr(ch="─"):
    print(ch * 54)


def _fmt_dur(p):
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", str(p)],
            capture_output=True, text=True, timeout=10).stdout.strip()
        d = int(float(out))
        return f"{d // 60}:{d % 60:02d}"
    except Exception:
        return "?"


def _ask(prompt, default="", allow_empty=True):
    """读一行输入；EOF 或空输入用默认值"""
    hint = f" [{default}]" if default != "" else ""
    try:
        v = input(f"  {prompt}{hint}: ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        v = ""
    if not v:
        v = default
    if not allow_empty and not v:
        return _ask(prompt, default, allow_empty)
    return v


def _pick(prompt, n, default=1):
    """在 1..n 之间选一个"""
    while True:
        v = _ask(prompt, str(default))
        try:
            i = int(v)
            if 1 <= i <= n:
                return i
        except ValueError:
            pass
        print(f"    请输入 1~{n}")


def _yes(prompt, default=True):
    d = "Y" if default else "n"
    v = _ask(prompt + " (y/n)", d).lower()
    return v.startswith("y")


def wizard():
    """一路问下来，返回和 argparse 等价的 Namespace"""
    base = Path(__file__).resolve().parent
    music_dir = base / "music"
    video_dir = base / "video"
    video_dir.mkdir(exist_ok=True)

    print()
    _hr("═")
    print("   music2video · 音频可视化生成")
    _hr("═")

    # ---------- 1. 选音频 ----------
    files = []
    if music_dir.is_dir():
        files = sorted(p for p in music_dir.iterdir() if p.suffix.lower() in AUDIO_EXT)

    src = None
    while src is None:
        if files:
            print(f"\n  music/ 里有 {len(files)} 个音频\n")
            for i, f in enumerate(files, 1):
                print(f"    {i}) {f.name:<36} {_fmt_dur(f)}")
            print(f"    0) 手动输入路径")
            ans = _ask("选择", "1" if len(files) == 1 else "")
            if ans == "0":
                p = Path(os.path.expanduser(_ask("音频路径")))
                if p.is_file():
                    src = p
                else:
                    print(f"    找不到 {p}")
            else:
                try:
                    idx = int(ans)
                    if 1 <= idx <= len(files):
                        src = files[idx - 1]
                except ValueError:
                    pass
        else:
            print(f"\n  music/ 里还没有音频\n")
            p = Path(os.path.expanduser(_ask("音频路径")))
            if p.is_file():
                src = p
            else:
                print(f"    找不到 {p}")

    # ---------- 2. 风格 ----------
    print("\n  可视化风格\n")
    keys = ["bars", "scale", "radial"]
    labels = ["bars    中心对称柱状，上下镜像",
              "scale   从中轴向两边缩放，宽高同时变",
              "radial  环形柱状，沿圆周发散"]
    for i, l in enumerate(labels, 1):
        print(f"    {i}) {l}")
    style = keys[_pick("选择", len(keys), 2) - 1]

    # ---------- 3. 歌名 / 作者 ----------
    lrc_meta = {}
    stem = src.stem
    for ext in (".lrc", ".LRC"):
        cand = src.with_suffix(ext)
        if cand.is_file():
            try:
                _, lrc_meta = parse_lrc(str(cand))
            except Exception:
                pass
            break

    print("\n  文字信息（回车用默认，输入 - 表示不显示）\n")
    title = clean_text(_ask("歌名", lrc_meta.get("ti") or stem))
    artist = clean_text(_ask("作者", lrc_meta.get("ar") or ""))

    # ---------- 4. 字幕 ----------
    subs = None
    found = None
    for ext in (".lrc", ".LRC", ".srt", ".SRT"):
        c = src.with_suffix(ext)
        if c.is_file():
            found = c
            break
    if found:
        if _yes(f"\n  发现字幕 {found.name}，用它吗", True):
            subs = str(found)
    else:
        if _yes("\n  要加字幕吗（.srt / .lrc）", False):
            p = Path(os.path.expanduser(_ask("字幕文件路径")))
            if p.is_file():
                subs = str(p)
            else:
                print(f"    找不到 {p}，跳过")

    # ---------- 5. 配色 ----------
    print("\n  配色\n")
    theme_list = ["orange", "catppuccin", "soft", "ash", "sunset", "fire", "mono", "neon"]
    theme_desc = {
        "orange": "橙（默认）", "catppuccin": "Catppuccin 粉彩渐变",
        "soft": "暗琥珀", "ash": "中性灰", "sunset": "日落粉",
        "fire": "火", "mono": "单色", "neon": "霓虹",
    }
    for i, k in enumerate(theme_list, 1):
        print(f"    {i}) {k:<11} {theme_desc[k]}")
    print(f"    {len(theme_list)+1}) 自定义颜色")
    ci = _pick("选择", len(theme_list) + 1, 1)
    custom_color = None
    if ci == len(theme_list) + 1:
        custom_color = _ask("颜色值（如 #FF7A18）", "#FF7A18")
        theme = "orange"
    else:
        theme = theme_list[ci - 1]

    # ---------- 6. 存在感 ----------
    print("\n  画面存在感\n")
    print("    1) 鲜艳   独立展示 / 封面视频")
    print("    2) 中等   配字、叠其他素材")
    print("    3) 低调   纯背景氛围")
    dim = [0.0, 0.45, 0.75][_pick("选择", 3, 1) - 1]

    # ---------- 汇总确认 ----------
    out = video_dir / (src.stem + ".mp4")
    print()
    _hr()
    print(f"   音频   {src}")
    print(f"   风格   {style}")
    print(f"   歌名   {title or '无'}")
    print(f"   作者   {artist or '无'}")
    print(f"   字幕   {Path(subs).name if subs else '(无)'}")
    print(f"   配色   {custom_color or theme} · 存在感 {['鲜艳','中等','低调'][[0.0,0.45,0.75].index(dim)]}")
    print(f"   输出   {out}")
    _hr()
    print()
    if not _yes("  开始渲染", True):
        print("  已取消")
        return None
    print()

    return argparse.Namespace(
        input=str(src), output=None, out2=str(out),
        style=style, size="1280x720", fps=30, bars=None,
        theme=theme, color=custom_color, color2=None, glow=None,
        saturation=1.0, brightness=1.0, dim=dim,
        glow_strength=0.65, gap=0.85, center_gap=18.0, no_glow=False,
        contrast=2.2, title=title, artist=artist,
        subs=subs, font=None, title_scale=1.0, sub_scale=1.0,
        no_title=(title is None and artist is None), crf=20,
    )


def main():
    # 不带任何参数（或 -i）就进入交互向导
    if len(sys.argv) == 1 or sys.argv[1] in ("-i", "--interactive"):
        while True:
            ns = wizard()
            if ns is None:
                return
            _run(ns)
            print()
            try:
                if not input("  再来一个？(y/n) [n]: ").strip().lower().startswith("y"):
                    break
            except (EOFError, KeyboardInterrupt):
                break
        return

    ap = argparse.ArgumentParser(
        description="音频 → 频谱可视化视频（直接运行不带参数则进入交互向导）",
        epilog="例子： python3 music2video.py music/xx.mp3 video/xx.mp4 --style scale")
    ap.add_argument("input", help="音频文件或目录")
    ap.add_argument("output", nargs="?", help="输出文件或目录")
    ap.add_argument("-o", "--output", dest="out2", help="输出文件或目录")
    ap.add_argument("--style", default="bars", choices=sorted(STYLES),
                    help="可视化风格：" + " / ".join(f"{k}={v}" for k, v in STYLES.items()))
    ap.add_argument("--size", default="1280x720")
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--bars", type=int, default=None,
                    help="柱子数量（不给则按风格选默认：bars=36 scale=16 radial=40）")
    ap.add_argument("--theme", default=None, choices=sorted(PRESETS))
    ap.add_argument("--color", default=None, help="柱子主色，如 #FF7A18")
    ap.add_argument("--color2", default=None, help="柱子渐变副色（柱尖）")
    ap.add_argument("--glow", default=None, help="光晕颜色")
    ap.add_argument("--saturation", type=float, default=1.0,
                    help="全局饱和度倍率，<1 更灰更低调，默认 1.0")
    ap.add_argument("--brightness", type=float, default=1.0,
                    help="全局亮度倍率，<1 更暗，默认 1.0")
    ap.add_argument("--dim", type=float, default=0.0,
                    help="整体压暗程度 0~1，越大越像背景（同时削光晕），默认 0")
    ap.add_argument("--glow-strength", type=float, default=0.65)
    ap.add_argument("--gap", type=float, default=0.85, help="柱间距/柱宽，默认 0.85")
    ap.add_argument("--center-gap", type=float, default=18.0,
                    help="中轴处上下两半之间留的空隙（像素），默认 8")
    ap.add_argument("--no-glow", action="store_true")
    ap.add_argument("--contrast", type=float, default=2.2, help="动态对比度 gamma，越大起伏越明显，默认 2.2")
    ap.add_argument("--title", default=None, help="歌名（默认取文件名）")
    ap.add_argument("--artist", default=None, help="作者 / 歌手")
    ap.add_argument("--subs", default=None, help="字幕文件：.srt 或 .lrc")
    ap.add_argument("--font", default=None, help="自定义字体文件（ttf/ttc）")
    ap.add_argument("--title-scale", type=float, default=1.0, help="标题字号倍率")
    ap.add_argument("--sub-scale", type=float, default=1.0, help="字幕字号倍率")
    ap.add_argument("--no-title", action="store_true", help="不显示歌名/作者")
    ap.add_argument("--crf", type=int, default=20)
    _run(ap.parse_args())


def _run(args):
    try:
        w, h = (int(x) for x in args.size.lower().split("x"))
    except Exception:
        sys.exit("--size 格式应为 1280x720")
    if w % 2 or h % 2:
        sys.exit("--size 的宽高必须是偶数（yuv420p 要求）")

    preset = PRESETS[args.theme or DEFAULT_PRESET]
    sat, val = args.saturation, args.brightness
    if args.dim > 0:
        # --dim：一条命令同时压低饱和度和亮度，并按比例削光晕
        d = min(max(args.dim, 0.0), 1.0)
        sat *= (1.0 - 0.70 * d)
        val *= (1.0 - 0.70 * d)
    n_bars = args.bars if args.bars else DEFAULT_BARS.get(args.style, 36)
    # 每根柱子的基色（支持多色标主题）
    cols = resolve_cols(preset, n_bars, args.color, args.color2, sat, val)
    glow1 = adjust_color(parse_color(args.glow, preset["glow"]), sat, val)
    # 多色标主题让光晕跟各自柱子的颜色走，避免右边是粉柱子却配紫色光晕
    if preset.get("stops") and args.glow is None:
        glow_cols = cols * 0.85
    else:
        glow_cols = np.tile(glow1, (n_bars, 1))
    bg_color = parse_color(preset["bg"])
    glow_cols = glow_cols * 0.0 if args.no_glow else glow_cols
    glow_strength = 0.0 if args.no_glow else args.glow_strength * (1.0 - 0.55 * min(max(args.dim, 0.0), 1.0))

    src = Path(os.path.expanduser(args.input))
    dst = Path(os.path.expanduser(args.out2 or args.output or ""))

    def build_decor(f, subs_path):
        subs = None
        meta = {}
        if subs_path:
            if str(subs_path).lower().endswith(".lrc"):
                subs, meta = parse_lrc(str(subs_path))
            else:
                subs = parse_srt(str(subs_path))
        # 没输入就不显示（不拿文件名顶替）；LRC 的 [ti:]/[ar:] 算输入
        title = None if args.no_title else (clean_text(args.title) or clean_text(meta.get("ti")))
        artist = None if args.no_title else (clean_text(args.artist) or clean_text(meta.get("ar")))
        if not (title or artist or subs):
            return None
        return Decor(w, h, h // 2, args.fps,
                     title=title, artist=artist, subs=subs, font_path=args.font,
                     title_scale=args.title_scale, sub_scale=args.sub_scale)

    def run_one(f, target):
        decor = build_decor(f, args.subs)
        convert(f, target, w, h, args.fps, n_bars, cols, glow_cols, bg_color,
                glow_strength, args.gap, args.crf, gamma=args.contrast,
                center_gap=args.center_gap, style=args.style, decor=decor)

    if src.is_dir():
        files = sorted(p for p in src.iterdir() if p.suffix.lower() in AUDIO_EXT)
        if not files:
            sys.exit(f"{src} 里没有音频文件")
        outdir = dst if str(dst) else src.parent / "video"
        outdir.mkdir(parents=True, exist_ok=True)
        print(f"批量处理 {len(files)} 个文件 → {outdir}")
        ok = fail = 0
        for f in files:
            try:
                run_one(f, outdir / (f.stem + ".mp4"))
                ok += 1
            except Exception as e:
                print(f"  ✗ {f.name}: {e}", file=sys.stderr)
                fail += 1
        print(f"\n完成：成功 {ok}，失败 {fail}")
    else:
        if not src.is_file():
            sys.exit(f"找不到文件：{src}")
        if str(dst) == "" or dst.is_dir():
            outdir = dst if str(dst) else src.parent
            outdir.mkdir(parents=True, exist_ok=True)
            target = outdir / (src.stem + ".mp4")
        else:
            dst.parent.mkdir(parents=True, exist_ok=True)
            target = dst
        run_one(src, target)


if __name__ == "__main__":
    main()
