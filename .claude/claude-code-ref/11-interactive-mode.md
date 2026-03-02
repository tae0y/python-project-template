# Interactive Mode

## Keyboard shortcuts

### General controls

| Shortcut            | Description                                      |
|---------------------|--------------------------------------------------|
| `Ctrl+C`           | Cancel current input or generation               |
| `Ctrl+D`           | Exit session                                     |
| `Ctrl+F`           | Kill all background agents (press twice to confirm) |
| `Ctrl+G`           | Open in default text editor                      |
| `Ctrl+L`           | Clear terminal screen (keeps conversation)       |
| `Ctrl+O`           | Toggle verbose output                            |
| `Ctrl+R`           | Reverse search command history                   |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard                       |
| `Ctrl+B`           | Background running tasks (tmux: press twice)     |
| `Ctrl+T`           | Toggle task list                                 |
| `Esc+Esc`          | Rewind / summarize                               |
| `Shift+Tab`        | Toggle permission modes                          |
| `Alt+P`            | Switch model                                     |
| `Alt+T`            | Toggle extended thinking                         |

### Text editing

| Shortcut    | Description                  |
|-------------|------------------------------|
| `Ctrl+K`   | Delete to end of line        |
| `Ctrl+U`   | Delete entire line           |
| `Ctrl+Y`   | Paste deleted text           |
| `Alt+Y`    | Cycle paste history          |
| `Alt+B`    | Move cursor back one word    |
| `Alt+F`    | Move cursor forward one word |

### Multiline input

| Method           | Shortcut       |
|------------------|----------------|
| Quick escape     | `\` + `Enter`  |
| macOS default    | `Option+Enter` |
| Shift+Enter      | `Shift+Enter` (iTerm2, WezTerm, Ghostty, Kitty natively) |
| Control sequence | `Ctrl+J`       |

### Quick commands

| Shortcut     | Description                          |
|--------------|--------------------------------------|
| `/` at start | Command or skill                     |
| `!` at start | Bash mode (run commands directly)    |
| `@`          | File path mention / MCP resource     |

## Built-in commands (selected)

| Command             | Purpose                                              |
|---------------------|------------------------------------------------------|
| `/clear`            | Clear conversation history and free context          |
| `/compact`          | Compact conversation with optional focus instructions|
| `/config`           | Open settings interface                              |
| `/context`          | Visualize current context usage                      |
| `/cost`             | Show token usage statistics                          |
| `/diff`             | Interactive diff viewer for uncommitted changes      |
| `/doctor`           | Diagnose installation and settings                   |
| `/export`           | Export conversation as plain text                    |
| `/fast`             | Toggle fast mode                                     |
| `/fork`             | Fork current conversation                            |
| `/hooks`            | Manage hook configurations                           |
| `/init`             | Initialize project with CLAUDE.md                    |
| `/keybindings`      | Open keybindings configuration                       |
| `/mcp`              | Manage MCP server connections and OAuth              |
| `/memory`           | Edit CLAUDE.md memory files and auto-memory          |
| `/model`            | Select or change model (left/right for effort level) |
| `/output-style`     | Switch output style (Default/Explanatory/Learning)   |
| `/permissions`      | View or update permissions                           |
| `/plan`             | Enter plan mode                                      |
| `/plugin`           | Manage plugins                                       |
| `/pr-comments`      | Fetch GitHub PR comments                             |
| `/release-notes`    | View changelog                                       |
| `/resume`           | Resume a conversation by ID or name                  |
| `/review`           | Review a pull request                                |
| `/rewind`           | Rewind to checkpoint                                 |
| `/sandbox`          | Toggle sandbox mode                                  |
| `/security-review`  | Analyze pending changes for security vulnerabilities |
| `/skills`           | List available skills                                |
| `/stats`            | Visualize daily usage and session history            |
| `/tasks`            | List and manage background tasks                     |
| `/theme`            | Change color theme                                   |
| `/vim`              | Toggle vim editing mode                              |

## Vim editor mode

Enable with `/vim` or configure permanently via `/config`.
Supports NORMAL/INSERT modes, full navigation (h/j/k/l, w/e/b, gg/G, f/t),
editing (d/c/y/p, dd/cc/yy, text objects iw/aw/i"/a"/i(/a(, etc.),
and repeat with `.`.

## Prompt suggestions

After Claude responds, grayed-out suggestions appear based on conversation history.
Press `Tab` to accept, `Enter` to accept and submit.
Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

## Task list

For complex work, Claude creates a task list visible in the status area.
`Ctrl+T` toggles the view. Tasks persist across context compactions.
Share across sessions: `CLAUDE_CODE_TASK_LIST_ID=my-project claude`.

## PR review status

When on a branch with an open PR, the footer shows a clickable PR link with
colored underline: green (approved), yellow (pending), red (changes requested),
gray (draft), purple (merged).
