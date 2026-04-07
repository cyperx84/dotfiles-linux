return {
  "rcarriga/nvim-notify",
  keys = {
    { '<leader>sl', '<cmd>Telescope notify<CR>', desc = '[S]earch Notify [L]og' },
  },
  config = function()
    require("notify").setup({
      background_colour = "#000000",
      stages = "fade_in_slide_out",
      timeout = 50,
      fps = 60,
      render = "compact",
    })
    vim.notify = require("notify")
  end,
}
