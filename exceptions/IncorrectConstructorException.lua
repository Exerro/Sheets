
 -- @once
 -- @print Including sheets.exceptions.IncorrectConstructorException

class "IncorrectConstructorException" extends "Exception"

function IncorrectConstructorException:IncorrectConstructorException( data, level )
	return self:Exception( "IncorrectConstructorException", data, level )
end
