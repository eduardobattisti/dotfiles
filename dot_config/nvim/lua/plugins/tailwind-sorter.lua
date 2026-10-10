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
    -- tailwind-sorter still calls `nvim-treesitter.parsers.get_parser`, which
    -- the nvim-treesitter `main` branch removed. Give it the core equivalent
    -- while it loads, without touching the real parsers module.
    local parsers = package.loaded["nvim-treesitter.parsers"]
    package.loaded["nvim-treesitter.parsers"] = {
      get_parser = function(bufnr)
        return vim.treesitter.get_parser(bufnr)
      end,
    }
    local ok, err = pcall(function()
      require("tailwind-sorter").setup(opts)
    end)
    package.loaded["nvim-treesitter.parsers"] = parsers
    if not ok then
      error(err)
    end
  end,
}