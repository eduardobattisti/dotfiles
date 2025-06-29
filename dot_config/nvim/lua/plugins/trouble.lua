return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    use_diagnostic_signs = true,
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
    -- You can customize more options here if needed
  },
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "LocationList" },
    { "<leader>xR", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP References" },
  },
}