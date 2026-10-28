function __better_tools_vim --argument-names fallback --description "Run nvim as the fallback editor when available"
    set -l bin (__better_tools_pick nvim)
    if test -z "$bin"
        command $fallback $argv[2..-1]
        return $status
    end

    command $bin $argv[2..-1]
end
