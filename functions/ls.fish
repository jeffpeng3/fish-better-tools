function ls --wraps=ls --description "Use eza when available, otherwise ls"
    if not status is-interactive
        command ls $argv
        return $status
    end

    if not set -q BETTER_TOOLS_PIPE
        if not test -t 1
            command ls $argv
            return $status
        end
    end

    __better_tools_ls $argv
end
