return {
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
    opts = {},
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },
  {
    "gpanders/editorconfig.nvim"
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  }
}
