-----------------------------------------------
--- Sprite class extension with support of  ---
--- imagetables and finite state machine,   ---
--- with json configuration and autoplay.   ---
---            By @Whitebrim   git.brim.ml  ---
-----------------------------------------------
--- Special thanks to Andrew "Drew" Loebach ---
--- for contributing to the documentation.  ---
-----------------------------------------------

import 'CoreLibs/object'
import 'CoreLibs/sprites'
local gfx <const> = playdate.graphics
local function emptyFunc()end

--#region EXAMPLES AND DOCS

---@docs
--[[

https://github.com/Whitebrim/AnimatedSprite/wiki

~ Installation:

1. import 'AnimatedSprite.lua'
2. playdate.graphics.sprite.update() -- Add this line to the playdate.update() function



~ Basics:

To create animated sprite you need:

1. Create AnimatedSprite instance
2. Add animation state
3. Play animation

See "example_1A" for the concrete example.



~ More detailed description:

AnimatedSprite is an extension for Playdate's sprite class. It handles all animation stuff.
You don't need to know when and how to update the sprite - just configure states and play the animation.

There's always the "default" state that contains default values for all states. If you don't add any states,
this default state will be used. It will play animation from the first frame to the last and loop infinitely,
changing frames on every update() call, no scaling, no flipping.

To create an animated sprite, you need to call AnimatedSprite.new(imagetable, [states, [animate] ])
Imagetable is Playdate's structure that is created using `playdate.graphics.imagetable.new`. This can be used 
to import image tables in a variety of formats: GIF, sequential image table, matrix image table. 
Read Playdate Docs for more info. If you want to configure the animation - add states, then play the animation.

If you add more than 1 state, the first one you add will be used as default state and when you call :playAnimation()
the animation will start from that state. If you want another state to be the default,
you can add .asDefault() after adding this state (example_1B), or later call :setDefaultState(stateName).
Don't confuse .defaultState (:setDefaultState(name)) variable and .states.default table:

.defaultState is a string field that contains the state name of the state to play animation from at the first start
or after animation reset (:stopAnimetion()).

.states.default table contains default values for all animation states.
If you add a new animation and don't specify any parameter, its value is taken from the default table.

To play the animation - call :playAnimation()
To pause the animation - call :pauseAnimation()
You can call :toggleAnimation() to toggle between play and pause.
If you need to reset your animation - call :stopAnimation(). This will reset all animation variables as if animation wasn't played before.
Then you can call :playAnimation() to start the animation from the default state.


~ JSON configuration

You can store states in JSON file in the project (example_2A)

JSON file structure:

[
	{
		"name": "default",
		"tickStep": 3
	},
	{
		"name":"idle",
		"frames":[1, 2, 3, 7, 8, 13, 14, 15],
		"firstFrameIndex" = 1,
		"framesCount" = 20,
		"animationStartingFrame" = 1,
		"tickStep" = 1,
		"frameStep" = 1,
		"reverse" = false,
		"loop" = true,
		"yoyo" = false,
		"flip" = 0,
		"xScale" = 1,
		"yScale" = 1,
		"nextAnimation" = "state name"
	}
]

Changing the default state is optional: It contains default values for all states.
Values from default state will be used if they're not overwritten in a state.
For example, if all your states need "tickStep" to be 3, you can just set states.default.tickStep to 3 before adding states.
All values are optional besides "name". If the value is not overwritten, the state will be assigned with the value from the default state.

The only difference between json load and :addState(...) is that
json state is configured with first frame index and frames COUNT, but
in :addState(...) function first frame index and last frame INDEX are used.

You can't assign function for events in json, you need to change them manually (example_3B)



~ All config parameters:

name (string)
	Name of the state, should be unique, used as id

frames (table of integers) [optional]
	If you provide the table with indexes then animation will play frames of these indexes.
	Useful for cases when you need to build a state with frames that are non-sequential.
	"firstFrameIndex" and "framesCount" will use the "frames" table, not the original imagetable for indexing.

firstFrameIndex (integer or string) [optional]
	Index of the first frame in the imagetable. Indexing starts from 1!
	If initialised with string (name of the state), firstFrameIndex will be the next frame after the last frame from that state.
	If there are any changes in the imagetable structure, then only the "framesCount" field of the changed states need
	to be updated in the json config.

framesCount (integer) [optional]
	How many total frames of animation there are in this animation state. The animation will start with 
	the frame number specified "firstFrameIndex", and include [framesCount] frames in the animation. 
	If not provided, this state will have all frames till the end of the imagetable. 

animationStartingFrame (integer) [optional]
	Local index of the frame to start animation with. First frame of the state (firstFrameIndex frame) will be indexed as 1.
	The only one parameter that doesn't use default state value when assigned!
	If not provided, will be 1 if "reverse" is `false`, else will be the last frame.

reverse (boolean) [optional]
	Default value is `false`.
	If `true` then animation will be animated backwards.
	If "reverse" = `true`, then it's highly recommended to leave "animationStartingFrame" blank,
	so the system can assign the last frame index by itself.

loop (boolean or integer) [optional]
	Default value is `true`, `false` if "nextAnimation" is provided.
	If `true`, animation will loop endlessly from last frame to the first
	If `false`, animation will call :stopAnimation() function on the last frame
	If initialised with integer, animation will call :stopAnimation() function after provided amount of finished loops.
	Initialising with `false` and 1 gives the same effect.

yoyo (boolean) [optional]
	Default value is `false`.
	If `true`, the animation will be played in ping-pong style: 1-2-3-2-1-2-3-2-1.
	Finished loops are counted the same way when 'yoyo' is set to 'true'.
	For example an animation with 4 frames, set to loop 2 times would animate "1-2-3-4-3-2-1" before calling :stopAnimation()

tickStep (number) [optional]
	Default value is 1.
	Speed of the animation, larger value -> slower animation.
	Amount of frames (fps) between changing sprites.
	1 = update every frame.

frameStep (integer) [optional]
	Default value is 1.
	Amount of frames to skip between animation updates.
	If you want to draw only every second image from your imagetable, set frameStep to 2.

flip (0 or 1 or 2 or 3) [optional]
	Default value is 0 (unflipped).
	Flips images to draw along the axes.
	0 = playdate.geometry.kUnflipped
	1 = playdate.geometry.kFlippedX
	2 = playdate.geometry.kFlippedY
	3 = playdate.geometry.kFlippedXY

xScale, yScale (number) [optional]
	Default value is 1.
	Scale for horizontal, vertical axis

nextAnimation (string) [optional]
	Default value is nil.
	Name of the existing animation state to switch to automatically after this animation ends.
	If "nextAnimation" is set and "loop" is not set, then "loop" will be `false` by default.
	If nextAnimation is not provided and loop is not endless then after animation ends :stopAnimation() will be called.


~ Events (example_3B):

All events receive an AnimatedSprite instance (self) as first argument.

onFrameChangedEvent(self)
	The event that will be triggered when the animation transitions to the next frame.
	Guaranteed to be called before "onLoopFinishedEvent".

onLoopFinishedEvent(self)
	The event that will be triggered every time when the animation enters the loop's last frame.
	Guaranteed to be called after "onFrameChangedEvent".

onAnimationEndEvent(self)
	The event that will be raised when this animation state is over.
	If this animation has "nextAnimation" set, next will be called "onStateChangedEvent" event from the next animation.
	Guaranteed to be called after "onLoopFinishedEvent".

onStateChangedEvent(self)
	The event that will be triggered after the animation state changes.
	Guaranteed to be called after "onAnimationEndEvent".



~ List of public functions that you will be using:
You can find a detailed description for the exact function, down the file near the implementation.


- Base functions from the sprite class

- .new(imagetable, [states], [animate]) / AnimatedSprite(imagetable, [states], [animate]) -- Create new animation sprite instance

- :playAnimation() -- Play the animation
- :pauseAnimation() -- Pause the animation
- :toggleAnimation() -- Toggle between play and pause
- :stopAnimation() -- Reset the animation

- :addState(name, [startFrame], [endFrame], [params], [animate]) -- Add a new state to the finite state machine
- .loadStates(path) -- Get the configuration table from the JSON file
- :setStates(states, [animate], [defaultState]) -- Initialise the finite machine with the configuration table [states]
- :getLocalStates() -- Get the table of the finite machine states
- :copyLocalStates() -- Get the copy of the state table to initialise other animated sprites
- :changeState(name, [instant]) -- Change current state in the finite state machine to the [name] state
- :forceNextAnimation([instant]) -- Only used when the next animation is unknown, otherwise use :changeState(name)
- :setDefaultState(name) -- You can change the default state. The animation will start from this state after the first call of :playAnimation()
- :printAllStates() -- Debug print of the finite state machine states

- :updateAnimation() -- Called by default in the :update() function. Invoke manually to move the animation to the next frame.

]]

