
 -- @include exceptions.DynamicParserException

 -- @print including(dynamic.DynamicValueParser)

local query_operator_list = { ["&"] = 1, ["|"] = 0, [">"] = 2 }

local is_operator = {
	["+"] = true;
	["-"] = true;
	["*"] = true;
	["/"] = true;
	["%"] = true;
	["^"] = true;
	["&"] = true;
	["|"] = true;
	[">"] = true;
	["<"] = true;
	[">="] = true;
	["<="] = true;
	["!="] = true;
	["=="] = true;
}

local op_precedences = {
	["|"] = 0;
	["&"] = 1;
	["!="] = 2;
	["=="] = 2;
	[">"] = 3;
	["<"] = 3;
	[">="] = 3;
	["<="] = 3;
	["+"] = 4;
	["-"] = 4;
	["*"] = 5;
	["/"] = 5;
	["%"] = 5;
	["^"] = 6;
}

local lua_operators = {
	["|"] = "or";
	["&"] = "and";
	["!="] = "~=";
}

local function parse_name( stream )
	return stream:skip_value( TOKEN_IDENTIFIER )
end

@ifn DEBUG
	@private
@endif
@class DynamicValueParser {
	stream = nil;
	flags = {};
}

function DynamicValueParser:DynamicValueParser( stream )
	self.stream = stream
	self.flags = {}
end

