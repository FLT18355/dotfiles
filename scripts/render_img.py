#!/usr/bin/env python3
import os
import sys
import base64
import io
import subprocess
import shutil
import fcntl
import termios
import struct
import tty
from PIL import Image

def get_terminal_size():
    """获取终端的行列数以及像素尺寸"""
    try:
        cols, rows = os.get_terminal_size()
    except OSError:
        cols, rows = 80, 24

    width_px, height_px = 0, 0
    try:
        data = fcntl.ioctl(sys.stdout.fileno(), termios.TIOCGWINSZ, b'\0'*8)
        rows, cols, width_px, height_px = struct.unpack('HHHH', data)
    except Exception:
        pass

    return cols, rows, width_px, height_px

def render_kitty(image: Image.Image):
    """使用 Kitty 协议渲染图片"""
    buffered = io.BytesIO()
    image.save(buffered, format="PNG")
    img_b64 = base64.standard_b64encode(buffered.getvalue()).decode("utf-8")

    chunk_size = 4096
    chunks = [img_b64[i:i+chunk_size] for i in range(0, len(img_b64), chunk_size)]
    
    output = []
    for i, chunk in enumerate(chunks):
        m = 1 if i < len(chunks) - 1 else 0
        if i == 0:
            # q=2 (静默), a=T (传输并显示), f=100 (PNG)
            output.append(f"\x1b_Gf=100,a=T,q=2,m={m};{chunk}\x1b\\")
        else:
            output.append(f"\x1b_Gm={m};{chunk}\x1b\\")
            
    sys.stdout.write("".join(output))
    sys.stdout.flush()

def render_sixel(img_path):
    """调用 chafa 使用 Sixel 协议渲染图片"""
    if not shutil.which("chafa"):
        return False
    
    # 获取终端大小，让 chafa 自适应
    cols, rows, _, _ = get_terminal_size()
    # chafa 会自己处理图片缩放，我们只需要给它全屏的尺寸
    subprocess.run(["chafa", "--format", "sixel", "--align", "center", "--size", f"{cols}x{rows}", img_path])
    return True

def main():
    if len(sys.argv) < 2:
        print("Usage: python full_screen_preview.py <image_path> [kitty|sixel]")
        sys.exit(1)

    img_path = sys.argv[1]
    protocol = sys.argv[2].lower() if len(sys.argv) > 2 else "kitty"

    if not os.path.exists(img_path):
        print(f"File not found: {img_path}")
        sys.exit(1)

    try:
        img = Image.open(img_path)
    except Exception as e:
        print(f"Failed to open image: {e}")
        sys.exit(1)

    # 保存终端原始设置
    old_settings = termios.tcgetattr(sys.stdin.fileno())

    try:
        # 进入备用屏幕 (\x1b[?1049h), 隐藏光标 (\x1b[?25l), 设置 Raw 模式
        sys.stdout.write("\x1b[?1049h\x1b[?25l\x1b[2J\x1b[H")
        sys.stdout.flush()
        tty.setraw(sys.stdin.fileno())

        cols, rows, width_px, height_px = get_terminal_size()

        # 估算字符宽高比（默认 1:2）
        cell_width = width_px / cols if width_px else 10
        cell_height = height_px / rows if height_px else 20

        # 计算全屏可用区域 (留 2% 的边距防溢出)
        max_w = int(width_px * 0.98) if width_px else int(cols * cell_width * 0.98)
        max_h = int(height_px * 0.98) if height_px else int(rows * cell_height * 0.98)

        # 等比缩放
        img.thumbnail((max_w, max_h), Image.Resampling.LANCZOS)

        img_cols = int(img.width / cell_width)
        img_rows = int(img.height / cell_height)

        # 计算居中位置
        pad_rows = max(0, (rows - img_rows) // 2)
        pad_cols = max(0, (cols - img_cols) // 2)

        # 将光标移动到居中位置
        if pad_rows > 0:
            sys.stdout.write("\n" * pad_rows)
        if pad_cols > 0:
            sys.stdout.write(" " * pad_cols)
        sys.stdout.flush()

        # 渲染图片
        if protocol == "kitty":
            render_kitty(img)
        elif protocol == "sixel":
            if not render_sixel(img_path):
                raise RuntimeError("Sixel requires 'chafa' to be installed. (sudo pacman -S chafa)")
        else:
            raise ValueError(f"Unknown protocol: {protocol}")

        # 进入事件循环，等待按 'q' 或 'Q' 或 Ctrl+C
        while True:
            char = sys.stdin.read(1)
            if char in ('q', 'Q') or char == '\x03': # \x03 是 Ctrl+C
                break

    except Exception as e:
        # 退出前清理屏幕并打印错误
        sys.stdout.write("\x1b[?1049l\x1b[?25h")
        sys.stdout.flush()
        print(f"\nError: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        # 恢复终端状态：退出备用屏幕 (\x1b[?1049l)，显示光标 (\x1b[?25h)，恢复 termios
        tty.setcbreak(sys.stdin.fileno())
        sys.stdout.write("\x1b[?1049l\x1b[?25h")
        sys.stdout.flush()
        termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, old_settings)

if __name__ == "__main__":
    main()