## Tree of Savior Lua Mods - cwLibrary ##

Here you can find all the addons I've created. Feel free to use my cwAPI to create yours too! Ask me if you need help.

Also, please check my database website. It's growing! http://tos.codware.com/

Have any question or suggestion about the addons or the website? Hit me at http://discordapp.com (user #3304).

## Download ##

<a href='https://github.com/fiote/treeofsavior-addons/releases'>Get the latest release here</a>

## cwToLearn
[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)
[![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges)

When selecting the "Show only attributes that can be learned" on the 'Learn Attributes' window, this addon will hide the attributes that you already have at max level.


## cwFarmed
[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)
[![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges)

[depends on cwAPI, help avaiable at https://github.com/fiote/treeofsavior-addons/wiki/cwFarmed]

Display how much silver you have grinded from mobs in the current section.

<img src='http://i.imgur.com/Gb2f190.png'>

Display the ammount of silver each monster dropped to you.

<img src='http://i.imgur.com/YEjP7eB.png'>

Display the ammount of XP each monster awarded you.

<img src='http://i.imgur.com/jo5uBAJ.png'>

<img src='http://i.imgur.com/fr20ksB.png'>

## cwCleric
[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)
[![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges)

[depends on cwAPI]

This addon acts as a class helper. If you have your "Heal: Remove Damage" attribute OFF and join a party, it will ask if you want to toggle it ON (so you can heal better). When you leave a party while having the attibute ON, it will ask if you want to toggle it OFF (so you can do more damage while soloing).

<img src='http://i.imgur.com/k2hipF4.png'>

<img src='http://i.imgur.com/8hMvkiZ.png'>

## cwShakeness
[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)
[![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges)

[depends on cwAPI]

A tiny addon that disables the 'shake' the games used on certain skills. I read users having headaches and nauseas because of that, so I thought it would be nice being able to disable them while ICM doesn't get us a solution.

Type /skn for help.

## cwAPI
[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)
[![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges)

An API of core functionalities.

Enables you to hook on events and decide if you custom function will be called before, after or instead of the original callback.

Enables you to load addon json as tables and save them back to the file (useful to persist user options).

Type /cw for help.

## Installation ##

Extract the zip to your Tree of Savior directory (C:\Program Files (x86)\Steam\steamapps\common\TreeOfSavior for me). Say yes to overwrite any files. An addons folder should be in the root directory. Your directories should look something like this:

<img src='https://camo.githubusercontent.com/3dd7b4c321f4c9f8013ebdff2985d52461c67e64/687474703a2f2f692e696d6775722e636f6d2f776d65316b4f632e706e67'>

Start game and login to character.

Press the "Load Addons" button. It should disappear. You're done!

## Uninstall ##

Delete any folder inside the addons directory that starts with cw. Those are my addons. You can keep the addonloader.lua since that'll keep other addons you might have still working.

## Usage ##

Right now i'm not using configuration files to control the addons settings. But most of them will let you use /somecommand to configure that. Please refer to each addon on the list at the beginning of this readme.