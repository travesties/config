return {
  'm4xshen/hardtime.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('hardtime').setup {}
  end,
}
