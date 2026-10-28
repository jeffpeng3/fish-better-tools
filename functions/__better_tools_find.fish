function __better_tools_find --description "Run bfs as find when opted in"
    if __better_tools_disabled find
        command find $argv
        return $status
    end

    set -l bin (__better_tools_optin find bfs)
    if test -z "$bin"
        command find $argv
        return $status
    end

    command $bin $argv
end
