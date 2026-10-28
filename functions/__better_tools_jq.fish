function __better_tools_jq --description "Run jaq as jq when opted in"
    if __better_tools_disabled jq
        command jq $argv
        return $status
    end

    set -l bin (__better_tools_optin jq jaq)
    if test -z "$bin"
        command jq $argv
        return $status
    end

    command $bin $argv
end
