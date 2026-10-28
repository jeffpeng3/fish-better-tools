function __better_tools_disabled --argument-names name --description "Check BETTER_TOOLS_DISABLE for a command name"
    set -q BETTER_TOOLS_DISABLE; or return 1

    set -l disabled (
        string replace --all ',' ' ' -- $BETTER_TOOLS_DISABLE |
            string split -- ' '
    )

    contains -- $name $disabled
end
