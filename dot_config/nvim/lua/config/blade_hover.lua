local M = {}

-- Blade directives are template grammar, not PHP symbols, so no PHP language
-- server can document them. Keep concise, useful help here and delegate every
-- other cursor position to BladeNav/LSP (including otter's projected PHP).
local directives = {
  ['@auth'] = { '@auth([guard])', 'Render when the current user is authenticated.' },
  ['@can'] = { '@can(ability[, arguments])', 'Render when the current user is authorized for the given ability.' },
  ['@cannot'] = { '@cannot(ability[, arguments])', 'Render when the current user is not authorized for the given ability.' },
  ['@canany'] = { '@canany(abilities[, arguments])', 'Render when the user is authorized for at least one listed ability.' },
  ['@checked'] = { '@checked(condition)', 'Print `checked` when the condition is true.' },
  ['@class'] = { '@class([classes])', 'Build a conditional HTML class attribute from an array.' },
  ['@component'] = { '@component(view[, data])', 'Render a class-based or anonymous Blade component.' },
  ['@csrf'] = { '@csrf', 'Insert a hidden CSRF token field in an HTML form.' },
  ['@each'] = { '@each(view, items, item[, emptyView])', 'Render a view once for every item in a collection.' },
  ['@else'] = { '@else', 'Render the alternative branch of a conditional block.' },
  ['@elseif'] = { '@elseif(condition)', 'Add another conditional branch to an `@if` block.' },
  ['@empty'] = { '@empty(value)', 'Render when a value is empty. Also marks the empty branch of `@forelse`.' },
  ['@endauth'] = { '@endauth', 'Close an `@auth` block.' },
  ['@endcan'] = { '@endcan', 'Close an `@can` block.' },
  ['@endcanany'] = { '@endcanany', 'Close an `@canany` block.' },
  ['@endcannot'] = { '@endcannot', 'Close an `@cannot` block.' },
  ['@endcomponent'] = { '@endcomponent', 'Close an `@component` block.' },
  ['@endempty'] = { '@endempty', 'Close an `@empty` block.' },
  ['@endenv'] = { '@endenv', 'Close an `@env` block.' },
  ['@endforeach'] = { '@endforeach', 'Close a `@foreach` loop.' },
  ['@endforelse'] = { '@endforelse', 'Close a `@forelse` loop.' },
  ['@endfor'] = { '@endfor', 'Close a `@for` loop.' },
  ['@endguest'] = { '@endguest', 'Close a `@guest` block.' },
  ['@endif'] = { '@endif', 'Close an `@if` block.' },
  ['@endisset'] = { '@endisset', 'Close an `@isset` block.' },
  ['@endproduction'] = { '@endproduction', 'Close a `@production` block.' },
  ['@endpush'] = { '@endpush', 'Close a `@push` block.' },
  ['@endsection'] = { '@endsection', 'Close a `@section` block.' },
  ['@endsession'] = { '@endsession', 'Close a `@session` block.' },
  ['@endslot'] = { '@endslot', 'Close a named component slot.' },
  ['@endswitch'] = { '@endswitch', 'Close a `@switch` block.' },
  ['@endunless'] = { '@endunless', 'Close an `@unless` block.' },
  ['@endverbatim'] = { '@endverbatim', 'Close a block whose contents Blade must not compile.' },
  ['@endwhile'] = { '@endwhile', 'Close a `@while` loop.' },
  ['@env'] = { '@env(environment|environments)', 'Render only in one or more application environments.' },
  ['@error'] = { '@error(field)', 'Render when a validation error exists for the given field.' },
  ['@extends'] = { '@extends(view)', 'Declare the layout inherited by this view.' },
  ['@for'] = { '@for(initialization; condition; iteration)', 'Render a standard PHP `for` loop.' },
  ['@foreach'] = { '@foreach(iterable as value)', 'Render once per item. The `$loop` variable is available inside.' },
  ['@forelse'] = { '@forelse(iterable as value)', 'Iterate items and provide an `@empty` branch for an empty iterable.' },
  ['@guest'] = { '@guest([guard])', 'Render when the current user is not authenticated.' },
  ['@if'] = { '@if(condition)', 'Render the block when the PHP expression is truthy.' },
  ['@include'] = { '@include(view[, data])', 'Include another Blade view and inherit the current variables.' },
  ['@includeIf'] = { '@includeIf(view[, data])', 'Include a view only when it exists.' },
  ['@includeWhen'] = { '@includeWhen(condition, view[, data])', 'Include a view when the condition is true.' },
  ['@includeUnless'] = { '@includeUnless(condition, view[, data])', 'Include a view unless the condition is true.' },
  ['@isset'] = { '@isset(value)', 'Render when a value is defined and is not `null`.' },
  ['@json'] = { '@json(value[, flags[, depth]])', 'Encode a value as JSON for output.' },
  ['@method'] = { '@method(method)', 'Insert the hidden HTTP method field used by HTML forms.' },
  ['@once'] = { '@once', 'Render the enclosed content only once per rendering cycle.' },
  ['@production'] = { '@production', 'Render only in the production environment.' },
  ['@props'] = { '@props([defaults])', 'Declare the data attributes accepted by an anonymous component.' },
  ['@push'] = { '@push(stack)', 'Append content to a named layout stack.' },
  ['@pushIf'] = { '@pushIf(condition, stack)', 'Append content to a stack when the condition is true.' },
  ['@selected'] = { '@selected(condition)', 'Print `selected` when the condition is true.' },
  ['@section'] = { '@section(name[, content])', 'Define content for a named layout section.' },
  ['@session'] = { '@session(key)', 'Render when a value exists in the session and expose it as `$value`.' },
  ['@show'] = { '@show', 'Close a section and immediately yield it.' },
  ['@slot'] = { '@slot(name[, attributes])', 'Define a named component slot.' },
  ['@stack'] = { '@stack(name)', 'Render all content pushed onto a named stack.' },
  ['@style'] = { '@style([styles])', 'Build a conditional inline style attribute from an array.' },
  ['@switch'] = { '@switch(expression)', 'Start a switch statement; use `@case`, `@break`, and `@default`.' },
  ['@unless'] = { '@unless(condition)', 'Render the block when the PHP expression is falsy.' },
  ['@verbatim'] = { '@verbatim', 'Prevent Blade from compiling the enclosed template text.' },
  ['@vite'] = { '@vite(entrypoints[, buildDirectory])', 'Load Vite development assets or versioned production assets.' },
  ['@viteReactRefresh'] = { '@viteReactRefresh', 'Inject the React refresh runtime before `@vite` in development.' },
  ['@while'] = { '@while(condition)', 'Render a standard PHP `while` loop.' },
  ['@yield'] = { '@yield(section[, default])', 'Display a named layout section.' },
}

local function directive_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local from = 1

  while true do
    local first, last = line:find('@[%a_][%w_]*', from)
    if not first then
      return nil
    end
    if cursor_col >= first and cursor_col <= last then
      return line:sub(first, last)
    end
    from = last + 1
  end
end

local function show_directive_help(name, help)
  local lines = {
    '```blade',
    help[1],
    '```',
    '',
    help[2],
    '',
    '[Laravel Blade documentation](https://laravel.com/docs/blade)',
  }
  vim.lsp.util.open_floating_preview(lines, 'markdown', {
    border = 'rounded',
    focus_id = 'blade-directive-hover',
  })
end

function M.hover()
  if vim.bo.filetype == 'blade' then
    local name = directive_at_cursor()
    local help = name and directives[name]
    if help then
      show_directive_help(name, help)
      return
    end

    -- BladeNav adds resolved config/env/translation values and delegates to
    -- all hover-capable clients, including otter-ls for embedded PHP.
    local ok, annotations = pcall(require, 'blade-nav.features.annotations')
    if ok then
      annotations.on_K()
      return
    end
  end

  vim.lsp.buf.hover()
end

return M
