function grep --wraps=grep --description "Use ugrep when BETTER_TOOLS_GREP is set"
    if not status is-interactive
        command grep $argv
        return $status
    end

    __better_tools_grep $argv
end
