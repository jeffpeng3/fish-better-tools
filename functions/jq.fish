function jq --wraps=jq --description "Use jaq when BETTER_TOOLS_JQ is set"
    if not status is-interactive
        command jq $argv
        return $status
    end

    __better_tools_jq $argv
end
