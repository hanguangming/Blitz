load("/etc/network.conf");

if the_network == nil then
    error("no network config.")
end

eval_table(the_network);

local servlet_array = {};
for name, servlet in pairs(the_network.servlets) do
    if not servlet.id then
        error(string.format("servlet '%s' not declare id.", name));
    end

    if servlet_array[servlet.id] then
        error(string.format("servlet(%s)'s id(%d) is repeated.", name, servlet.id));
    end

    if not servlet.port then
        error(string.format("servlet '%s' not declare port.", name));
    end

    servlet.name = name;
    servlet_array[servlet.id] = servlet;
end

local node_array = {};
local port_map = {};
for name, node in pairs(the_network.nodes) do
    if node.id == nil then
        error(string.format("network node '%s' not declare id.", name));
    end

    if node_array[node.id] then
        error(string.format("network node(%s)'s id(%d) is repeated.", name, node.id));
    end
    node_array[node.id] = node;

    local host = node.host;
    if host == nil or host == "" then
        host = the_network.host;
    end

    local tmp = {};
    for servlet_name, servlet in pairs(node.servlets) do
        if type(servlet) == "string" then
            servlet_name = servlet;
            servlet = {};
        end

        local template = the_network.servlets[servlet_name];
        if not template then
            error(string.format("unknown servlet '%s' at node '%s'.", servlet_name, name));
        end
        if template.used then
            error(string.format("repeatedly use servlet '%s'", servlet_name));
        end
        template.used = true;

        servlet.id = template.id;
        servlet.name = template.name;
        servlet.ap = template.ap;

        if not servlet.port then
            servlet.port = template.port;
        end

        if not servlet.host or servlet.host == "" then
            if not template.host or template.host == "" then
                servlet.host = host;
            else
                servlet.host = template.host;
            end
        end

        tmp[servlet_name] = servlet;
    end
    node.servlets = tmp;

    if not node.instance_num then
        node.instance_num = #node;
        if node.instance_num == 0 then
            node.instance_num = 1;
        end
    end

    for instance_index = 1, node.instance_num do
        local instance = node[instance_index];
        if not instance then
            instance = {};
            node[instance_index] = instance;
        end

        local instance_servlets = instance.servlets;
        if not instance_servlets then
            instance_servlets = {};
            instance.servlets = instance_servlets;
        end

        for servlet_name, servlet in pairs(node.servlets) do
            local instance_servlet = instance_servlets[servlet_name];
            if not instance_servlet then
                instance_servlet = {}
                instance_servlets[servlet_name] = instance_servlet;
            end
            if not instance_servlet.host then
                instance_servlet.host = servlet.host;
            end
            if not instance_servlet.port then
                for port = servlet.port, 65535 do
                    if not port_map[port] then
                        instance_servlet.port = port;
                        servlet.port = port + 1;
                        break;
                    end
                end
            end;
            instance_servlet.id = servlet.id;
            instance_servlet.ap = servlet.ap;
            instance_servlet.name = servlet.name;
            instance_servlet.used = true;
        end

        for name, servlet in pairs(instance.servlets) do
            if not servlet.used then
                error("unknown servlet '%s'.", name);
            end
        end
    end
end

servlet_array = nil;
node_array = nil;
port_map = nil;



