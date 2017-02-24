
 -- @print including (interfaces.IThemed)

@interface IThemed {
	active_styles = {};
}

function IThemed:IThemed()
	self.active_styles = {}
end

function IThemed:update_styles( start )
	local plist = {}

	for i = start, #self.active_styles do
		for property, v in pairs( self.active_styles[i] ) do
			if not self[property .. "_is_defined"] then
				plist[property] = v
			end
		end
	end

	for property, v in pairs( plist ) do
		self["set_" .. property]( self, v )
	end
end
