# canter.nvim

## Introduction

lightweight neovim code runner plugin that works with Snacks.nvim terminal

### Demo

![demo](https://github.com/dchae/canter.nvim/blob/main/assets/canter_demo.gif?raw=true)

## Table of Contents

- [canter.nvim](#canternvim)
  - [Introduction](#introduction)
    - [Demo](#demo)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
    - [Optional (but recommended)](#optional-but-recommended)
  - [Installation](#installation)
    - [With lazy.nvim](#with-lazynvim)
    - [Other package managers](#other-package-managers)
  - [Configuration](#configuration)
    - [Options](#options)
      - [Default options](#default-options)
      - [Example config](#example-config)
  - [Usage](#usage)
    - [Terminal Usage](#terminal-usage)
    - [Shebang example with node](#shebang-example-with-node)
    - [Default Keybinds](#default-keybinds)
  - [Roadmap](#roadmap)
  - [Credits](#credits)

## Requirements

- Neovim (>= 0.7)

### Optional (but recommended)

- [Snacks.nvim](https://github.com/folke/snacks.nvim) (>= 2.11.0)
  - better Terminal
- [which-key](https://github.com/folke/which-key.nvim) (>= 3.15.0)
  - custom leader key menu group name
- These both come default with lazy.nvim

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
  debug = false,
  -- File extension to runner/interpreter mapping
  runners = {},

  -- Terminal configuration
  terminal = {
    type = "snacks", -- "snacks" or "builtin"

    -- Options for built-in terminal
    builtin_opts = {
      position = "vsplit", -- "vsplit", "split", or "float"
      escape_keymap = true, -- escape terminal mode with <Esc>
    },

    -- Options for Snacks.nvim terminal
    snacks_opts = {
      win = {
        position = "bottom",
        relative = "editor",
      },
      interactive = false,
    },
  },

  -- Default keymaps (can be overridden)
  keymaps = {
    ["<leader><cr><cr>"] = {
      cmd = ":CanterRun<CR>",
      desc = "Run current file (Auto)",
    },
    ["<leader><cr>w"] = {
      cmd = ":CanterWait<CR>",
      desc = "Run current file (Wait)",
    },
  },
}
```

**NOTE** - does not come with runners by default, you must add your own.

- `runners`: table `([file_extension] = runner/interpreter)`
- `terminal`: table of options passed to terminal
  - `type`: type of terminal
  - `builtin_opts`: options for built-in terminal
  - `snacks_opts`: options for Snacks.nvim terminal
- `keymaps`: table of keybindings and their descriptions

#### Example config

The current filename will be interpolated into the runner command.
For example, `node %s` will become `node 'myFile.js'`.

```lua
opts = {
  runners = {
    ["js"] = "node %s",
    ["ts"] = "bun %s",
    ["rb"] = "ruby %s",
    ["py"] = "python %s",
    ["cpp"] = "make brun",
  },
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

### Terminal Usage

When using the built-in terminal in wait mode:

- Press `<Esc>` to exit terminal mode and return to normal mode (if `escape_keymap` is enabled)
- Alternatively, use the default Neovim terminal escape sequence: `<C-\><C-n>`

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

- [x] should work with native terminal when Snacks is not available
- [ ] option to autosave before running
- [ ] refactor terminal code to a separate module
- [ ] automatically scan and resolve runners for a given file extension
  - [ ] prompt to set or confirm runner when new filetype is encountered
- [x] native support for runner flags
- [x] better compiled language support
  - should be able to compile, show build result, and run with one command
- [ ] native command to toggle or undo chmod make executable

## Credits

- this plugin grew out of the custom keymap script I was using, which was in turn inspired by u/linkarzu script on [r/neovim](https://www.reddit.com/r/neovim/comments/1ai19ux/execute_current_file_script_using_a_keymap_i_use/)
