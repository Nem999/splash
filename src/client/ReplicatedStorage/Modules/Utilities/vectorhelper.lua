local D = {} 

-- Quick way to get the distance in between 2 vectors

function D.GetDistance(v1 : Vector3, v2 : Vector3): number
	if typeof(v1) == "Instance" then
		return (v1.Position - v2.Position).Magnitude
	elseif typeof(v1) == "Vector3" then
		return (v1 - v2).Magnitude
	end
end

function D:Compare(v1, v2, Distance)
	if self.GetDistance(v1, v2) <= Distance then
		return true
	else
		return false
	end
end

return D