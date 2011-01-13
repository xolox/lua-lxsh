-- Run this Lua script from the project root.

function readfile(path)
  local handle = assert(io.open(path))
  local data = assert(handle:read '*a')
  assert(handle:close()); return data
end

function writefile(path, data)
  local handle = assert(io.open(path, 'w'))
  assert(handle:write [[
<html>
<head>
<style type="text/css">
html, body { margin: 0; padding: 0; }
pre { margin: 0; padding: 1em; }
</style>
</head>
<body>]])
  assert(handle:write(data))
  assert(handle:write '</body></html>')
  local nbytes = handle:seek()
  assert(handle:close())
  return nbytes
end

for _, colors in ipairs { 'earendel', 'slate', 'wiki' } do

  local options = { colors = require('lxsh.colors.' .. colors) }
  
  -- Highlight example Lua source code (from my Lua/APR binding).
  local highlighter = require 'lxsh.highlighters.lua'
  local input = readfile 'examples/apr.lua'
  local outfile = 'examples/' .. colors .. '/apr.lua.html'
  local nbytes = writefile(outfile, highlighter(input, options))
  print(('Wrote %iK to %s'):format(nbytes/1024, outfile))
  
  -- Highlight example C source code (also from my Lua/APR binding).
  local highlighter = require 'lxsh.highlighters.c'
  local input = readfile 'examples/lua_apr.c'
  local outfile = 'examples/' .. colors .. '/lua_apr.c.html'
  local nbytes = writefile(outfile, highlighter(input, options))
  print(('Wrote %iK to %s'):format(nbytes/1024, outfile))

end
