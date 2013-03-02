-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local socket = require "socket"
local udpSocket = socket.udp()
udpSocket:setsockname("localhost",51248)
udpSocket:setpeername("localhost",51249)
udpSocket:settimeout(0)
--[[
Corona® Cider Debugger Library v 1.0
Author: M.Y. Developers
Copyright (C) 2012 M.Y. Developers All Rights Reserved
Support: mydevelopergames@gmail.com
Website: http://www.mydevelopersgames.com/
License: Many hours of genuine hard work have gone into this project and we kindly ask you not to redistribute or illegally sell this package.
We are constantly developing this software to provide you with a better development experience and any suggestions are welcome. Thanks for you support.

-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--]]
local json = require "json"
local CIDER_DIR = ".cider/"
local toNetbeansFile
local pathToNetbeansFile = CIDER_DIR.."fromCorona.cider"
local fromNetbeansFile
local pathFromNetbeansFile = CIDER_DIR.."toCorona.cider"
local startDebuggerMessage = {type = "s"};
local statusMessage
local previousLine, previousFile
local Root = {} --this is for variable dumps
local globalsBlacklist = {}
local breakpoints = {}
local runToCursorKey
local maxSize = 3000
	--Dont get globals already here
	for i,v in pairs(_G) do
		globalsBlacklist[v] = true --dont profile corona stuff
	end

local function block()
	--block until we get the continue command from netbeans
end
--this will block the program initially and wait for netbeans connection


local function serializeDump(tab, mirror, traversed)--mirrors table and removes functions, userdata, and tries to identify type
	if(traversed == nil) then
		traversed = 10
		mirror = {}
	end
	if(traversed == 0) then
		return; --recursion limit reached
	end
	traversed = traversed-1
	for i,v in pairs(tab) do
		if(type(v)=="table") then
				mirror[i] = {}
				
				--check if this is a display object (see if there is a _class key)
				if(v._class) then
					local dispTable = mirror[i]
						--in a displayGroup
						dispTable[".isDisplayObject"] = true
						dispTable.x, dispTable.y, dispTable.rotation, dispTable.alpha, dispTable.width, dispTable.height, dispTable.isVisible =
						v.x,v.y,v.rotation,v.alpha,v.width,v.height,v.isVisible					
						if(v.numChildren) then
							--in a display object
							dispTable.numChildren = v.numChildren;	
							dispTable[".isDisplayGroup"] = true
						else
												
						end					
					else
					serializeDump(v, mirror[i],traversed)
				end				
			
		elseif(type(v)=="function") then
			mirror[i]  = {}
			mirror[i].isCoronaBridgeFunction = true
			mirror[i].id = i
		elseif(type(v)=="string" or type(v)=="boolean" or type(v)=="number" ) then
			mirror[i] = v;
		elseif(type(v)=="nil") then
			mirror[i] = json.Null();
		end
	end
	return mirror	
end
local function localsDump(stackLevel) --puts all locals into table
--[[
	local locals = {}	
	local stackIndex = 1
	local key,v = debug.getlocal(stackLevel, stackIndex)
	--generate the top level
	while(key) do		
		if(key:sub(1,1)~="(") then
			locals[key] = v
			print(key, type(v))
		end
		stackIndex = stackIndex+1
		key,v = debug.getlocal(stackLevel, stackIndex)
	end	--]]
  local vars = {}
  local db = debug.getinfo(stackLevel, "fS")
  local func = db.func
  local i = 1
  while true do
    local name, value = debug.getupvalue(func, i)
    if not name then break end
    vars[name] = value

    i = i + 1
  end
  i = 1
  while true do
    local name, value = debug.getlocal(stackLevel, i)
    if not name then break end
	if(name:sub(1,1)~="(") then
		vars[name] = value
	end
    i = i + 1
  end
  --setmetatable(vars, { __index = getfenv(func), __newindex = getfenv(func) })

	return serializeDump(   vars	)
end
local function globalsDump()
	local globalsVars = {}
	for i,globalv in pairs(_G) do
	
		if(globalsBlacklist[globalv]==nil) then
	
			globalsVars[i] = globalv
		end
	end		
	return serializeDump(globalsVars)
end
local function writeVariableDump() --write the var dump to file
	local Root = {}
	Root = localsDump(5)
	Root[".Globals"] = globalsDump()
	local message = {}
	message.type = "gl"
	message.value = Root	
	--we must break up this message into parts so that it does not get truncated
	messageString = json.encode(message)
	if(messageString:len()>maxSize) then
		while(messageString:len()>maxSize) do				
			local part = messageString:sub(1,maxSize)
			message = {}
			message.type = "ms"
			message.value = part			
			udpSocket:send(json.encode(message))
			messageString = messageString:sub(maxSize+1)
		end
			message = {}
			message.type = "me"
			message.value = messageString			
			udpSocket:send(json.encode(message))				
	else
		udpSocket:send(messageString)
	end
end
local function standardizePath(input)
	input = string.lower(input)
	input = string.gsub(input, "/", "\\")
	return input
end
local steppingInto
local steppingOver
local pauseOnReturn
local stepOut
local firstLine = false

