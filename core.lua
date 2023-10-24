--[[
MIT License

Copyright (c) 2023 Graham Ranson of Glitch Games Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

--- Class creation.
local Time = {}

-- Localised functions.
local getTimer = system.getTimer
local time = os.time
local date = os.date
local floor = math.floor
local mod = math.mod
local format = string.format

-- Localised values.

function Time:new( params )

	-- Get the params, if any
	self._params = params or {}

	-- Current delta time
	self._dt = 0

	-- The previous time
	self._previousTime = 0

	-- Calculate the fps factor
	self._fpsFactor = 1000 / display.fps

	-- Set our current frames to a passed in value or 0
	self._frames = self._params.frames or 0

	-- Get the time that we started
	self._start = time()

	-- Add the main enter frame handler
	Runtime:addEventListener( "enterFrame", self )
	
	return self

end

--- EnterFrame handler for this Time.
-- @param event The enterFrame event table.
function Time:enterFrame( event )
	
	-- Increment the frame count
	self._frames = self._frames + 1

	-- Get the system timer
	local timer = getTimer()

	-- Calculate the current delta time
	self._dt = ( timer - self._previousTime ) / self._fpsFactor

	-- Set the previous time
	self._previousTime = timer

	-- Calculate the current fps
	self._fps = self._frames / ( time() - self._start ) or 0

end

--- Gets the delta time for the game.
-- @return The delta time.
function Time:delta()
	return self._dt --s * 60
end

--- Gets the fps for the game.
-- @return The fps.
function Time:fps()
	return self._fps or 0
end

--- Sets the lifetime frames of the Time.
-- @param frames The frame count to set. Optional, defaults to 0.
function Time:setFrames( frames )
	self._frames = frames or 0
end

--- Gets the lifetime frames of the Time.
-- @return The frame count.
function Time:getFrames()
	return self._frames
end

--- Converts a frame count to a table containing days, hours, minutes, seconds, and milliseconds.
-- @param frames The frame count to use. Optional, defaults to the current frame time of the Time.
-- @return The time.
function Time:framesToTime( frames )

	-- Get the frames passed in our our current frames or 0 as a backup
	local frames = frames or self:getFrames() or 0

	-- Convert frames to seconds
	frames = frames / display.fps

	-- Table to store the new time
	local time = {}

	-- Calculate the day count
	time.days = floor( frames / 86400 )

	-- Calculate the hour count
	time.hours = floor( mod( frames or 0, 86400 ) / 3600 )

	-- Calculate the minute count
	time.minutes = floor( mod( frames or 0, 3600 ) / display.fps )

	-- Calculate the second count
	time.seconds = floor( mod( frames or 0, display.fps ) )

	-- Calculate the millisecond count
	time.milliseconds = floor( mod( ( frames or 0 ) * display.fps, display.fps ) )

	-- Return the time table
	return time

end

-- Calculates the current game date based on a starting date and multiplier factor.
-- @param start The starting timestamp. Optional, defaults to Jan 1 1970.
-- @param multiplier A scale factor for creating an accelerated game clock like GTA etc. Optional, defaults to 1.
-- @param format A date format for converting a timestamp to a human readable format using os.date. Optional.
-- @return The calculated date, either as a timestamp or string if a format has been passed in.
function Time:date( start, multiplier, format )

	-- Calculate the date
	local calculatedDate = ( start or 0 ) + ( ( self:getFrames() / display.fps ) * ( multiplier or 1 ) )

	-- And return it
	return format and date( format, calculatedDate ) or calculatedDate

end

-- Starts the timer.
function Time:start()

	-- Get the current system time
	self._startTime = getTimer()

end

-- Stops the timer.
-- @param message The message to get displayed alongside the elapsed time. Optional.
-- @return The elapsed time.
function Time:stop( message )

	-- Calculate the elapsed time
	local elapsed = getTimer() - self._startTime

	-- Print out the time and message
	print( format('%s = %1.2f ms', message or "Time", elapsed ) )

	-- Return the elapsed time
	return tonumber( format('%1.2f', elapsed ) )

end

--- Destroys the time library.
function Time:destroy()

	-- Nil out the delta time
	self._dt = nil

	-- Nil out the fps
	self._fps = nil

	-- Nil out the frames
	self._frames = nil

	-- Nil out the previous time
	self._previousTime = nil

	-- Nil out the fps factor
	self._fpsFactor = nil

	-- Remove the main enter frame handler
	Runtime:removeEventListener( "enterFrame", self )

end

return Time
