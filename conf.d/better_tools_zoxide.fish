status is-interactive; or return

function __better_tools_zoxide_init --on-event fish_prompt --description "Initialize zoxide after config.fish has loaded"
    functions --erase __better_tools_zoxide_init

    if __better_tools_disabled zoxide
        return
    end

    if __better_tools_disabled cd
        return
    end

    if set -q BETTER_TOOLS_ZOXIDE; and test "$BETTER_TOOLS_ZOXIDE" = 0
        return
    end

    command -q zoxide; or return
    functions -q __zoxide_z; and return

    zoxide init fish --cmd cd | source
end
