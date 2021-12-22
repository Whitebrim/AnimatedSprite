local gfx = playdate.graphics
imagetable = gfx.imagetable.new("assets/test")

TestInit = {}

function TestInit:jsonTests()
    local emptyFunc = self.sprite.states.default.onFrameChangedEvent
    expected = {
        default = {
            name = "default",
			firstFrameIndex = 1,
			framesCount = 16,
			animationStartingFrame = 1,
			tickStep = 3,
			frameStep = 1,
			reverse = false,
			loop = true,
			yoyo = false,
			flip = gfx.kImageUnflipped,
			xScale = 1,
			yScale = 1,
			nextAnimation = nil,
			onFrameChangedEvent = emptyFunc,
			onStateChangedEvent = emptyFunc,
			onLoopFinishedEvent = emptyFunc,
			onAnimationEndEvent = emptyFunc
        },
        run = {
            name = "run",
            animationStartingFrame = 1,
            firstFrameIndex = 1,
            framesCount = 5,
            yoyo = true
        },
        jump = {
            name = "jump",
            animationStartingFrame = 1,
            firstFrameIndex = 6,
            framesCount = 3,
            loop = false,
            nextAnimation = "jump top"
        },
        ["jump top"] = {
            name = "jump top",
            animationStartingFrame = 1,
            firstFrameIndex = 9,
            framesCount = 1,
            loop = 2,
            nextAnimation = "fall"
        },
        fall = {
            name = "fall",
            animationStartingFrame = 1,
            firstFrameIndex = 10,
            framesCount = 2,
            loop = false,
            tickStep = 2
        },
        landing = {
            name = "landing",
            animationStartingFrame = 1,
            firstFrameIndex = 12,
            framesCount = 2,
            loop = false,
            nextAnimation = "run",
            tickStep = 4
        },
        ["sit down"] = {
            name = "sit down",
            animationStartingFrame = 1,
            firstFrameIndex = 14,
            framesCount = 3,
            loop = false,
            nextAnimation = "stand up",
            tickStep = 2
        },
        ["stand up"] = {
            name="stand up",
            animationStartingFrame = 3,
            firstFrameIndex = 14,
            framesCount = 3,
            loop = false,
            reverse = true,
            nextAnimation = "run"
        },
        random = {
            name = "random",
            animationStartingFrame = 1,
            firstFrameIndex = 1,
            frames = {1, 2, 3, 7, 8, 13, 14, 15},
            framesCount = 8
        }
    }

    luaunit.assertEquals(self.sprite.states.random.framesCount, 8)
    luaunit.assertEquals(self.sprite.states.run.tickStep, 3)
    luaunit.assertEquals(self.sprite.states.fall.tickStep, 2)
    luaunit.assertEquals(self.sprite.states, expected)
end

function TestInit:setUp()
    self.sprite = AnimatedSprite.new(imagetable)
end

function TestInit:test1()
    luaunit.assertEquals(self.sprite.imagetable, imagetable)
end

function TestInit:test2()
    self.sprite:addState("test", 1, 16, {tickStep = 2})

    luaunit.assertEquals(self.sprite.states.test.tickStep, 2)

    self.sprite:getLocalStates().test.tickStep = nil

    luaunit.assertEquals(self.sprite.states.test.tickStep, 1)
end

function TestInit:test3()
    self.sprite:addState("idle", 1, 5, {tickStep = 2})
    self.sprite:addState("appear", 6, nil, {tickStep = 2, nextAnimation = "idle"}).asDefault()
    
    luaunit.assertEquals(self.sprite.states.appear.framesCount, 11)
    luaunit.assertEquals(self.sprite.states[self.sprite.states[self.sprite.defaultState].nextAnimation].framesCount, 5)
end

function TestInit:test4()
    self.sprite:addState("idle", nil, nil, nil, true)

    luaunit.assertEquals(self.sprite.states.idle.animationStartingFrame, 1)
    luaunit.assertEquals(self.sprite.states.idle.firstFrameIndex, 1)
    luaunit.assertEquals(self.sprite.states.idle.framesCount, 16)
end

function TestInit:test5()
    local states = AnimatedSprite.loadStates("assets/test.json")
    self.sprite = AnimatedSprite.new(imagetable, states, true)

    self:jsonTests()
end

function TestInit:test6()
    local states = AnimatedSprite.loadStates("assets/test.json")
    self.sprite = AnimatedSprite.new(imagetable, states)

    self:jsonTests()
