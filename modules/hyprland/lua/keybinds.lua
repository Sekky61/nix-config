local M = {}

function M.bind(spec)
  hl.bind(spec.keys, spec.action, spec.options)
end

function M.bind_all(specs)
  for _, spec in ipairs(specs) do
    M.bind(spec)
  end
end

return M
