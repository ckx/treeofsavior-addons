-- ======================================================
--	options
-- ======================================================

-- setting defaults
local defaults = {};
defaults.minAlert = {};
defaults.minAlert.silver = 0;
defaults.minAlert.xp = 0;
defaults.minAlert.pet = 0;

defaults.show = {};
defaults.show.silver = true;
defaults.show.xp = true;
defaults.show.pet = true;

-- loading json file
local options = cwAPI.json.load('cwfarmed');
if (not options) then options = defaults; end

-- applying defaults if needed
for atr,vlr in pairs(defaults) do
	if (not options[atr]) then options[atr] = vlr; end
end

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
end

settings.getPet = function() 
	local petList = session.pet.GetPetInfoVec();
	local petInfo = petList:at(0);
	local curExp = petInfo:GetExp();
	local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_PET,curExp);

	local max = xpInfo.totalExp - xpInfo.startExp;	
	local now = curExp - xpInfo.startExp;	
	local pr = now*100/max;
	return now, max, pr;
end

settings.resetPet = function() 
	settings.pet = {};
	settings.pet.now, _, settings.pet.prnow = settings.getPet();
	settings.pet.gain = 0;
	settings.pet.prnow = 0;
	settings.pet.qtmobs = 0;
end

local log = cwAPI.util.log;

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
		settings.silver.gain = settings.silver.gain + itemQty;	
		if (settings.silver.gain >= options.minAlert.silver) then
			cwAPI.util.log('[Silver] +'..GetCommaedText(settings.silver.gain)..' obtained.');
			settings.silver.gain = 0;
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

	petExpUpdate();

	if (options.show.xp) then 
		local newxp = session.GetEXP();
		local diff = newxp - settings.xpbase.now;
		if (diff > 0) then 
			settings.xpbase.qtmobs = settings.xpbase.qtmobs+1;
			settings.xpbase.gain = settings.xpbase.gain + diff;
			local max = session.GetMaxEXP();
			local prgain = settings.xpbase.gain/max * 100;
			if (prgain >= options.minAlert.xp) then
				local dspr = string.format("%.2f%%", prgain, 100.0);
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
--	on pet xp update
-- ======================================================

function petExpUpdate()	
	local now, max, prtotal = settings.getPet();

	if (prtotal < settings.pet.prnow) then
		settings.resetPet();
	end

	local diff = now - settings.pet.now;

	if (diff > 0) then		
		settings.pet.gain = settings.pet.gain + diff;
		local prgain = settings.pet.gain*100/max;

		if (prgain >= options.minAlert.pet) then
			local dstotal = string.format("%.1f%%",prtotal, 100.0);
			local dspr = string.format("%.2f%%", prgain, 100.0);
			cwAPI.util.log('[XPpet] +'..dspr..' ('..dstotal..').');
			settings.pet.gain = 0;
		end
		
		settings.pet.prnow = prtotal;
		settings.pet.now = now;
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

	if (cmd == 'silver' or cmd == 'xp' or cmd == 'pet') then
		local atr = cmd;
		local dsflag = table.remove(words,1);
		if (dsflag == 'on') then options.show[atr] = true; end 
		if (dsflag == 'off') then options.show[atr] = false; end 
		local msgflag = 'Show '..atr..' set to ['..dsflag..'].';
		cwAPI.json.save(options,'cwfarmed');
		return ui.MsgBox(msgtitle..msgflag);		
	end

	if (cmd == 'silvermin' or cmd == 'xpmin' or cmd == 'petmin') then
		local newvlr = table.remove(words,1);
		local atr = string.gsub(cmd,'min','');

		local word = '%'; local format = '%.3f'; local min = 0.1;
		if (atr == 'silver') then word = 'coins'; format = '%d'; min = 1; end

		options.minAlert[atr] = tonumber(newvlr);
		local dspr = string.format(format,options.minAlert[atr],min);
		local msgflag = 'Min '..atr..' alert set to ['..dspr..' '..word..'].';
		cwAPI.json.save(options,'cwfarmed');
		return ui.MsgBox(msgtitle..msgflag);
	end

	if (not cmd) then
		local flagsv = ''; if (options.show.silver) then flagsv = 'on'; else flagsv = 'off'; end
		local alertsv = options.minAlert.silver;

		local flagxp = ''; if (options.show.xp) then flagxp = 'on'; else flagxp = 'off'; end
		local alertxp = string.format("%.2f%%",options.minAlert.xp, 0.1);

		local flagpet = ''; if (options.show.pet) then flagpet = 'on'; else flagpet = 'off'; end
		local alertpet = string.format("%.2f%%",options.minAlert.pet, 0.1);

		local msgcmd = '';
		local msgcmd = msgcmd .. '/farmed reset{nl}'..'Reset the silver counting.{nl}'..'-----------{nl}';

		local msgcmd = msgcmd .. '/farmed silver [on/off]{nl}'..'Show or hide silver messages (now: '..flagsv..').{nl}'..'-----------{nl}';
		local msgcmd = msgcmd .. '/farmed silvermin [value]{nl}'..'Only show silver messages when x is obtained (now: '..alertsv..').{nl}'..'-----------{nl}';

		local msgcmd = msgcmd .. '/farmed xp [on/off]{nl}'..'Show or hide xp messages (now: '..flagxp..').{nl}'..'-----------{nl}';
		local msgcmd = msgcmd .. '/farmed xpmin [value]{nl}'..'Only show xp messages when x% is obtained (now: '..alertxp..').{nl}'..'-----------{nl}';

		local msgcmd = msgcmd .. '/farmed pet [on/off]{nl}'..'Show or hide pet messages (now: '..flagpet..').{nl}'..'-----------{nl}';
		local msgcmd = msgcmd .. '/farmed petmin [value]{nl}'..'Only show pet messages when x% is obtained (now: '..alertpet..').{nl}'..'-----------{nl}';

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
	settings.resetPet();

	-- executing onload
	cwAPI.events.on('ITEMMSG_ITEM_COUNT',inventoryUpdate,1);
	cwAPI.events.on('DRAW_TOTAL_VIS',refreshZeny,1);
	cwAPI.events.on('CHARBASEINFO_ON_MSG',charbaseUpdate,1);

	cwAPI.commands.register('/farmed',checkCommand);
	cwAPI.util.log('[cwFarmed:help] /farmed');

	cwAPI.json.save(options,'cwfarmed');

	return true;
end
