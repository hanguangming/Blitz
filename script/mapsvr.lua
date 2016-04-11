
load('boot.lua');

function read_array(str)
    if str then
        str = string.gsub(str, '%[', "{");
        str = string.gsub(str, '%]', "}");
        return assert(loadstring("return " .. str))();
    end
end

the_map_info = load("/etc/worldmap.csv");

local i = 1;
while true do
    tab = the_map_info[i];
    if not tab then
        break;
    end
    i = i + 1;
    tab["xiangling"] = read_array(tab["xiangling"]);
end


the_side_info = load("/etc/side.csv");
the_soldier_info = load('/etc/army.csv');
the_npc_info = load('/etc/corps.csv');
the_items_info = load('/etc/item.csv');
the_award_info = load('/etc/reward.csv');
the_param_info = load('/etc/parameter.csv');

