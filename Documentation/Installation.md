
# Installation

*How to add this library to your project.*

<br>

#### Using toybox.py

You can add it to your **Playdate** project by installing [**toybox.py**](https://toyboxpy.io), going to your project folder in a Terminal window and typing:

```console
toybox add Whitebrim/AnimatedSprite
toybox update
```

Then, if your code is in the `source` folder, just import the following:

```lua
import '../toyboxes/toyboxes.lua'
```

#### Manually

1.  Download the [`AnimatedSprite.lua`][Library] file.

    <br>

2.  Move the file into your project folder.

    <br>
    
3.  Copy the path to the file.

    <br>
    
4.  Import the library with this path:

    ```lua
    import "<Path To The File>"
    ```
    
    ```lua
    import "AnimatedSprite.lua"
    ```
    
    <br>

### Update your code

If missing, add the following function <br>
    to your `playdate.update()` function:
    
    ```lua
    playdate.graphics.sprite.update()
    ```

<br>


<!----------------------------------------------------------------------------->

[Library]: https://github.com/Whitebrim/AnimatedSprite/blob/master/AnimatedSprite.lua