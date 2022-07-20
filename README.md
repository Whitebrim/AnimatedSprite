
# AnimatedSprite   [![Badge License]][License]

Animated sprites library for **[PlayDate]**.

<br>
<br>
<br>

<div align = center>

[![Button Installation]][Install]   
[![Button Documentation]][Wiki]   
[![Button Performance]][Performance]

</div>

<br>
<br>

## Features

*How the sprites class has been extended.*

- **Finite State Machines**

- **JSON Loading**

- **Animations**

<br>
<br>

## Showcase

*A small example how you could use it.*

```lua
import 'AnimatedSprite.lua'

-- Loading imagetable from the disk
imagetable = playdate.graphics.imagetable.new('path')

-- Creating an AnimatedSprite instance
sprite = AnimatedSprite.new(imagetable)

-- Adding custom a animation state (Optional)
sprite:addState('idle',1,5,{ tickStep = 2 })

-- Playing the animation
sprite:playAnimation()
```

<br>
<br>

## Contacts

[![Button Telegram]][Telegram]   
[![Button Discord]][Discord]   
[![Button Mail]][Mail]

<br>


<!----------------------------------------------------------------------------->

[Telegram]: https://tg.brim.ml
[Playdate]: https://play.date/
[Discord]: https://discordapp.com/users/241961053578199040
[Wiki]: https://github.com/Whitebrim/AnimatedSprite/wiki
[Mail]: mailto:white@brim.ml

[Performance]: Documentation/Performance.md
[Install]: Documentation/Installation.md
[License]: LICENSE


<!----------------------------------[ Badges ]--------------------------------->

[Badge License]: https://img.shields.io/badge/License-MIT-ac8b11.svg?style=for-the-badge&labelColor=yellow


<!---------------------------------[ Buttons ]--------------------------------->

[Button Documentation]: https://img.shields.io/badge/Documentation-0099E5?style=for-the-badge&logoColor=white&logo=GitBook
[Button Installation]: https://img.shields.io/badge/Installation-EF2D5E?style=for-the-badge&logoColor=white&logo=DocuSign
[Button Performance]: https://img.shields.io/badge/Performance-428813?style=for-the-badge&logoColor=white&logo=GoogleAnalytics


[Button Telegram]: https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logoColor=white&logo=Telegram
[Button Discord]: https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logoColor=white&logo=Discord
[Button Mail]: https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logoColor=white&logo=Gmail

