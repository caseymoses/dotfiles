return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>",          desc = "Git [D]iff (all changes)" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>",          desc = "Git diff [C]lose" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",  desc = "Git file [H]istory" },
  },
}
