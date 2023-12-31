return function(...)
	local args = {...}

	if typeof(args[1]) == "table" then
		return args[1][math.random(1, #args[1])]
	else
		return args[1][math.random(1, #args)]
	end
end