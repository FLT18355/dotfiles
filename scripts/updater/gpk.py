#!/usr/bin/env python3
import sys
import urllib.request
import json
import hashlib
import tempfile
import shutil
from pathlib import Path

try:
    from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn, BarColumn, TextColumn
    from rich.console import Console
except ImportError:
    print("󰅚 请先安装 rich 库: pip install rich")
    sys.exit(1)

console = Console()

REPO = "neur0map/glazepkg"
PROXY = "https://v4.gh-proxy.org/"  # 如果你不需要代理，可以将其置空 ""
TARGET_ARCH = "gpk-linux-arm64"
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_FILE = INSTALL_DIR / "gpk"

def main():
    console.print(f"[cyan]󰍉 正在获取 {REPO} 的最新版本信息...[/cyan]")

    # 1. 获取最新 Release 信息
    api_url = f"{PROXY}https://api.github.com/repos/{REPO}/releases/latest"
    try:
        req = urllib.request.Request(api_url, headers={"User-Agent": "Python-Updater"})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
    except Exception as e:
        console.print(f"[red]󰅚 获取版本信息失败: {e}[/red]")
        sys.exit(1)

    tag_name = data.get("tag_name", "Unknown")
    download_url = None
    checksum_url = None

    # 2. 解析下载链接和校验文件链接
    for asset in data.get("assets", []):
        name = asset.get("name", "")
        if name == TARGET_ARCH:
            download_url = asset.get("browser_download_url")
        elif name == "checksums.txt":
            checksum_url = asset.get("browser_download_url")

    if not download_url:
        console.print(f"[red]󰅚 未找到适用于 {TARGET_ARCH} 的下载包。[/red]")
        sys.exit(1)

    accel_url = f"{PROXY}{download_url}" if PROXY else download_url
    console.print(f"[green]󰄬 找到最新版本: {tag_name}[/green]")
    console.print(f"[blue]󰁔 下载地址: {accel_url}[/blue]")

    # 3. 确保安装目录存在
    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    # 4. 下载二进制文件
    console.print("[yellow]󰇚 开始下载 gpk...[/yellow]")
    try:
        req = urllib.request.Request(accel_url, headers={"User-Agent": "Python-Updater"})
        with urllib.request.urlopen(req) as response:
            total_size = int(response.info().get("Content-Length", 0))

            with Progress(
                TextColumn("[bold blue]{task.fields[filename]}", justify="right"),
                BarColumn(),
                DownloadColumn(),
                TransferSpeedColumn(),
                TimeRemainingColumn(),
                console=console
            ) as progress:
                task = progress.add_task("下载中...", total=total_size, filename="gpk")

                with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
                    tmp_path = Path(tmp_file.name)
                    while True:
                        chunk = response.read(8192)
                        if not chunk:
                            break
                        tmp_file.write(chunk)
                        progress.update(task, advance=len(chunk))

        # 5. 校验 SHA256 (如果有 checksums.txt)
        if checksum_url:
            console.print("[yellow]󰒃 正在校验 SHA256...[/yellow]")
            checksum_accel_url = f"{PROXY}{checksum_url}" if PROXY else checksum_url
            req_checksum = urllib.request.Request(checksum_accel_url, headers={"User-Agent": "Python-Updater"})
            with urllib.request.urlopen(req_checksum) as resp:
                checksums = resp.read().decode('utf-8')
                
            expected_hash = None
            for line in checksums.splitlines():
                if TARGET_ARCH in line:
                    expected_hash = line.split()[0]
                    break
            
            if expected_hash:
                h = hashlib.sha256()
                with open(tmp_path, "rb") as f:
                    for chunk in iter(lambda: f.read(1 << 20), b""):
                        h.update(chunk)
                actual_hash = h.hexdigest()
                
                if actual_hash != expected_hash:
                    raise Exception(f"SHA256 校验失败: 期望 {expected_hash}, 实际 {actual_hash}")
                console.print("[green]󰄬 SHA256 校验通过[/green]")
            else:
                console.print(f"[yellow]󰀦 未在 checksums.txt 中找到 {TARGET_ARCH} 的校验值，跳过校验。[/yellow]")

        # 6. 赋予执行权限并原子替换
        tmp_path.chmod(0o755)
        tmp_path.replace(TARGET_FILE)
        console.print(f"[bold green]󰄬 安装成功! 已安装到: {TARGET_FILE}[/bold green]")
        console.print("[cyan]󰁔 提示: 确保 ~/.local/bin 在你的 PATH 中，然后直接运行 `gpk` 即可。[/cyan]")

    except Exception as e:
        console.print(f"[red]󰅚 操作失败: {e}[/red]")
        sys.exit(1)
    finally:
        if 'tmp_path' in locals() and tmp_path.exists():
            tmp_path.unlink()

if __name__ == "__main__":
    main()