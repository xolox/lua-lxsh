Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> -- Load the lexer.
> lexer = require 'lxsh.lexers.lua'
> -- Run the lexer on a string of source code.
> for kind, text in lexer.gmatch 'i = i + 1 -- example' do
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
