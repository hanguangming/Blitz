require("main.GameGlobal")
local WorldMap = class("WorldMap")
local floor = math.floor
local config = GameGlobal:GetWorldMapTableDataManager()

function WorldMap:ctor()
	local map_desc = require("main.map")
	self:initImages(map_desc.tilesets)

	self._cellWidth = map_desc.tilewidth
	self._cellHeight = map_desc.tileheight
	self._cellCols = map_desc.width
	self._cellRows = map_desc.height
	self._width = map_desc.width * map_desc.tilewidth
	self._height = map_desc.height * map_desc.tileheight

	self._templates = {}
	self._cities = {}
	self._city_list = {}
	self._city_count = 0

	self:initCells();
	for k, v in ipairs(map_desc.layers) do
		if v.name == "map" then
			self:initMap(v.objects)
		elseif v.name == "city" then
			self:initCity(v.objects)
		elseif v.name == "path" then
			self:initPath(v.objects);
		elseif string.find(v.name, "template") then
			self:initTemplate(v.properties.city, v.objects)
		end
	end

	for _, city in pairs(self._cities) do
		local temp = self._templates[city.type]
		city.ix = city.x
		city.iy = city.y
		city.nx = city.x + temp.nx;
		city.ny = city.y + temp.ny;
		city.sx = city.x + temp.sx;
		city.sy = city.y + temp.sy;
		city.bx = city.x + temp.bx;
		city.by = city.y + temp.by;
		city.x = city.x + temp.x;
		city.y = city.y + temp.y;
		city.width = temp.w;
		city.height = temp.h;

		local bounds = {}
		bounds.min = {x = city.x - city.width / 2, y = city.y - city.height / 2}
		bounds.max = {x = city.x + city.width / 2, y = city.y + city.height / 2}
		city.bounds = bounds

		local min_cell = self:getCell(bounds.min.x, bounds.min.y)
		local max_cell = self:getCell(bounds.max.x, bounds.max.y)
		if min_cell and max_cell then
			for x = min_cell.x, max_cell.x do
				for y = min_cell.y, max_cell.y do
					self._cells[x][y].cities[city.id] = city
				end
			end
		end
	end
	self:buildPath()
end

function WorldMap:initCells()
	self._cells = {}
	for i = 1, self._cellCols do
		local array = {}
		for j = 1, self._cellRows do 
			array[j] = {x = i, y = j, cities = {}}
		end
		self._cells[i] = array;
	end
end

function WorldMap:initImages(images)
	self._images = {}
	for k, v in ipairs(images) do
		local image = {}
		image.id = v.firstgid
		image.width = v.imagewidth
		image.height = v.imageheight
		image.file = v.image
		image.texture = cc.Director:getInstance():getTextureCache():addImage(image.file);
		self._images[image.id] = image
	end
	self._cityStateTexture = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_tubiao1.png");
	self._pathTexture = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_luxiandian.png");
	self._sideTexture = {}
	self._sideTexture[1] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_shu.png"); 
	self._sideTexture[2] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_wei.png"); 
	self._sideTexture[3] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_wu.png"); 
	self._sideTexture[4] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_qin.png"); 
	self._sideTexture[5] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_huang.png"); 
	self._sideTexture[6] = cc.Director:getInstance():getTextureCache():addImage("meishu/ui/guozhanditu/UI_gzdt_chengshiming_man.png"); 
end

function WorldMap:initMap(blocks)
	self._blocks = {}
	for k, v in ipairs(blocks) do
		local block = {}
		block.x, block.y = self:cordTrans(v.x, v.y)
		block.width = v.width
		block.height = v.height
		block.image = self._images[v.gid]
		self._blocks[k] = block
	end
end

function WorldMap:probeCity(id)
	id = tonumber(id)
	local city = self._cities[id]
	if not city then
		city = {}
		city.id = id
		city.joins = {}
		self._cities[id] = city
		self._city_count = self._city_count + 1
		city.index = self._city_count
		self._city_list[self._city_count] = city
	end
	return city
end

function WorldMap:initCity(cities)
	for k, v in ipairs(cities) do
		local city = self:probeCity(v.properties.city)

		city.x, city.y = self:cordTrans(v.x, v.y)
		city.width = v.width
		city.height = v.height
		city.type = v.type

		city.x = city.x + v.width / 2
		city.y = city.y + v.height / 2
		city.image = self._images[v.gid]
		city.name = string.gsub(v.name, "\n", "")
		city.side = config[city.id].mbelong


		local image_cities;
		if not city.image.cities then
			image_cities = {}
			city.image.cities = image_cities
			city.image.city_count = 0
		else
			image_cities = city.image.cities
		end
		city.image.city_count = city.image.city_count + 1
		image_cities[city.image.city_count] = city
	end
end

