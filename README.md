# canter.nvim

## Introduction

lightweight neovim code runner plugin that works with Snacks.nvim terminal

## Requirements

- Neovim (>= 0.7)
- [Snacks.nvim](https://github.com/folke/snacks.nvim) (>= 2.11.0)
  - needed for Terminal
- [which-key](https://github.com/folke/which-key.nvim) (>= 3.15.0)
  - only needed for custom leader key menu group name

## Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
   "dchae/canter.nvim",
   opts = {}
},
```

### Other package managers

Install normally, and add this line to your `init.lua`:

```lua
require("canter.nvim").setup()
```

## Configuration

Pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

### Options

#### Default options
```lua
opts = {
    -- File extension to runner/interpreter mapping
    runners = {},

    -- Terminal configuration (passed to Snacks.nvim)
    Snacks_terminal_opts = {
        win = {
            position = "bottom",
            relative = "editor"
        },
        interactive = false
    },

    -- Default keymaps (can be overridden)
    keymaps = {
        ["<leader><cr><cr>"] = {
            cmd = ":CanterRun<CR>",
            desc = "Run current file (Auto)"
        },
        ["<leader><cr>w"] = {
            cmd = ":CanterWait<CR>",
            desc = "Run current file (Wait)"
        }
    }
}
```

**NOTE** - does not come with runners by default, you must add your own.

- `runners`: table `([file_extension] = runner/interpreter)`
- `Snacks_terminal_opts`: table of options passed to Snacks.nvim terminal
  - `win`: window positioning options
  - `interactive`: whether terminal starts in interactive mode
- `keymaps`: table of keybindings and their descriptions

#### Example config
```lua
opts = {
    runners = {
        ["js"] = "node", 
        ["rb"] = "ruby", 
        ["py"] = "python"
    },
    Snacks_terminal_opts = {
        win = {
            position = "right",  -- Change terminal position to right
            relative = "editor"
        },
        interactive = true      -- Always start in interactive mode
    }
}
```

## Usage

"Run current file (Auto)"

- if file contains a shebang on the first line, the plugin will attempt to:
  1. make the file executable via `chmod`
  2. execute the current file
- else, if the file has a corresponding runner
  1. execute the current file via its runner in `Snacks.terminal`

"Run current file (Wait)"

- same as above, but stops before actually executing so you can add flags or confirm the command before pressing enter.
  - necessarily, the terminal is interactive by default in this mode.

### Shebang example with node
`test.js`
```js
#!/usr/bin/env node

console.log("Hello, world!");
// "Hello, world!"
```

### Default Keybinds

All keybinds can be customized in the config. The defaults are:

- `<Leader><CR><CR>`: Run current file (Auto)
  - executes current file in terminal
  - default behaviour is non-interactive; file will run and then any key will dismiss terminal
- `<Leader><CR>w`: Run current file (Wait)
  - loads current file run command in terminal
  - default behaviour is interactive

To customize keybinds, modify the `keymaps` table in your config:

```lua
opts = {
    keymaps = {
        -- Override default run binding
        ["<leader>r"] = {
            cmd = ":CanterRun<CR>",
            desc = "Run current file"
        },
        -- Add new binding
        ["<leader>rw"] = {
            cmd = ":CanterWait<CR>",
            desc = "Run and wait"
        }
    }
}
```

## Roadmap

- should work with vsplit terminal when Snacks is not available
- automatically scan and resolve runners for a given file extension
- better support for runner flags

## Credits
- plugin inspired by keymap script by u/linkarzu on r/neovim
