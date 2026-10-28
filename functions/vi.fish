function vi --wraps=vi --description "Use nvim when available, otherwise vi"
    if not status is-interactive; or __better_tools_disabled vi
        command vi $argv
        return $status
    end

    __better_tools_vim vi $argv
end
