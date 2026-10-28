function ll --description "Long listing with eza when available"
    if __better_tools_disabled ls
        command ls -l $argv
        return $status
    end

    set -l bin (__better_tools_pick eza)
    if test -z "$bin"
        command ls -l $argv
        return $status
    end

    command $bin -l --group-directories-first (__better_tools_icons) $argv
end
