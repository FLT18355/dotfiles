#!/usr/bin/env python3
import os
import sys
import urllib.request
import json
from pathlib import Path

try:
    from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn, BarColumn, TextColumn
    from rich.console import Console
except ImportError:
    print("请先安装 rich 库: pip install rich 或 uv pip install rich")
    sys.exit(1)

console = Console()

REPO = "herdrdev/herdr"
PROXY = "https://v4.gh-proxy.org/"
TARGET_ARCH = "linux-aarch64"
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_FILE = INSTALL_DIR / "herdr"

def main():
    console.print(f"[cyan]🔍 正在获取 {REPO} 的最新版本信息...[/cyan]")
    
    # 1. 获取最新 Release 信息
    api_url = f"{PROXY}https://api.github.com/repos/{REPO}/releases/latest"
    try:
        req = urllib.request.Request(api_url, headers={"User-Agent": "Python-Updater"})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
    except Exception as e:
        console.print(f"[red]❌ 获取版本信息失败: {e}[/red]")
        sys.exit(1)

    tag_name = data.get("tag_name", "Unknown")
    download_url = None
    
    # 2. 解析下载链接
    for asset in data.get("assets", []):
        if TARGET_ARCH in asset.get("name", ""):
            download_url = asset.get("browser_download_url")
            break

    if not download_url:
        console.print(f"[red]❌ 未找到适用于 {TARGET_ARCH} 的下载包。[/red]")
        sys.exit(1)

    accel_url = f"{PROXY}{download_url}"
    console.print(f"[green]✅ 找到最新版本: {tag_name}[/green]")
    console.print(f"[blue]🔗 下载地址: {accel_url}[/blue]")

    # 3. 确保目录存在
    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    # 4. 带进度条下载
    console.print("[yellow]⬇️ 开始下载...[/yellow]")
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
                task = progress.add_task("下载中...", total=total_size, filename="herdr")
                
                with open(TARGET_FILE, "wb") as f:
                    while True:
                        chunk = response.read(8192)
                        if not chunk:
                            break
                        f.write(chunk)
                        progress.update(task, advance=len(chunk))
        
        # 5. 赋予执行权限
        TARGET_FILE.chmod(0o755)
        console.print(f"[bold green]🎉 更新成功! 已安装到: {TARGET_FILE}[/bold green]")
        
    except Exception as e:
        console.print(f"[red]❌ 下载失败: {e}[/red]")
        if TARGET_FILE.exists():
            TARGET_FILE.unlink()  # 清理破损文件
        sys.exit(1)

if __name__ == "__main__":
    main()