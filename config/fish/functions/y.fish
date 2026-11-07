function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    set -l cwd (cat $tmp)
    if test -n "$cwd" && test "$cwd" != "$PWD"
        builtin cd $cwd
    end
    rm -f $tmp
end