local function examples ()

	local imagetable = gfx.imagetable.new("path")

	---Basic initialisation
	function example_1A()
		sprite = AnimatedSprite.new(imagetable) -- Creating AnimatedSprite instance
		sprite:addState("idle", 1, 5, {tickStep = 2}) -- Adding custom animation state
		sprite:playAnimation() -- Playing the animation
	end

	---You can overwrite the sprite's :update() function. If you do so, don't forget to call updateAnimation() in :update()
	function example_1B()
		sprite = AnimatedSprite.new(imagetable)
		sprite:addState("idle", 1, 5, {tickStep = 2})
		sprite:addState("appear", 6, nil, {tickStep = 2, nextAnimation = "idle"}).asDefault()

		function sprite:update()
			local newX = sprite.x + 1
			if newX > 400 then
				sprite:changeState("appear")
				newX -= 400
			end
			sprite:moveTo(newX, sprite.y)
	
			sprite:updateAnimation()
		end

		sprite:playAnimation()
	end

	---Pass `nil` if you want your animation state from the first frame to the last frame, but you want to configure playback  
	---Alternatively you can just change states.default state as shown in example_3A or manually by changing sprite.states.default's values
	function example_1C()
		sprite = AnimatedSprite.new(imagetable)
		sprite:addState("idle", nil, nil, {tickStep = 2}, true) -- "True" states for autoplay, substitutes :playAnimation()
	end

	---Best practice. Using states from configuration json file
	function example_2A()
		local states = AnimatedSprite.loadStates("path")
		sprite = AnimatedSprite.new(imagetable, states, true) -- "True" states for autoplay, substitutes :playAnimation()
	end

	---You can start animation later after initialising sprite
	function example_2B()
		local states = AnimatedSprite.loadStates("path")
		sprite = AnimatedSprite.new(imagetable, states)
		sprite:playAnimation()
	end

	---You can set up states later after initialising sprite
	function example_2C()
		local states = AnimatedSprite.loadStates("path")
		sprite = AnimatedSprite.new(imagetable)
		sprite:setStates(states)
		sprite:playAnimation()
	end

	---One line initialisation
	function example_2D()
		sprite = AnimatedSprite.new(imagetable, AnimatedSprite.loadStates("path"), true) -- "True" states for autoplay, substitutes :playAnimation()
	end

	---Only "default" state can be partly updated, other states will be fully overwritten when using :setStates  
	---If you want to update some values, please refer to them directly (example_3B)
	function example_3A()
		sprite = AnimatedSprite.new(imagetable)
		sprite:setStates({
			{
				name = "default",
				onFrameChangedEvent = function (self) print(self._currentFrame) end,
				onStateChangedEvent = function (self) print("State changed to", self.currentState) end,
				onLoopFinishedEvent = function (self) print("Finished loops =", self._loopsFinished) end,
				onAnimationEndEvent = function (self) print("Ended animation of the state", self.currentState) end
			},
			{
				name = "idle",
				firstFrameIndex = 3,
				framesCount = 5,
				tickStep = 4,
				yoyo = true,
			},
			{
				name = "run",
				firstFrameIndex = "idle",
				framesCount = 10,
				tickStep = 2,
				loop = 5,
				nextAnimation = "idle"
			}
		}, true, "run")
	end

	---You can directly change values in states on the go
	function example_3B()
		local states = AnimatedSprite.loadStates("path")
		sprite = AnimatedSprite.new(imagetable, states)
		sprite.states.default.tickStep = 4
		sprite.states.idle.flip = gfx.kImageFlippedXY
		sprite.states["idle"].onFrameChangedEvent = function (self) print(self._currentFrame) end
		sprite:playAnimation()
	end
