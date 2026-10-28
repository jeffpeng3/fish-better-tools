function __better_tools_icons --description "Print eza icon flags when enabled"
    set -q BETTER_TOOLS_ICONS; or return 1
    test "$BETTER_TOOLS_ICONS" = 0; and return 1

    echo --icons=auto
end
