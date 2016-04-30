-- ======================================================
--	settings
-- ======================================================

cwAPI = {};
cwAPI.devMode = false;

-- ======================================================
--	util	
-- ======================================================

cwAPI.util = {};

function cwAPI.util.log(msg) 
	CHAT_SYSTEM(getvarvalue(msg));  
end 

function cwAPI.util.dev(msg,flag) 
	if (flag) then cwAPI.util.log(msg) end;
end 

function cwAPI.util.splitString(s,type)
	if (not type) then type = ' '; end
	local words = {};
	local m = type;
	if (type == ' ') then m = "%S+" end;
	if (type == '.') then m = "%." end;
	for word in s:gmatch(m) do table.insert(words, word) end
	return words;
end

function cwAPI.util.tablelength(T)
  	local count = 0
  	for _ in pairs(T) do count = count + 1 end
  	return count
end

function getvarvalue(var)
	if (var == nil) then return 'nil'; end	
	local tp = type(var); 
	if (tp == 'string' or tp == 'number') then 
		return var; 
	end
	if (tp == 'boolean') then 
		if (var) then 
			return 'true';
		else
			return 'false';
		end
	end
	return tp;
end

-- ======================================================
--	EVENTS
-- ======================================================

cwAPI.events = {};
cwAPI.evorig = '_original';

function cwAPI.events.original(event) 
	return _G[event..cwAPI.evorig];	
end

function cwAPI.events.on(event,callback,order) 
	if _G[event] == nil then 
		cwAPI.util.dev('Global '..event..' does not exists.',cwAPI.devMode);
		return;
	end

	cwAPI.events.store(event);

	_G[event] = function(...)
		local t = {...};
		if (order == -1) then
			callback(unpack(t));
		end
		if (order ~= 0) then
			local fn = cwAPI.events.original(event);
			local ret = fn(unpack(t));
		end
		if (order == 0) then			
			local ret = callback(unpack(t));
		end
		if (order == 1) then
			callback(unpack(t));
		end

		return ret;
	end

	cwAPI.util.dev('api.events on '..event,cwAPI.devMode);
end

function cwAPI.events.reset(event)
	if _G[event] == nil then 
		cwAPI.util.dev('Global '..event..' does not exists.',cwAPI.devMode);
		return;
	end
	local fn = cwAPI.events.original(event);
	if fn ~= nil then
		cwAPI.util.dev('Reseting '..event,cwAPI.devMode);
		_G[event] = fn;
		_G[event..cwAPI.evorig] = nil;
	end
end

function cwAPI.events.resetAll() 
	for key,value in pairs(_G) do
		if (type(value) == 'function' and not string.match(key,cwAPI.evorig)) then
			cwAPI.events.reset(key);
		end
	end
end

function cwAPI.events.store(event) 
	if _G[event] == nil then 
		cwAPI.util.dev('Global '..event..' does not exists.',cwAPI.devMode);
		return;
	end
	local fn = cwAPI.events.original(event);
	if fn == nil then
		cwAPI.util.dev('Storing '..event,cwAPI.devMode);
		_G[event..cwAPI.evorig] = _G[event];
	end
end

function cwAPI.events.listen(event) 	
	if _G[event] == nil then 
		cwAPI.util.log('Global '..event..' does not exists.');
		return;
	end
	cwAPI.events.reset(event);
	cwAPI.events.store(event);

	_G[event] = function(a,b,c,d,e,f,g)
		cwAPI.util.log('> '..event);
		cwAPI.events.printParams(a,b,c,e,d,f,g);
		local fn = cwAPI.events.original(event);
		cwAPI.util.log('> fn');
		local ret = fn(a);
		cwAPI.util.log('> ret');
		return ret;
	end
	cwAPI.util.log('api.events listening to '..event);
end

function cwAPI.events.printParams(a,b,c,e,d,f,g) 	
	if (a) then cwAPI.util.dev('a) '..getvarvalue(a),cwAPI.devMode); end
	if (b) then cwAPI.util.dev('b) '..getvarvalue(b),cwAPI.devMode); end
	if (c) then cwAPI.util.dev('c) '..getvarvalue(c),cwAPI.devMode); end
	if (d) then cwAPI.util.dev('d) '..getvarvalue(d),cwAPI.devMode); end
	if (e) then cwAPI.util.dev('e) '..getvarvalue(e),cwAPI.devMode); end
	if (f) then cwAPI.util.dev('f) '..getvarvalue(f),cwAPI.devMode); end
	if (g) then cwAPI.util.dev('g) '..getvarvalue(g),cwAPI.devMode); end
end

-- ======================================================
--	COMMANDS
-- ======================================================

cwAPI.commands = {};
cwAPI.commands.hooks = {};

function cwAPI.commands.register(cmd,callback) 
	cwAPI.commands.hooks[cmd] = callback;
end

