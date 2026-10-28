function cat --wraps=cat --description "Use bat when available, otherwise cat"
    if not status is-interactive
        command cat $argv
        return $status
    end

    if not set -q BETTER_TOOLS_PIPE
        if not test -t 1
            command cat $argv
            return $status
        end

        if not set -q argv[1]; and test -t 0
            command cat $argv
            return $status
        end
    end

    __better_tools_cat $argv
end
