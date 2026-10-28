function __better_tools_ls --description "Run eza as ls when the arguments are compatible"
    if __better_tools_disabled ls
        command ls $argv
        return $status
    end

    set -l bin
    if set -q BETTER_TOOLS_LS
        set bin $BETTER_TOOLS_LS
    else
        set bin (__better_tools_pick eza)
    end

    if test -z "$bin"
        command ls $argv
        return $status
    end

    set -l eza_args
    set -l seen_flags
    set -l end_of_options

    for arg in $argv
        if test -n "$end_of_options"
            set -a eza_args $arg
            continue
        end

        switch $arg
            case --
                set end_of_options 1
                set -a eza_args --
            case --help --version
                command $bin $arg
                return $status
            case --all --almost-all --long --oneline --recurse --reverse \
                --directory --list-dirs --inode --numeric --classify '--classify=*' \
                --icons '--icons=*' '--color=*' --group-directories-first
                set -a eza_args $arg
            case -
                set -a eza_args $arg
            case '-*'
                for flag in (string sub --start 2 -- $arg | string split -- '')
                    switch $flag
                        case a A l 1 R d r i n F x
                            if not contains -- $flag $seen_flags
                                set -a seen_flags $flag
                                set -a eza_args -$flag
                            end
                        case h
                            # ls -h is human-readable; eza is human-readable by default.
                        case '*'
                            command ls $argv
                            return $status
                    end
                end
            case '*'
                set -a eza_args $arg
        end
    end

    command $bin $eza_args
end
