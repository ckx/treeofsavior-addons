-- ======================================================
--	begin
-- ======================================================

ui.SysMsg('=====================================');

_G["ADDON_LOADER"] = {};
local debugLoading = false;
local closeAfter = true;

local function trydofile(fullpath)
	local f, error = io.open(fullpath,"r");
	if (f ~= nil) then
		io.close(f);
		dofile(fullpath);
		return true;
	else 
		return false;
	end
end

-- ======================================================
--	Fix to make this loader compatible with Excrulon addons
-- ======================================================

trydofile('../addons/utility.lua');

-- ======================================================
--	load_all function
-- ======================================================

_G["ADDON_LOAD_ALL"] = function()

	ui.SysMsg('Opening addon folders...');

	-- getting the current directory 
	local info = debug.getinfo(1,'S');
	local directory = info.source:match[[^@?(.*[\/])[^\/]-$]];

	-- iterating all folders
	local i, addons, popen = 0, {}, io.popen;
	for filename in popen('dir "'..directory..'" /b /ad'):lines() do
	   	-- checking if there is {folder}/{folder}.lua inside it, and dofile-ing it if there is
		if (debugLoading) then ui.SysMsg('- '..filename..' (lua)'); end
	   	local fullpath = '../addons/'..filename..'/'..filename..'.lua';
	   	local loaded = trydofile(fullpath);	   	
	   	-- if there is, we'll store this folder 
	   	if (loaded) then
	   		i = i + 1;
	   		addons[i] = filename;
	   	end	  
	end

	ui.SysMsg('Initializing addons...');

	-- now, with all the folders that have a {folder}.lua file inside it
	for i,filename in pairs(addons) do
		if (debugLoading) then ui.SysMsg('- '..filename); end
		-- we look for a hook on the ADDON_LOADER global
		local fn = _G['ADDON_LOADER'][filename];
		local ok = true;
		-- and if there is one, we'll call it
		if fn then ok = fn(); end
		-- if the hook returned false, a error message should be shown
		if (not ok) then ui.SysMsg('['..filename..'] failed.') end
	end

	ui.SysMsg('Addons loaded!');
end

-- ======================================================
--	calling it as soon as the game open this
-- ======================================================

_G['ADDON_LOAD_ALL']();
_G["ADDON_LOADER"]["LOADED"] = closeAfter;

-- ======================================================
-- showing the addonloader frame
-- ======================================================

local addonLoaderFrame = ui.GetFrame("addonloader");
addonLoaderFrame:Move(0, 0);
--addonLoaderFrame:SetOffset(1600, 320);
addonLoaderFrame:SetOffset(500,30);
addonLoaderFrame:ShowWindow(0);

-- ======================================================
-- hooking it on map-init
-- ======================================================

function initWithAddons()
	if _G["ADDON_LOADER"]["LOADED"] then
		local addonLoaderFrame = ui.GetFrame("addonloader");
		addonLoaderFrame:ShowWindow(0);
	end
end

cwAPI.events.on('MAP_ON_INIT',initWithAddons,1);

if (not closeAfter) then addonLoaderFrame:ShowWindow(1); end