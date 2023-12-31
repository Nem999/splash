local tabl = {}

--[[
	Description: This module stores helpful table functions.
]]

function tabl:CheckTableEquality(t1,t2) -- Compare if two tables and their keys are the same
	if typeof(t1) ~= "table" then error(t1.." is not a table.") end
	if typeof(t2) ~= "table" then error(t2.." is not a table.") end
	if #t1~=#t2 then return false end
	for i=1,#t1 do if t1[i]~=t2[i] then return false end end
	return true
end

local insert = table.insert
tabl.stringify = function(v, spaces, usesemicolon, depth) -- Allows tables to be displayed in console useful for live in game servers.
        if type(v) ~= 'table' then
            return tostring(v)
        elseif not next(v) then
            return '{}'
        end

        spaces = spaces or 4
        depth = depth or 1

        local space = (" "):rep(depth * spaces)
        local sep = usesemicolon and ";" or ","
        local concatenationBuilder = {"{"}

        for k, x in next, v do
            insert(concatenationBuilder, ("\n%s[%s] = %s%s"):format(space,type(k)=='number'and tostring(k)or('"%s"'):format(tostring(k)), tabl.stringify(x, spaces, usesemicolon, depth+1), sep))
        end

        local s = table.concat(concatenationBuilder)
        return ("%s\n%s}"):format(s:sub(1,-2), space:sub(1, -spaces-1))
end

function tabl:DeepCopy(original)
		local copy = {}
		for k, v in pairs(original) do
			if type(v) == "table" then
				v = self:DeepCopy(v)
			end
			copy[k] = v
		end
	return copy
end

return tabl
