return {
  dir = vim.fn.expand("~/devstuff/projects/claude/claude-time-machine/nvim-plugin"),
  name = "claude-time-machine.nvim",
  lazy = false,  -- Load immediately
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("claude-time-machine").setup()
  end,
  keys = {
    { "<leader>ct", "<cmd>ClaudeTimeline<cr>", desc = "Claude Timeline" },
    { "<leader>cr", "<cmd>ClaudeRestore<cr>", desc = "Claude Restore" },
    { "<leader>cd", "<cmd>ClaudeDiff<cr>", desc = "Claude Diff" },
    { "<leader>cs", "<cmd>ClaudeSquash<cr>", desc = "Claude Squash" },
    { "<leader>cl", "<cmd>ClaudeLabel<cr>", desc = "Claude Label" },
  },
  cmd = {
    "ClaudeTimeline",
    "ClaudeRestore",
    "ClaudeDiff",
    "ClaudeSquash",
    "ClaudeLabel",
    "ClaudeStatus",
  },
}