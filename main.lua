
local storyboard = require "storyboard"
local widget = require "widget"
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
--Debug the smart way with Cider!
--start coding and press the debug button

local db = require("db")

db:initialize{}
db:printStuff{}

local function onSystemEvent( event )
        if( event.type == "applicationExit" ) then              
            db:close()
        end
end

storyboard.gotoScene( "menu" )

--local loadBtn = widget.newButton{
--    label = "Load",
--    labelColor = { default={0}, over={0} },
--    font = native.systemFontBold,
--    xOffset=2, yOffset=-1,
----    default = "load-default.png",
----    over = "load-over.png",
--    width=50, height=25,
--    left=10, top=28
--}
--
---- onRelease listener callback for loadBtn
--local function onLoadRelease( event )
--    titleField.text = "woot"
--    print(titleField.text)
--end
--loadBtn.onRelease = onLoadRelease
--
--local textFont = native.newFont( native.systemFont )
--
--titleField = native.newTextBox(10, 90, 100, 30)
--titleField.font = textFont
--titleField.text = "test"
--titleField.size = 14
--    print(titleField.text)