end

--#endregion


class("AnimatedSprite").extends(gfx.sprite)

---@param imagetable table
---@param states? table If provided, calls `setStates(states)` after initialisation
---@param animate? boolean If `True`, then the animation of default state will start after initialisation. Default: `False`
function AnimatedSprite.new(imagetable, states, animate)
	return AnimatedSprite(imagetable, states, animate)
end

function AnimatedSprite:init(imagetable, states, animate)
	AnimatedSprite.super.init(self)
	
	---@type table
	self.imagetable = imagetable
	assert( self.imagetable )

	self:add()

	self.defaultState = "default"
	self.states = {
		default = {
			name = "default",
			---@type integer|string
			firstFrameIndex = 1,
			framesCount = #self.imagetable,
			animationStartingFrame = 1,
			tickStep = 1,
			frameStep = 1,
			reverse = false,
			---@type boolean|integer
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
		}
	}

	self._enabled = false
	self._currentFrame = 0 -- purposely
	self._ticks = 1
	self._previousTicks = 1
	self._loopsFinished = 0
	self._currentYoyoDirection = true

	if (states) then
		self:setStates(states)
	end

	if (animate) then
		self:playAnimation()
	end
end

local function drawFrame(self)
	local state = self.states[self.currentState]
	self:setImage(self._image, state.flip, state.xScale, state.yScale)
