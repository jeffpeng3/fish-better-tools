function la --description "Long listing with hidden files using eza when available"
    if __better_tools_disabled ls
        command ls -la $argv
        return $status
    end

    set -l bin (__better_tools_pick eza)
    if test -z "$bin"
        command ls -la $argv
        return $status
    end

    command $bin -la --group-directories-first (__better_tools_icons) $argv
end
