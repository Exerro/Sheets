
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'test.elements.Panel'
 -- @endif

 -- @print Including test.elements.Panel

class "Panel" extends "Sheet" {}

function Panel:onPreDraw()
	self.canvas:clear( self.style:getField( self.class, "colour", "default" ) )
end

Style.addToTemplate( Panel, {
	["colour"] = LIGHTGREY;
} )