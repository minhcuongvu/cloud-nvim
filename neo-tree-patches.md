# Neo-tree Patches (Windows/MSYS2)

Neo-tree has several issues on Windows environments with Unicode usernames or
MSYS2 git. These are patched automatically via a Lazy.nvim `build` hook in
`lua/plugins/neo-tree.lua` that rewrites the plugin source files after every
install/update.

## Patches Applied

### 1. Suppress "git status exited abnormally" warnings

**File:** `lua/neo-tree/git/init.lua`

Git status commands frequently fail on Windows (Unicode paths, MSYS2
compatibility). The default `log.at.warn` call spams the message log. The patch
downgrades it to `log.at.trace` so it's only visible with verbose logging.

### 2. Graceful handling of `git ls-files` failures

**File:** `lua/neo-tree/git/ls-files.lua`

The original code calls `assert(vim.v.shell_error == 0)` after running
`git ls-files`, which crashes neo-tree entirely when git fails. The patch
replaces the assert with an early `return {}` so the tree still renders
without git status info.

### 3. Nil guard for `state.tree` in `open_with_cmd`

**File:** `lua/neo-tree/sources/common/commands.lua`

When opening a file, `open_with_cmd` accesses `state.tree.get_node` without
checking if `state.tree` exists. If the tree hasn't initialized yet (e.g.
during startup race conditions), this throws `E5108: attempt to index local
'tree' (a nil value)`. The patch adds `if not tree then return end` before the
`pcall`.

## How It Works

The `build` callback in the plugin spec uses `io.open` / `string.gsub` to
apply the patches directly to the plugin source files on disk. Lazy.nvim runs
`build` after every `:Lazy install` and `:Lazy update`, so the patches are
re-applied automatically whenever neo-tree is updated.

On a fresh clone, run `:Lazy install` (or just open Neovim, which triggers it
automatically) and the patches will be applied during the install step.

## Additional Config Notes

- The `git_status` **source** is excluded (`sources = { "filesystem", "buffers" }`)
  because it fails outright with Unicode usernames on MSYS2. Git status
  **indicators** still work via `enable_git_status = true`.
- `use_libuv_file_watcher` is disabled to avoid file watching issues on Windows.
- `scan_mode = "shallow"` is used for performance.
