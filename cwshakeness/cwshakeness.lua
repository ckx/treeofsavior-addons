-- ======================================================
--	settings
-- ======================================================

local settings = {};
settings.devMode = false;

settings.origname = 'cwShakeness_originalShockwave';
settings.maxEnabled = 1;

-- ======================================================
--	storing
-- ======================================================

function storeShockwave() 
	-- storing the original shockwave function in a safe place
	-- that means we can restore it later, if we need to
	local fname = settings.origname;
	if (_G[fname] == nil) then _G[fname] = world.ShockWave; end
end 
-- ======================================================
--	replacing
-- ======================================================

function replaceShockwave() 
	-- replacing the shockwave function
	local fname = settings.origname;
	world.ShockWave = function(actor, type, range, intensity, time, freq, something)
		-- if the intensity of the shockwave is smaller than what is enabled
		if (intensity <= settings.maxEnabled) then
			-- then we carry on and execute it using the original stored shockwave
			local fn = _G[fname];
			fn(actor, type, range, intensity, time, freq, something);
		else 
			-- if it's not, the shockwave simply doesn't happen
			cwAPI.util.dev('cwShakeness interrupted call ('..intensity..' > '..settings.maxEnabled..').',settings.devMode);
		end
	end
end

-- ======================================================
--	commands
-- ======================================================

function cwShakenessCommands(words)
	local count = cwAPI.util.tablelength(words);
	local cmd = '';
	if (count > 0) then cmd = table.remove(words,1); end 

	local msgtitle = 'cwShakeness{nl}'..'-----------{nl}';

	if (cmd == 'max') then
		settings.maxEnabled = tonumber(table.remove(words,1));
		local msgupd = 'Allowed value updated{nl}'..'Intensity now: '..settings.maxEnabled;
		return ui.MsgBox(msgtitle..msgupd);
	end

	if (cmd == '') then		
		local msgcmd = '/skn max [x]{nl}'..'Set the max intensity allowed{nl}'..'-----------{nl}';
		local msgint = 'Intensity now: '..settings.maxEnabled;			
		return ui.MsgBox(msgtitle..msgcmd..msgint,"","Nope");
	end

	local msgerr = 'Command not valid.{nl}'..'Type "/skn" for help.';
	ui.MsgBox(msgtitle..msgerr,"","Nope");
end


-- ======================================================
--	LOADER
-- ======================================================

_G['ADDON_LOADER']['cwshakeness'] = function() 
	-- checking dependences
	if (not cwAPI) then
		ui.SysMsg('cwShakeness requires cwAPI to run.');
		return false;
	end
	-- executing onload
	storeShockwave();
	replaceShockwave();
	cwAPI.commands.register('/skn',cwShakenessCommands);
	cwAPI.util.log('[cwShakeness:help] /skn');
	return true;
end