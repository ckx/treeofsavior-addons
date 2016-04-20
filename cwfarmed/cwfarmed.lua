-- ======================================================
--	settings
-- ======================================================

local settings = {};
settings.devMode = false;

settings.silverID = 900011;
settings.zenny = 0;
settings.items = {};

-- ======================================================
--	on item update
-- ======================================================

local function refreshZeny() 
	local invframe = ui.GetFrame("inventory");
	local fn = _G['DRAW_TOTAL_VIS'];
	fn(invframe,'invenZeny'); 
end

local function inventoryUpdate(actor,evName,itemID,itemQty)
	local itemID = math.floor(itemID);

	-- if the item is not stored, we'll start it
	if (not settings.items[itemID]) then 
		settings.items[itemID] = 0; 		
	end

	-- adding the itemQty to the total stored
	settings.items[itemID] = settings.items[itemID]+itemQty;

	-- if this is a silver add, lets update the UI
	if (itemID == settings.silverID) then refreshZeny() end
end

-- ======================================================
--	on get commaed text
-- ======================================================

local function fioGetCommaedText(qtZeny)
	settings.zenny = qtZeny;
	local fn = cwAPI.events.original('GetCommaedText');
	local ret = fn(settings.zenny);
	local farmed = settings.items[settings.silverID];
	if (farmed) then ret = ret .. " | "..fn(farmed); end
	return ret;
end

local function checkDrawVisible(actor,evName)
	if (evName == 'invenZeny') then
		-- changing the getcommaed function so it will add the earned zenny
		cwAPI.events.on('GetCommaedText',fioGetCommaedText,true);
		-- firing the original draw visible
		local fn = cwAPI.events.original('DRAW_TOTAL_VIS');
		fn(actor,evName); 
		-- resting the getcommaed so nothing else will be affected
		cwAPI.events.reset('GetCommaedText');
	end
end

-- ======================================================
--	commands
-- ======================================================

local function checkCommand(words)
	local cmd = table.remove(words,1);

	local msgtitle = 'cwFarmed{nl}'..'-----------{nl}';

	if (cmd == 'reset') then
		settings.items = {};
		refreshZeny();
		local msgreset = 'Counter resetted successfully.';
		return ui.MsgBox(msgtitle..msgreset);
	end

	if (not cmd) then
		local msgcmd = '/farmed reset{nl}'..'Reset the silver counting.{nl}'..'-----------{nl}';
		return ui.MsgBox(msgtitle..msgcmd,"","Nope");
	end

	local msgerr = 'Command not valid.{nl}'..'Type "/farmed" for help.';
	ui.MsgBox(msgtitle..msgerr,"","Nope");
end


-- ======================================================
--	LOADER
-- ======================================================

_G['ADDON_LOADER']['cwfarmed'] = function() 
	-- checking dependences
	if (not cwAPI) then
		ui.SysMsg('[cwFarmed] requires cwAPI to run.');
		return false;
	end
	-- executing onload
	cwAPI.events.on('ITEMMSG_ITEM_COUNT',inventoryUpdate);
	cwAPI.events.on('DRAW_TOTAL_VIS',checkDrawVisible,true);
	cwAPI.commands.register('/farmed',checkCommand);
	cwAPI.util.log('[cwFarmed:help] /farmed');
	return true;
end
