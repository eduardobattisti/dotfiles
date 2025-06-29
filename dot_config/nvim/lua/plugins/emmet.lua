return {
  "mattn/emmet-vim",
  ft = { "html", "css", "javascriptreact", "typescriptreact", "vue", "php" },
  config = function()
    vim.g.user_emmet_leader_key = "<C-y>"
    vim.g.user_emmet_settings = {
      javascript = {
        extends = "jsx",
      },
      typescript = {
        extends = "jsx",
      },
    }
    -- Optional: Enable Emmet in PHP files (for embedded HTML)
    vim.g.user_emmet_install_global = 0
    vim.cmd [[
      autocmd FileType html,css,javascriptreact,typescriptreact,vue,php EmmetInstall
    ]]
  end,
}
