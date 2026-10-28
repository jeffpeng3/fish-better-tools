#!/usr/bin/env fish

set -g failures 0
set -g tmp (mktemp -d)
set -l root (path resolve (status dirname)/..)
set -p fish_function_path $root/functions

function assert_equal --argument-names description expected actual
    if test "$expected" = "$actual"
        echo "ok   $description"
    else
        echo "FAIL $description"
        echo "     expected: $expected"
        echo "     actual:   $actual"
        set -g failures (math $failures + 1)
    end
end

function make_stub --argument-names dir name
    rm -f $dir/$name
    printf '#!/bin/sh\necho %s "$@"\n' $name >$dir/$name
    chmod +x $dir/$name
end

function link_native --argument-names dir
    for tool in cat ls find grep jq vim vi
        if command -q -- $tool
            ln -sf (command -v -- $tool) $dir/$tool
        end
    end
end

set -g sample $tmp/sample.txt
set -g sample_json $tmp/sample.json
printf 'alpha\nbeta\n' >$sample
printf '{"a":1}\n' >$sample_json

mkdir -p $tmp/base $tmp/with-bat $tmp/with-batcat $tmp/with-eza $tmp/opt $tmp/fallback
for dir in base with-bat with-batcat with-eza opt fallback
    link_native $tmp/$dir
end
make_stub $tmp/with-bat bat
make_stub $tmp/with-batcat batcat
make_stub $tmp/with-eza eza
make_stub $tmp/opt bfs
make_stub $tmp/opt ugrep
make_stub $tmp/opt jaq
make_stub $tmp/opt nvim
make_stub $tmp/opt eza
make_stub $tmp/fallback vim
make_stub $tmp/fallback vi

set -l original_path $PATH
set -l want_cat (command cat $sample | string collect)
set -l want_cat_numbered (command cat -n $sample | string collect)

set -gx PATH $tmp/base
set -l got (__better_tools_cat $sample | string collect)
set -gx PATH $original_path
assert_equal "cat falls back without bat" "$want_cat" "$got"

set -gx PATH $tmp/with-bat
set -l got (__better_tools_cat $sample | string collect)
set -gx PATH $original_path
assert_equal "cat uses bat" "bat --paging=never --style=plain $sample" "$got"

set -gx PATH $tmp/with-batcat
set -l got (__better_tools_cat $sample | string collect)
set -gx PATH $original_path
assert_equal "cat uses batcat" "batcat --paging=never --style=plain $sample" "$got"

set -gx PATH $tmp/with-bat
set -l got (__better_tools_cat -n $sample | string collect)
set -gx PATH $original_path
assert_equal "cat falls back for flags" "$want_cat_numbered" "$got"

set -gx PATH $tmp/with-bat
set -gx BETTER_TOOLS_DISABLE cat
set -l got (__better_tools_cat $sample | string collect)
set -e BETTER_TOOLS_DISABLE
set -gx PATH $original_path
assert_equal "cat honors BETTER_TOOLS_DISABLE" "$want_cat" "$got"

set -gx PATH $tmp/base
set -gx BETTER_TOOLS_CAT $tmp/with-bat/bat
set -l got (__better_tools_cat $sample | string collect)
set -e BETTER_TOOLS_CAT
set -gx PATH $original_path
assert_equal "cat honors BETTER_TOOLS_CAT" "bat --paging=never --style=plain $sample" "$got"

set -gx PATH $tmp/with-bat
set -l got (cat $sample | string collect)
set -gx PATH $original_path
assert_equal "cat wrapper delegates when non-interactive" "$want_cat" "$got"

set -l want_ls (command ls $tmp | string collect)
set -l want_ls_size (command ls -S $tmp | string collect)

