return {
  {
    'adalessa/laravel.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
    },
    ft = { 'php', 'blade' },
    event = { 'BufEnter composer.json' },
    keys = {
      { '<leader>Ll', function() Laravel.pickers.laravel() end, desc = 'Laravel: Picker' },
      { '<leader>La', function() Laravel.pickers.artisan() end, desc = 'Laravel: Artisan' },
      { '<leader>Lr', function() Laravel.pickers.routes() end, desc = 'Laravel: Routes' },
      { '<leader>Lm', function() Laravel.pickers.make() end, desc = 'Laravel: Make' },
      { '<leader>Lc', function() Laravel.pickers.commands() end, desc = 'Laravel: Commands' },
      { '<leader>Lo', function() Laravel.pickers.resources() end, desc = 'Laravel: Resources' },
      { '<leader>Lt', function() Laravel.commands.run 'actions' end, desc = 'Laravel: Code actions' },
      { '<leader>Lu', function() Laravel.commands.run 'hub' end, desc = 'Laravel: Artisan Hub' },
      { '<leader>Lp', function() Laravel.commands.run 'command_center' end, desc = 'Laravel: Command center' },
      { '<leader>Lh', function() Laravel.run 'artisan docs' end, desc = 'Laravel: Documentation' },
      { '<leader>Lv', function() Laravel.commands.run 'view:finder' end, desc = 'Laravel: View finder' },
    },
    opts = {
      features = {
        pickers = {
          provider = 'telescope',
        },
      },
      -- Generates typed Eloquent helpers under vendor/ so Intelephense can
      -- understand model/query-builder chains that Laravel creates at runtime.
      eloquent_generate_doc_blocks = true,
    },
  },
  {
    'ricardoramirezr/blade-nav.nvim',
    ft = { 'blade', 'php' },
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {},
  },
}
