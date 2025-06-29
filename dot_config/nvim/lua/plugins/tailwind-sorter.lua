return {
  "laytan/tailwind-sorter.nvim",
  ft = { "html", "css", "scss", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "php", "blade" },
  build = "cd formatter && npm install",
  opts = {
    on_save_enabled = false, -- set to true to sort classes on save
    on_save_pattern = { "*.html", "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.vue", "*.php", "*.blade.php" },
    node_path = "node",
  },
  keys = {
    {
      "<leader>ts",
      function()
        require("tailwind-sorter").sort()
      end,
      desc = "Sort Tailwind CSS classes",
      mode = "n",
    },
  },
  config = function(_, opts)
    require("tailwind-sorter").setup(opts)
  end,
}