--x = {A} * e ^ -x
return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope.nvim",
      "ahmedkhalf/project.nvim",
    },
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "package.json", "Makefile" },
      silent_chdir = false,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
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
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
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
          live_grep = {
            additional_args = function()
              return { "--hidden", "--glob", "!**/.git/*" }
            end,
          },
        },
        extensions = {
          fzf = {},
          frecency = {
            show_scores = true,
            show_unindexed = false,
            ignore_patterns = { "*.git/*", "*/tmp/*" },
          },
        },
      })
      telescope.load_extension("projects")

      local builtin = require("telescope.builtin")

      require("telescope").load_extension("fzf")

      vim.keymap.set("n", "<leader>ff", builtin.find_files, {
        desc = "find_files"
      })

      vim.keymap.set("n", "<leader>fg", builtin.live_grep,
        { desc = "live_grep" })

      vim.keymap.set("n", "<leader>fb", builtin.buffers,
        { desc = "buffers" })

      vim.keymap.set("n", "<leader>fh", builtin.help_tags,
        { desc = "help_tags" })

      vim.keymap.set("n", "<leader>en", function()
        require("telescope.builtin").find_files {
          cwd = vim.fn.stdpath("config")
        }
      end, { desc = "find_files.config" })

      vim.keymap.set("n", "<leader>ep", function()
        require("telescope.builtin").find_files {
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
        }
      end, { desc = "find_files.data" })
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
      end, { desc = " Neo-tree" })
    end,
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
            goto_definition      = "gnd",
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
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = {

      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategy = {
        [''] = 'rainbow-delimiters.strategy.global',
        vim = 'rainbow-delimiters.strategy.local',
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      priority = {
        [''] = 110,
        lua = 210,
      },
      highlight = {
        'RainbowDelimiterYellow', -- darkest
        'RainbowDelimiterViolet',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterCyan',
        'RainbowDelimiterYellow', -- lightest
      },
    },
    config = function(_, opts)
      require('rainbow-delimiters.setup').setup(opts)
    end
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
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      disable_hint = false,
      graph_style = "ascii"
    },
    config = function(_, opts)
      local neogit = require("neogit")
      neogit.setup(opts)
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    enabled = true,
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
    end,
  },
}
