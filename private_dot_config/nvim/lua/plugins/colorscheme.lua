return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard" -- soft, medium, hard
      vim.g.everforest_enable_italic = true
      vim.g.everforest_transparent_background = 1 -- 0=normal, 1=transparent, 2=full transparent
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