end

local function setImage(self)
	local frames = self.states[self.currentState].frames
	if (frames) then
		self._image = self.imagetable[frames[self._currentFrame]]
	else
		self._image = self.imagetable[self._currentFrame]
	end
end

---Start/resume the animation  
---If `currentState` is nil then `defaultState` will be choosen as current
function AnimatedSprite:playAnimation()
	
	local state = self.states[self.currentState]

	if (type(self.currentState) == 'nil') then
		self.currentState = self.defaultState
		state = self.states[self.currentState]
		self._currentFrame = state.animationStartingFrame + state.firstFrameIndex - 1
	end

	if (self._currentFrame == 0) then
		self._currentFrame = state.animationStartingFrame + state.firstFrameIndex - 1
	end

	self._enabled = true
	self._previousTicks = self._ticks
	setImage(self)
	drawFrame(self)
	if (state.framesCount == 1) then
		self._loopsFinished += 1
		state.onFrameChangedEvent(self)
		state.onLoopFinishedEvent(self)
	else
		state.onFrameChangedEvent(self)
	end
end

---Stop the animation without resetting
function AnimatedSprite:pauseAnimation()
	self._enabled = false
end

---Play/Pause animation based on current state
function AnimatedSprite:toggleAnimation()
	if (self._enabled) then
		self:pauseAnimation()
	else
		self:playAnimation()
	end
end

---Stop and reset the animation
---After calling `playAnimation` `defaulState` will be played
function AnimatedSprite:stopAnimation()
	self:pauseAnimation()
	self.currentState = nil
	self._currentFrame = 0 -- purposely
	self._ticks = 1
	self._previousTicks = self._ticks
	self._loopsFinished = 0
	self._currentYoyoDirection = true
end

local function addState(self, params)
	if (self.defaultState == "default") then
		self.defaultState = params.name -- Init first added state as default
	end

	self.states[params.name] = {}
	local state = self.states[params.name]
	local default = self.states.default

	local function setParam(name, value)
		if(value == nil) then
			state[name] = default[name]
		else
			state[name] = value
		end
	end

	params = params or {}

	state.name = params.name
	if (params.frames ~= nil) then
		state["frames"] = params.frames -- Custom animation for non-sequential frames from the imagetable
		params.framesCount = params.framesCount and params.framesCount or #params.frames
		if (type(params.firstFrameIndex) ~= "string") then
			params.firstFrameIndex = params.firstFrameIndex and params.firstFrameIndex or 1
		end
	end
	if (type(params.firstFrameIndex) == "string") then
		local thatState = self.states[params.firstFrameIndex]
		state["firstFrameIndex"] = thatState.firstFrameIndex + thatState.framesCount
	else
		setParam("firstFrameIndex", params.firstFrameIndex) -- index in the imagetable for the firstFrame
	end
	state["framesCount"] = params.framesCount and params.framesCount or (self.states.default.framesCount - state.firstFrameIndex + 1) -- This state frames count
	setParam("nextAnimation", params.nextAnimation) -- Animation to switch to after this finishes
	if (params.nextAnimation == nil) then
		setParam("loop", params.loop) -- You can put in number of loops or true for endless loop
	else
		state["loop"] = params.loop or false
	end
	setParam("reverse", params.reverse) -- You can reverse animation sequence
	state["animationStartingFrame"] = params.animationStartingFrame or (state.reverse and state.framesCount or 1) -- Frame to start the animation from
	setParam("tickStep", params.tickStep) -- Speed of animation (2 = every second frame)
	setParam("frameStep", params.frameStep) -- Number of images to skip on next frame
	setParam("yoyo", params.yoyo) -- Ping-pong animation (from 1 to n to 1 to n)
	setParam("flip", params.flip) -- You can set up flip mode, read Playdate SDK Docs for more info
	setParam("xScale", params.xScale) -- Optional scale for horizontal axis
	setParam("yScale", params.yScale) -- Optional scale for vertical axis

	setParam("onFrameChangedEvent", params.onFrameChangedEvent) -- Event that will be raised when animation moves to the next frame
	setParam("onStateChangedEvent", params.onStateChangedEvent) -- Event that will be raised when animation state changes
	setParam("onLoopFinishedEvent", params.onLoopFinishedEvent) -- Event that will be raised when animation changes to the final frame
	setParam("onAnimationEndEvent", params.onAnimationEndEvent) -- Event that will be raised after animation in this state ends

	return state
