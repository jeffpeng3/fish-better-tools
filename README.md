# better-tools

A [fisher](https://github.com/jorgebucaran/fisher) plugin that transparently uses modern CLI tools when they are installed and compatible, and falls back to the original command otherwise.

| Command | Preferred tool | Fallback |
| --- | --- | --- |
| `cat` | `bat` or `batcat` | `cat` |
| `ls` | `eza` | `ls` |

## Requirements

- fish 3.5 or newer
- Optional: [bat](https://github.com/sharkdp/bat) or the Debian/Ubuntu `batcat` binary
- Optional: [eza](https://github.com/eza-community/eza)

## Install

```fish
fisher install jeffpeng3/fish-better-tools
```

Pin a release:

```fish
fisher install jeffpeng3/fish-better-tools@v0.1.0
```

Local development:

```fish
fisher install /path/to/fish-better-tools
```

Reinstall after editing local files because fisher copies plugin files into `~/.config/fish`.

## Behavior

Overrides only apply to interactive fish sessions. Scripts, command substitution, and piped output keep the native command. Set `BETTER_TOOLS_PIPE=1` to allow the preferred tool when stdout is not a terminal.

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

## Configuration

| Variable | Effect |
| --- | --- |
| `BETTER_TOOLS_DISABLE` | Space or comma separated command names to disable, for example `cat ls` |
| `BETTER_TOOLS_CAT` | Explicit path or name for the bat binary |
| `BETTER_TOOLS_LS` | Explicit path or name for the eza binary |
| `BETTER_TOOLS_PIPE=1` | Use bat or eza when stdout is not a terminal |

## Escape hatches

```fish
command cat file
command ls -la
functions -e cat
functions -e ls
```

## Tests

```fish
fish tests/run.fish
```

The test suite creates temporary stubs for `bat`, `batcat`, and `eza`, so it does not need those tools installed.

## Uninstall

```fish
fisher remove jeffpeng3/fish-better-tools
```

## License

MIT
