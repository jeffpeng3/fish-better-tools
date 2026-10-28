function __better_tools_grep --description "Run ugrep as grep when opted in"
    if __better_tools_disabled grep
        command grep $argv
        return $status
    end

    set -l bin (__better_tools_optin grep ugrep)
    if test -z "$bin"
        command grep $argv
        return $status
    end

    if test -t 0; and test (count $argv) -gt 0
        set -l last $argv[-1]
        if test "$last" != -; and not test -e "$last"
            command grep $argv
            return $status
        end
    end

    command $bin -G $argv
end
