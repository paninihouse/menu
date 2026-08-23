# Usage

How to use the program effectively.

Using *menu* is very straightforward.
Give it a list of newline-separated strings through `stdin` and the program will present them back to you.
Move the selection to an item of your choosing and press Return, *menu* will stop and print the selected item to `stdout`.
At this point, what to do with the result is up to you to decide, the limit is just your imagination.

```sh
# Present a list of fruits in a menu and say out loud the chosen one.
echo "Apple\nBanana\nMango\nPeach" | menu | say
```

## Options

You can further customize the appearance and behaviour of *menu* thanks to the following options:

| Option | Description | Default |
| --- | --- | --- |
| `-t`, `--top` / `-b`, `--bottom` | Define the position of the menu on the screen. | `--top` |
| `-p`, `--prompt <prompt>` | Define the prompt to be displayed before the input. | |
| `-c`, `--counter` | Define the visibility of the counter. | |
| `-m`, `--monitor <monitor>` | Display on the monitor number supplied. | `0` |
| `--version` | Show the version. | |
| `-h`, `--help` | Show help information. | |

## Bindings

You can further customize the appearance and behaviour of *menu* thanks to the following options:

| Action | Description | Binding |
| --- | --- | --- |
| `confirm` | Quit `menu` and write the selected string to `stdout`. | `Return` |
| `confirmInput` | Quit `menu` and write the raw input to `stdout`. | `Shift + Return` |
| `quit` | Quit `menu` without writing anything to `stdout`. | `Escape` |
| `complete` | Replace input with the currently selected string. | `Tab` |
| `forward` | Move selection forward by one. | `Control + j` |
| | | `Control + l` |
| `backward` | Move selection backward by one. | `Control + k` |
| | | `Control + h` |
