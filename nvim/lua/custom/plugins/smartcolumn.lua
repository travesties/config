return {
  'm4xshen/smartcolumn.nvim',
  config = function()
    require('smartcolumn').setup {
      colorcolumn = '88',
      scope = 'line',
      disabled_filetypes = {
        'help',
        'text',
        'markdown',
        'NvimTree',
        'lazy',
        'mason',
        'help',
        'checkhealth',
        'lspinfo',
        'noice',
        'Trouble',
        'startup',
      },
    }
  end,
}
