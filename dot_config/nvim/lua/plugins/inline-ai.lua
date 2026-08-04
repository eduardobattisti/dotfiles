local provider = (vim.env.NVIM_AI_PROVIDER or 'none'):lower()
local auto_trigger_values = {
  ['1'] = true,
  ['on'] = true,
  ['true'] = true,
  ['yes'] = true,
}
local auto_trigger = auto_trigger_values[(vim.env.NVIM_AI_AUTO_TRIGGER or ''):lower()] or false

local minuet_providers = {
  claude = true,
  codestral = true,
  gemini = true,
  ollama = true,
  openai = true,
  openai_compatible = true,
  openai_fim_compatible = true,
}

local supported = provider == 'none' or minuet_providers[provider]
if not supported then
  vim.schedule(function()
    vim.notify(
      ('Unknown NVIM_AI_PROVIDER %q; inline AI is disabled'):format(provider),
      vim.log.levels.WARN
    )
  end)
  provider = 'none'
end

local function optional_env(name)
  local value = vim.env[name]
  return value ~= nil and value ~= '' and value or nil
end

local function minuet_options()
  local selected_provider = provider
  local options = {}

  if provider == 'ollama' then
    selected_provider = 'openai_fim_compatible'
    options = {
      api_key = function()
        return 'ollama'
      end,
      name = optional_env 'NVIM_AI_PROVIDER_NAME' or 'Ollama',
      end_point = optional_env 'NVIM_AI_ENDPOINT' or 'http://localhost:11434/v1/completions',
      model = optional_env 'NVIM_AI_MODEL' or 'qwen2.5-coder:7b',
      optional = {
        max_tokens = 256,
        top_p = 0.9,
      },
    }
  else
    local api_key_env = optional_env 'NVIM_AI_API_KEY_ENV'
    if api_key_env then
      options.api_key = api_key_env
    end

    options.model = optional_env 'NVIM_AI_MODEL'
    options.end_point = optional_env 'NVIM_AI_ENDPOINT'
    options.name = optional_env 'NVIM_AI_PROVIDER_NAME'
  end

  return {
    provider = selected_provider,
    request_timeout = 3,
    throttle = 1000,
    debounce = 400,
    provider_options = {
      [selected_provider] = options,
    },
    virtualtext = {
      auto_trigger_ft = auto_trigger and { '*' } or {},
      auto_trigger_ignore_ft = { 'gitcommit', 'gitrebase', 'help', 'markdown' },
      keymap = {
        accept = '<M-l>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },
  }
end

return {
  {
    'milanglacier/minuet-ai.nvim',
    cond = minuet_providers[provider] == true,
    event = 'InsertEnter',
    cmd = 'Minuet',
    opts = minuet_options,
  },
}