end

function TestInit:test7()
    local states = AnimatedSprite.loadStates("assets/test.json")
    self.sprite = AnimatedSprite.new(imagetable)
    self.sprite:setStates(states)

    self:jsonTests()
end

function TestInit:test8()
    self.sprite = AnimatedSprite.new(imagetable)
    self.sprite:setStates({
        {
            name = "default",
            firstFrameIndex = 2
        },
        {
            name = "idle",
            framesCount = 5,
            tickStep = 4,
            yoyo = true,
        },
        {
            name = "run",
            firstFrameIndex = "idle",
            framesCount = 9,
            tickStep = 2,
            loop = 5,
            nextAnimation = "idle"
        }
    }, true, "run")

    luaunit.assertEquals(self.sprite.defaultState, "run")
    luaunit.assertEquals(self.sprite._enabled, true)
    luaunit.assertEquals(self.sprite.states.default.firstFrameIndex, 2)
    luaunit.assertEquals(self.sprite.states.idle.firstFrameIndex, 2)
    luaunit.assertEquals(self.sprite.states.run.firstFrameIndex, 7)

    self.sprite:setStates({
        {
            name = "default",
            tickStep = 5
        },
        {
            name = "idle",
            framesCount = 2,
            tickStep = 4
        },
        {
            name = "run",
            firstFrameIndex = 8,
        }
    })

    luaunit.assertEquals(self.sprite.states.idle.yoyo, false) -- Overwritten
    luaunit.assertEquals(self.sprite.states.default.firstFrameIndex, 2) -- Not overwritten because it's default state
    luaunit.assertEquals(self.sprite.states.idle.firstFrameIndex, 2)
    luaunit.assertEquals(self.sprite.states.run.firstFrameIndex, 8)
end

function TestInit:test9()
    local emptyFunc = self.sprite.states.default.onFrameChangedEvent
    local function onFrameChangedEvent(self) print(self._currentFrame) end
    local states = AnimatedSprite.loadStates("assets/test.json")
    self.sprite = AnimatedSprite.new(imagetable, states)

    luaunit.assertEquals(self.sprite.states.default.tickStep, 3)
    luaunit.assertEquals(self.sprite.states.run.flip, gfx.kImageUnflipped)
    luaunit.assertEquals(self.sprite.states.run.onFrameChangedEvent, emptyFunc)

    self.sprite.states.default.tickStep = 4
    self.sprite.states.run.flip = gfx.kImageFlippedXY
    self.sprite.states.run.onFrameChangedEvent = onFrameChangedEvent

    luaunit.assertEquals(self.sprite.states.default.tickStep, 4)
    luaunit.assertEquals(self.sprite.states.run.flip, gfx.kImageFlippedXY)
    luaunit.assertEquals(self.sprite.states.run.onFrameChangedEvent, onFrameChangedEvent)
end

function TestInit:tearDown()
    self.sprite = nil
end

TestAnimation = {}

function TestAnimation:NextFrame()
    self.sprite:updateAnimation()
end

function TestAnimation:setUp()
    local states = AnimatedSprite.loadStates("assets/test.json")
    self.sprite = AnimatedSprite.new(imagetable, states, true)
end

---comment
---@param currentstate string
---@param currentFrame integer
---@param finishedLoops integer
---@param skipFrames integer
function TestAnimation:proceedAnimation(currentstate, currentFrame, finishedLoops, skipFrames)
    luaunit.assertEquals(self.sprite.currentState, currentstate)
    luaunit.assertEquals(self.sprite:getCurrentFrameIndex(), currentFrame)
    luaunit.assertEquals(self.sprite._loopsFinished, finishedLoops)
    for i = 1, skipFrames do
        TestAnimation:NextFrame()
    end
end

function TestAnimation:test1()
    TestAnimation:proceedAnimation("run", 1, 0, 3)
    TestAnimation:proceedAnimation("run", 2, 0, 3)
    TestAnimation:proceedAnimation("run", 3, 0, 3)
    TestAnimation:proceedAnimation("run", 4, 0, 3)
    luaunit.assertEquals(self.sprite:getImage(), imagetable[5])
    TestAnimation:proceedAnimation("run", 5, 1, 3)
    TestAnimation:proceedAnimation("run", 4, 1, 3)
    TestAnimation:proceedAnimation("run", 3, 1, 3)
    TestAnimation:proceedAnimation("run", 2, 1, 3)
    TestAnimation:proceedAnimation("run", 1, 2, 3)
    TestAnimation:proceedAnimation("run", 2, 2, 3)
