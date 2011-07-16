# LXSH: Lexing & Syntax Highlighting in Lua

LXSH is a collection of [lexers][lexing] and [highlighters][highlighting] written in [Lua][lua] using the excellent pattern-matching library [LPeg][lpeg]. The highlighters generate [HTML][html] designed to be easily embedded in web pages. Two programming languages are currently supported, these are Lua and C. The highlighters support three color schemes, here are some examples of both languages in every color scheme:

 * **Lua:** [Earendel](http://peterodding.com/code/lua/lxsh/examples/earendel/apr.lua.html), [Slate](http://peterodding.com/code/lua/lxsh/examples/slate/apr.lua.html), [Wiki](http://peterodding.com/code/lua/lxsh/examples/wiki/apr.lua.html)
 * **Lua's interactive prompt:** [Earendel](http://peterodding.com/code/lua/lxsh/examples/earendel/prompt.lua.html), [Slate](http://peterodding.com/code/lua/lxsh/examples/slate/prompt.lua.html), [Wiki](http://peterodding.com/code/lua/lxsh/examples/wiki/prompt.lua.html)
 * **C:** [Earendel](http://peterodding.com/code/lua/lxsh/examples/earendel/lua_apr.c.html), [Slate](http://peterodding.com/code/lua/lxsh/examples/slate/lua_apr.c.html), [Wiki](http://peterodding.com/code/lua/lxsh/examples/wiki/lua_apr.c.html)

As you can see in the above examples the highlighters replace standard library identifiers (and then some) with hyperlinks to the relevant documentation. You can also try switching between style sheets while staying on the same page by using your web browsers *View → Page styles* menu (this works using so-called "alternate style sheets").

## Installation

The easiest way to download and install LXSH is using [LuaRocks][luarocks]:

    $ luarocks install http://peterodding.com/code/lua/lxsh/downloads/lxsh-0.7-1.rockspec

If you don't have LuaRocks installed you can [download the latest release][zipball] directly from GitHub as a ZIP archive. To install create an `lxsh` directory in your [$LUA_PATH][lua_path] and copy the contents of the `src` directory from the ZIP archive to the `lxsh` directory so that you end up with the following structure:

 * `$LUA_PATH/lxsh/init.lua`
 * `$LUA_PATH/lxsh/lexers/*.lua`
 * `$LUA_PATH/lxsh/highlighters/*.lua`
 * `$LUA_PATH/lxsh/colors/*.lua`
 * `$LUA_PATH/lxsh/docs/*.lua`

## Usage

If you want to call a lexer or access an LPeg pattern defined by the lexer you can do so as follows (this example demonstrates the Lua lexer but the C lexer works the same):

    > -- Load the LXSH module.
    > require 'lxsh'

    > -- Run the lexer on a string of source code.
    > for kind, text in lxsh.lexers.lua.gmatch 'i = i + 1 -- example' do
    >>  print(kind, text)
    >> end
    identifier  i
    whitespace   
    operator    =
    whitespace   
    identifier  i
    whitespace   
    operator    +
    whitespace   
    number      1
    whitespace   
    comment     -- example

    > -- Use one of the patterns defined by the lexer.
    > lxsh.lexers.lua.patterns.comment:match '--[=[ this is a long comment ]=]'

Lexers define the following functions:

 * `lexer.find(subject [, init [, options ]])` takes a string and optional starting position, matches a single token (anchored) and returns two values: the token kind and the last matched character
 * `lexer.match(subject [, init [, options ]])` takes a string and optional starting position, matches a single token (anchored) and returns two values: the token kind and the matched text
 * `lexer.gmatch(subject [, options])` returns an iterator that produces two values on each iteration: the token kind and the matched text

When `options` is given it should be a table of options that can be used to configure lexers. Currently only one option is defined: When you pass `join_identifiers=true` to the Lua lexer, expressions like `io.write` will be matched as a single identifier instead of the sequence (identifier `io`, operator `.`, identifier `write`).

The syntax highlighters can be used as follows:

    > print(lxsh.highlighters.lua("require 'lpeg'", { external = true }))
    <pre class="sourcecode lua">
    <a href="http://www.lua.org/manual/5.1/manual.html#pdf-require" class="library">require</a>
    <span class="constant">'lpeg'</span>
    </pre>

You can customize the output of the highlighters by passing a table with one or more of the following options:

 * `encodews`: Replace newlines with `<br>` elements and ordinary spaces with non-breaking spaces so that whitespace is preserved when the highlighted code isn't embedded in a `<pre>` block
 * `external`: By default the highlighters generate inline CSS which makes it easier to use the output directly but it also bloats the size significantly. If you want to reduce the size and don't mind including an external style sheet you can set this option to `true`. You'll need to make sure the required styles are loaded, e.g. by embedding the output of `lxsh.highlighters.includestyles(preferred, includeswitcher)` in the `<head>` of your HTML document (the `preferred` argument indicates the default style sheet and if you pass `includeswitcher` as `true` then an interactive style sheet switcher using JavaScript is included)
 * `colors`: The color scheme to use, one of the following:
   * `lxsh.colors.earendel` based on the [Vim color scheme Earendel][earendel] by Georg Dahn (this is the default)
   * `lxsh.colors.slate` based on the [Vim color scheme Slate][slate] by Ralph Amissah
   * `lxsh.colors.wiki` based on the style of the [lua-users wiki][lua_wiki]

## Tokens produced by the lexers

The Lua lexer produces the following tokens:

 * comment
 * constant (`true`, `false` and `nil`)
 * error (invalid input)
 * identifier
 * keyword
 * number
 * operator
 * string
 * whitespace

The C lexer produces the following tokens:

 * comment
 * constant (character and string literals like `'C'` and `"Lua"`)
 * error (invalid input)
 * identifier
 * keyword 
 * number
 * operator
 * preprocessor
 * whitespace

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/lua/lxsh/> and <http://github.com/xolox/lua-lxsh>.

## License

This software is licensed under the [MIT license][mit].  
© 2011 Peter Odding &lt;<peter@peterodding.com>&gt;.

[lexing]: http://en.wikipedia.org/wiki/Lexical_analysis
[highlighting]: http://en.wikipedia.org/wiki/Syntax_highlighting
[lua]: http://www.lua.org/
[lpeg]: http://www.inf.puc-rio.br/~roberto/lpeg/
[html]: http://en.wikipedia.org/wiki/HTML
[lua_example]: http://peterodding.com/code/lua/lxsh/examples/apr.lua.html
[c_example]: http://peterodding.com/code/lua/lxsh/examples/lua_apr.c.html
[luarocks]: http://www.luarocks.org/
[zipball]: http://github.com/xolox/lua-lxsh/zipball/master
[lua_path]: http://www.lua.org/manual/5.1/manual.html#pdf-package.path
[earendel]: http://www.vim.org/scripts/script.php?script_id=2188
[slate]: http://code.google.com/p/vim/source/browse/runtime/colors/slate.vim
[lua_wiki]: http://lua-users.org/wiki/
[mit]: http://en.wikipedia.org/wiki/MIT_License