function cwAPI.commands.parseMessage(message)
	local words = cwAPI.util.splitString(message);
	local cmd = table.remove(words,1);

	cwAPI.util.dev(cmd,cwAPI.devMode);

	local fn = cwAPI.commands.hooks[cmd];
	if (fn ~= nil) then
		return fn(words); 
	else		
		fn = cwAPI.events.original('UI_CHAT');
		fn(message);
	end
end

local parseMessage = function(message) cwAPI.commands.parseMessage(message); end

-- ======================================================
--	JSONs
-- ======================================================

cwAPI.json = {};

function cwAPI.json.load(name)
	local file, error = io.open("../addons/"..name.."/"..name..".json", "r");
	if (error) then
		ui.SysMsg("Error opening "..name.." to load json: "..error);
		return null;
	else 
	    local filestring = file:read("*all");
	    local filetable = JSON:decode(filestring);    
	    io.close(file);
	    return filetable;
	end
end

function cwAPI.json.save(name,filetable)
	local file, error = io.open("../addons/"..name.."/"..name..".json", "w");
	if (error) then
		ui.SysMsg("Error opening "..name.." to write json: "..error);
		return false;
	else 
		local filestring = JSON:encode_pretty(filetable);
		file:write(filestring);
	    io.close(file);
	    return true;
	end
end

-- ======================================================
--	ATTRIBUTES
-- ======================================================

cwAPI.attributes = {};

function cwAPI.attributes.getData(attrID)
	local topFrame = ui.GetFrame('skilltree');
	topFrame:SetUserValue("CLICK_ABIL_ACTIVE_TIME",imcTime.GetAppTime()-10);

	-- geting the attribute instance
	local abil = session.GetAbility(attrID);
	if (not abil) then return nil; end

	-- loading its IES data
	local abilClass = GetIES(abil:GetObject());

	-- getting its name and ID	
	local abilName = abilClass.ClassName;
	local abilID = abilClass.ClassID;

	-- getting the current state
	local state = abilClass.ActiveState;

	-- returning it
	return abilName, abilID, state;
end

function cwAPI.attributes.toggleOff(attrID)
	local abilName, abilID, state = cwAPI.attributes.getData(attrID);
	cwAPI.util.dev('Disabling ['..abilName..']...',cwAPI.devMode);

	-- if the attribute is already disabled, there's nothing to do
	if (state == 0) then
		cwAPI.util.dev('The attribute is already disabled.',cwAPI.devMode);
		return; 
	end 

	local topFrame = ui.GetFrame('skilltree');
	topFrame:SetUserValue("CLICK_ABIL_ACTIVE_TIME",imcTime.GetAppTime()-10);

	-- calling the toggle function
	local fn = _G['TOGGLE_ABILITY_ACTIVE'];
	fn(nil, nil, abilName, abilID);
	cwAPI.util.dev('Attibute disabled.',cwAPI.devMode);
end

function cwAPI.attributes.toggleOn(attrID)
	local abilName, abilID, state = cwAPI.attributes.getData(attrID);
	cwAPI.util.dev('Enabling ['..abilName..']...',cwAPI.devMode);

	-- if the attribute is already disabled, there's nothing to do
	if (state == 1) then
		cwAPI.util.dev('The attribute is already enabled.',cwAPI.devMode);
		return; 
	end 

	local topFrame = ui.GetFrame('skilltree');
	topFrame:SetUserValue("CLICK_ABIL_ACTIVE_TIME",imcTime.GetAppTime()-10);

	-- calling the toggle function
	local fn = _G['TOGGLE_ABILITY_ACTIVE'];
	fn(nil, nil, abilName, abilID);
	cwAPI.util.dev('Attibute enabled.',cwAPI.devMode);
end

-- ======================================================
--	commands
-- ======================================================

local function runScript(words)
	local funcStr = '';
	for key,value in pairs(words) do
		funcStr = funcStr .. value .. ' '; 
	end
	loadstring(funcStr)();
end

local function reloadAddons()
	ui.SysMsg('=====================================');
	_G['ADDON_LOAD_ALL']();
end

local function showAddonsButton() 
	local addonLoaderFrame = ui.GetFrame("addonloader");
	addonLoaderFrame:ShowWindow(1);
end 

-- ======================================================
--	commands
-- ======================================================

local function checkCommand(words)
	cwAPI.util.log('====== cwAPI =====');
	cwAPI.util.log('"/addons" will show the addons button.');
	cwAPI.util.log('"/reload" will reload all addons.');
	cwAPI.util.log('"/script" will let you run lua commands like a bash.');
	cwAPI.util.log('--------------------------');
end

-- ======================================================
--	LOADER
-- ======================================================

cwAPI.events.resetAll();
cwAPI.events.on('UI_CHAT',parseMessage,0);
cwAPI.commands.register('/addons',showAddonsButton);
cwAPI.commands.register('/reload',reloadAddons);

_G['ADDON_LOADER']['cwapi'] = function() 	
	-- executing onload
	cwAPI.commands.register('/script',runScript);
	cwAPI.commands.register('/cw',checkCommand);	
	cwAPI.util.log('[cwAPI:help] /cw');
	return true;
end 


