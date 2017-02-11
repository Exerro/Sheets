
 -- @once
 -- @print Including sheets.core.Sheet

class "Sheet"
	implements "ITagged"
	implements "ISize"
{
	x = 0;
	y = 0;
	z = 0;

	style = nil;

	parent = nil;

	-- internal
	changed = true;
	canvas = nil;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;
	handles_keyboard = false;
	handles_text = false;
	values = nil;
}

function Sheet:Sheet( x, y, width, height )
	if x ~= nil then self:set_x( x ) end
	if y ~= nil then self:set_y( y ) end
	if width ~= nil then self:set_width( width ) end
	if height ~= nil then self:set_height( height ) end

	self.canvas:set_width( self.width )
	self.canvas:set_height( self.height )
end

function Sheet:initialise()
	self.values = ValueHandler( self )
	self.canvas = DrawingCanvas( 1, 1 )

	self:ITagged()
	self:ISize()

	self.values:add( "x", 0 )
	self.values:add( "y", 0 )
	self.values:add( "z", 0, { custom_update_code = "if self.parent then self.parent:reposition_child_z_index( self ) end" } )
	self.values:add( "parent", nil, function( self, parent )
		if parent and not class.type_of( parent, Sheet ) and not class.type_of( parent, Screen ) then
			Exception.throw( IncorrectParameterException( "expected Sheet or Screen parent, got " .. class.type( parent ), 2 ) )
		end

		if parent then
			return parent:add_child( self )
		else
			return self:remove()
		end
	end )
end

function Sheet:remove()
	if self.parent then
		return self.parent:remove_child( self )
	end
end

function Sheet:is_visible()
	return self.parent and self.parent:is_child_visible( self )
end

function Sheet:bring_to_front()
	if self.parent then
		return self:set_parent( self.parent ) -- TODO: improve this
	end
	return self
end

function Sheet:set_changed( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then -- TODO: why not self.parent.changed?
		self.parent:set_changed()
	end
	return self
end

function Sheet:set_cursor_blink( x, y, colour )
	colour = colour or GREY

	parameters.check( 3, "x", "number", x, "y", "number", y, "colour", "number", colour )

	self.cursor_active = true
	self.cursor_x = x
	self.cursor_y = y
	self.cursor_colour = colour

	return self
end

function Sheet:reset_cursor_blink()
	self.cursor_active = false
	return self
end

function Sheet:tostring()
	return "[Instance] " .. self.class:type() .. " " .. tostring( self.id )
end

function Sheet:update( dt )
	self.values:update( dt )

	if self.on_update then
		self:on_update( dt )
	end
end

function Sheet:draw()
	if self.changed then
		local cx, cy, cc

		self:reset_cursor_blink()

		if self.on_pre_draw then
			self:on_pre_draw()
		end

		if cx then
			self:set_cursor_blink( cx, cy, cc )
		end

		if self.on_post_draw then
			self:on_post_draw()
		end

		self.changed = false
	end
end

function Sheet:handle( event )
	if event:type_of( MouseEvent ) then
		if event:is( EVENT_MOUSE_PING ) and event:is_within_area( 0, 0, self.width, self.height ) and event.within then
			event.button[#event.button + 1] = self
		end
		self:on_mouse_event( event )
	elseif event:type_of( KeyboardEvent ) and self.handles_keyboard and self.on_keyboard_event then
		self:on_keyboard_event( event )
	elseif event:type_of( TextEvent ) and self.handles_text and self.on_text_event then
		self:on_text_event( event )
	end
end

function Sheet:on_mouse_event( event )
	if not event.handled and event:is_within_area( 0, 0, self.width, self.height ) and event.within then
		if event:is( EVENT_MOUSE_DOWN ) then
			return event:handle( self )
		end
	end
end
