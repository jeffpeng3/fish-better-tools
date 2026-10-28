function __better_tools_pick --description "Print the first available external command"
    for candidate in $argv
        if command -q -- $candidate
            echo $candidate
            return 0
        end
    end

    return 1
end
