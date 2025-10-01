return {
  "vague2k/vague.nvim",
  priority = 1000, -- Load colorscheme first
  config = function()
    require("vague").setup({
      -- optional configuration here
    })
    vim.cmd.colorscheme("vague")
  end,
}