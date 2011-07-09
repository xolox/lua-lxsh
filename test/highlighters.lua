--[[

 Unit tests for the HTML syntax highlighters of the LXSH module.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 9, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

-- Tests for the Lua highlighter. {{{1

local lua_highlighter = require 'lxsh.highlighters.lua'

-- Constants (true, false and nil). {{{2
assert(lua_highlighter('true false nil', { external = true }) == [[
<pre class="sourcecode lua"><span class="constant">true</span> <span class="constant">false</span> <span class="constant">nil</span></pre>]])

-- Interactive prompt. {{{2
assert(lua_highlighter([[
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> print "Hello world!"]], { external = true }) == [[
<pre class="sourcecode lua"><span class="prompt">Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio</span>
<span class="prompt">&gt;</span> <a href="http://www.lua.org/manual/5.1/manual.html#pdf-print" class="library">print</a> <span class="constant">"Hello world!"</span></pre>]])

-- Numbers. {{{2
assert(lua_highlighter('1 3.14 1. .1 0x0123456789ABCDEF 1e5', { external = true }) == [[
<pre class="sourcecode lua"><span class="number">1</span> <span class="number">3.14</span> <span class="number">1.</span> <span class="number">.1</span> <span class="number">0x0123456789ABCDEF</span> <span class="number">1e5</span></pre>]])

-- String literals. {{{2
assert(lua_highlighter([==[
'single quoted string'
"double quoted string"
[[long string]]
[[multi line
long string]]
[=[nested [[long]] string]=]
]==], { external = true }) == [==[
<pre class="sourcecode lua"><span class="constant">'single quoted string'</span>
<span class="constant">"double quoted string"</span>
<span class="constant">[[long string]]</span>
<span class="constant">[[multi line
long string]]</span>
<span class="constant">[=[nested [[long]] string]=]</span>
</pre>]==])

-- Comments. {{{2
assert(lua_highlighter([==[
#!shebang line
-- single line comment
--[=[
 long
 comment
]=]
--[[
nested
--[=[long]=]
comment
]]
]==], { external = true }) == [==[
<pre class="sourcecode lua"><span class="comment">#!shebang line
</span><span class="comment">-- single line comment
</span><span class="comment">--[=[
 long
 comment
]=]</span>
<span class="comment">--[[
nested
--[=[long]=]
comment
]]</span>
</pre>]==])

-- Operators. {{{2
assert(lua_highlighter('not ... and .. ~= == >= <= or ] { = > ^ [ < ; ) * ( % } + - : , / . #', { external = true }) == [==[
<pre class="sourcecode lua"><span class="operator">not</span> <span class="operator">...</span> <span class="operator">and</span> <span class="operator">..</span> <span class="operator">~=</span> <span class="operator">==</span> <span class="operator">&gt;=</span> <span class="operator">&lt;=</span> <span class="operator">or</span> <span class="operator">]</span> <span class="operator">{</span> <span class="operator">=</span> <span class="operator">&gt;</span> <span class="operator">^</span> <span class="operator">[</span> <span class="operator">&lt;</span> <span class="operator">;</span> <span class="operator">)</span> <span class="operator">*</span> <span class="operator">(</span> <span class="operator">%</span> <span class="operator">}</span> <span class="operator">+</span> <span class="operator">-</span> <span class="operator">:</span> <span class="operator">,</span> <span class="operator">/</span> <span class="operator">.</span> <span class="operator">#</span></pre>]==])

-- Keywords. {{{2
assert(lua_highlighter('break do else elseif end for function if in local repeat return then until while', { external = true }) == [==[
<pre class="sourcecode lua"><span class="keyword">break</span> <span class="keyword">do</span> <span class="keyword">else</span> <span class="keyword">elseif</span> <span class="keyword">end</span> <span class="keyword">for</span> <span class="keyword">function</span> <span class="keyword">if</span> <span class="keyword">in</span> <span class="keyword">local</span> <span class="keyword">repeat</span> <span class="keyword">return</span> <span class="keyword">then</span> <span class="keyword">until</span> <span class="keyword">while</span></pre>]==])

-- Hyper links embedded in strings/comments and documentation links. {{{2
assert(lua_highlighter([[
-- http://peterodding.com/code/lua/lxsh
os.execute("firefox http://lua.org")
]], { external = true }) == [[
<pre class="sourcecode lua"><span class="comment">-- <a href="http://peterodding.com/code/lua/lxsh">http://peterodding.com/code/lua/lxsh</a>
</span><a href="http://www.lua.org/manual/5.1/manual.html#pdf-os.execute" class="library">os.execute</a><span class="operator">(</span><span class="constant">"firefox <a href="http://lua.org"">http://lua.org"</a></span><span class="operator">)</span>
</pre>]])

-- vim: ts=2 sw=2 et
