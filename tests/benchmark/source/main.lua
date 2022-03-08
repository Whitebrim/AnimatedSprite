import '../../../AnimatedSprite.lua'
local gfx <const> = playdate.graphics
local imagetable = gfx.imagetable.new("assets/mushroom")
local sprites = {} 
local i = 1
local animate = true
local states = AnimatedSprite.loadStates("assets/config.json")
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.display.setRefreshRate(50)

local function ManualLoopAnimation(s)
    s:changeState("idle")
end

local menu = playdate.getSystemMenu()
menu:addMenuItem("Reset", function()
    for i,v in ipairs(sprites) do v:remove() end
    sprites = {}
    i = 1
    gfx.clear()
end)

local function SpawnNewSprite()
    local sprite = AnimatedSprite.new(imagetable, states, true)
    sprite.states.fall.onAnimationEndEvent = ManualLoopAnimation
    sprite:setZIndex(i)
	sprite:moveTo(math.random(0,390), math.random(0,230))
    sprites[i] = sprite
    print(i)
    i = i + 1
end

local function DeleteLastSprite()
    if (i > 1) then
        i = i - 1
        sprites[i]:remove()
        sprites[i] = nil
        print(i)
    end
end

function playdate.update()
    if (animate) then
        gfx.sprite.update()
    end
    local crank = math.floor(playdate.getCrankChange())
    if (crank > 0) then
        for i = 1, crank, 1 do
            SpawnNewSprite()
        end
    end
    if (crank < 0) then
        for i = 1, -crank, 1 do
            DeleteLastSprite()
        end
    end

    if (playdate.buttonJustPressed(playdate.kButtonUp)) then
        SpawnNewSprite()
    end
    if (playdate.buttonJustPressed(playdate.kButtonDown)) then
        DeleteLastSprite()
    end

	playdate.drawFPS(0,0)
end