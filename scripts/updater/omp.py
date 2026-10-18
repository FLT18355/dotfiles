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

REPO = "can1357/oh-my-pi"
PROXY = "https://v4.gh-proxy.org/"
# 注意这里去掉了 musl
TARGET_ASSET = "omp-linux-arm64" 
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_FILE = INSTALL_DIR / "omp"

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
    
    # 2. 精确解析下载链接
    for asset in data.get("assets", []):
        if asset.get("name") == TARGET_ASSET:
            download_url = asset.get("browser_download_url")
            break

    if not download_url:
        console.print(f"[red]❌ 未找到适用于 {TARGET_ASSET} 的下载包。[/red]")
        sys.exit(1)

    accel_url = f"{PROXY}{download_url}"
    console.print(f"[green]✅ 找到最新版本: {tag_name}[/green]")
    console.print(f"[blue]🔗 下载地址: {accel_url}[/blue]")

    # 3. 确保安装目录存在
    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    # 4. 带进度条下载
    console.print("[yellow]⬇️ 开始下载 (文件较大，约 206MB，请耐心等待)...[/yellow]")
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
                task = progress.add_task("下载中...", total=total_size, filename="omp")
                
                # 下载到临时文件，防止断网破坏旧文件
                tmp_file_path = TARGET_FILE.with_suffix(".tmp")
                with open(tmp_file_path, "wb") as f:
                    while True:
                        chunk = response.read(1024 * 64) # 64KB 分块加速
                        if not chunk:
                            break
                        f.write(chunk)
                        progress.update(task, advance=len(chunk))
        
        # 5. 赋予执行权限，并原子替换
        tmp_file_path.chmod(0o755)
        tmp_file_path.replace(TARGET_FILE)
        
        console.print(f"[bold green]🎉 更新成功! 已安装到: {TARGET_FILE}[/bold green]")
        
    except Exception as e:
        console.print(f"[red]❌ 下载失败: {e}[/red]")
        if 'tmp_file_path' in locals() and tmp_file_path.exists():
            tmp_file_path.unlink()
        sys.exit(1)

if __name__ == "__main__":
    main()