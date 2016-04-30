-- ======================================================
--	on attribute shop list refresh
-- ======================================================

function refreshAbilityShop(frame, msg)
	local frame = ui.GetFrame("abilityshop");	
	local abilGroupName = frame:GetUserValue("ABIL_GROUP_NAME");

	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end

	local gbox = GET_CHILD_RECURSIVELY(frame, 'abilityshopGBox');
	DESTROY_CHILD_BYNAME(gbox, 'ABILSHOP_');
	local posY = 5;

	-- abilGroupNameÀ¸·Î xml¿¡¼­ ÇØ´çµÇ´Â ±¸ÀÔ°¡´ÉÇÑ Æ¯¼º¸®½ºÆ® °¡Á®¿À±â
	local abilList, abilListCnt = GetClassList("Ability");
	local abilGroupList, abilGroupListCnt = GetClassList(abilGroupName);

	local onlyShowLearnable = GET_CHILD_RECURSIVELY(frame,"onlyShowLearnable");
	for i = 0, abilGroupListCnt-1 do

		local groupClass = GetClassByIndexFromList(abilGroupList, i);
		if groupClass ~= nil then
			local abilClass = GetClassByNameFromList(abilList, groupClass.ClassName);
			if abilClass ~= nil then

				local showit = true;

				if onlyShowLearnable:IsChecked() == 1 then
					local abilIES = GetAbilityIESObject(pc, abilClass.ClassName);
					local abilLv = 1;
					if abilIES ~= nil then abilLv = abilIES.Level + 1; end
					local maxLevel = tonumber(groupClass.MaxLevel);
					if maxLevel < abilLv then showit = false; end
				end

				if (showit) then
					posY = MAKE_ABILITYSHOP_ICON(frame, pc, gbox, abilClass, groupClass, posY);
				end
			end
		end
	end

	local invenZeny = GET_CHILD_RECURSIVELY(frame, 'invenZeny', 'ui::CRichText');	
	local zeny = GET_TOTAL_MONEY();
	local commaed = GetCommaedText(zeny);
	invenZeny:SetText("{@st41b}"..commaed);

	local abilityshopGBox = GET_CHILD_RECURSIVELY(frame, 'abilityshopGBox');
	abilityshopGBox:UpdateData();
	frame:Invalidate();

end

-- ======================================================
--	LOADER
-- ======================================================

_G['ADDON_LOADER']['cwtolearn'] = function() 
	-- checking dependences
	if (not cwAPI) then
		ui.SysMsg('[cwFarmed] requires cwAPI to run.');
		return false;
	end
	-- executing onload
	cwAPI.events.on('REFRESH_ABILITYSHOP',refreshAbilityShop,0);
	return true;
end