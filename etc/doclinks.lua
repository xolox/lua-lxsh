-- Documentation links for LPeg (too random to automate extraction).
local links = {
  ['lpeg.match'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-match',
  ['lpeg.type'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-type',
  ['lpeg.version'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-version',
  ['lpeg.setstack'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-setmaxstack',
  ['lpeg.P'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-p',
  ['lpeg.B'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-behind',
  ['lpeg.R'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-r',
  ['lpeg.S'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-s',
  ['lpeg.V'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-v',
  ['lpeg.locale'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-locale',
  ['lpeg.C'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-c',
  ['lpeg.Carg'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-arg',
  ['lpeg.Cb'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-b',
  ['lpeg.Cc'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-cc',
  ['lpeg.Cf'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-f',
  ['lpeg.Cg'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-g',
  ['lpeg.Cp'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-p',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Ct'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-t',
  ['lpeg.Cmt'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#matchtime',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
}

-- Scan the Lua reference manual for documentation links.
local http = require 'socket.http'
local manual = 'http://www.lua.org/manual/5.1/manual.html'
local source = http.request(manual)
local links = {}
for anchor in source:gmatch 'name="([^"]+)"' do
  if anchor:find '^pdf%-' and not anchor:find '^pdf%-LUA_' then
    -- links[anchor:match '^pdf%-(.+)$'] = manual .. '#' .. anchor
  elseif anchor:find '^luaL?_' or anchor:find '^pdf%-LUA_' then
    links[anchor:gsub('^pdf%-', '')] = manual .. '#' .. anchor
  end
end
see(links)
do return end

-- Scan the Lua/APR manual for documentation links.
local manual = 'http://peterodding.com/code/lua/apr/docs/'
local source = http.request(manual)
for anchor in source:gmatch 'name="(apr%.[A-Za-z0-9_]+)"' do
  links[anchor] = manual .. '#' .. anchor
end

-- Use a pretty printer to dump the resulting table.
see(links)
