# AnimatedSprite
Sprite class extension that covers animations, finite state machine and json loading. Made for Playdate.

Quick Look
==========

```lua
import "AnimatedSprite.lua"

imagetable = playdate.graphics.imagetable.new("path") -- Loading imagetable from the disk
sprite = AnimatedSprite.new(imagetable) -- Creating AnimatedSprite instance
sprite:addState("idle", 1, 5, {tickStep = 2}) -- Adding custom animation state (Optional)
sprite:playAnimation() -- Playing the animation
```

Documentation
=============

See the [**github wiki page**](https://github.com/Whitebrim/AnimatedSprite/wiki) for examples & documentation.

Installation
============

Just copy the `AnimatedSprite.lua` file wherever you want it (for example to a libraries/ folder). Then write this in `main.lua` file (change path to your path):

```lua
import "AnimatedSprite.lua"
```

Add this line to the playdate.update() function if you haven't already.

```lua
playdate.graphics.sprite.update()
```

Performance
===========
  
![AnimatedSpriteDiagram](https://user-images.githubusercontent.com/23287829/157312624-b2ee8dc7-f7b8-46cf-a79a-3ed2cbda6ec9.png)

Contacts
========

<p align="left">
<a href="https://tg.brim.ml" target="_blank"><img align="center" src="https://telegram.org/img/t_logo.svg" alt="tg.brim.ml" height="40" width="40" /></a>
<a href="https://discordapp.com/users/241961053578199040" target="_blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/discord.svg" alt="Whitebrim#4444" height="45" width="45" /></a>
<a href="mailto:white@brim.ml" target="_blank"><img align="center" src="https://yastatic.net/iconostasis/_/ZPJ8fJU3QLcrqa5E2fUpDDqmgGs.svg" alt="white@brim.ml" height="40" width="40"></a>
</p>

License
=======

AnimatedSprite is distributed under the MIT license.

Trademarks
==========

[Playdate](https://play.date/) is a trademark of [Panic](https://panic.com/)
