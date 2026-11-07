#!/usr/bin/env python3
import sys
import urllib.request
import json
import tarfile
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

REPO = "jdx/mise"
PROXY = "https://v4.gh-proxy.org/"
# 根据你的截图，寻找这个特定的后缀 (GNU 版)
TARGET_SUFFIX = "linux-arm64.tar.xz" 
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_FILE = INSTALL_DIR / "mise"

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

    # 2. 解析下载链接：精准匹配不含 musl 的 linux-arm64.tar.xz
    for asset in data.get("assets", []):
        name = asset.get("name", "")
        if name.endswith(TARGET_SUFFIX) and "musl" not in name:
            download_url = asset.get("browser_download_url")
            break

    if not download_url:
        console.print(f"[red]󰅚 未找到适用于 {TARGET_SUFFIX} 的下载包。[/red]")
        sys.exit(1)

    accel_url = f"{PROXY}{download_url}"
    console.print(f"[green]󰄬 找到最新版本: {tag_name}[/green]")
    console.print(f"[blue]󰁔 下载地址: {accel_url}[/blue]")

    # 3. 确保安装目录存在
    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    # 4. 带进度条下载
    console.print("[yellow]󰇚 开始下载...[/yellow]")
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
                task = progress.add_task("下载中...", total=total_size, filename="mise.tar.xz")

                with tempfile.NamedTemporaryFile(delete=False, suffix=".tar.xz") as tmp_file:
                    tmp_path = Path(tmp_file.name)
                    while True:
                        chunk = response.read(8192)
                        if not chunk:
                            break
                        tmp_file.write(chunk)
                        progress.update(task, advance=len(chunk))

        # 5. 解压 (注意后缀变成了 .tar.xz，模式用 r:xz)
        console.print("[yellow]󰃢 正在解压并提取文件...[/yellow]")
        tmp_target = TARGET_FILE.with_name(TARGET_FILE.name + ".tmp")
        with tarfile.open(tmp_path, "r:xz") as tar:
            mise_member = None
            for member in tar.getmembers():
                # mise 的包解压出来就是一个叫 mise 的二进制文件
                if member.isfile() and (member.name.endswith("/mise") or member.name == "mise"):
                    mise_member = member
                    break

            if not mise_member:
                raise Exception("压缩包中未找到 mise 可执行文件")

            with tar.extractfile(mise_member) as source:
                with open(tmp_target, "wb") as target:
                    shutil.copyfileobj(source, target)

        # 6. 赋予执行权限并原子替换
        tmp_target.chmod(0o755)
        tmp_target.replace(TARGET_FILE)
        console.print(f"[bold green]󰄬 更新成功! 已安装到: {TARGET_FILE}[/bold green]")

    except Exception as e:
        console.print(f"[red]󰅚 操作失败: {e}[/red]")
        sys.exit(1)
    finally:
        if 'tmp_path' in locals() and tmp_path.exists():
            tmp_path.unlink()
        if 'tmp_target' in locals() and tmp_target.exists():
            tmp_target.unlink()

if __name__ == "__main__":
    main()