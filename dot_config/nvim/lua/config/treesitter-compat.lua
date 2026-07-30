-- Nvim 0.12 removed the `all` option from vim.treesitter.query.add_directive/add_predicate:
-- captures are now always passed as `TSNode[]` lists, never a single TSNode.
-- nvim-treesitter's query_predicates.lua (queries like `set-lang-from-info-string!`)
-- still assumes a single node and calls `node:range()` on it, crashing with
-- "attempt to call method 'range' (a nil value)" whenever a markdown injection
-- (e.g. fenced code blocks in hover docs) is parsed.
-- Unwrap single-element lists before they reach get_node_text/node methods.
local orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  if type(node) == 'table' then
    node = node[1]
  end
  return orig_get_node_text(node, source, opts)
end