function WorldMap:initTemplate(id, objects)
	local x, y, w, h
	local gid
	local base_x, base_y
	local name_x, name_y
	local state_x, state_y
	local bottom_x, bottom_y
	local box_x, box_y, box_w, box_h

	for _, obj in ipairs(objects) do
		w = obj.width;
		h = obj.height;
		x = obj.x + w / 2;

		if obj.type == "0" then
			y = obj.y - h / 2;
			x, y = self:cordTrans(x, y)
			base_x = x;
			base_y = y;
			gid = obj.gid
		elseif obj.type == "1" then
			y = obj.y + h / 2;
			x, y = self:cordTrans(x, y)
			bottom_x = x;
			bottom_y = y;
		elseif obj.type == "2" then
			y = obj.y + h / 2;
			x, y = self:cordTrans(x, y)
			state_x = x;
			state_y = y;
		elseif obj.type == "3" then
			y = obj.y + h / 2;
			x, y = self:cordTrans(x, y)
			box_x = x;
			box_y = y;
			box_w = w;
			box_h = h;
		elseif obj.type == "4" then
			y = obj.y + h / 2;
			x, y = self:cordTrans(x, y)
			name_x = x;
			name_y = y;
		end
	end

	local temp = self._templates[id]
	if not temp then
		temp = {}
		self._templates[id] = temp
	end

	temp.nx = name_x - base_x
	temp.ny = name_y - base_y
	temp.sx = state_x - base_x
	temp.sy = state_y - base_y
	temp.bx = bottom_x - base_x
	temp.by = bottom_y - base_y
	temp.x = box_x - base_x
	temp.y = box_y - base_y
	temp.w = box_w;
	temp.h = box_h;
end

function WorldMap:initPath(paths)
	for _, path in ipairs(paths) do
		local count = #path.polyline;
		local from = self:probeCity(path.properties.from)
		local to = self:probeCity(path.properties.to)
		local from_join = {city = to, path = {}}
		local to_join = {city = from, path = {}}
		from.joins[to.id] = from_join;
		to.joins[from.id] = to_join;

		for i = 1, count - 2 do
			local p = path.polyline[i + 1]
			p.x, p.y = self:cordTrans(path.x + p.x, path.y + p.y)
			from_join.path[i] = p
			to_join.path[count - i - 1] = p
		end
	end
end

function WorldMap:makeMat()
	local mat = {}
	for i = 1, self._city_count do
		mat[i] = {}
	end
	return mat
end

function WorldMap:buildPath()
	if false then
		local mat = self:makeMat()
		local path = self:makeMat()
		for i = 1, self._city_count do
			local city1 = self._city_list[i]
			for j = 1, self._city_count do
				local city2 = self._city_list[j]
				if city1 == city2 then
					mat[i][j] = 0
				elseif city1.joins[city2.id] then
					mat[i][j] = 1
				end
				path[i][j] = i;
			end
		end

		for k = 1, self._city_count do
			for i = 1, self._city_count do
				for j = 1, self._city_count do
					local ik = mat[i][k] or 99999
					local kj = mat[k][j] or 99999
					local ij = mat[i][j] or 99999
					if ik + kj < ij then
						mat[i][j] = ik + kj
						path[i][j] = path[k][j]
					end
				end
			end
		end
		self._path = path

	   local file,err = io.open("/tmp/path.lua", "wb")
	   if err then return err end
	   file:write("return {")
	   for i = 1, self._city_count do
	   		file:write("{")
			for j = 1, self._city_count do
				file:write(path[i][j] .. ",")
			end
		   file:write("},")
		end
	    file:write("}")
        file:close()
	else
		self._path = require("main.path")
	end
end

function WorldMap:getPath(from, to)
	if from == to then
		return
	end

	local from_city = self._cities[from]
	local to_city = self._cities[to]
	local from_index = from_city.index
	local to_index = to_city.index
	local temp = to_index

	local path = {}
	local index = 256
	while (temp ~= from_index) do
		index = index - 1;
		path[index] = self._city_list[temp].id
		temp = self._path[from_index][temp]
		if not temp then
			return
		end
	end

	local ret = {cities = {}}
	local i = 1
	while (true) do
		if not path[index] then
			break;
		end
		ret.cities[i] = self._cities[path[index]]
		i = i + 1
		index = index + 1
	end
	return ret
end

function WorldMap:getCell(x, y)
	if x < 0 or y < 0 then
		return
	end

	x = floor(x / self._cellWidth) + 1
	y = floor(y / self._cellHeight) + 1
	if x > self._cellCols then
		return
	end
	if y > self._cellRows then
		return
	end
	return self._cells[x][y]
end

function WorldMap:cordTrans(x, y)
	return x, self._height - y
end

function WorldMap:getCityByPos(x, y)
	local cell = self:getCell(x, y)
	if not cell then
		return
	end

	for _, city in pairs(cell.cities) do
		local bounds = city.bounds;
		if x >= bounds.min.x and x <= bounds.max.x and y >= bounds.min.y and y <= bounds.max.y then
			return city;
		end
	end
end

return WorldMap.new()


