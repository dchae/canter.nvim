-- Prevent loading multiple times
if vim.g.loaded_canter == 1 then
    return
end
vim.g.loaded_canter = 1

-- Require canter
require("canter").setup()