end

---Parse `json` file with animation configuration
---@param path string Path to the file
---@return table config You can use it in `setStates(states)`
function AnimatedSprite.loadStates(path)
	return assert(json.decodeFile(path), "Requested JSON parse failed. Path: " .. path)
end

---Returns reference to the current states
---@return table states Reference to the current states
function AnimatedSprite:getLocalStates()
	return self.states
end

---Copies states
---@return table states Deepcopy of the current states
function AnimatedSprite:copyLocalStates()
	return table.deepcopy(self.states)
end

---All states from the `states` will be added to the current state machine (overwrites values in case of conflict)
---@param states table State machine state list, you can get one by calling `loadStates`
---@param animate? boolean If `True`, then the animation of default/current state will start immediately after. Default: `False`
---@param defaultState? string If provided, changes default state
function AnimatedSprite:setStates(states, animate, defaultState)
	local statesCount = #states

	if (statesCount == 0) then
		addState(self, states)
		if (defaultState) then
			self.defaultState = defaultState
		end
		if (animate) then
			self:playAnimation()
		end
		return
	end
	for i = 1, statesCount do
		if (states[i].name ~= "default") then
			addState(self, states[i])
		else
			local default = self.states.default
			for key, value in pairs(states[i]) do
				default[key] = value
			end
		end
	end

	if (defaultState) then
		self.defaultState = defaultState
	end
	if (animate) then
		self:playAnimation()
	end
end

---You can add new states to the state machine using this function
---@param name string Name of the state, should be unique, used as id
---@param startFrame? integer Index of the first frame in the imagetable (starts from 1). Default: `1` (from states.default)
---@param endFrame? integer Index of the last frame in the imagetable. Default: last frame (from states.default)
---@param params? table See examples
---@param animate? boolean If `True`, then the animation of this state will start immediately after. Default: `False`
function AnimatedSprite:addState(name, startFrame, endFrame, params, animate)
	params.firstFrameIndex = startFrame or 1
	params.framesCount = endFrame
	params.name = name

	addState(self, params)

	if (animate) then
		self.currentState = name
		self:playAnimation()
	end

	return {
		asDefault = function ()
			self.defaultState = name
		end
	}
end

---Changes current state to an existing state
---@param name string New state name
---@param instant? boolean If `False`, then the change will be performed after the last frame of this loop iteration. Default: `True`
function AnimatedSprite:changeState(name, instant)
	if (name == self.currentState) then
		return
	end
	local instant = type(instant) == "nil" and true or instant
	local state = self.states[name]
	assert (state)
	self.currentState = name
	self._currentFrame = 0 -- purposely
	self._loopsFinished = 0
	self._currentYoyoDirection = true
	state.onStateChangedEvent(self)
	if (instant) then
		self:playAnimation()
	end
end

