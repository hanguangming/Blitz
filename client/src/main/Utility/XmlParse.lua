function allXml2Table(xml)
	
	local localstring = string
	
	local xml,s = localstring.gsub(xml,'<?.-?>','', 1)
	local tb = {};
	while s do 
		local cur =s;
		_,s,tag = localstring.find(xml,'<(.-)>',s);
		if	tag  then 
			local PartXml;
			_,s,PartXml=  localstring.find(xml,'<'..tag..'>(.-)</'..tag..'>',cur);
			tb[tag] = PartXml2Table(PartXml);
		end
	end
	return tb;
end

function PartXml2Table(xml)
	local s =0,tag;
	local cur ;
	local localstring = string
	_,cur,tag = localstring.find(xml,'<(.-)>',s);
	if cur== nil  then 
		return  xml;
	end	
	local  tb = {}
	local tableinsert = table.insert
	while s do 
		cur = s;
		_,s,tag = localstring.find(xml,'<(.-)>',cur);
			if	tag  then 
				local PartXml;
				_,s,PartXml=  localstring.find(xml,'<'..tag..'>(.-)</'..tag..'>',cur);
				assert(PartXml)
				if tb[tag] == nil then
					tb[tag]= PartXml2Table(PartXml);
				elseif tb[tag][1] == nil then
					local tbFirst = tb[tag];
					tb[tag] =nil;
					tb[tag] = {}
					tb[tag][1] =tbFirst;
					tb[tag][2] = PartXml2Table(PartXml);
				else
					
					tableinsert(tb[tag], PartXml2Table(PartXml));
				end
			end	
	end
	return  tb;
end
