for mode in default insert
    bind --mode $mode " " __abbr_tips_bind_space
    bind --mode $mode \n __abbr_tips_bind_newline
    bind --mode $mode \r __abbr_tips_bind_newline
end

set -g __abbr_tips_used 0

function trim_value
    string trim --left --right --chars '"\'' -- $argv | string join ' '
end

function __abbr_tips_install --on-event abbr_tips_install
    set -gx ABBR_TIPS_REGEXES
    set -a ABBR_TIPS_REGEXES '(^(\w+\s+)+(-{1,2})\w+)(\s\S+)'
    set -a ABBR_TIPS_REGEXES '(^(\s?(\w-?)+){3}).*'
    set -a ABBR_TIPS_REGEXES '(^(\s?(\w-?)+){2}).*'
    set -a ABBR_TIPS_REGEXES '(^(\s?(\w-?)+){1}).*'

    set -Ux ABBR_TIPS_PROMPT "\n 󰛨 \e[38;2;203;166;247m{{ .abbr }}\e[0m \e[38;2;88;91;112m󰁔\e[0m \e[38;2;137;180;250m{{ .cmd }}\e[0m"
    
    set -gx ABBR_TIPS_AUTO_UPDATE background

    __abbr_tips_init
end

function __abbr_tips --on-event fish_postexec -d "Abbreviation reminder for the current command"
    set -l cmd_str (string replace -r -a '\s+' ' ' -- "$argv")
    set -l cmd_list (string split ' ' -- "$cmd_str")

    if test (count $cmd_list) -eq 0
        return
    end

    if test "$cmd_list[1]" = abbr
        argparse --name abbr --ignore-unknown a/add e/erase g/global U/universal -- $cmd_list
        if set -q _flag_a; and not contains -- "$cmd_list[2]" $__ABBR_TIPS_KEYS
            set -a __ABBR_TIPS_KEYS "$cmd_list[2]"
            set -a __ABBR_TIPS_VALUES (trim_value "$cmd_list[3..-1]")
        else if set -q _flag_e; and set -l abb (contains -i -- "$cmd_list[2]" $__ABBR_TIPS_KEYS)
            set -e __ABBR_TIPS_KEYS[$abb]
            set -e __ABBR_TIPS_VALUES[$abb]
        end
        return
    else if test "$cmd_list[1]" = alias
        argparse --name alias --ignore-unknown s/save -- $cmd_list
        if test (count $cmd_list) -lt 2
            return
        end
        set -l alias_key
        set -l alias_value
        if string match -q '*=*' -- "$cmd_list[2]"
            set -l command_split (string split '=' -- $cmd_list[2])
            set alias_key "a__$command_split[1]"
            set alias_value $command_split[2..-1]
        else
            set alias_key "a__$cmd_list[2]"
            set alias_value $cmd_list[3..-1]
        end

        set alias_value (trim_value "$alias_value")

        if set -l abb (contains -i -- "$cmd_list[3..-1]" $__ABBR_TIPS_KEYS)
            set __ABBR_TIPS_KEYS[$abb] $alias_key
            set __ABBR_TIPS_VALUES[$abb] $alias_value
        else
            set -a __ABBR_TIPS_KEYS $alias_key
            set -a __ABBR_TIPS_VALUES $alias_value
        end
        return
    else if test "$cmd_list[1]" = functions
        argparse --name functions e/erase -- $cmd_list
        if set -q _flag_e; and test (count $cmd_list) -ge 2
            if set -l abb (contains -i -- a__{$cmd_list[2]} $__ABBR_TIPS_KEYS)
                set -e __ABBR_TIPS_KEYS[$abb]
                set -e __ABBR_TIPS_VALUES[$abb]
            end
        end
        return
    end

    if test "$__abbr_tips_used" = "1"
        set -g __abbr_tips_used 0
        return
    else if abbr -q "$cmd_str"
        or not type -q "$cmd_list[1]"
        return
    else if test (type -t "$cmd_list[1]") = function
        and not contains -- "$cmd_list[1]" $ABBR_TIPS_ALIAS_WHITELIST
        return
    end

    set -l abb
    if not set abb (contains -i -- "$cmd_str" $__ABBR_TIPS_VALUES)
        for r in $ABBR_TIPS_REGEXES
            set -l test_cmd (string replace -r -a -- "$r" '$1' "$cmd_str")
            if set abb (contains -i -- "$test_cmd" $__ABBR_TIPS_VALUES)
                break
            end
        end
    end

    if test -n "$abb"
        set -l key "$__ABBR_TIPS_KEYS[$abb]"
        set -l val "$__ABBR_TIPS_VALUES[$abb]"
        set -l prompt_str "$ABBR_TIPS_PROMPT"

        if string match -q "a__*" -- "$key"
            set -l alias_name (string sub -s 4 -- "$key")
            if functions -q "$alias_name"
                set prompt_str (string replace -a '{{ .abbr }}' -- "$alias_name" "$prompt_str")
                set prompt_str (string replace -a '{{ .cmd }}' -- "$val" "$prompt_str")
                echo -e "$prompt_str"
            else
                set -e __ABBR_TIPS_KEYS[$abb]
                set -e __ABBR_TIPS_VALUES[$abb]
            end
        else
            set prompt_str (string replace -a '{{ .abbr }}' -- "$key" "$prompt_str")
            set prompt_str (string replace -a '{{ .cmd }}' -- "$val" "$prompt_str")
            echo -e "$prompt_str"
        end
    end

    return
end

function __abbr_tips_update --on-event abbr_tips_update
    __abbr_tips_clean
    __abbr_tips_install
end

function __abbr_tips_uninstall --on-event abbr_tips_uninstall
    __abbr_tips_clean
    functions --erase __abbr_tips_init
end