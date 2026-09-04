function sa
    echo 系统优化中 | lolcat
    echo "正在清理缓存..." | lolcat
    sudo pacman -Scc --noconfirm
    echo 成功 | lolcat
    echo "正在打印当前家目录..." | lolcat
    echo $HOME | lolcat
    echo "正在运行主程序..." | lolcat
    sudo pacman -Syu --noconfirm
    echo "是否要运行 pip-review 更新 Python 包？" | lolcat
    echo "1) 继续运行" | lolcat
    echo "2) 跳过" | lolcat
    echo -n "❯ 选择 (1/2): " | lolcat
    read choice
    switch $choice
        case 1 继续 y Y
            echo "正在运行 pip-review..." | lolcat
            prw
        case 2 跳过 n N ""
            echo "跳过 pip-review" | lolcat
        case '*'
            echo "无效输入，默认跳过" | lolcat
    end
    echo "运行完毕,再一次清理pip cache" | lolcat
    pip cache purge
    echo "所有执行程序都运行完毕,感谢您的使用,Bye" | lolcat
end
