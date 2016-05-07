-- ======================================================
--	options
-- ======================================================

local options = cwAPI.json.load("cwfarmed");

-- ======================================================
--	settings
-- ======================================================

local settings = {};

settings.devMode = false;
settings.silverID = 900011;

-- function to reset xp values (usually after a level up)
settings.resetXP = function()
	settings.xpbase = {};
	settings.xpbase.now = session.GetEXP();
	settings.xpbase.gain = 0;
	settings.xpbase.qtmobs = 0;
end

settings.resetSilver = function() 
	settings.silver = {};
	settings.silver.farmed = 0;
	settings.silver.gain = 0;
	settings.silver.qtmobs = 0;
end

-- ======================================================
--	on item update
-- ======================================================

local function refreshZeny() 
	local zeny = GET_TOTAL_MONEY();
	local frame = ui.GetFrame("inventory");
	local bottomGbox = frame:GetChild('bottomGbox');
	local moneyGbox	= bottomGbox:GetChild('moneyGbox');
	local INVENTORY_CronCheck = GET_CHILD(moneyGbox, 'invenZeny', 'ui::CRichText');

	local bothZeny = GetCommaedText(zeny)..' | '..GetCommaedText(settings.silver.farmed);
    INVENTORY_CronCheck:SetText('{@st41b}'..bothZeny);
end 

local function inventoryUpdate(actor,evName,itemID,itemQty)
	local itemID = math.floor(itemID);
	-- if this is a silver update, we'll refresh the zeny
	if (itemID == settings.silverID) then 	
		settings.silver.farmed = settings.silver.farmed + itemQty;
		settings.silver.qtmobs = settings.silver.qtmobs+1;
		settings.silver.gain = settings.silver.gain + itemQty;		
		if (settings.silver.gain >= options.minAlert.silver) then
			local pts = '[Silver] +'..GetCommaedText(settings.silver.gain)..' obtained';
			if (settings.silver.qtmobs > 1) then pts = pts .. ' ('..settings.silver.qtmobs..' mobs)'; end
			cwAPI.util.log(pts..'.');
			settings.silver.gain = 0;
			settings.silver.qtmobs = 0;
		end
		refreshZeny(); 
	end
end

-- ======================================================
--	on char base update
-- ======================================================

local function charbaseUpdate(frame, msg) 
	if (msg == 'LEVEL_UPDATE') then
		settings.resetXP();
	end

	if (options.show.xp) then 
		local newxp = session.GetEXP();
		local diff = newxp - settings.xpbase.now;
		if (diff > 0) then 
			settings.xpbase.qtmobs = settings.xpbase.qtmobs+1;
			settings.xpbase.gain = settings.xpbase.gain + diff;
			local max = session.GetMaxEXP();
			local prgain = settings.xpbase.gain/max * 100;
			if (prgain >= options.minAlert.xp) then
				local dspr = string.format("%.3f%%", prgain, 100.0);
				local pts = settings.xpbase.gain..' pts';
				if (settings.xpbase.qtmobs > 1) then pts = pts .. '/'..settings.xpbase.qtmobs..' mobs'; end
				cwAPI.util.log('[XPbase] +'..dspr..' ('..pts..').');
				settings.xpbase.gain = 0;
				settings.xpbase.qtmobs = 0;
			end
			settings.xpbase.now = newxp;
		end
	end
end

-- ======================================================
--	commands
-- ======================================================

local function checkCommand(words)
	local cmd = table.remove(words,1);
	local msgtitle = 'cwFarmed{nl}'..'-----------{nl}';

	if (cmd == 'reset') then
		settings.silver.farmed = 0;
		refreshZeny();
		local msgreset = 'Counter resetted successfully.';
		return ui.MsgBox(msgtitle..msgreset);
	end

	if (cmd == 'silver') then
		local dsflag = table.remove(words,1);
		if (dsflag == 'on') then options.show.silver = true; end 
		if (dsflag == 'off') then options.show.silver = false; end 
		local msgflag = 'Show silver set to ['..dsflag..'].';
		cwAPI.json.save("cwfarmed",options);
		return ui.MsgBox(msgtitle..msgflag);		
	end

	if (cmd == 'silvermin') then
		local newvlr = table.remove(words,1);
		options.minAlert.silver = tonumber(newvlr);
		local dspr = string.format("%d",options.minAlert.silver, 1);
		local msgflag = 'Min Silver alert set to ['..dspr..' coins].';
		cwAPI.json.save("cwfarmed",options);
		return ui.MsgBox(msgtitle..msgflag);
	end

	if (cmd == 'xp') then
		local dsflag = table.remove(words,1);
		if (dsflag == 'on') then options.show.xp = true; end 
		if (dsflag == 'off') then options.show.xp = false; end 
		local msgflag = 'Show XP alert set to ['..dsflag..'].';
		cwAPI.json.save("cwfarmed",options);
		return ui.MsgBox(msgtitle..msgflag);
	end

	if (cmd == 'xpmin') then
		local newpr = table.remove(words,1);
		settings.resetXP();
		options.minAlert.xp = tonumber(newpr);
		local dspr = string.format("%.3f",options.minAlert.xp, 0.1);
		local msgflag = 'Min XP set to ['..dspr..'%].';
		cwAPI.json.save("cwfarmed",options);
		return ui.MsgBox(msgtitle..msgflag);
	end

	if (not cmd) then
		local flagsv = ''; if (options.show.silver) then flagsv = 'on'; else flagsv = 'off'; end
		local alertsv = options.minAlert.silver;

		local flagxp = ''; if (options.show.xp) then flagxp = 'on'; else flagxp = 'off'; end
		local alertxp = string.format("%.2f%%",options.minAlert.xp, 0.1);

		local msgcmd = '';
		local msgcmd = msgcmd .. '/farmed reset{nl}'..'Reset the silver counting.{nl}'..'-----------{nl}';

		local msgcmd = msgcmd .. '/farmed silver [on/off]{nl}'..'Show or hide silver messages (now: '..flagsv..').{nl}'..'-----------{nl}';
		local msgcmd = msgcmd .. '/farmed silvermin [value]{nl}'..'Only show silver messages when x is obtained (now: '..alertsv..').{nl}'..'-----------{nl}';

		local msgcmd = msgcmd .. '/farmed xp [on/off]{nl}'..'Show or hide xp messages (now: '..flagxp..').{nl}'..'-----------{nl}';
		local msgcmd = msgcmd .. '/farmed xpmin [value]{nl}'..'Only show xp messages when x% is obtained (now: '..alertxp..').{nl}'..'-----------{nl}';
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

	settings.resetXP();
	settings.resetSilver();

	-- executing onload
	cwAPI.events.on('ITEMMSG_ITEM_COUNT',inventoryUpdate,1);
	cwAPI.events.on('DRAW_TOTAL_VIS',refreshZeny,1);
	cwAPI.events.on('CHARBASEINFO_ON_MSG',charbaseUpdate,1);

	cwAPI.commands.register('/farmed',checkCommand);
	cwAPI.util.log('[cwFarmed:help] /farmed');
	return true;
end
