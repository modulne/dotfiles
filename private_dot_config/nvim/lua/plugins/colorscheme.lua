return {
  {
    "sainnhe/everforest",
    lazy = false,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_enable_italic = true
      vim.g.everforest_transparent_background = 1
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
