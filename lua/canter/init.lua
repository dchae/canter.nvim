-- Helper functions
local function get_current_file_path()
    local filepath = vim.fn.expand("%:p:.") -- Get the current filepath, relative to current dir if possible
    return vim.fn.shellescape(filepath)
end

---@param runImmediately (boolean)
---@param opts (table)
local function run_current_file(runImmediately, opts)
    local filepath = get_current_file_path()
    local file_extension = vim.fn.expand("%:e")
    local first_line = vim.fn.getline(1)

    local runners = opts.runners
    local snacks_opts = opts.Snacks_terminal_opts

    if string.match(first_line, "^#!/") then -- If first line starts with shebang (e.g. #!/usr/bin/env node)
        vim.cmd("!chmod +x " .. filepath) -- Make the file executable

        if not string.match(filepath, "/") then -- if filepath is relative add "./"
            filepath = "./" .. filepath
        end

        if runImmediately then
            Snacks.terminal(filepath, snacks_opts)
            vim.cmd("startinsert")
        else
            Snacks.terminal.open()
            vim.cmd("startinsert")
            vim.api.nvim_input(filepath)
        end
    elseif runners[file_extension] then -- if we have a valid runner for the filetype
        local runner = runners[file_extension] -- Get runner
        local cmd = runner .. " " .. filepath -- Runner and filepath (e.g. node script.js)
        if runImmediately then
            Snacks.terminal(cmd, snacks_opts)
            vim.cmd("startinsert")
        else
            Snacks.terminal.open()
            vim.cmd("startinsert")
            vim.api.nvim_input(cmd)
        end
    else
        vim.cmd("echo 'Error: Could not resolve interpreter or find shebang line.'")
    end
end

local default_opts = { -- default options
    runners = {},
    Snacks_terminal_opts = {
        win = {
            position = "bottom",
            relative = "editor"
        },
        interactive = false
    },
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

local M = {}

---@param user_opts (table | nil)
function M.setup(user_opts)
    user_opts = user_opts or {}
    local opts = vim.tbl_deep_extend("force", default_opts, user_opts)

    local function run_current_file_auto()
        run_current_file(true, opts) -- Pass the entire opts table, not just runners
    end
    local function run_current_file_wait()
        run_current_file(false, opts) -- Pass the entire opts table, not just runners
    end

    -- Add keymaps if configured
    if opts.keymaps then
        for key, mapping in pairs(opts.keymaps) do
            vim.keymap.set('n', key, mapping.cmd, {
                desc = mapping.desc,
                silent = true
            })
        end
    end

    -- Register which-key group
    local ok, wk = pcall(require, "which-key")
    if ok then
        wk.add({{
            "<leader><cr>",
            group = "Canter (run code)"
        }})
    end

    local commands = {
        CanterRun = run_current_file_auto,
        CanterWait = run_current_file_wait
    }

    for cmd, fn in pairs(commands) do
        vim.api.nvim_create_user_command(cmd, fn, {
            nargs = 0
        })
    end
end

return M