set -gx PATH $tmp/base
set -l got (__better_tools_ls $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls falls back without eza" "$want_ls" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls uses eza" "eza $tmp" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls -lah $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls translates -lah" "eza -l -a $tmp" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls -ll $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls deduplicates flags" "eza -l $tmp" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls -h $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls drops -h" "eza $tmp" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls --icons=auto $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls passes eza long options" "eza --icons=auto $tmp" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls -S $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls falls back for -S" "$want_ls_size" "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls -t $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls falls back for -t" (command ls -t $tmp | string collect) "$got"

set -gx PATH $tmp/with-eza
set -l got (__better_tools_ls --help | string collect)
set -gx PATH $original_path
assert_equal "ls sends --help to eza" "eza --help" "$got"

set -gx PATH $tmp/with-eza
set -l got (ls $tmp | string collect)
set -gx PATH $original_path
assert_equal "ls wrapper delegates when non-interactive" "$want_ls" "$got"

set -gx PATH $tmp/opt
set -l got (__better_tools_optin find bfs | string collect)
set -gx PATH $original_path
assert_equal "opt-in stays off by default" "" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_FIND 1
set -l got (__better_tools_optin find bfs | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
assert_equal "opt-in resolves the default tool" bfs "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_FIND $tmp/opt/bfs
set -l got (__better_tools_optin find bfs | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
assert_equal "opt-in accepts an explicit path" "$tmp/opt/bfs" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_FIND 0
set -l got (__better_tools_optin find bfs | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
assert_equal "opt-in can be disabled with 0" "" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_FIND 1
set -l got (__better_tools_find $tmp -maxdepth 0 | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
assert_equal "find uses bfs when opted in" "bfs $tmp -maxdepth 0" "$got"

set -l want_find (command find $tmp -maxdepth 0 | string collect)

set -gx PATH $tmp/base
set -gx BETTER_TOOLS_FIND 1
set -l got (__better_tools_find $tmp -maxdepth 0 | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
assert_equal "find falls back without bfs" "$want_find" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_FIND 1
set -gx BETTER_TOOLS_DISABLE find
set -l got (__better_tools_find $tmp -maxdepth 0 | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_FIND
set -e BETTER_TOOLS_DISABLE
assert_equal "find honors BETTER_TOOLS_DISABLE" "$want_find" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_GREP 1
set -l got (__better_tools_grep alpha $sample | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_GREP
assert_equal "grep uses ugrep when opted in" "ugrep -G alpha $sample" "$got"

set -l want_grep (command grep alpha $sample | string collect)

set -gx PATH $tmp/base
set -l got (__better_tools_grep alpha $sample | string collect)
set -gx PATH $original_path
assert_equal "grep falls back by default" "$want_grep" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_GREP 1
set -gx BETTER_TOOLS_DISABLE grep
set -l got (__better_tools_grep alpha $sample | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_GREP
set -e BETTER_TOOLS_DISABLE
assert_equal "grep honors BETTER_TOOLS_DISABLE" "$want_grep" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_JQ 1
set -l got (__better_tools_jq . $sample_json | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_JQ
assert_equal "jq uses jaq when opted in" "jaq . $sample_json" "$got"

set -l want_jq (command jq . $sample_json | string collect)

set -gx PATH $tmp/base
set -l got (__better_tools_jq . $sample_json | string collect)
set -gx PATH $original_path
assert_equal "jq falls back by default" "$want_jq" "$got"

set -gx PATH $tmp/opt
set -l got (__better_tools_vim vim $sample | string collect)
set -gx PATH $original_path
assert_equal "vim uses nvim" "nvim $sample" "$got"

set -gx PATH $tmp/fallback
set -l got (__better_tools_vim vim $sample | string collect)
set -gx PATH $original_path
assert_equal "vim falls back without nvim" "vim $sample" "$got"

set -gx PATH $tmp/fallback
set -l got (__better_tools_vim vi $sample | string collect)
set -gx PATH $original_path
assert_equal "vi falls back without nvim" "vi $sample" "$got"

set -gx PATH $tmp/opt
set -l got (ll $tmp | string collect)
set -gx PATH $original_path
assert_equal "ll uses eza" "eza -l --group-directories-first $tmp" "$got"

set -gx PATH $tmp/opt
set -l got (la $tmp | string collect)
set -gx PATH $original_path
assert_equal "la uses eza" "eza -la --group-directories-first $tmp" "$got"

set -gx PATH $tmp/opt
set -l got (lt $tmp | string collect)
set -gx PATH $original_path
assert_equal "lt uses eza tree" "eza --tree --level=2 --group-directories-first $tmp" "$got"

set -gx PATH $tmp/opt
set -gx BETTER_TOOLS_ICONS 1
set -l got (ll $tmp | string collect)
set -gx PATH $original_path
set -e BETTER_TOOLS_ICONS
assert_equal "ll adds icons when enabled" "eza -l --group-directories-first --icons=auto $tmp" "$got"

set -l want_ll (command ls -l $tmp | string collect)

set -gx PATH $tmp/base
set -l got (ll $tmp | string collect)
set -gx PATH $original_path
assert_equal "ll falls back without eza" "$want_ll" "$got"

rm -rf $tmp

if test $failures -gt 0
    echo "$failures test(s) failed"
    exit 1
end

echo "all tests passed"
