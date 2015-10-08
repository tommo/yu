# YU LANGUAGE

*README*
----
Yu is a static-type language compiles into plain Lua.
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

A: The language was started as a part of my own game engine. I was using Lua as my main script language. Lua is lean and flexible, it's always a great fun to work with it. But sometimes, I miss the features provided by a static language like type checking, IDE support. Lua also lacks some 'syntactic sugar' which I've got bound to, like 'continue', 'switch'.  So I decide to design a static language on top of Lua.



Q: What's the syntax looks like?

A: The syntax is designed to be very similar to Lua. Most of the syntax elements come from Lua. 
I also took some other languages for reference: BlitzMax ( the class related keywords like 'field', 'method' ), OOC (argument type 'inference'), ActionScript ( 'as' keyword ), and Go ( 'func' keyword )
Effort has been made to have the language look like a dynamic language as much as it can. 
You will find Yu code a pleasure to write.



Q: What's the difference against other Lua targeting languages ?

A: There are some other languages targeting Lua like MoonScript and LoomScript. 
LoomScript compiles into bytecode. It is designed to utilize Lua/Luajit VM directly and create its own eco-system. 
On the other hand, MoonScript has a similar purpose as Yu of being an alternative way to utilize Lua's eco-system. However, it is a dynamic language and with a very different syntax. 


Q: How do you handle debugging?

A: Debug support can be challenging for language-to-language compiler. Yu uses a 'creative' hack to inject Yu source information into generated Lua code. With the help of built-in debug information converter, you can get correct error message and even stack dump for Yu code.


Q: Is Yu faster than Lua?

A: Since the code generation is quite straightforward, there is no much performance difference against equivalent Lua code. 


Q: How do I interface Lua?

A: To interface Lua functions, you need to write function declarations in an extern block, it's very easy. You can even put embed Lua code in your Yu code. 


Q: Can I access Yu module from Lua?

A: Yes. Yu provides an intuitive way for Yu symbol access from Lua side. You can call Yu function with or without type checking for arguments. Furthermore, you have the access to Yu's reflection information from Lua side.


Q: Is there any dependency?

A: Yu is designed to be lightweight and embeddable into any Lua system. Although the parser needs *LPeg* and build system needs *LuaFileSystem* (optional for file modification detection),  the runtime and generated codes are just pure Lua.


Q: How is the performance of the compiler?

A: Yu is written in pure Lua with help of LPeg. It won't be as fast as other 'hardcore' compilers. Fortunately, Yu syntax is simple and it has a build-by-need system, so it won't take much of your time in most of the occasions.


Q: Can I compile Yu code during runtime?

A: Sure. If you have LPeg in your Lua system, Yu compiler will work just out of the box. However, if you want to 'link' against other prebuilt Yu modules, you have to provide the corresponding interface files.



