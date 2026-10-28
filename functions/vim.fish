function vim --wraps=vim --description "Use nvim when available, otherwise vim"
    if not status is-interactive; or __better_tools_disabled vim
        command vim $argv
        return $status
    end

    __better_tools_vim vim $argv
end
