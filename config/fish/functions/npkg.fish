function npkg
    if contains -- -h $argv; or contains -- --help $argv
        /usr/bin/pacman $argv | sed s/pacman/npkg/g
    else
        sudo /usr/bin/pacman $argv
    end
end
