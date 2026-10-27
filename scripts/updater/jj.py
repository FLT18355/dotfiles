#!/usr/bin/env python3
import sys
import urllib.request
import json
import hashlib
import tarfile
import tempfile
import shutil
from pathlib import Path

try:
    from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn, BarColumn, TextColumn
    from rich.console import Console
except ImportError:
    print("请先安装 rich 库: pip install rich 或 uv pip install rich")
    sys.exit(1)

console = Console()

REPO = "jj-vcs/jj"
PROXY = "https://v4.gh-proxy.org/"
TARGET_ARCH = "aarch64-unknown-linux-musl"
INSTALL_DIR = Path.home() / ".local" / "bin"
TARGET_FILE = INSTALL_DIR / "jj"

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
    asset_digest = None

    # 2. 解析下载链接 (寻找包含 aarch64-unknown-linux-musl.tar.gz 的包)
    for asset in data.get("assets", []):
        if TARGET_ARCH in asset.get("name", "") and asset.get("name", "").endswith(".tar.gz"):
            download_url = asset.get("browser_download_url")
            asset_digest = asset.get("digest")  # 形如 sha256:...
            break

    if not download_url:
        console.print(f"[red]❌ 未找到适用于 {TARGET_ARCH} 的下载包。[/red]")
        sys.exit(1)

    accel_url = f"{PROXY}{download_url}"
    console.print(f"[green]✅ 找到最新版本: {tag_name}[/green]")
    console.print(f"[blue]🔗 下载地址: {accel_url}[/blue]")

    # 3. 确保安装目录存在
    INSTALL_DIR.mkdir(parents=True, exist_ok=True)

    # 4. 带进度条下载压缩包到临时目录
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
                task = progress.add_task("下载中...", total=total_size, filename="jj.tar.gz")

                # 创建临时文件
                with tempfile.NamedTemporaryFile(delete=False, suffix=".tar.gz") as tmp_file:
                    tmp_path = Path(tmp_file.name)
                    while True:
                        chunk = response.read(8192)
                        if not chunk:
                            break
                        tmp_file.write(chunk)
                        progress.update(task, advance=len(chunk))

        # 5. 校验 sha256，防止中转站或链路被篡改
        console.print("[yellow]🔐 正在校验 sha256...[/yellow]")
        if not asset_digest:
            raise Exception("该 Release 未提供 digest，无法校验，已中止")
        h = hashlib.sha256()
        with open(tmp_path, "rb") as f:
            for chunk in iter(lambda: f.read(1 << 20), b""):
                h.update(chunk)
        actual = "sha256:" + h.hexdigest()
        if actual != asset_digest:
            raise Exception(f"sha256 校验失败: 期望 {asset_digest}, 实际 {actual}")

        # 6. 解压并提取 jj 二进制
        console.print("[yellow]📦 正在解压并提取文件...[/yellow]")
        tmp_target = TARGET_FILE.with_name(TARGET_FILE.name + ".tmp")
        with tarfile.open(tmp_path, "r:gz") as tar:
            # 在压缩包里寻找名为 jj 的二进制文件
            jj_member = None
            for member in tar.getmembers():
                if member.isfile() and (member.name.endswith("/jj") or member.name == "jj"):
                    jj_member = member
                    break

            if not jj_member:
                raise Exception("压缩包中未找到 jj 可执行文件")

            # 解压到临时文件，成功后再原子替换，避免断网留下坏二进制
            with tar.extractfile(jj_member) as source:
                with open(tmp_target, "wb") as target:
                    shutil.copyfileobj(source, target)

        # 7. 赋予执行权限并原子替换
        tmp_target.chmod(0o755)
        tmp_target.replace(TARGET_FILE)
        console.print(f"[bold green]🎉 更新成功! 已安装到: {TARGET_FILE}[/bold green]")

    except Exception as e:
        console.print(f"[red]❌ 操作失败: {e}[/red]")
        sys.exit(1)
    finally:
        # 清理临时文件
        if 'tmp_path' in locals() and tmp_path.exists():
            tmp_path.unlink()
        if 'tmp_target' in locals() and tmp_target.exists():
            tmp_target.unlink()

if __name__ == "__main__":
    main()