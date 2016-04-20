-- ======================================================
--	begin
-- ======================================================

_G["ADDON_LOADER"] = {};

-- ======================================================
--	load_all function
-- ======================================================

_G["ADDON_LOAD_ALL"] = function()

	ui.SysMsg('Loading Addons...');

	-- getting the current directory 
	local info = debug.getinfo(1,'S');
	local directory = info.source:match[[^@?(.*[\/])[^\/]-$]];

	-- iterating all folders
	local i, addons, popen = 0, {}, io.popen;
	for filename in popen('dir "'..directory..'" /b /ad'):lines() do
	   	-- checking if there is {folder}/{folder}.lua inside it
	   	local fullpath = '../addons/'..filename..'/'..filename..'.lua';
		local f = io.open(fullpath,"r");
	   	if f ~= nil then 
	   		io.close(f); 
	   		-- if there is, we'll store this folder 
	   		i = i + 1;
	   		addons[i] = filename;
	   		-- and also dofile it to store all global functions it might have
	   		dofile(fullpath); 
	   	end
	end

	-- now, with all the folders that have a {folder}.lua file inside it
	for i,filename in pairs(addons) do
		-- we look for a hook on the ADDON_LOADER globla
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
_G["ADDON_LOADER"]["LOADED"] = true;

-- ======================================================
-- showing the addonloader frame
-- ======================================================

local addonLoaderFrame = ui.GetFrame("addonloader");
addonLoaderFrame:Move(0, 0);
addonLoaderFrame:SetOffset(450, 30);
addonLoaderFrame:ShowWindow(0);

function MAP_ON_INIT_HOOKED(addon, frame)
	_G["MAP_ON_INIT_OLD"](addon, frame);
	if _G["ADDON_LOADER"]["LOADED"] then
		local addonLoaderFrame = ui.GetFrame("addonloader");
		addonLoaderFrame:ShowWindow(0);
	end
end

-- ======================================================
-- hooking it on map-init
-- ======================================================

local mapOnInitHook = "MAP_ON_INIT";
if _G["MAP_ON_INIT_OLD"] == nil then
	_G["MAP_ON_INIT_OLD"] = _G[mapOnInitHook];
	_G[mapOnInitHook] = MAP_ON_INIT_HOOKED;
else
	_G[mapOnInitHook] = MAP_ON_INIT_HOOKED;
end
