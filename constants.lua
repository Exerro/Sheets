
 -- @define SHEETS_EVENT_MOUSE_DOWN 0
 -- @define SHEETS_EVENT_MOUSE_UP 1
 -- @define SHEETS_EVENT_MOUSE_CLICK 2
 -- @define SHEETS_EVENT_MOUSE_HOLD 3
 -- @define SHEETS_EVENT_MOUSE_DRAG 4
 -- @define SHEETS_EVENT_MOUSE_SCROLL 5
 -- @define SHEETS_EVENT_MOUSE_PING 6
 -- @define SHEETS_EVENT_KEY_DOWN 7
 -- @define SHEETS_EVENT_KEY_UP 8
 -- @define SHEETS_EVENT_TEXT 9
 -- @define SHEETS_EVENT_VOICE 10
 -- @define SHEETS_EVENT_PASTE 11

 -- @define ALIGNMENT_LEFT 0
 -- @define ALIGNMENT_CENTRE 1
 -- @define ALIGNMENT_CENTER ALIGNMENT_CENTRE
 -- @define ALIGNMENT_RIGHT 2
 -- @define ALIGNMENT_TOP 3
 -- @define ALIGNMENT_BOTTOM 4

 -- @define GRAPHICS_AREA_BOX 0
 -- @define GRAPHICS_AREA_CIRCLE 1
 -- @define GRAPHICS_AREA_LINE 2
 -- @define GRAPHICS_AREA_VLINE 3
 -- @define GRAPHICS_AREA_HLINE 4
 -- @define GRAPHICS_AREA_FILL 5
 -- @define GRAPHICS_AREA_POINT 6
 -- @define GRAPHICS_AREA_CCIRCLE 7

 -- @define TRANSPARENT 0
 -- @define WHITE 1
 -- @define ORANGE 2
 -- @define MAGENTA 4
 -- @define LIGHTBLUE 8
 -- @define YELLOW 16
 -- @define LIME 32
 -- @define PINK 64
 -- @define GREY 128
 -- @define LIGHTGREY 256
 -- @define CYAN 512
 -- @define PURPLE 1024
 -- @define BLUE 2048
 -- @define BROWN 4096
 -- @define GREEN 8192
 -- @define RED 16384
 -- @define BLACK 32768

 -- @define TOKEN_EOF "eof"
 -- @define TOKEN_STRING "string"
 -- @define TOKEN_FLOAT "float"
 -- @define TOKEN_BOOLEAN "float"
 -- @define TOKEN_INTEGER "int"
 -- @define TOKEN_IDENTIFIER "identifier"
 -- @define TOKEN_KEYWORD "float"
 -- @define TOKEN_NEWLINE "newline"
 -- @define TOKEN_WHITESPACE "whitespace"
 -- @define TOKEN_SYMBOL "symbol"
 -- @define TOKEN_OPERATOR "operator"

 -- @define QUERY_ALL "all"
 -- @define QUERY_ID "id"
 -- @define QUERY_TAG "tag"
 -- @define QUERY_CLASS "class"
 -- @define QUERY_ATTRIBUTES "attributes"
 -- @define QUERY_NEGATE "negate"
 -- @define QUERY_OPERATOR "operator"

 -- @if SHEETS_LOWRES
	 -- @define BLANK_PIXEL { WHITE, WHITE, " " }
 -- @else
 	 -- @define BLANK_PIXEL WHITE
 -- @endif

 -- @if SHEETS_LOWRES
	 -- @define CIRCLE_CORRECTION 1.5
 -- @else
	 -- @define CIRCLE_CORRECTION 1
 -- @endif

 -- @if SHEETS_CORE_ELEMENTS
	 -- @define SHEETS_BUTTON
	 -- @define SHEETS_CHECKBOX
	 -- @define SHEETS_COLOURSELECTOR
	 -- @define SHEETS_CONTAINER
	 -- @define SHEETS_DRAGGABLE
	 -- @define SHEETS_IMAGE
	 -- @define SHEETS_KEYHANDLER
	 -- @define SHEETS_LABEL
	 -- @define SHEETS_MENU
	 -- @define SHEETS_PANEL
	 -- @define SHEETS_RADIOBUTTON
	 -- @define SHEETS_SCROLLCONTAINER
	 -- @define SHEETS_TABS
	 -- @define SHEETS_TERMINAL
	 -- @define SHEETS_TEXT
	 -- @define SHEETS_TEXTINPUT
	 -- @define SHEETS_TOGGLE
	 -- @define SHEETS_WINDOW
 -- @endif

 -- @if SHEETS_LOWRES
 	-- @define GRAPHICS_NO_TEXT false
 -- @else
 	-- @define GRAPHICS_NO_TEXT true
 -- @endif

 -- @ifn SHEETS_LOWRES
	 -- @define GRAPHICS_DEFAULT_FONT _graphics_default_font
 -- @endif
