-- ======================================================
--	settings
-- ======================================================

local settings = {};
settings.devMode = false;
settings.isOnParty = false;

-- ======================================================
--	attibute list
-- ======================================================

local attributes = {};
attributes.HealRemoveDamage = 401016;

-- ======================================================
--	leave party
-- ======================================================

function toggleHealRemoveDamageOff() 
	cwAPI.attributes.toggleOff(attributes.HealRemoveDamage);
end

local function leftParty(state) 
	if (state == 1) then
		local msgtitle = 'cwCleric{nl}'..'-----------{nl}';
		local msgalert = 'You just left a party but your "Heal: Remove Damage" is ON. Do you want to toggle it off?';
		ui.MsgBox(msgtitle..msgalert,'toggleHealRemoveDamageOff()',"None");	
	end
end

-- ======================================================
--	join party
-- ======================================================

function toggleHealRemoveDamageOn() 
	cwAPI.attributes.toggleOn(attributes.HealRemoveDamage);
end

local function joinedParty(state) 
	if (state == 0) then
		local msgtitle = 'cwCleric{nl}'..'-----------{nl}';
		local msgalert = 'You just joined a party but your "Heal: Remove Damage" is OFF. Do you want to toggle it on?';
		ui.MsgBox(msgtitle..msgalert,'toggleHealRemoveDamageOn()',"None");	
	end
end

-- ======================================================
--	check what happened
-- ======================================================

local function checkIfLeftOrJoined() 
	local abilName, abilID, state = cwAPI.attributes.getData(attributes.HealRemoveDamage);
	if (abilName == nil) then return; end

	local pcparty = session.party.GetPartyInfo();
	
	if (not settings.isOnParty and pcparty ~= nil) then
		settings.isOnParty = true;
		local list = session.party.GetPartyMemberList(PARTY_NORMAL);
		local count = list:Count();
		if (count > 0) then joinedParty(state); end
		return;
	end

	if (settings.isOnParty and pcparty == nil) then
		settings.isOnParty = false;
		leftParty(state);
		return;
	end
end 

-- ======================================================
--	LOADER
-- ======================================================


_G['ADDON_LOADER']['cwcleric'] = function() 
	cwAPI.events.on('ON_PARTY_UPDATE',checkIfLeftOrJoined,1);


	-- inverting the flag to force a alert onload if needed
	local pcparty = session.party.GetPartyInfo();
	if (pcparty ~= nil) then settings.isOnParty = true; end
	checkIfLeftOrJoined();
	
	return true;
end