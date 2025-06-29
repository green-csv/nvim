return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = { enabled = true },
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end,                 desc = "Smart Find Files" },
      { "<leader>,",       function() Snacks.picker.buffers() end,               desc = "Buffers" },
      { "<leader>/",       function() Snacks.picker.grep() end,                  desc = "Grep" },
      { "<leader>:",       function() Snacks.picker.command_history() end,       desc = "Command History" },
      { "<leader>n",       function() Snacks.picker.notifications() end,         desc = "Notification History" },
      { "<leader>e",       function() Snacks.explorer() end,                     desc = "File Explorer" },
      --Git
      { "<leader>gb",      function() Snacks.picker.git_branches() end,          desc = "Git Branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,               desc = "Git Log" },
      { "<leader>gL",      function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,            desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
      { "<leader>gd",      function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
      { "<leader>gf",      function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },
      --LazyGit
      { "<leader>gg",      function() Snacks.lazygit() end,                      desc = "Lazygit" },
      -- LSP
      { "gd",              function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
      { "gD",              function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
      { "gr",              function() Snacks.picker.lsp_references() end,        nowait = true,                     desc = "References" },
      { "gI",              function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
      { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
      { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      -- Other
      { "<leader>z",       function() Snacks.zen() end,                          desc = "Toggle Zen Mode" },
      { "<leader>Z",       function() Snacks.zen.zoom() end,                     desc = "Toggle Zoom" },
      { "<leader>.",       function() Snacks.scratch() end,                      desc = "Toggle Scratch Buffer" },
      { "<leader>S",       function() Snacks.scratch.select() end,               desc = "Select Scratch Buffer" },
      { "<leader>n",       function() Snacks.notifier.show_history() end,        desc = "Notification History" },
      { "<leader>bd",      function() Snacks.bufdelete() end,                    desc = "Delete Buffer" },
      { "<leader>cR",      function() Snacks.rename.rename_file() end,           desc = "Rename File" },
      { "<leader>gB",      function() Snacks.gitbrowse() end,                    desc = "Git Browse",               mode = { "n", "v" } },
      { "<leader>un",      function() Snacks.notifier.hide() end,                desc = "Dismiss All Notifications" },
      { "<c-/>",           function() Snacks.terminal() end,                     desc = "Toggle Terminal" },
      { "<c-_>",           function() Snacks.terminal() end,                     desc = "which_key_ignore" },
      { "]]",              function() Snacks.words.jump(vim.v.count1) end,       desc = "Next Reference",           mode = { "n", "t" } },
      { "[[",              function() Snacks.words.jump(-vim.v.count1) end,      desc = "Prev Reference",           mode = { "n", "t" } },
    }
  },
}
