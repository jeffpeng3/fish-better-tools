function __better_tools_optin --argument-names command_name default_bin --description "Resolve an opt-in tool from BETTER_TOOLS_<NAME>"
    set -l var BETTER_TOOLS_(string upper -- $command_name)
    set -q $var; or return 1

    set -l value $$var
    test "$value" = 0; and return 1

    if contains -- $value 1 true yes on
        __better_tools_pick $default_bin
        return
    end

    echo $value
end
