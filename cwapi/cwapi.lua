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
	ui.SysMsg(getvarvalue(msg));  
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
	if (tp == 'string' or tp == 'number') then return var; end
	return tp;
end

-- ======================================================
--	MONSTER	
-- ======================================================

cwAPI.monster = {};
function cwAPI.monster.getWiki(monID) 
	local monCls = GetClassByType("Monster",monID);
	if (monCls == nil) then return nil; end
	local wiki = GetWikiByName(monCls.Journal);
	return wiki;
end

function cwAPI.monster.getProp(monID,propName)
	local wiki = cwAPI.monster.getWiki(monID);
	if (wiki == nil) then return nil; end
	return GetWikiIntProp(wiki,propName);
end

function cwAPI.monster.getExp(monID)
	return cwAPI.monster.getProp(monID,'Exp');
end

-- ======================================================
--	TARGET
-- ======================================================

cwAPI.target = {};

function cwAPI.target.get() 
	return world.GetActor(session.GetTargetHandle());
end

-- ======================================================
--	EVENTS
-- ======================================================

cwAPI.events = {};
cwAPI.evorig = '_original';

function cwAPI.events.original(event) 
	return _G[event..cwAPI.evorig];	
end

function cwAPI.events.on(event,callback,replace) 
	if _G[event] == nil then 
		cwAPI.util.dev('Global '..event..' does not exists.',cwAPI.devMode);
		return;
	end

	cwAPI.events.store(event);

	_G[event] = function(a,b,c,d,e,f,g)
		local ret = callback(a,b,c,d,e,f,g);
		if (not replace) then
			local fn = cwAPI.events.original(event);
			local ret = fn(a,b,c,d,e,f,g);
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
		cwAPI.util.dev('Global '..event..' does not exists.',cwAPI.devMode);
		return;
	end
	cwAPI.events.reset(event);
	cwAPI.events.store(event);

	_G[event] = function(a,b,c,d,e,f,g)
		cwAPI.util.dev('> '..event,cwAPI.devMode);
		cwAPI.events.printParams(a,b,c,e,d,f,g);
		local fn = cwAPI.events.original(event);
		cwAPI.util.dev('> fn',cwAPI.devMode);
		local ret = fn(a);
		cwAPI.util.dev('> ret',cwAPI.devMode);
		return ret;
	end
	cwAPI.util.dev('api.events listening to '..event,cwAPI.devMode);
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

_G['ADDON_LOADER']['cwapi'] = function() 	
	-- executing onload
	cwAPI.events.resetAll();
	cwAPI.events.on('UI_CHAT',parseMessage,true);
	cwAPI.commands.register('/script',runScript);
	cwAPI.commands.register('/addons',showAddonsButton);
	cwAPI.commands.register('/reload',reloadAddons);
	cwAPI.commands.register('/cw',checkCommand);	
	cwAPI.util.log('[cwAPI:help] /cw');
	return true;
end 