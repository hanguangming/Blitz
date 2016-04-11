package.path = home_dir() .. "/script/fightsvr/src/?.lua;/usr/share/lua/5.1/?.lua";

load('boot.lua');

the_soldier_info = load('/etc/army.csv');

load('fightsvr/src/main/fight/Fight.lua');
load('fightsvr/fight.lua');


