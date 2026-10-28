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
    printf '#!/bin/sh\necho %s "$@"\n' $name >$dir/$name
    chmod +x $dir/$name
end

function link_native --argument-names dir
    ln -sf (command -v cat) $dir/cat
    ln -sf (command -v ls) $dir/ls
end

set -g sample $tmp/sample.txt
printf 'alpha\nbeta\n' >$sample

mkdir -p $tmp/base $tmp/with-bat $tmp/with-batcat $tmp/with-eza
link_native $tmp/base
link_native $tmp/with-bat
link_native $tmp/with-batcat
link_native $tmp/with-eza
make_stub $tmp/with-bat bat
make_stub $tmp/with-batcat batcat
make_stub $tmp/with-eza eza

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

rm -rf $tmp

if test $failures -gt 0
    echo "$failures test(s) failed"
    exit 1
end

echo "all tests passed"
