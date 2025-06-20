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

vim.g.mapleader = ' '

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 150 }
  end,
})

-- lazy.nvim bootstrap (only needed once)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)



local status_ok, lazy = pcall(require, "lazy")
if status_ok then
  lazy.setup({
    {
      "nvimdev/dashboard-nvim",
      event = "VimEnter",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope.nvim",
        "ahmedkhalf/project.nvim",
      },
      config = function()
        require("project_nvim").setup({
          detection_methods = { "lsp", "pattern" },
          patterns = { ".git", "package.json", "Makefile" },
          silent_chdir = false,
        })
        -- then load the Telescope extension
        require("telescope").load_extension("projects")

        require("dashboard").setup({
          theme = "hyper",
          config = {
            week_header = { enable = true },
            shortcut = {
              { desc = "󰊳 Update", group = "Function", action = "Lazy update", key = "u" },
              { desc = " Files", group = "Label", action = "Telescope find_files", key = "f" },
              { desc = " Projects", group = "DiagnosticHint", action = "Telescope projects", key = "p" },
            },
          },
        })
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.5",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "ahmedkhalf/project.nvim",
        "nvim-telescope/telescope-frecency.nvim",
        "debugloop/telescope-undo.nvim",
      },
      config = function()
        require("project_nvim").setup({
          detection_methods = { "lsp", "pattern" },
          patterns = { ".git", "package.json", "Makefile" },
          silent_chdir = false,
        })

        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git/" },
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<C-d>"] = require("telescope.actions")
                    .delete_buffer,
              },
              n = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<C-d>"] = require("telescope.actions")
                    .delete_buffer,
              },
            },
            vimgrep_arguments = {
              'rg',
              '--color=never',
              '--no-heading',
              '--with-filename',
              '--line-number',
              '--column',
              '--smart-case',
              '--hidden',
              '--glob', '!.git/*'
            },
          },
          pickers = {
            oldfiles = {
              cwd_only = true,
            },
            live_grep = {
              additional_args = function()
                return { "--hidden", "--glob", "!**/.git/*" }
              end,
            },
          },
          extensions = {
            frecency = {
              show_scores = true,
              show_unindexed = false,
              ignore_patterns = { "*.git/*", "*/tmp/*" },
            },
          },
        })
        telescope.load_extension("frecency")
        telescope.load_extension("undo")
        telescope.load_extension("projects")

        local builtin = require("telescope.builtin")
        local extensions = telescope.extensions

        vim.keymap.set("n", "<leader>ff", function()
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          local conf = require("telescope.config").values
          local builtin = require("telescope.builtin")
          local extensions = require("telescope").extensions

          pickers.new({}, {
            prompt_title = "Recent & Frecency",
            finder = finders.new_table({
              results = {
                { "Recent Files", "oldfiles" },
                { "Frecency",     "frecency" },
              },
              entry_maker = function(entry)
                return {
                  value = entry[2],
                  display = entry[1],
                  ordinal = entry[1],
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state
                    .get_selected_entry()
                actions.close(prompt_bufnr)
                if selection.value == "oldfiles" then
                  builtin.oldfiles()
                elseif selection.value == "frecency" then
                  extensions.frecency.frecency()
                end
              end)
              return true
            end,
          }):find()
        end, { desc = "Recent Files & Frecency" })

        vim.keymap.set("n", "<leader>fg", builtin.live_grep,
          { desc = "Search text (grep)" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers,
          { desc = "Open buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags,
          { desc = "Search help tags" })
      end,
    },
    {
      "S1M0N38/love2d.nvim",
      event = "VeryLazy",
      opts = {
        restart_on_save = true,
        debug_window_opts = {
          split = "below"
        }
      },
    },
    { -- core LSP
      "neovim/nvim-lspconfig",
      dependencies = {
        "mason.nvim",
        { "mason-org/mason-lspconfig.nvim", config = function() end },
      },
      opts = function()
        local ret = {
          inlay_hints = {
            enable = true
          }
        }
        return ret
      end, -- keep your other opts here
      config = function()
        local lsp = require("lspconfig")
        local cmp_caps = require("cmp_nvim_lsp").default_capabilities()
        local function on_attach(client, bufnr)
          -- keep your inlay-hint toggle
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
          -- omnifunc: <C-x><C-o>
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
        ---------------------------------------------------------------------------
        -- 1.  tsserver  – TypeScript, TSX, JavaScript
        ---------------------------------------------------------------------------
        lsp.vtsls.setup({
          capabilities = cmp_caps,
          on_attach = on_attach,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints                        = "all", -- "none"|"literals"|"all"
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints                = true,
                includeInlayVariableTypeHints                         = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName      = false,
                includeInlayPropertyDeclarationTypeHints              = true,
                includeInlayFunctionLikeReturnTypeHints               = true,
                includeInlayEnumMemberValueHints                      = true,
              },
            },
            javascript = { -- same switches for *.js, *.jsx
              inlayHints = vim.deepcopy(
                require("lspconfig.util").ts
                .inlay_hints_default -- clone above table
              ),
            },
          },
        })
        ---------------------------------------------------------------------------
        -- 2.  lua-ls  – Lua files
        ---------------------------------------------------------------------------
        lsp.lua_ls.setup({
          capabilities = cmp_caps,
          on_attach = on_attach,
          settings = {
            Lua = {
              hint = {                  -- lua-ls inlay block  [oai_citation:2‡github.com](https://github.com/josa42/coc-lua?utm_source=chatgpt.com)
                enable     = true,      -- master switch
                arrayIndex = "Auto",    -- "Auto"|"Disable"|"Enable"
                await      = true,      -- show `await` where needed
                paramName  = "All",     -- "Disable"|"All"|"Literal"
                paramType  = true,      -- show param types
                semicolon  = "Disable", -- virtual ‘;’ hints
                setType    = true,      -- show type at assignments
              },
            },
          },
        })
      end,
    },
    {
      "ahmedkhalf/project.nvim",
      dependencies = { "nvim-telescope/telescope.nvim" },
      config = function()
        require("project_nvim").setup({
          -- detect projects based on git root or LSP workspace
          detection_methods = { "lsp", "pattern" },
          -- patterns to identify project root
          patterns = { ".git", "package.json", "Makefile", "Jusfile" },
          -- don’t change your cwd automatically
          silent_chdir = false,
          -- scope: workspace (false) vs global (true)
          scope_chdir = nil,
        })
        -- register the extension with Telescope
        require("telescope").load_extension("projects")
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          window = {
            ["<C-v>"] = function(state)
              local node = state.tree:get_node()
              if node and node.path then
                vim.cmd("vsplit " ..
                  vim.fn.fnameescape(node.path))
                require("neo-tree.command").execute({
                  action =
                  "close"
                }) -- optional auto-close tree
              end
            end,
            position = "float",
          },
          filesystem = {
            follow_current_file = { enabled = true },
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
            },
            use_libuv_file_watcher = true,
          },
          default_component_configs = {
            preview = {
              use_float = false, -- keep preview inside the main window
            },
          },
          event_handlers = {
            {
              event = "file_opened",
              handler = function()
                require("neo-tree.command").execute({
                  action =
                  "close"
                })
              end,
            },
          },

        })

        vim.keymap.set("n", "<leader>e", function()
          require("neo-tree.command").execute({
            toggle = true,
            reveal = true,
            dir = vim.uv.cwd(),
          })
        end, { desc = " Neo-tree (toggle & reveal current file)" })
      end,
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        {
          "folke/lazydev.nvim",
          ft = "lua", -- only load on lua files
          opts = {
            library = {
              { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
          },
        },
      },
      config = function()
        require('lspconfig').lua_ls.setup {}
      end
    },
    {
      "rmehri01/onenord.nvim",
      priority = 1000, -- load early
      config = function()
        require("onenord").setup({
          borders = true,
          fade_nc = false,
          disable = {
            background = true, -- transparent background
          },
        })
        vim.cmd("colorscheme onenord")
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-refactor"
      },
      branch = 'master',
      lazy = false,
      build = ":TSUpdate",
      opts = {
        highlight = { enable = true },
        refactor = {
          highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true,
          },
          highlight_current_scope = { enable = true },
          smart_rename = {
            enable = true,
            keymaps = {
              smart_rename = "grr",
            }
          },
          navigation = {
            enable = true,
            keymaps = {
              goto_definition      = "gnd", -- go to definition of symbol [oai_citation:22‡github.com](https://github.com/nvim-treesitter/nvim-treesitter-refactor#:~:text=false%60.%20keymaps%20%3D%20,)
              list_definitions     = "gnD", -- list all definitions in file
              list_definitions_toc = "gO",  -- list definitions in a TOC (quickfix)
              goto_next_usage      = "<a-*>",
              goto_previous_usage  = "<a-#>",
            }
          }
        }
        -- ... other options ...
      }
    },
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate",
      config = function()
        require("mason").setup()
      end,
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = {
            theme = "onenord",
            section_separators = "",
            component_separators = "",
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch" },
            lualine_c = { "filename" }, -- keep only the file name here
            lualine_x = {},             -- ← remove the filetype component
            lualine_y = {},
            lualine_z = { "location" },
          },
        })
      end,
    },
    {
      "folke/which-key.nvim",
      config = function()
        require("which-key").setup({})
      end,
    },
    {
      "gpanders/editorconfig.nvim"
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      config = function()
        require("ibl").setup({
          indent = {
            char = "┊", -- You can change to "▏", "┊", or "┆"
          },
          scope = {
            enabled = true,
            show_start = false,
            show_end = false,
          },
          exclude = {
            filetypes = {
              "alpha",          -- dashboard.nvim’s filetype
              "dashboard",      -- older variants
              "neo-tree",       -- Neo-tree sidebar
              "TelescopePrompt" -- Telescope’s prompt window
            },
          },
        })
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "L3MON4D3/LuaSnip",         -- snippets engine
        "saadparwaiz1/cmp_luasnip", -- snippet source
        "hrsh7th/cmp-nvim-lsp",     -- LSP source
        "hrsh7th/cmp-buffer",       -- words in open buffers
        "hrsh7th/cmp-path",         -- filesystem paths
        "windwp/nvim-autopairs",    -- you already have it
      },
      config = function()
        local cmp = require("cmp")

        cmp.setup({
          completion = { completeopt = "menu,menuone,noinsert" },
          snippet = {
            expand = function(args) require("luasnip").lsp_expand(args.body) end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"]     = cmp.mapping.select_next_item(),         -- cycle
            ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
            ["<CR>"]      = cmp.mapping.confirm({ select = true }), -- accept
            ["<C-Space>"] = cmp.mapping.complete(),                 -- force menu
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }, {
            { name = "buffer" },
            { name = "path" },
          }),
        })

        require("nvim-autopairs").setup {}
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "nvim-telescope/telescope.nvim",
      },
      config = function()
        local neogit = require("neogit")
        neogit.setup {}
      end,
    },
    {
      "akinsho/bufferline.nvim",
      version = "*",
      enabled = false,
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("bufferline").setup({
          options = {
            numbers = "buffer_id",
            mode = "buffers",
            diagnostics = "nvim_lsp",
            show_buffer_close_icons = false,
            show_close_icon = false,
            separator_style = "thin",
            max_name_length = 200, -- Set a high limit for name display
            max_prefix_length = 30,
            tab_size = 30,
            truncate_names = false,
          },
        })

        vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>",
          { desc = "Next buffer" })
        vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>",
          { desc = "Previous buffer" })
      end,
    },
    {
      "folke/persistence.nvim",
      event = "BufReadPre", -- load before opening files
      config = function()
        require("persistence").setup({
          dir = vim.fn.stdpath("state") .. "/sessions/",            -- default
          options = { "buffers", "curdir", "tabpages", "winsize" }, -- restore settings
        })

        -- Keymaps
        local persistence = require("persistence")

        vim.keymap.set("n", "<leader>qs",
          function() persistence.load() end, {
            desc = "Restore session for current dir"
          })

        vim.keymap.set("n", "<leader>ql",
          function() persistence.load_last() end,
          {
            desc = "Restore last session"
          })

        vim.keymap.set("n", "<leader>qd",
          function() persistence.stop() end, {
            desc = "Don't save session for this dir"
          })
      end,
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


vim.keymap.set("n", "<leader>T", function()
  local cwd = vim.fn.getcwd()
  vim.cmd("tabnew")
  vim.cmd("lcd " .. cwd)
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Open terminal in new tab" })


-- Escape terminal mode back to normal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Toggle between open splits/panes (you already have this)

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right pane" })


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
  local buf = vim.api.nvim_get_current_buf()
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
