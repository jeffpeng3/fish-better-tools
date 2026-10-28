function __better_tools_cat --description "Run bat as cat when the arguments are safe"
    if __better_tools_disabled cat
        command cat $argv
        return $status
    end

    set -l bin
    if set -q BETTER_TOOLS_CAT
        set bin $BETTER_TOOLS_CAT
    else
        set bin (__better_tools_pick bat batcat)
    end

    if test -z "$bin"
        command cat $argv
        return $status
    end

    set -l end_of_options
    for arg in $argv
        if test -n "$end_of_options"
            continue
        end

        switch $arg
            case --
                set end_of_options 1
            case -
            case '-*'
                command cat $argv
                return $status
        end
    end

    command $bin --paging=never --style=plain $argv
end
