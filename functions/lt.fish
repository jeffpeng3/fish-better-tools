function lt --description "Two-level tree with eza when available"
    if __better_tools_disabled ls
        command ls -R $argv
        return $status
    end

    set -l bin (__better_tools_pick eza)
    if test -z "$bin"
        if command -q tree
            command tree $argv
        else
            command ls -R $argv
        end
        return $status
    end

    command $bin --tree --level=2 --group-directories-first (__better_tools_icons) $argv
end
