# YU LANGUAGE

*README*
----
Yu is a static-type language comiles into plain Lua.
The syntax is in a flavor very similar to Lua.

*Hello,world!*
----
[Lua version:]
print "Hello, world!"

[Yu version:]
extern
  function print(...*)
end
print "Hello, world!"


*FAQ*
----
Q: Why another language?
A: The language was started as a part of my own game engine. I was using Lua as my main script language. Lua is lean and flexible, it's always a great fun to work with it. But sometimes, I miss the features provided by a static language like type checking, IDE support. Lua also lacks some 'syntactic sugar' which I've get bound to like 'continue', 'switch'.  So I decide to design a static language on top of Lua.


Q: What's the syntax looks like?
A: The syntax is designed to be very similar to Lua. Most of the syntax elements come from Lua. 
I also took some other languages for reference: BlitzMax ( the 'field' and 'method' keywords ), OOC (argument type 'inference'), ActionScript ( 'as' keyword ), and Go ( 'func' keyword )
Effort has been made to have the language look like a dynamic language as much as it can. 
You will find Yu code is a pleasure to write.


Q: What's the difference against other Lua targeting languages ?
A: There are some other languages targeting Lua like MoonScript and LoomScript. 
LoomScript compiles into bytecode. It is designed to be utilizing Lua/Luajit VM directly and create its own eco-system. 
On the other hand, MoonScript has similar purpose as Yu of being an alternative way to utilize Lua's eco-system. However, it is a dynamic language and with a very different syntax. 