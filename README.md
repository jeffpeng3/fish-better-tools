# better-tools

A [fisher](https://github.com/jorgebucaran/fisher) plugin that transparently uses modern CLI tools when they are installed and compatible, and falls back to the original command otherwise.

Default replacements:

| Command | Preferred tool | Fallback |
| --- | --- | --- |
| `cat` | `bat` or `batcat` | `cat` |
| `ls` | `eza` | `ls` |
| `vim` / `vi` | `nvim` | `vim` / `vi` |
| `cd` | `zoxide` | builtin `cd` |

Opt-in replacements:

| Command | Preferred tool | Enable with |
| --- | --- | --- |
| `find` | `bfs` | `BETTER_TOOLS_FIND=1` |
| `grep` | `ugrep` | `BETTER_TOOLS_GREP=1` |
| `jq` | `jaq` | `BETTER_TOOLS_JQ=1` |

Convenience aliases:

| Alias | Behavior |
| --- | --- |
| `ll` | `eza -l --group-directories-first` |
| `la` | `eza -la --group-directories-first` |
| `lt` | `eza --tree --level=2 --group-directories-first` |

## Requirements

- fish 3.5 or newer
- Optional: [bat](https://github.com/sharkdp/bat) or the Debian/Ubuntu `batcat` binary
- Optional: [eza](https://github.com/eza-community/eza)
- Optional: [zoxide](https://github.com/ajeetdsouza/zoxide)
- Optional: [neovim](https://github.com/neovim/neovim)
- Optional: [bfs](https://github.com/tavianator/bfs), [ugrep](https://github.com/Genivia/ugrep), [jaq](https://github.com/01mf02/jaq)

## Install

```fish
fisher install jeffpeng3/fish-better-tools
```

Pin a release:

```fish
fisher install jeffpeng3/fish-better-tools@v0.2.0
```

Local development:

```fish
fisher install /path/to/fish-better-tools
```

Reinstall after editing local files because fisher copies plugin files into `~/.config/fish`.

## Behavior

Default replacements only apply to interactive fish sessions. Scripts and command substitution keep the native command.

`cat`, `ls`, and the eza aliases also require stdout to be a terminal. Set `BETTER_TOOLS_PIPE=1` to allow them when stdout is not a terminal.

### cat

`cat` becomes `bat --paging=never --style=plain` when:

- stdout is a terminal
- every argument is a file path, `-`, or `--`
- no file arguments means stdin must not be a terminal

Any flag falls back to `command cat`. This avoids bat flag differences such as `cat -b` and `cat -n`.

### ls

`ls` becomes `eza` when stdout is a terminal and all flags are compatible.

Compatible short flags:

```text
-a -A -l -1 -R -d -r -i -n -F -x
```

`-h` is dropped because eza sizes are human-readable by default. Any other short flag falls back to `command ls`. This includes flags with different meanings in eza, such as `-S`, `-s`, `-t`, `-G`, `-g`, `-C`, `-L`, `-o`, and `-p`.

Compatible long options:

```text
--all --almost-all --long --oneline --recurse --reverse --directory --list-dirs
--inode --numeric --classify --classify=* --icons --icons=* --color=*
--group-directories-first
```

`--help` and `--version` go to eza.

### vim and vi

Interactive `vim` and `vi` use `nvim` when it is installed.

### cd

When `zoxide` is installed, the plugin runs `zoxide init fish --cmd cd` once. Normal paths and `cd -` still work through zoxide. Existing zoxide initialization is detected and skipped.

### find

`find` uses `bfs` only when `BETTER_TOOLS_FIND` is enabled. Arguments are passed through unchanged. Traversal and output order can differ from GNU find.

### grep

`grep` uses `ugrep -G` only when `BETTER_TOOLS_GREP` is enabled. `-G` matches GNU grep's default basic regular expressions.

When stdin is a terminal and the last argument is not an existing path or `-`, the plugin falls back to native grep. This avoids ugrep's recursive default for commands such as `grep pattern`.

### jq

`jq` uses `jaq` only when `BETTER_TOOLS_JQ` is enabled. jaq is compatible with most jq programs, but behavior can differ for edge cases.

## Configuration

| Variable | Effect |
| --- | --- |
| `BETTER_TOOLS_DISABLE` | Space or comma separated command names to disable, for example `cat ls` |
| `BETTER_TOOLS_CAT` | Explicit path or name for the bat binary |
| `BETTER_TOOLS_LS` | Explicit path or name for the eza binary |
| `BETTER_TOOLS_FIND` | `1` or a binary path to enable bfs for find |
| `BETTER_TOOLS_GREP` | `1` or a binary path to enable ugrep for grep |
| `BETTER_TOOLS_JQ` | `1` or a binary path to enable jaq for jq |
| `BETTER_TOOLS_ZOXIDE=0` | Disable the zoxide cd integration |
| `BETTER_TOOLS_ICONS=1` | Add `--icons=auto` to the eza aliases |
| `BETTER_TOOLS_PIPE=1` | Use bat or eza when stdout is not a terminal |

Example opt-in setup in `config.fish`:

```fish
set -gx BETTER_TOOLS_FIND 1
set -gx BETTER_TOOLS_GREP 1
set -gx BETTER_TOOLS_JQ 1
```

## Escape hatches

```fish
command cat file
command ls -la
command find . -name '*.fish'
command grep pattern file
command jq . file.json
builtin cd /tmp
functions -e cat
functions -e ls
```

## Tests

```fish
fish tests/run.fish
```

The test suite creates temporary stubs for bat, batcat, eza, bfs, ugrep, jaq, nvim, vim, and vi, so it does not need those tools installed.

## Uninstall

```fish
fisher remove jeffpeng3/fish-better-tools
```

## License

MIT
