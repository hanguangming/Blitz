local function print_with_indent(str, indent)
    print(string.rep(" ", 2 * indent) .. str);
end;

local function print_nv(name, value, indent)
    local str = name .. " = ";
    if type(value) == "table" then
        str = str .. "{";
        print_with_indent(str, indent);
        for k,v in pairs(value) do
            if type(k) == "number" then
                print_nv("[" .. k .. "]", v, indent + 1);
            else
                print_nv("['" .. k .. "']", v, indent + 1);
            end
        end
        print_with_indent("},", indent);
    elseif type(value) == "boolean" then
        if value then
            str = str .. "true,";
        else
            str = str .. "false,";
        end
        print_with_indent(str, indent);
    elseif type(value) == "string" then
        str = str .. "'" .. value .. "',";
        print_with_indent(str, indent);
    else
        str = str .. value .. ",";
        print_with_indent(str, indent);
    end
end

function print_table(name, value)
    print_nv(name, value, 0);
end

