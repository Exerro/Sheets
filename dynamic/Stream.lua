
 -- @include exceptions.StreamException
 -- @print including(dynamic.Stream)

local escape_chars = {
	["n"] = "\n";
	["r"] = "\r";
	["t"] = "\t";
}

local symbols = {
	["("] = true; [")"] = true;
	["["] = true; ["]"] = true;
	["{"] = true; ["}"] = true;
	["."] = true; [":"] = true;
	[","] = true; [";"] = true;
	["="] = true;
	["$"] = true;
	["+"] = true; ["-"] = true;
	["*"] = true; ["/"] = true;
	["%"] = true; ["^"] = true;
	["#"] = true;
	["!"] = true;
	["&"] = true; ["|"] = true;
	["?"] = true;
	[">"] = true; ["<"] = true;
	[">="] = true; ["<="] = true;
	["!="] = true; ["=="] = true;
}

local keywords = {
	["self"] = true;
	["application"] = true;
	["parent"] = true;
}

@ifn DEBUG
	@private
@endif
@class Stream {
	position = 1;
	line = 1;
	character = 1;
	text = "";
	source = "stream";
	strline = "";
	lines = {}
}

function Stream:Stream( text, source, line )
	self.text = text
	self.source = source
	self.strline = text:match "(.-)\n" or text
	self.lines = {}

	while text do
		self.lines[#self.lines + 1] = text:match "^(.-)\n" or text
		text = text:match "^.-\n(.*)$"
	end
end

function Stream:get_strline()
	local text = self.text

	for i = 1, self.line - 1 do
		text = text:gsub( ".-\n", "" )
	end

	self.strline = text:match "(.-)\n" or text
end

function Stream:consume_string()
	local text = self.text
	local close = text:sub( self.position, self.position )
	local escaped = false
	local sub = string.sub
	local str = {}
	local schar, sline = self.character, self.line
	local sstrline = self.strline

	self.character = self.character + 1

	for i = self.position + 1, #text do
		local char = sub( text, i, i )

		if char == "\n" then
			self.line = self.line + 1
			self.character = 0
			self:get_strline()
		end

		if escaped then
			str[#str + 1] = escape_chars[char] or "\\" .. char
		elseif char == "\\" then
			escaped = true
		elseif char == close then
			self.position = i + 1
			self.character = self.character + 1
			return { type = TOKEN_STRING, value = table.concat( str ), position = {
				source = self.source;
				start = { character = schar, line = sline };
				finish = { character = self.character - 1, line = self.line };
				lines = self.lines;
			} }
		else
			str[#str + 1] = char
		end

		self.character = self.character + 1
	end

	Exception.throw( StreamException.unfinished_string {
		source = self.source, lines = self.lines;
		start = { character = schar, line = sline };
		finish = { character = self.character, line = self.line };
	} )
end

function Stream:consume_identifier()
	local word = self.text:match( "[%w_]+", self.position )
	local char = self.character
	local type = keywords[word] and TOKEN_KEYWORD
		or (word == "true" or word == "false" and TOKEN_BOOLEAN)
		or TOKEN_IDENTIFIER

	self.position = self.position + #word
	self.character = self.character + #word

	return { type = type, value = word, position = {
		source = self.source;
		start = { character = char, line = self.line };
		finish = { character = char + #word - 1, line = self.line };
		lines = self.lines;
	} }
end

function Stream:consume_number()
	local char = self.character
	local num = self.text:match( "%d*%.?%d+e[%+%-]?%d+", self.position )
	         or self.text:match( "%d*%.?%d+", self.position )
	local type = (num:find "%." or num:find "e%-")
		     and TOKEN_FLOAT or TOKEN_INTEGER

	self.position = self.position + #num
	self.character = self.character + #num

	return { type = type, value = num, position = {
		source = self.source;
		start = { character = char, line = self.line };
		finish = { character = char + #num - 1, line = self.line };
		lines = self.lines;
	} }
end

function Stream:consume_whitespace()
	local line, char = self.line, self.character
	local type = TOKEN_WHITESPACE
	local value = "\n"

	if self.text:sub( 1, 1 ) == "\n" then
		self.line = self.line + 1
		self.position = self.position + 1
		self.character = 1
		type = TOKEN_NEWLINE
		self:get_strline()
	else
		local n = #self.text:match( "^[^%S\n]+", self.position )

		value = self.text:sub( self.position, self.position + n - 1 )
		self.position = self.position + n
		self.character = self.character + n
	end

	return { type = type, value = value, position = {
		source = self.source;
		start = { character = char, line = self.line };
		finish = { character = self.character - 1, line = self.line };
		lines = self.lines;
	} }
end

function Stream:consume_symbol()
	local text = self.text
	local sub = string.sub
	local pos = self.position
	local s3 = sub( text, pos, pos + 2 )
	local s2 = sub( text, pos, pos + 1 )
	local s1 = sub( text, pos, pos + 0 )
	local value = s1
	local char = self.character

	if symbols[s3] then
		value = s3
	elseif symbols[s2] then
		value = s2
	elseif not symbols[s1] then
		Exception.throw( StreamException.unexpected_symbol( s1, {
			source = self.source, lines = self.lines;
			start = { character = self.character, line = self.line };
			finish = { character = self.character, line = self.line };
		} ) )
	end

	self.character = self.character + #value
	self.position = self.position + #value

	return { type = TOKEN_SYMBOL, value = value, position = {
		source = self.source;
		start = { character = char, line = self.line };
		finish = { character = char + #value - 1, line = self.line };
		lines = self.lines;
	} }
end

function Stream:consume()
	if self.position > #self.text then
		return { type = TOKEN_EOF, value = "", position = {
			source = self.source; lines = self.lines;
			start = { character = self.character, line = self.line };
			finish = { character = self.character, line = self.line };
		} }
	end

	local char = self.text:sub( self.position, self.position )

	if char == "\"" or char == "'" then
		return self:consume_string()
	elseif char == " " or char == "\t" or char == "\n" then
		return self:consume_whitespace()
	elseif self.text:find( "^%.?%d", self.position ) then
		return self:consume_number()
	elseif char:find "%w" or char == "_" then
		return self:consume_identifier()
	else
		return self:consume_symbol()
	end
end

function Stream:is_EOF()
	return self:peek().type == TOKEN_EOF
end

function Stream:peek()
	if self.buffer then
		return self.buffer
	end

	local token = self:consume()
	self.buffer = token
	return token
end

function Stream:next()
	local token = self:peek()
	self.buffer = nil
	return token
end

function Stream:test( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and token or nil
end

function Stream:skip( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and self:next() or nil
end

function Stream:skip_value( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and self:next().value or nil
end