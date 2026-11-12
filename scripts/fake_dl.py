#!/usr/bin/env python3
import argparse
import os
import requests
from rich.console import Console
from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn, BarColumn, TextColumn

console = Console()

def download_file(url, output_path=None, referer=None):
    # 核心伪装：伪造一个极其逼真的现代 Chrome 浏览器请求头
    # 很多服务器（如 Pixiv、B站、知乎）就是靠这几个头来拦截爬虫的
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "none",
    }
    
    # 如果有防盗链，必须伪造 Referer
    if referer:
        headers["Referer"] = referer

    # 如果没指定文件名，从 URL 里提取
    if not output_path:
        output_path = url.split("/")[-1].split("?")[0]
        if not output_path:
            output_path = "downloaded_file.bin"

    console.print(f"[cyan]󰇚 正在伪装请求并连接: {url}[/cyan]")
    if referer:
        console.print(f"[dim]  └─ 伪装来源 (Referer): {referer}[/dim]")

    try:
        # stream=True 是必须的，防止大文件直接撑爆内存
        with requests.get(url, headers=headers, stream=True, timeout=15) as response:
            response.raise_for_status() # 检查是否 404 或 403
            
            total_size = int(response.headers.get('content-length', 0))
            
            # 初始化 rich 进度条
            with Progress(
                TextColumn("[bold blue]{task.fields[filename]}", justify="right"),
                BarColumn(),
                DownloadColumn(),
                TransferSpeedColumn(),
                TimeRemainingColumn(),
                console=console
            ) as progress:
                task = progress.add_task("下载中", total=total_size, filename=os.path.basename(output_path))
                
                # 分块写入文件
                with open(output_path, "wb") as f:
                    for chunk in response.iter_content(chunk_size=65536): # 每次写 64KB
                        if chunk:
                            f.write(chunk)
                            progress.update(task, advance=len(chunk))
                            
        console.print(f"[bold green]󰄬 下载完成: {output_path}[/bold green]")
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 403:
            console.print(f"[bold red]󰅚 拦截失败！服务器返回 403 Forbidden。可能还需要伪装 Cookie 或 Token。[/bold red]")
        else:
            console.print(f"[bold red]󰅚 请求失败: {e}[/bold red]")
    except Exception as e:
        console.print(f"[bold red]󰅚 发生错误: {e}[/bold red]")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Python 伪装下载器 (使用 rich 渲染进度条)")
    parser.add_argument("url", help="要下载的文件直链")
    parser.add_argument("-o", "--output", help="保存的文件名 (默认自动提取)")
    parser.add_argument("-r", "--referer", help="伪装来源地址 (绕过防盗链，比如填 https://www.pixiv.net/)")
    
    args = parser.parse_args()
    
    download_file(args.url, args.output, args.referer)