vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.termguicolors = true -- Better color support
vim.opt.cursorline = true    -- Highlight the current line
vim.opt.scrolloff = 8        -- Keep cursor away from screen edge
vim.opt.signcolumn = "yes"   -- Always show sign column (prevents text shifting)

vim.g.netrw_liststyle = 3

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 150 }
  end,
})


-- lazy.nvim bootstrap (only needed once)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none",
    "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
vim.g.maplocalleader = "\\"

local status_ok, lazy = pcall(require, "lazy")
if status_ok then
  lazy.setup({
    spec = {
      { import = "plugins" }
    },
    install = {
      -- missing = true,
      -- colorscheme = "onenord"
    },
    checker = { enabled = true },
    change_detection = {
      enabled = true,
      notify = false,
    },
  })
end

vim.cmd [[highlight IblIndent guifg=#3B4252]]

-- Set transparent background
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight VertSplit guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
  highlight FloatNormal guibg=NONE
  highlight FloatBorder guibg=NONE
]])


vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = true })
  end,
})
-- Escape terminal mode back to normal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })


vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo windo wincmd =")
  end,
  desc = "Auto-resize tabs and windows when the screen is resized",
})
-- Custom Command:: Filetype
vim.api.nvim_create_user_command('Filetype', function()
  vim.cmd('echo "Filetype: ' .. vim.bo.filetype .. '"')
end, {})

vim.api.nvim_create_user_command('ToggleBufferline', function()
  if vim.o.showtabline == 2 then
    vim.o.showtabline = 0 -- hide bufferline
  else
    vim.o.showtabline = 2 -- show bufferline
  end
end, { desc = "Toggle bufferline (showtabline)" })

-- bind K to show LSP hover information
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover info' })

vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.diagnostic.config({
  virtual_text = {
    prefix = "■", -- ■ or any character you like
    spacing = 4, -- how many spaces between code and message
  },
  signs = true, -- show gutter signs
  underline = true, -- underline the problematic code
})