---Force to move animation state machine to the next state
---@param instant? boolean If `False` change will be performed after the final frame of this loop iteration. Default: `True`
function AnimatedSprite:forceNextAnimation(instant)
	local instant = type(instant) == "nil" and true or instant
	local state = self.states[self.currentState]
	
	if (instant) then
		forcedSwitchOnLoop = nil
		if (state.nextAnimation) then
			self:changeState(state.nextAnimation, false)
		else
			self:stopAnimation()
		end
		state.onAnimationEndEvent(self)
	else
		forcedSwitchOnLoop = self._loopsFinished + 1
	end
end

---Sets default state.
---@param name string Name of an existing state
function AnimatedSprite:setDefaultState(name)
	assert (self.states[name])
	self.defaultState = name
end

---Print all states from this state machine table to the console
function AnimatedSprite:printAllStates()
	printTable(self.states)
end

---Function that will procees the animation to the next step without redrawing sprite
local function processAnimation(self)
	local state = self.states[self.currentState]

	function changeFrame(value)
		value += state.firstFrameIndex
		self._currentFrame = value
		state.onFrameChangedEvent(self)
	end

	local reverse = state.reverse
	local frame = self._currentFrame - state.firstFrameIndex
	local framesCount = state.framesCount
	local frameStep = state.frameStep

	if (self._currentFrame == 0) then -- true only after changing state
		self._currentFrame = state.animationStartingFrame + state.firstFrameIndex - 1
		if (framesCount == 1) then
			self._loopsFinished += 1
			state.onFrameChangedEvent(self)
			state.onLoopFinishedEvent(self)
			return
		else
			state.onFrameChangedEvent(self)
		end
		setImage(self)
		return
	end

	if (framesCount == 1) then -- if this state is only 1 frame long
		self._loopsFinished += 1
		state.onFrameChangedEvent(self)
		state.onLoopFinishedEvent(self)
		return
	end

	if (state.yoyo) then
		if (reverse ~= self._currentYoyoDirection) then
			if (frame + frameStep + 1 < framesCount) then
				changeFrame(frame + frameStep)
			else
				if (frame ~= framesCount - 1) then
					self._loopsFinished += 1
					changeFrame(2 * framesCount - frame - frameStep - 2)
					state.onLoopFinishedEvent(self)
				else
					changeFrame(2 * framesCount - frame - frameStep - 2)
				end
				self._currentYoyoDirection = not self._currentYoyoDirection
			end
		else
			if (frame - frameStep > 0) then
				changeFrame(frame - frameStep)
			else
				if (frame ~= 0) then
					self._loopsFinished += 1
					changeFrame(frameStep - frame)
					state.onLoopFinishedEvent(self)
				else
					changeFrame(frameStep - frame)
				end
				self._currentYoyoDirection = not self._currentYoyoDirection
			end
		end
	else
		if (reverse) then
			if (frame - frameStep > 0) then
				changeFrame(frame - frameStep)
			else
				if (frame ~= 0) then
					self._loopsFinished += 1
					changeFrame((frame - frameStep) % framesCount)
					state.onLoopFinishedEvent(self)
				else
					changeFrame((frame - frameStep) % framesCount)
				end
			end
		else
			if (frame + frameStep + 1 < framesCount) then
				changeFrame(frame + frameStep)
			else
				if (frame ~= framesCount - 1) then
					self._loopsFinished += 1
					changeFrame((frame + frameStep) % framesCount)
					state.onLoopFinishedEvent(self)
				else
					changeFrame((frame + frameStep) % framesCount)
				end
			end
		end
	end

	setImage(self)
end

---Called by default in the `:update()` function.  
---Must be called once per frame if you overwrite `:update()`.  
---Invoke manually to move the animation to the next frame.
function AnimatedSprite:updateAnimation()
	if (self._enabled) then
		self._ticks += 1
		if ((self._ticks - self._previousTicks) >= self.states[self.currentState].tickStep) then
			local state = self.states[self.currentState]
			processAnimation(self)
			drawFrame(self)
			self._previousTicks += state.tickStep
			local loop = state.loop
			local loopsFinished = self._loopsFinished
			if (type(loop) == "number" and loop <= loopsFinished or 
				type(loop) == "boolean" and not loop and loopsFinished >= 1 or
				forcedSwitchOnLoop == loopsFinished) then
				self:forceNextAnimation(state, true)
			end
		end
	end
end

function AnimatedSprite:update()
	if (self.alive) then
		self:updateAnimation()
	end
end