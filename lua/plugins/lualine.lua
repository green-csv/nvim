local mode_map = {
  ['NORMAL'] = 'N',
  ['INSERT'] = 'I',
  ['VISUAL'] = 'V',
  ['V-LINE'] = 'VL',
  ['V-BLOCK'] = 'VB',
  ['REPLACE'] = 'R',
  ['COMMAND'] = 'C',
  ['TERMINAL'] = 'T',
}

local function short_mode(mode)
  return mode_map[mode] or mode:sub(1, 1)
end

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
    },
    config = function(_, opts)
      local options = vim.tbl_deep_extend("force", {
        sections = {
          lualine_a = { { 'mode', fmt = short_mode } },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        }
      }, opts or {})
      require("lualine").setup(options)
    end

  }
}