end

function TestAnimation:test2()
    self.sprite:changeState("jump")
    TestAnimation:proceedAnimation("jump", 6, 0, 3)
    TestAnimation:proceedAnimation("jump", 7, 0, 3)
    TestAnimation:proceedAnimation("jump", 8, 1, 3)
    TestAnimation:proceedAnimation("jump top", 9, 1, 3)
    TestAnimation:proceedAnimation("jump top", 9, 2, 3)
    TestAnimation:proceedAnimation("fall", 10, 0, 2)
    TestAnimation:proceedAnimation("fall", 11, 1, 2)
    TestAnimation:proceedAnimation(nil, 0, 0, 2)
end

function TestAnimation:test3()
    self.sprite:changeState("sit down")
    TestAnimation:proceedAnimation("sit down", 14, 0, 2)
    TestAnimation:proceedAnimation("sit down", 15, 0, 2)
    TestAnimation:proceedAnimation("sit down", 16, 1, 2)
    TestAnimation:proceedAnimation("stand up", 16, 0, 3)
    TestAnimation:proceedAnimation("stand up", 15, 0, 3)
    TestAnimation:proceedAnimation("stand up", 14, 1, 3)
    TestAnimation:proceedAnimation("run", 1, 0, 3)
end

function TestAnimation:test4()
    self.sprite:changeState("random")
    --[1, 2, 3, 7, 8, 13, 14, 15]
    TestAnimation:proceedAnimation("random", 1, 0, 3)
    TestAnimation:proceedAnimation("random", 2, 0, 3)
    TestAnimation:proceedAnimation("random", 3, 0, 3)
    TestAnimation:proceedAnimation("random", 7, 0, 3)
    TestAnimation:proceedAnimation("random", 8, 0, 3)
    TestAnimation:proceedAnimation("random", 13, 0, 3)
    TestAnimation:proceedAnimation("random", 14, 0, 3)
    TestAnimation:proceedAnimation("random", 15, 1, 3)
    TestAnimation:proceedAnimation("random", 1, 1, 3)
    TestAnimation:proceedAnimation("random", 2, 1, 3)
    TestAnimation:proceedAnimation("random", 3, 1, 3)
    TestAnimation:proceedAnimation("random", 7, 1, 3)
    self.sprite.states.random.reverse = true
    TestAnimation:proceedAnimation("random", 8, 1, 3)
    TestAnimation:proceedAnimation("random", 7, 1, 3)
    TestAnimation:proceedAnimation("random", 3, 1, 3)
    TestAnimation:proceedAnimation("random", 2, 1, 3)
    TestAnimation:proceedAnimation("random", 1, 2, 3)
    TestAnimation:proceedAnimation("random", 15, 2, 3)
    self.sprite.states.random.reverse = false
    TestAnimation:proceedAnimation("random", 14, 2, 3)
    TestAnimation:proceedAnimation("random", 15, 3, 3)
    TestAnimation:proceedAnimation("random", 1, 3, 3)
end

function TestAnimation:tearDown()
    self.sprite = nil
end

TestEvents = {}

function TestEvents:setUp()
    self.sprite = AnimatedSprite.new(imagetable, states, true)
    local output = ""
    self.sprite:addState("first", 1, 4, {
        tickStep = 1,
        loop = 2,
        nextAnimation = "second",
        onFrameChangedEvent = function() output = output.."F" end,
        onStateChangedEvent = function() output = output.."S" end,
        onLoopFinishedEvent = function() output = output.."L" end,
        onAnimationEndEvent = function() output = output.."A" end})
    self.sprite:addState("second", 5, 4, {
        onFrameChangedEvent = function() output = output.."f" end,
        onStateChangedEvent = function() output = output.."s" end,
        onLoopFinishedEvent = function() output = output.."l" end,
        onAnimationEndEvent = function() output = output.."a" end})
    self.sprite:changeState("first")
    output = output.."0"
    for i = 1, 8 do
        self.sprite:updateAnimation()
        output = output..i
    end

    luaunit.assertEquals(output, "SF0F1F2FL3F4F5F6FL7Asf8")
end

function TestEvents:test1()
    
end

function TestEvents:tearDown()
    self.sprite = nil
end