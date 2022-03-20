-----------------------------------------------
--- Sprite class extension with support of  ---
--- imagetables and finite state machine,   ---
--- with json configuration and autoplay.   ---
---            By @Whitebrim   git.brim.ml  ---
-----------------------------------------------

-- You can find examples and docs at https://github.com/Whitebrim/AnimatedSprite/wiki
-- Comments use EmmyLua style

import 'CoreLibs/object'
import 'CoreLibs/sprites'
local gfx <const> = playdate.graphics
local function emptyFunc()end

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
	assert(self.imagetable, "Imagetable is nil. Check if it was loaded correctly.")

	self:add()

	self.globalFlip = gfx.kImageUnflipped
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
	self:setImage(self._image, state.flip ~ self.globalFlip, state.xScale, state.yScale)
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
	assert(params.name, "The animation state is unnamed!")
	if (self.defaultState == "default") then
		self.defaultState = params.name -- Init first added state as default
	end

	self.states[params.name] = {}
	local state = self.states[params.name]
	setmetatable(state, {__index = self.states.default})

	params = params or {}

	state.name = params.name
	if (params.frames ~= nil) then
		state["frames"] = params.frames -- Custom animation for non-sequential frames from the imagetable
		params.framesCount = params.framesCount or #params.frames
		if (type(params.firstFrameIndex) ~= "string") then
			params.firstFrameIndex = params.firstFrameIndex or 1
		end
	end
	if (type(params.firstFrameIndex) == "string") then
		local thatState = self.states[params.firstFrameIndex]
		state["firstFrameIndex"] = thatState.firstFrameIndex + thatState.framesCount
	else
		state["firstFrameIndex"] = params.firstFrameIndex -- index in the imagetable for the firstFrame
	end
	state["framesCount"] = params.framesCount and params.framesCount or (self.states.default.framesCount - state.firstFrameIndex + 1) -- This state frames count
	state["nextAnimation"] = params.nextAnimation -- Animation to switch to after this finishes
	if (params.nextAnimation == nil) then
		state["loop"] = params.loop -- You can put in number of loops or true for endless loop
	else
		state["loop"] = params.loop or false
	end
	state["reverse"] = params.reverse -- You can reverse animation sequence
	state["animationStartingFrame"] = params.animationStartingFrame or (state.reverse and state.framesCount or 1) -- Frame to start the animation from
	state["tickStep"] = params.tickStep -- Speed of animation (2 = every second frame)
	state["frameStep"] = params.frameStep -- Number of images to skip on next frame
	state["yoyo"] = params.yoyo -- Ping-pong animation (from 1 to n to 1 to n)
	state["flip"] = params.flip -- You can set up flip mode, read Playdate SDK Docs for more info
	state["xScale"] = params.xScale -- Optional scale for horizontal axis
	state["yScale"] = params.yScale -- Optional scale for vertical axis

	state["onFrameChangedEvent"] = params.onFrameChangedEvent -- Event that will be raised when animation moves to the next frame
	state["onStateChangedEvent"] = params.onStateChangedEvent -- Event that will be raised when animation state changes
	state["onLoopFinishedEvent"] = params.onLoopFinishedEvent -- Event that will be raised when animation changes to the final frame
	state["onAnimationEndEvent"] = params.onAnimationEndEvent -- Event that will be raised after animation in this state ends

	return state
end

---Parse `json` file with animation configuration
---@param path string Path to the file
---@return table config You can use it in `setStates(states)`
function AnimatedSprite.loadStates(path)
	return assert(json.decodeFile(path), "Requested JSON parse failed. Path: " .. path)
end

---Returns imagetable frame index that is currently displayed
---@return integer Current frame index
function AnimatedSprite:getCurrentFrameIndex()
	if (self.currentState and self.states[self.currentState].frames) then
		return self.states[self.currentState].frames[self._currentFrame]
	else
		return self._currentFrame
	end
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

	local function proceedState(state)
		if (state.name ~= "default") then
			addState(self, state)
		else
			local default = self.states.default
			for key, value in pairs(state) do
				default[key] = value
			end
		end
	end
	
	if (statesCount == 0) then
		proceedState(states)
		if (defaultState) then
			self.defaultState = defaultState
		end
		if (animate) then
			self:playAnimation()
		end
		return
	end

	for i = 1, statesCount do
		proceedState(states[i])
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
	params = params or {}
	params.firstFrameIndex = startFrame or 1
	params.framesCount = endFrame and (endFrame - params.firstFrameIndex + 1) or nil
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
---@param play? boolean If new animation should be played right away. Default: `True`
function AnimatedSprite:changeState(name, play)
	if (name == self.currentState) then
		return
	end
	local play = type(play) == "nil" and true or play
	local state = self.states[name]
	assert (state, "There's no state named \""..name.."\".")
	self.currentState = name
	self._currentFrame = 0 -- purposely
	self._loopsFinished = 0
	self._currentYoyoDirection = true
	state.onStateChangedEvent(self)
	if (play) then
		self:playAnimation()
	end
end

---Force to move animation state machine to the next state
---@param instant? boolean If `False` change will be performed after the final frame of this loop iteration. Default: `True`
---@param state? string Name of the state to change to. If not provided, animator will try to change to the next animation, else stop the animation.
function AnimatedSprite:forceNextAnimation(instant, state)
	local instant = type(instant) == "nil" and true or instant
	local currentState = self.states[self.currentState]
	self.forcedState = state
	
	if (instant) then
		self.forcedSwitchOnLoop = nil
		currentState.onAnimationEndEvent(self)
		if (currentState.name == self.currentState) then -- If state was not changed during the event then proceed
			if (type(self.forcedState) == "string") then
				self:changeState(self.forcedState)
				self.forcedState = nil
			elseif (currentState.nextAnimation) then
				self:changeState(currentState.nextAnimation)
			else
				self:stopAnimation()
			end
		end
	else
		self.forcedSwitchOnLoop = self._loopsFinished + 1
	end
end

---Sets default state.
---@param name string Name of an existing state
function AnimatedSprite:setDefaultState(name)
	assert (self.states[name], "State name is nil.")
	self.defaultState = name
end

---Print all states from this state machine table to the console
function AnimatedSprite:printAllStates()
	printTable(self.states)
end

---Function that will procees the animation to the next step without redrawing sprite
local function processAnimation(self)
	local state = self.states[self.currentState]

	local function changeFrame(value)
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
			local loop = state.loop
			local loopsFinished = self._loopsFinished
			if (type(loop) == "number" and loop <= loopsFinished or 
				type(loop) == "boolean" and not loop and loopsFinished >= 1 or
				self.forcedSwitchOnLoop == loopsFinished) then
				self:forceNextAnimation(true)
				return
			end
			processAnimation(self)
			drawFrame(self)
			self._previousTicks += state.tickStep
		end
	end
end

function AnimatedSprite:update()
	self:updateAnimation()
end