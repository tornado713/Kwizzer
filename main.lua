
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

local function onSystemEvent( event )
        if( event.type == "applicationExit" ) then              
            db:close()
        end
end

storyboard.gotoScene( "menu" )