local processFunctions = {}
processFunctions.gpc = function()
	--now send the program counter position to netbeans
	local message = {}
	message.type = "gpc"
	message.value = {["file"] = previousFile,["line"] = previousLine}
	udpSocket:send(json.encode(message))
end
processFunctions.gl = function()
	--gets the global and local variable state
	writeVariableDump()
end
processFunctions.p = function()
local inPause = true
--pause execution until resume is recieved, process other commands as they are received
statusMessage = "paused"
processFunctions.gpc()
writeVariableDump()
	local line = udpSocket:receive();
	local keepWaiting = true;
	while(keepWaiting) do
		if(line) then
			line = json.decode(line)
			if(line.type~="p") then
				processFunctions[line.type](line);
			end
			if(line.type == "k" or line.type == "r" or line.type == "si" or line.type == "sov" or line.type == "sou" or line.type == "rtc") then --if run or step
				return;
			end			
		end
		line = udpSocket:receive()
	end
end
processFunctions.r = function()
	runToCursorKey = nil;
end
processFunctions.s = function()
	
end
processFunctions.sb = function(input)
	--sets a breakpoint
--	file = system.pathForFile(input.path)
	breakpoints[ standardizePath(input.path)..input.line] = true;
end

processFunctions.rb = function(input)
	--removes a breakpoint
--	file = system.pathForFile(input.path)
	breakpoints[ standardizePath(input.path)..input.line] = nil;
end

processFunctions.rtc = function(input)
	--removes a breakpoint
--	file = system.pathForFile(input.path)
	 runToCursorKey = standardizePath(input.path)..input.line;
end
processFunctions.si = function()
	print("stepping into")
	steppingInto = true
	runToCursorKey = nil
end
processFunctions.sov = function()
	print("stepping over")
	steppingOver= true
	runToCursorKey = nil
end
processFunctions.sou = function()
	print("stepping out")
	pauseOnReturn = true
	steppingInto = false
	steppingOver= false
	runToCursorKey = nil
end
processFunctions.e = function(evt)
	evt = evt.value
	--print("event recieved",evt.name, evt.xGravity, evt.yGravity, evt.zGravity);
	Runtime:dispatchEvent(evt);
end
processFunctions.k = function(evt)
	--just remove all the breakpoints
	os.exit()
	breakpoints = {}
	steppingInto = false
	steppingOver= false
	pauseOnReturn = false
	runToCursorKey = nil
end
--this will do the debug loop, listen for netbeans commands and respond accordingly, executes every line, return, call

local function debugloop(phase)
		debug.sethook (debugloop, "",0 )
		local inDebugLoop = true	
		local info = debug.getinfo(2,"Sln")
		local fileKey = info.source
		local lineKey = info.currentline
				
		local isLuaFunction = string.len(fileKey) > 6
		if(fileKey:find("@")) then
			fileKey = fileKey:sub(2)
		end
		
		if(isLuaFunction) then
			 previousLine, previousFile =  lineKey ,fileKey	--do before standardization
			fileKey = standardizePath(fileKey)
			if(phase == "call" ) then
				if(steppingOver) then
					pauseOnReturn = true;
					steppingOver = false;
				end
			elseif(phase == "return" ) then
				if(steppingOver) then
					steppingOver =  false
					steppingInto = true
				end				
				if(pauseOnReturn) then
					pauseOnReturn = false;
					steppingInto = true;--pause after stepping one more
				end
			elseif(phase == "line" ) then
	
				 local inLine = true
				 if(steppingInto or steppingOver or firstLine) then
					firstLine = false;
					steppingInto = false;
					steppingOver = false;
					processFunctions.p() --pause after stepping one line					
				 else
					--check if we are at a breakpoint or if we are at run to cursor 
					local key = fileKey..lineKey
					if(breakpoints[key] or runToCursorKey==key) then
						--we are at breakpoint
						print("breakpoint")
						processFunctions.p() 	
					end
				 end
				 
			end
	
			--in a lua function
			--check for netbeans commands

			local line = udpSocket:receive()
			while(line) do
				--Process Line Here

				line = json.decode(line)
				processFunctions[line.type](line);
				line = udpSocket:receive()				
			end
			
		end
	
		debug.sethook (debugloop, "crl",0 )
end

local function initBlock()

	--send start command and wait for response
	--first get debugger state send gb command


	message = {}
	message.type = "s"	
	udpSocket:send(json.encode(message))		
	print( "waiting for netbeans debugger initialization")	
	local line = udpSocket:receive()
	 keepWaiting = true
	while( keepWaiting ) do
		if(line) then
			print(line)
			line = json.decode(line)
			if(line.type=="s") then			
				keepWaiting = false
				break;
			end
			if(line.type=="sb") then
				processFunctions[line.type](line);--proccess current then the rest		
			end
		end
		line = udpSocket:receive()		
	end
	
	line = udpSocket:receive()	
	while(line) do
		line = json.decode(line)
		if(line.type=="sb")  then
			processFunctions[line.type](line);

		end
		line = udpSocket:receive()	
	end	
	
	--now we have the first line with the start command, we can give back control of the program
		print("debugger started")	
end

initBlock()

debug.sethook (debugloop, "crl",0 )	