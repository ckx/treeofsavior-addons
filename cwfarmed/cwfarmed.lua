-- ======================================================
--	settings
-- ======================================================

local settings = {};
settings.devMode = false;

settings.silverID = 900011;
settings.zenny = 0;
settings.items = {};
settings.items[settings.silverID] = 0;

-- ======================================================
--	on item update
-- ======================================================

local function refreshZeny() 
	local zeny = GET_TOTAL_MONEY();
	local frame = ui.GetFrame("inventory");
	local bottomGbox = frame:GetChild('bottomGbox');
	local moneyGbox	= bottomGbox:GetChild('moneyGbox');
	local INVENTORY_CronCheck = GET_CHILD(moneyGbox, 'invenZeny', 'ui::CRichText');

	local farmedZeny = settings.items[settings.silverID];
	local bothZeny = GetCommaedText(zeny)..' | '..GetCommaedText(farmedZeny);
    INVENTORY_CronCheck:SetText('{@st41b}'..bothZeny);
end 

local function inventoryUpdate(actor,evName,itemID,itemQty)
	local itemID = math.floor(itemID);
	-- if the item is not stored, we'll start it
	if (not settings.items[itemID]) then settings.items[itemID] = 0; end
	-- adding the itemQty to the total stored
	settings.items[itemID] = settings.items[itemID]+itemQty;
	-- if this is a silver update, we'll refresh the zeny
	if (itemID == settings.silverID) then 
		cwAPI.util.log('[Silver] x'..itemQty..' acquired.');
		refreshZeny(); 
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
	cwAPI.events.on('ITEMMSG_ITEM_COUNT',inventoryUpdate,1);
	cwAPI.events.on('DRAW_TOTAL_VIS',refreshZeny,1);

	cwAPI.commands.register('/farmed',checkCommand);
	cwAPI.util.log('[cwFarmed:help] /farmed');
	return true;
end

