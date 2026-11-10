#!/usr/bin/env python3
import sys
import os
import urllib.request
import hashlib
import tempfile
import tarfile
from pathlib import Path

try:
    from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn, BarColumn, TextColumn
    from rich.console import Console
except ImportError:
    print("󰅚 请先安装 rich: pip install rich")
    sys.exit(1)

console = Console()

REPO = "Gaurav-Gosain/tuios"
PROXY = "https://v4.gh-proxy.org/"
TARGET_ARCH = "Linux_arm64"
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_BIN = INSTALL_DIR / "tuios"
TIMEOUT = 20


def url_with_proxy(raw: str) -> str:
    if not PROXY:
        return raw
    base = PROXY.rstrip("/")
    return f"{base}/{raw}"


def get_url(url: str):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "tuios-installer"}
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        return resp.read()


def download_file(url: str, dest: Path):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "tuios-installer"}
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        total_size = int(resp.info().get("Content-Length", 0))
        with Progress(
            TextColumn("[bold blue]{task.fields[filename]}", justify="right"),
            BarColumn(),
            DownloadColumn(),
            TransferSpeedColumn(),
            TimeRemainingColumn(),
            console=console,
        ) as progress:
            task = progress.add_task("下载中...", total=total_size, filename="tuios")
            with dest.open("wb") as f:
                while chunk := resp.read(8192):
                    f.write(chunk)
                    progress.update(task, advance=len(chunk))


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def main():
    console.print(f"[cyan]󰍉 获取 {REPO} 最新 release …[/cyan]")
    api_url = url_with_proxy(f"https://api.github.com/repos/{REPO}/releases/latest")
    try:
        raw = get_url(api_url)
        import json
        meta = json.loads(raw.decode("utf-8"))
    except Exception as e:
        console.print(f"[red]󰅚 获取 release 失败: {e}[/red]")
        sys.exit(1)

    tag = meta.get("tag_name", "unknown")
    tar_url: str | None = None
    checksum_url: str | None = None

    for asset in meta.get("assets", []):
        name = asset.get("name", "")
        if f"_{TARGET_ARCH}.tar.gz" in name:
            tar_url = asset["browser_download_url"]
        elif name == "checksums.txt":
            checksum_url = asset["browser_download_url"]

    if not tar_url:
        console.print(f"[red]󰅚 找不到包含 _{TARGET_ARCH}.tar.gz 的压缩包[/red]")
        sys.exit(1)

    accel_tar = url_with_proxy(tar_url)
    console.print(f"[green]󰄬 最新版本: {tag}[/green]")
    console.print(f"[blue]󰁔 下载: {accel_tar}[/blue]")

    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False) as tmp_tar:
        tmp_tar_path = Path(tmp_tar.name)
        try:
            download_file(accel_tar, tmp_tar_path)

            expected_hash: str | None = None
            if checksum_url:
                console.print("[yellow]󰒃 校验 SHA256 …[/yellow]")
                try:
                    cs_raw = get_url(url_with_proxy(checksum_url)).decode("utf-8")
                    tar_name = tar_url.split("/")[-1]
                    for line in cs_raw.splitlines():
                        parts = line.split()
                        if len(parts) >= 2 and parts[1] == tar_name:
                            expected_hash = parts[0]
                            break
                except Exception as e:
                    console.print(f"[red]󰅚 无法拉取 checksums.txt: {e}[/red]")

            # 拿不到校验值就中止（以前是警告后继续安装，等于校验可被绕过）
            if not expected_hash:
                if os.environ.get("ALLOW_UNVERIFIED") == "1":
                    console.print("[yellow]󰀦 未取得 SHA256，按 ALLOW_UNVERIFIED=1 继续安装[/yellow]")
                else:
                    raise Exception(
                        "没有可用的 SHA256 校验值，已中止安装"
                        "（确认无风险可设 ALLOW_UNVERIFIED=1）"
                    )
            else:
                actual = sha256_file(tmp_tar_path)
                if actual != expected_hash:
                    raise Exception(f"SHA256 不匹配！\n期望: {expected_hash}\n实际: {actual}")
                console.print("[green]󰄬 SHA256 校验通过[/green]")

            with tempfile.TemporaryDirectory() as extract_dir:
                extract_path = Path(extract_dir)
                with tarfile.open(tmp_tar_path, "r:gz") as tf:
                    if sys.version_info >= (3, 12):
                        tf.extractall(extract_path, filter="data")
                    else:
                        tf.extractall(extract_path)

                bin_candidate = extract_path / "tuios"
                if not bin_candidate.exists():
                    console.print("[red]󰅚 在压缩包里找不到 tuios 二进制[/red]")
                    sys.exit(1)

                bin_candidate.chmod(0o755)
                bin_candidate.replace(TARGET_BIN)

            console.print(f"[bold green]󰄬 安装完成 → {TARGET_BIN}[/bold green]")
            console.print("[cyan]󰁔 确认 ~/.local/bin 在 PATH，然后运行 tuios[/cyan]")

        finally:
            if tmp_tar_path.exists():
                tmp_tar_path.unlink()


if __name__ == "__main__":
    main()
