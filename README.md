## ADDONS ##

#### cwAPI: 
An API of core functionalities.

#### cwFarmed [depends on cwAPI]: 
Display how much silver you have grinded from mobs in the current section (that is, since you entered the game). 
<img src='http://i.imgur.com/Gb2f190.png'>

#### cwShakeness [depends on cwAPI]:
A tiny addon that disables the 'shake' the games used on certain skills. I read users having headaches and nauseas because of that, so I thought it would be nice being able to disable them while ICM doesn't get us a solution.

## ADDONLOADER ##

This is a improved version of Excrulon (https://github.com/Excrulon) addonloader.lua file. This one will go throught everything on the addons directory looking for folders that looks like an addon folder (something/something.lua).

To include new addons on your client, just put the addon folder on the addons directory. Just make sure the .lua file have the exactly same name as the addon folder.

#### INSTALLATION

Just extract the addonloader.lua to your Tree of Savior folder. It differ from computer to computer but mine is located at  C:\SteamLibrary\steamapps\common\TreefOfSavior\addons. If this is the first time you're trying addons, the 'addons' folder might have to be created.

#### COMPATIBILITY

Some changes need to be done on existing addons (mapfogviewer, monstertracker, etc) to make them compatible with this loader. I'm trying to contact Exclulon about that. But if you have created an addon and/or want to make it compatible yourself, it's not that hard. And not every addon need adjustments! If you addon have no dependency whatsoever on other file, then it's good to go! But if you addon depends on some other file (like Exclulon addons depending on that addons/utility.lua), you need to change things. 

First: no addons/file.lua is read, so you would to move the utility.lua to a utility/utility.lua, making it work like an addon too. 

Second: since the addons will be included in alphabetical order, any addon that uses another addon may fail to load since the other addon is not loaded yet. To solve that, you need to encapsulate all the direct calls you addon do that depends on the other addon.

Example:

mytest/mytest.lua
```lua
function getabc() 
  return "abc";
end 

alertlog("this is a test: "..getabc());
```

utility/utility.lua 
```lua
function alertlog(msg) 
  ui.SysMsg("ALERT: "..msg);
end
```

Since mytest.lua will loaded first, it will fail because alertlog (defined in utility.lua) is not defined yet.

To solve that, just change mytest.lua to this:
```lua
function getabc()
  return "abc";
end

_G['ADDON_LOADER']['mytest'] = function() 
  alertlog("this is a test: "..getabc());
end
```

See what I did? All dependent-on-other calls that would need to be executed on load just need to be moved inside the new function (which is always named after the addon name itself). That works because I created the addonloader.lua in a way that it will first OPEN all addons (defining every global function on them) and THEN it will execute the _G['ADDON_LOADER'][addon_name] functions.

Works like a charm ^^
