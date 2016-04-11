
function eval_table(table, elm)
    if elm ~= nil then
        if type(table[elm]) == "function" then
            table[elm] = table[elm]();
        end
        if type(table[elm]) == "table" then
            eval_table(table[elm]);
        end
    else
        for key in pairs(table) do
            eval_table(table, key);
        end
    end
end