function DynamicValueParser:parse_primary_expression()
	local position = self.stream:peek().position

	if self.stream:skip( TOKEN_KEYWORD, "self" ) then
		return { type = DVALUE_SELF, position = position }

	elseif self.stream:skip( TOKEN_KEYWORD, "application" ) then
		return { type = DVALUE_APPLICATION, position = position }

	elseif self.stream:skip( TOKEN_KEYWORD, "parent" ) then
		return { type = DVALUE_PARENT, position = position }

	elseif self.stream:test( TOKEN_IDENTIFIER ) then
		return { type = DVALUE_IDENTIFIER, value = parse_name( self.stream ), position = position }

	elseif self.stream:test( TOKEN_INTEGER ) then
		return { type = DVALUE_INTEGER, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_FLOAT ) then
		return { type = DVALUE_FLOAT, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_BOOLEAN ) then
		return { type = DVALUE_BOOLEAN, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_STRING ) then
		return { type = DVALUE_STRING, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
		if self.flags.enable_queries then
			self.stream:next()
		else
			Exception.throw( DynamicParserException.disabled_queries( self.stream:peek().position ) )
		end

		local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
		local query = self:parse_query_term( true )

		return { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = { type = DVALUE_APPLICATION }, position = position }
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		local expr = self:parse_expression()
			or Exception.throw( DynamicParserException.expected_expression( "after '('", self.stream:peek().position ) )

		return self.stream:skip( TOKEN_SYMBOL, ")" ) and expr
			or Exception.throw( DynamicParserException.expected_closing( ")", self.stream:peek().position ) )
	end

	return nil
end

function DynamicValueParser:parse_term()
	local operators = {}
	local op_positions = {}

	while self.stream:test( TOKEN_SYMBOL, "#" )
	   or self.stream:test( TOKEN_SYMBOL, "!" )
	   or self.stream:test( TOKEN_SYMBOL, "-" )
	   or self.stream:test( TOKEN_SYMBOL, "+" ) do
		op_positions[#op_positions + 1] = self.stream:peek().position
		operators[#operators + 1] = self.stream:next().value
	end

	local term = self:parse_primary_expression()

	while term do
		local position = self.stream:peek().position

		if self.stream:skip( TOKEN_SYMBOL, "." ) then
			local index = parse_name( self.stream )
			           or self.stream:skip_value( TOKEN_KEYWORD, "parent" )
		   			   or self.stream:skip_value( TOKEN_KEYWORD, "application" )
			           or Exception.throw( DynamicParserException.invalid_dotindex( self.stream:peek() ) )

			term = { type = DVALUE_DOTINDEX, value = term, index = index, position = position }

		elseif self.stream:skip( TOKEN_SYMBOL, "#" ) then
			local tag = parse_name( self.stream )
			         or self.stream:skip_value( TOKEN_KEYWORD )
					 or Exception.throw( DynamicParserException.invalid_tagname( self.stream:peek() ) )

			term = { type = DVALUE_TAG_CHECK, value = term, tag = tag, position = position }

		elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
			local parameters = {}

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
				repeat
					while self.stream:skip( TOKEN_WHITESPACE ) do end
					parameters[#parameters + 1] = self:parse_expression()
						or Exception.throw( DynamicParserException.expected_expression( "for function parameter", self.stream:peek().position ) )
					while self.stream:skip( TOKEN_WHITESPACE ) do end
				until not self.stream:skip( TOKEN_SYMBOL, "," )

				if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
					Exception.throw( DynamicParserException.expected_closing( ")", self.stream:peek().position ) )
				end
			end

			term = { type = DVALUE_CALL, value = term, parameters = parameters, position = position }

		elseif self.stream:skip( TOKEN_SYMBOL, "[" ) then
			while self.stream:skip( TOKEN_WHITESPACE ) do end
			local index = self:parse_expression() or Exception.throw( DynamicParserException.expected_expression( "for index", self.stream:peek().position ) )
			while self.stream:skip( TOKEN_WHITESPACE ) do end

			if not self.stream:skip( TOKEN_SYMBOL, "]" ) then
				Exception.throw( DynamicParserException.expected_closing( "]", self.stream:peek().position ) )
			end

			term = { type = DVALUE_INDEX, value = term, index = index, position = position }

		elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
			if self.flags.enable_queries then
				self.stream:next()
			else
				Exception.throw( DynamicParserException.disabled_queries( self.stream:peek().position ) )
			end

			local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
			local query = self:parse_query_term( true )

			term = { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = term, position = position }
		elseif self.stream:test( TOKEN_SYMBOL, "%" ) then
			if self.flags.enable_percentages then
				self.stream:next()
			else
				Exception.throw( DynamicParserException.disabled_percentages( self.stream:peek().position ) )
			end

			term = { type = DVALUE_PERCENTAGE, value = term, position = position }
		else
			break
		end
	end

	for i = #operators, 1, -1 do
		term = term and { type = DVALUE_UNEXPR, value = term, operator = operators[i], position = op_positions[i] }
	end

	return term
end

function DynamicValueParser:parse_expression()
	local operand_stack = { self:parse_term() }
	local operator_stack = {}
	local precedences = {}
	local positions = {}

	if #operand_stack == 0 then
		return nil
	end

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) and is_operator[self.stream:peek().value] do
		positions[#positions + 1] = self.stream:peek().position
		local op = self.stream:next().value
		local prec = op_precedences[op]

		while precedences[1] and precedences[#precedences] >= prec do
			local rvalue = table.remove( operand_stack, #operand_stack )

			table.remove( precedences, #precedences )

			operand_stack[#operand_stack] = {
				type = DVALUE_BINEXPR;
				operator = table.remove( operator_stack, #operator_stack );
				lvalue = operand_stack[#operand_stack];
				rvalue = rvalue;
				position = table.remove( positions, #positions );
			}
		end

		while self.stream:skip( TOKEN_WHITESPACE ) do end

		operand_stack[#operand_stack + 1] = self:parse_term()
			or Exception.throw( DynamicParserException.expected_expression( "after operator '" .. op .. "'", positions[#positions] ) )
		operator_stack[#operator_stack + 1] = lua_operators[op] or op
		precedences[#precedences + 1] = prec

		while self.stream:skip( TOKEN_WHITESPACE ) do end
	end

	while precedences[1] do
		local rvalue = table.remove( operand_stack, #operand_stack )

		table.remove( precedences, #precedences )

		operand_stack[#operand_stack] = {
			type = DVALUE_BINEXPR;
			operator = table.remove( operator_stack, #operator_stack );
			lvalue = operand_stack[#operand_stack];
			rvalue = rvalue;
			position = table.remove( positions, #positions );
		}
	end

	return operand_stack[1]
end

function DynamicValueParser:parse_query_term( in_dynamic_value )
	local negation_count, obj = 0

	while self.stream:skip( TOKEN_SYMBOL, "!" ) do
		negation_count = negation_count + 1
	end

	if self.stream:test( TOKEN_IDENTIFIER ) then -- ID
		local name = self.stream:next().value

		if self.stream:skip( TOKEN_SYMBOL, "?" ) then
			obj = { type = QUERY_CLASS, value = name }
			self.stream:skip( TOKEN_WHITESPACE )
		else
			obj = { type = QUERY_ID, value = name }
		end
	elseif self.stream:skip( TOKEN_SYMBOL, "*" ) then
		obj = { type = QUERY_ANY }
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		print( self.stream:peek().value )
		obj = self:parse_query()

		if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
			Exception.throw( DynamicParserException.expected_closing( ")", self.stream:skip().position ) )
		end
	end

	local tags = {}

	while (not in_dynamic_value or not obj) and self.stream:skip( TOKEN_SYMBOL, "#" ) do -- tags
		local tag = { type = QUERY_TAG, value = parse_name( self.stream ) or self.stream:skip_value( TOKEN_KEYWORD ) or Exception.throw( DynamicParserException.invalid_tagname( self.stream:peek() ) ) }

		if obj then
			obj = { type = QUERY_OPERATOR, operator = "&", lvalue = obj, rvalue = tag }
		else
			obj = tag
		end

		self.stream:skip( TOKEN_WHITESPACE )
	end

	if self.stream:skip( TOKEN_SYMBOL, "[" ) then
		local attributes = {}

		repeat
			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local name = parse_name( self.stream ) or Exception.throw( DynamicParserException.invalid_property( self.stream:peek() ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local comparison
			    = self.stream:skip_value( TOKEN_SYMBOL, "=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "!=" )
			   or Exception.throw( DynamicParserException.invalid_comparison( self.stream:peek().position ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local value = self:parse_expression() or Exception.throw( DynamicParserException.expected_expression( "after comparison '" .. comparison .. "'", self.stream:peek().position ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			attributes[#attributes + 1] = {
				name = name;
				comparison = comparison;
				value = value;
			}
		until not self.stream:skip( TOKEN_SYMBOL, "," )

		while self.stream:skip( TOKEN_WHITESPACE ) do end

		if not self.stream:skip( TOKEN_SYMBOL, "]" ) then
			Exception.throw( DynamicParserException.expected_closing( "]", self.stream:peek().position ) )
		end

		obj = obj and {
			type = QUERY_OPERATOR;
			rvalue = obj;
			lvalue = { type = QUERY_ATTRIBUTES, attributes = attributes };
			operator = "&";
		} or { type = QUERY_ATTRIBUTES, attributes = attributes }
	end

	if not obj then
		Exception.throw( DynamicParserException.expected_query_term( self.stream:peek().position ) )
	end

	if negation_count % 2 == 1 then
		obj = { type = QUERY_NEGATE, value = obj }
	end

	return obj
end

function DynamicValueParser:parse_query( in_dynamic_value )
	local operands = { self:parse_query_term( in_dynamic_value ) }
	local operators = {}

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) do
		local prec = query_operator_list[self.stream:peek().value]

		if prec then
			while operators[1] and query_operator_list[operators[#operators]] >= prec do -- assumming left associativity for all operators
				operands[#operands - 1] = {
					type = QUERY_OPERATOR;
					lvalue = operands[#operands - 1];
					rvalue = table.remove( operands, #operands );
					operator = table.remove( operators, #operators );
				}
			end

			operators[#operators + 1] = self.stream:next().value

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			operands[#operands + 1] = self:parse_query_term( in_dynamic_value )

			while self.stream:skip( TOKEN_WHITESPACE ) do end
		else
			break
		end
	end

	while operators[1] do
		operands[#operands - 1] = {
			type = QUERY_OPERATOR;
			lvalue = operands[#operands - 1];
			rvalue = table.remove( operands, #operands );
			operator = table.remove( operators, #operators );
		}
	end

	return operands[1]
end
