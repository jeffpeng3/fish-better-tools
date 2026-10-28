function find --wraps=find --description "Use bfs when BETTER_TOOLS_FIND is set"
    if not status is-interactive
        command find $argv
        return $status
    end

    __better_tools_find $argv
end
