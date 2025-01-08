-- Helper functions
-- recursive print table for debugging
local function printTable(tbl, indent)
   local dbg_msg = ""
   indent = indent or 0
   for key, value in pairs(tbl) do
      local spacing = string.rep("  ", indent)
      if type(value) == "table" then
         dbg_msg = spacing .. key .. ":"
         print(dbg_msg)
         printTable(value, indent + 1)
      else
         dbg_msg = spacing .. key .. ": " .. tostring(value)
         print(dbg_msg)
      end
   end
end

local function get_current_file_path()
   local filepath = vim.fn.expand("%:p:.") -- Get the current filepath, relative to current dir if possible
   return filepath
end

local function get_shebang()
   local first_line = vim.fn.getline(1)
   if string.match(first_line, "^#!/") then -- If first line starts with shebang (e.g. #!/usr/bin/env node)
      return first_line
   end
   return nil
end

local function build_command(filepath, shebang, opts)
   local safe_filepath = vim.fn.shellescape(filepath)
   local file_extension = vim.fn.fnamemodify(filepath, ":e")
   -- local file_extension = vim.fn.expand("%:e")
   local runner = opts.runners[file_extension] -- Get runner
   local cmd = nil

   if shebang then
      if string.match(filepath, "^/") then
         cmd = safe_filepath
      else -- if filepath is relative add "./"
         cmd = "./" .. safe_filepath
      end
   elseif runner then -- if we have a valid runner for the filetype
      cmd = runner .. " " .. safe_filepath -- Runner and filepath (e.g. "node script.js")
   end

   return cmd
end

local function execute_command(cmd, wait, opts)
   if wait then
      Snacks.terminal.open()
      vim.cmd("startinsert")
      vim.api.nvim_input(cmd)
   else
      Snacks.terminal(cmd, opts.Snacks_terminal_opts)
      vim.cmd("startinsert")
   end
end

---@param runImmediately (boolean)
---@param opts (table)
local function run_current_file(runImmediately, opts)
   local wait = not runImmediately -- refactor this

   local filepath = get_current_file_path()
   local shebang = get_shebang()
   local cmd = build_command(filepath, shebang, opts)

   if not cmd then
      local error_msg =
         "Error (Canter): Could not resolve runner or shebang line.\nTry adding a runner for this filetype to your config opts."
      vim.api.nvim_echo({ { error_msg, "ErrorMsg" } }, true, {})
      return
   end

   if shebang then
      vim.cmd("!chmod +x " .. filepath) -- Make the file executable
   end

   execute_command(cmd, wait, opts)
end

local default_opts = { -- default options
   runners = {},
   Snacks_terminal_opts = {
      win = {
         position = "bottom",
         relative = "editor",
      },
      interactive = false,
   },
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

local M = {}

---@param user_opts (table | nil)
function M.setup(user_opts)
   user_opts = user_opts or {}
   -- merge user opts with defaults
   local opts = vim.tbl_deep_extend("force", default_opts, user_opts)

   local function run_current_file_auto()
      run_current_file(true, opts)
   end
   local function run_current_file_wait()
      run_current_file(false, opts)
   end

   -- Add keymaps if configured
   if opts.keymaps then
      for key, mapping in pairs(opts.keymaps) do
         vim.keymap.set("n", key, mapping.cmd, {
            desc = mapping.desc,
            silent = true,
         })
      end
   end

   -- Register which-key group
   local ok, wk = pcall(require, "which-key")
   if ok then
      wk.add({
         { "<leader><cr>", group = "Canter (run code)" },
      })
   end

   local commands = {
      CanterRun = run_current_file_auto,
      CanterWait = run_current_file_wait,
   }

   for cmd, fn in pairs(commands) do
      vim.api.nvim_create_user_command(cmd, fn, {
         nargs = 0,
      })
   end
end

return M
