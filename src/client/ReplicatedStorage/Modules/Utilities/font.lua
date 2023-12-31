-- [[ SERVICES ]]
local ContentProvider = game:GetService("ContentProvider")

-- [[ NEUTRALS ]]
local rbxFont = Font
local Font = {}

Fonts = {}

Fonts.Kartun = {
	A = "rbxassetid://15658268822",
	B = "rbxassetid://15658268709",
	C = "rbxassetid://15658268610",
	D = "rbxassetid://15658268505",
	E = "rbxassetid://15658268427",
	F = "rbxassetid://15658268318",
	G = "rbxassetid://15658268183",
	H = "rbxassetid://15658268033",
	I = "rbxassetid://15658267824",
	J = "rbxassetid://15658267703",
	K = "rbxassetid://15658267585",
	L = "rbxassetid://15658267438",
	M = "rbxassetid://15658267292",
	N = "rbxassetid://15658267168",
	O = "rbxassetid://15658267055",
	P = "rbxassetid://15658266908",
	Q = "rbxassetid://15658266774",
	R = "rbxassetid://15658266662",
	S = "rbxassetid://15658266593",
	T = "rbxassetid://15658266506",
	U = "rbxassetid://15658266388",
	V = "rbxassetid://15658266304",
	W = "rbxassetid://15658266120",
	X = "rbxassetid://15658265926",
	Y = "rbxassetid://15658265725",
	Z = "rbxassetid://15658265625",
	GetLetter = function(letter)
		return Fonts.Kartun[string.upper(letter)]
	end,
}

-- [[ FUNCTIONS ]]

function Font:GetFont(font : string):{}
	if not font then error("Argument missing or nil") end
	if typeof(font) ~= "string" then error("Argument is not of type: string") end
	if not Fonts[font] then warn("Font: "..font.." does not exist.") else
	
		return Fonts[font]
	
	end
end

function Font:PreloadFonts()
	local ToPreload = {}
	for _, Font in pairs(Fonts) do
		for _, Letter in pairs(Font) do
			if typeof(Letter) == "string" then
				table.insert(ToPreload, Letter)
			end
		end
	end
		
	ContentProvider:PreloadAsync(ToPreload)
	
end

task.spawn(Font.PreloadFonts)

return Font