
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionAnimator'
 -- @endif

 -- @print Including sheets.interfaces.IPositionAnimator

 -- @defineifndef SHEETS_DEFAULT_TRANSITION_TIME .3
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_EASING SHEETS_EASING_TRANSITION

IPositionAnimator = {}

function IPositionAnimator:transitionX( to, time, easing )
	local a = Animation():setRounded()
		:addKeyFrame( self.x, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing or SHEETS_DEFAULT_TRANSITION_EASING )
	self:addAnimation( "x", self.setX, a )
	return a
end

function IPositionAnimator:transitionY( to, time, easing )
	local a = Animation():setRounded()
		:addKeyFrame( self.y, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing or SHEETS_DEFAULT_TRANSITION_EASING )
	self:addAnimation( "y", self.setY, a )
	return a
end

function IPositionAnimator:transitionWidth( to, time, easing )
	local a = Animation():setRounded()
		:addKeyFrame( self.width, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing or SHEETS_DEFAULT_TRANSITION_EASING )
	self:addAnimation( "width", self.setWidth, a )
	return a
end

function IPositionAnimator:transitionHeight( to, time, easing )
	local a = Animation():setRounded()
		:addKeyFrame( self.height, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing or SHEETS_DEFAULT_TRANSITION_EASING )
	self:addAnimation( "height", self.setHeight, a )
	return a
end

function IPositionAnimator:transitionInLeft( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition in" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.x, to or 0, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_ENTRANCE )
	self:addAnimation( "x", self.setX, a )
end

function IPositionAnimator:transitionOutLeft( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition out" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.x, to or -self.width, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_EXIT )

	local f = a:getLastAdded()

	self:addAnimation( "x", self.setX, a )

	function f.onFinish()
		self:remove()
	end
end

function IPositionAnimator:transitionInRight( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition in" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.x, to or self.parent.width - self.width, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_ENTRANCE )
	self:addAnimation( "x", self.setX, a )
end

function IPositionAnimator:transitionOutRight( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition out" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.x, to or self.parent.width, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_EXIT )

	local f = a:getLastAdded()

	self:addAnimation( "x", self.setX, a )

	function f.onFinish()
		self:remove()
	end
end

function IPositionAnimator:transitionInTop( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition in" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.y, to or 0, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_ENTRANCE )
	self:addAnimation( "y", self.setY, a )
end

function IPositionAnimator:transitionOutTop( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition out" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.y, to or -self.height, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_EXIT )

	local f = a:getLastAdded()

	self:addAnimation( "y", self.setY, a )

	function f.onFinish()
		self:remove()
	end
end

function IPositionAnimator:transitionInBottom( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition in" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.y, to or self.parent.height - self.height, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_ENTRANCE )
	self:addAnimation( "y", self.setY, a )
end

function IPositionAnimator:transitionOutBottom( time, to )
	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot transition out" )
	end
	local a = Animation():setRounded()
		:addKeyFrame( self.y, to or self.parent.height, time or SHEETS_DEFAULT_TRANSITION_TIME, SHEETS_EASING_EXIT )

	local f = a:getLastAdded()

	self:addAnimation( "y", self.setY, a )

	function f.onFinish()
		self:remove()
	end
end
