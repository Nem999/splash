-- // Services
local RunService = game:GetService("RunService") -- Best Service
local PlayersService = game:GetService("Players")

-- // Modules

local flags = require(script.Parent.flags)
local signal = require(script.Parent.signal)

-- // Neutrals

local Camera = workspace.CurrentCamera
local ScreenSize = Camera.ViewportSize
local RenderStep = signal.new()
local HeartBeat = signal.new()
local OnScreenSizeUpdated = signal.new()
local AllImagesLoaded = signal.new()
local Animations = {}
local frames = {}
local FrameByFrames = {}

local TotalDeltaHeartBeat = 0
local TotalDeltaRender = 0

-- // Functions

if RunService:IsClient() then
	RunService.RenderStepped:Connect(function(DT)
		TotalDeltaRender += DT
		if (TotalDeltaRender < 1/flags.GetFlag("FrameLimit")) then return end
		RenderStep:Fire(DT)
		TotalDeltaRender = 0
	end)
end

RunService.Heartbeat:Connect(function(DT)
	TotalDeltaHeartBeat += DT
	if (TotalDeltaHeartBeat < 1/flags.GetFlag("FrameLimit")) then return end
	HeartBeat:Fire(DT)
	TotalDeltaHeartBeat = 0
end)

function SetupCamera()
	Camera = workspace.CurrentCamera
	ScreenSize = Camera.ViewportSize
	
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		ScreenSize = Camera.ViewportSize
	--	warn("Screen size changed to: "..ScreenSize.X..", "..ScreenSize.Y)
		flags:Log("Screen size changed to: "..ScreenSize.X..", "..ScreenSize.Y, script)
		OnScreenSizeUpdated:Fire(ScreenSize)
	end)
	
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if Camera then Camera:Destroy() end
	SetupCamera()
end)

SetupCamera()

frames.RenderStepped = RenderStep

frames.Heartbeat = HeartBeat

frames.OnScreenSizeUpdate = OnScreenSizeUpdated

frames.AllImagesLoaded = AllImagesLoaded

function LoadAnimations()
	if RunService:IsClient() then
		for _, FrameSequence in pairs(FrameByFrames) do
			if typeof(FrameSequence) == "table" then
				if FrameSequence.ImageSequence then
					Animations[FrameSequence.Name] = {}
					local lastframe
					for _, Frame in pairs(FrameSequence.AllFrames) do
						if typeof(Frame) == "number" then
							Frame = "rbxassetid://"..Frame
						end
						
						local UIAspectRatioConts =  Instance.new("UIAspectRatioConstraint")
						UIAspectRatioConts.AspectRatio = FrameSequence.AspectRatio
						UIAspectRatioConts.Name = ""

						local UISizeConts = Instance.new("UISizeConstraint")
						UISizeConts.MaxSize = FrameSequence.MaxSize
						UISizeConts.MinSize = FrameSequence.MinSize
						UISizeConts.Name = ""
						
						local Label = Instance.new("ImageLabel")
						Label.AnchorPoint = Vector2.new(.5, .5)
						Label.BackgroundTransparency = 1
						Label.Size = FrameSequence.Size
						Label.Position = UDim2.new(.9, 0, .9, 0)
						Label.Image = Frame
						Label.ImageColor3 = FrameSequence.Color
						Label.Name = ""

						UISizeConts.Parent = Label
						UIAspectRatioConts.Parent = Label
						Label.Parent = PlayersService.LocalPlayer.PlayerGui.SplashGui.FrameByFrames.Sequence
						lastframe = Label
						
						table.insert(Animations[FrameSequence.Name], Label)
						task.delay(.1, function()
							Label.Position = UDim2.new(2, 0, 2, 0)
						end)
					end
					
				end
			end
			
		end
	end
end

function frames:Play(Animation : string, Position : UDim2)
	if not Animations[Animation] then warn(Animation.." is not a valid frame by frame animation.") return end
	
	task.spawn(function()
		
		local PreviousFrame
		
		for _, NextFrame in pairs(Animations[Animation]) do
			frames.RenderStepped:Wait()
			if PreviousFrame then PreviousFrame.Position = UDim2.new(2, 0, 2, 0) end

			NextFrame.Position = Position

			PreviousFrame = NextFrame
		end

		frames.RenderStepped:Wait()

		PreviousFrame.Position = UDim2.new(2, 0, 2, 0)
		
	end)
	
end

FrameByFrames.ArrowTracker = {
	Name = "ArrowTracker",
	ImageSequence = false,
	AllFrames = {
	14103098358,
	14103099385,
	14103100982,
	14103101890,
	14103103159,
	14103104766,
	14103106668,
	14103182595,
	14103184005,
	14103190477,
	14103191801,
	14103192616,
	14103194321,
	14103195737,
	14103196782,
	14103198126,
	14103201436,
	14103202635,
	14103203527,
	14103204954,
	14103205901,
	14103207197,
	14103208387,
	14103209588,
	14103212060,
	14103213304,
	14103214292,
	14103215385,
	14103216508,
	14103217762,
	14103220071,
	14103221254,
	14103222547,
	14103224740,
	14103225907,
	14103226923
	}
}

FrameByFrames.Rosette = {
	Name = "Rosette",
	ImageSequence = false,
	AllFrames = {
	13763910182,
	13763913735,
	13763914858,
	13763916012,
	13763917649,
	13763918717,
	13763920493,
	13763925039,
	13763925799,
	13763926548,
	13763927655,
	13763928662,
	13763929611,
	13763930767,
	13763932088,
	13763934458,
	13763935405,
	13763936199,
	13763936963,
	13763937894,
	13763938584,
	13763939733,
	13763940658,
	13763945379,
	13763946454,
	13763947150,
	13763948497,
	13763950136,
	13763951011,
	13763951852,
	13763952753,
	13763954803,
	13763956016,
	13763957907,
	13763958810,
	13763959579,
	13763960302,
	13763962478,
	13763963153,
	13763963977,
	13763964930,
	13763966470,
	13763967376,
	13763968027,
	13763969142,
	13763970597,
	13763971342
	}
}

FrameByFrames.StarStruck = {
	Name = "StarStruck",
	ImageSequence = false,
	AllFrames = {
	13762271299,
	13762272321,
	13762273228,
	13762275070,
	13762276957,
	13762277960,
	13762278924,
	13762281006,
	13762282107,
	13762283056,
	13762283986,
	13762284802,
	13762285844,
	13762286750,
	13762287703,
	13762289072,
	13762291288,
	13762292722,
	13762293828,
	13762295687,
	13762297172,
	13762298948,
	13762300117,
	13762304787,
	13762305989,
	13762307274,
	13762308539,
	13762309971,
	13762311048,
	13762312628,
	13762314108,
	13762315434,
	13762318216,
	13762319488,
	13762320734,
	13762322282,
	13762324433,
	13762325858,
	13762327138,
	13762328582,
	13762329773,
	13762330666,
	13762331822,
	13762334992,
	13762336124,
	13762337520,
	13762338787,
	13762340348,
	13762341358,
	13762342571,
	13762343772,
	13762345698,
	13762346870,
	13762348296,
	13762349382,
	13762350700,
	13762351772,
	13762352889,
	13762356058,
	13762357048,
	13762358274,
	13762359300,
	13762360621,
	13762362074,
	13762363488,
	13762364823,
	13762365914,
	13762367216,
	13762368199,
	13762369339,
	13762370790
	}
}

FrameByFrames.Ready = {
	Name = "Ready",
	ImageSequence = true,
	Size = UDim2.fromScale(0.301, 0.293),
	MaxSize = Vector2.new(500, 281),
	MinSize = Vector2.new(330, 185),
	AspectRatio = 1.779,
	Color = Color3.fromRGB(255, 255, 255),
	Position = UDim2.new(1.2, 0, 1.2, 0),
	AllFrames = {
	"rbxassetid://15717013817",
	"rbxassetid://15717013654",
	"rbxassetid://15717013564",
	"rbxassetid://15717013495",
	"rbxassetid://15717013411",
	"rbxassetid://15717013321",
	"rbxassetid://15717013218",
	"rbxassetid://15717013123",
	"rbxassetid://15717012979",
	"rbxassetid://15717012782",
	"rbxassetid://15717012641",
	"rbxassetid://15717012538",
	"rbxassetid://15717012420",
	"rbxassetid://15717012313",
	"rbxassetid://15717012235",
	"rbxassetid://15717012145",
	"rbxassetid://15717012079",
	"rbxassetid://15717011977",
	"rbxassetid://15717011908",
	"rbxassetid://15717011770",
	"rbxassetid://15717011585",
	"rbxassetid://15717011489",
	"rbxassetid://15717011402",
	"rbxassetid://15717011328",
	"rbxassetid://15717010317",
	"rbxassetid://15717010151",
	"rbxassetid://15717010030",
	"rbxassetid://15717009943",
	"rbxassetid://15717009847",
	"rbxassetid://15717009750",
	"rbxassetid://15717009660",
	"rbxassetid://15717009522",
	"rbxassetid://15717009433",
	"rbxassetid://15717009344",
	"rbxassetid://15717009259",
	"rbxassetid://15717009135",
	"rbxassetid://15717008942",
	"rbxassetid://15717008770",
	"rbxassetid://15717008600",
	"rbxassetid://15717008448",
	"rbxassetid://15717008372",
	"rbxassetid://15717008297",
	"rbxassetid://15717008208",
	"rbxassetid://15717008075",
	"rbxassetid://15717007995",
	"rbxassetid://15717007895",
	"rbxassetid://15717007747",
	"rbxassetid://15717007647",
	"rbxassetid://15717007545",
	"rbxassetid://15717007379",
	"rbxassetid://15717007268",
	"rbxassetid://15717007179",
	"rbxassetid://15717007052",
	"rbxassetid://15717006907",
	"rbxassetid://15717006787",
	"rbxassetid://15717006674",
	"rbxassetid://15717006563",
	"rbxassetid://15717006400",
	"rbxassetid://15717006285",
	"rbxassetid://15717006151",
	"rbxassetid://15717006010",
	"rbxassetid://15717005846",
	"rbxassetid://15717005663",
	"rbxassetid://15717005447",
	"rbxassetid://15717005357",
	"rbxassetid://15717005222",
	"rbxassetid://15717005100",
	"rbxassetid://15717005033",
	"rbxassetid://15717004937",
	"rbxassetid://15717004825",
	"rbxassetid://15717004746",
	"rbxassetid://15717004592",
	"rbxassetid://15717004422",
	"rbxassetid://15717004295",
	"rbxassetid://15717004194"
	}
}

FrameByFrames.Round1 = {
	Name = "Round1",
	ImageSequence = true,
	Size = UDim2.fromScale(0.301, 0.293),
	MaxSize = Vector2.new(500, 281),
	MinSize = Vector2.new(330, 185),
	AspectRatio = 1.779,
	Color = Color3.fromRGB(255, 255, 255),
	Position = UDim2.new(1.2, 0, 1.2, 0),
	AllFrames = {
	"rbxassetid://15780060351",
	"rbxassetid://15780060280",
	"rbxassetid://15780060231",
	"rbxassetid://15780051757",
	"rbxassetid://15780051692",
	"rbxassetid://15780051603",
	"rbxassetid://15780051492",
	"rbxassetid://15780051369",
	"rbxassetid://15780051261",
	"rbxassetid://15780051139",
	"rbxassetid://15780051010",
	"rbxassetid://15780050909",
	"rbxassetid://15780050834",
	"rbxassetid://15780050025",
	"rbxassetid://15780049913",
	"rbxassetid://15780049780",
	"rbxassetid://15780049691",
	"rbxassetid://15780049628",
	"rbxassetid://15780049560",
	"rbxassetid://15780049496",
	"rbxassetid://15780049401",
	"rbxassetid://15780049274",
	"rbxassetid://15780049120",
	"rbxassetid://15780048975",
	"rbxassetid://15780048863",
	"rbxassetid://15780048733",
	"rbxassetid://15780048625",
	"rbxassetid://15780048510",
	"rbxassetid://15780048413",
	"rbxassetid://15780048312",
	"rbxassetid://15780048237",
	"rbxassetid://15780048161",
	"rbxassetid://15780048032",
	"rbxassetid://15780047914",
	"rbxassetid://15780531965",
	"rbxassetid://15780047597",
	"rbxassetid://15780047476",
	"rbxassetid://15780047375",
	"rbxassetid://15780047304",
	"rbxassetid://15780047202",
	"rbxassetid://15780047132",
	"rbxassetid://15780047051",
	"rbxassetid://15780046980",
	"rbxassetid://15780046883",
	"rbxassetid://15780046780",
	"rbxassetid://15780046689",
	"rbxassetid://15780046499",
	"rbxassetid://15780046395",
	"rbxassetid://15780046300",
	"rbxassetid://15780046222",
	"rbxassetid://15780046149",
	"rbxassetid://15780046041",
	"rbxassetid://15780045903",
	"rbxassetid://15780045817",
	"rbxassetid://15780045750",
	"rbxassetid://15780045694",
	"rbxassetid://15780045563",
	"rbxassetid://15780045471",
	"rbxassetid://15780045334",
	"rbxassetid://15780045231",
	"rbxassetid://15780045060",
	"rbxassetid://15780044950",
	"rbxassetid://15780044872",
	"rbxassetid://15780044097",
	"rbxassetid://15780044034",
	"rbxassetid://15780043940",
	"rbxassetid://15780043858",
	"rbxassetid://15780043779",
	"rbxassetid://15780043716",
	"rbxassetid://15780043641",
	"rbxassetid://15780043567",
	"rbxassetid://15780043474",
	"rbxassetid://15780043372",
	"rbxassetid://15780043281",
	"rbxassetid://15780043181",
	"rbxassetid://15780043078",
	"rbxassetid://15780042980",
	"rbxassetid://15780042779",
	"rbxassetid://15780042713",
	"rbxassetid://15780042612",
	"rbxassetid://15780042529",
	"rbxassetid://15780042463",
	"rbxassetid://15780042384",
	"rbxassetid://15780042273",
	"rbxassetid://15780042178",
	"rbxassetid://15780042113",
	"rbxassetid://15780042030",
	"rbxassetid://15780041899",
	"rbxassetid://15780041811",
	"rbxassetid://15780041719",
	"rbxassetid://15780041560",
	"rbxassetid://15780041372",
	"rbxassetid://15780041249",
	"rbxassetid://15780041169",
	"rbxassetid://15780041069",
	"rbxassetid://15780040897",
	"rbxassetid://15780040760",
	"rbxassetid://15780040625",
	"rbxassetid://15780040532",
	"rbxassetid://15780040354",
	"rbxassetid://15780040245",
	"rbxassetid://15780040150",
	"rbxassetid://15780040071",
	"rbxassetid://15780040019",
	"rbxassetid://15780039956",
	"rbxassetid://15780039825",
	"rbxassetid://15780039682",
	"rbxassetid://15780039495",
	"rbxassetid://15780039359",
	"rbxassetid://15780039226",
	"rbxassetid://15780039104",
	"rbxassetid://15780039009",
	"rbxassetid://15780038879",
	}
}

FrameByFrames.Round2 = {
	Name = "Round2",
	ImageSequence = true,
	Size = UDim2.fromScale(0.301, 0.293),
	MaxSize = Vector2.new(500, 281),
	MinSize = Vector2.new(330, 185),
	AspectRatio = 1.779,
	Color = Color3.fromRGB(255, 255, 255),
	Position = UDim2.new(1.2, 0, 1.2, 0),
	AllFrames = {
		"rbxassetid://15787366757",
		"rbxassetid://15787366647",
		"rbxassetid://15787366542",
		"rbxassetid://15787366352",
		"rbxassetid://15787366161",
		"rbxassetid://15787365980",
		"rbxassetid://15787365795",
		"rbxassetid://15787365647",
		"rbxassetid://15787352861",
		"rbxassetid://15787352784",
		"rbxassetid://15787352670",
		"rbxassetid://15787352536",
		"rbxassetid://15787351054",
		"rbxassetid://15787350905",
		"rbxassetid://15787350745",
		"rbxassetid://15787350584",
		"rbxassetid://15787350411",
		"rbxassetid://15787350150",
		"rbxassetid://15787349894",
		"rbxassetid://15787349605",
		"rbxassetid://15787349505",
		"rbxassetid://15787349414",
		"rbxassetid://15787349294",
		"rbxassetid://15787349155",
		"rbxassetid://15787349007",
		"rbxassetid://15787348840",
		"rbxassetid://15787348694",
		"rbxassetid://15787348563",
		"rbxassetid://15787348452",
		"rbxassetid://15787348317",
		"rbxassetid://15787348167",
		"rbxassetid://15787347990",
		"rbxassetid://15787347819",
		"rbxassetid://15787347655",
		"rbxassetid://15787347472",
		"rbxassetid://15787347294",
		"rbxassetid://15787347176",
		"rbxassetid://15787347059",
		"rbxassetid://15787346902",
		"rbxassetid://15787346733",
		"rbxassetid://15787346563",
		"rbxassetid://15787346417",
		"rbxassetid://15787346244",
		"rbxassetid://15787346124",
		"rbxassetid://15787345944",
		"rbxassetid://15787345678",
		"rbxassetid://15787435262",
		"rbxassetid://15787345449",
		"rbxassetid://15787345344",
		"rbxassetid://15787345203",
		"rbxassetid://15787345063",
		"rbxassetid://15787344878",
		"rbxassetid://15787344641",
		"rbxassetid://15787344525",
		"rbxassetid://15787344412",
		"rbxassetid://15787344259",
		"rbxassetid://15787344139",
		"rbxassetid://15787344067",
		"rbxassetid://15787343968",
		"rbxassetid://15787343856",
		"rbxassetid://15787343777",
		"rbxassetid://15787343668",
		"rbxassetid://15787343551",
		"rbxassetid://15787342249",
		"rbxassetid://15787342106",
		"rbxassetid://15787341972",
		"rbxassetid://15787341870",
		"rbxassetid://15787341724",
		"rbxassetid://15787341554",
		"rbxassetid://15787341425",
		"rbxassetid://15787341271",
		"rbxassetid://15787341067",
		"rbxassetid://15787340952",
		"rbxassetid://15787495775",
		"rbxassetid://15787340761",
		"rbxassetid://15787340613",
		"rbxassetid://15787340414",
		"rbxassetid://15787340259",
		"rbxassetid://15787340160",
		"rbxassetid://15787340064",
		"rbxassetid://15787339950",
		"rbxassetid://15787339558",
		"rbxassetid://15787339394",
		"rbxassetid://15787339202",
		"rbxassetid://15787339072",
		"rbxassetid://15787338959",
		"rbxassetid://15787338860",
		"rbxassetid://15787338748",
		"rbxassetid://15787338578",
		"rbxassetid://15787338408",
		"rbxassetid://15787338303",
		"rbxassetid://15787338172",
		"rbxassetid://15787338029",
		"rbxassetid://15787337815",
		"rbxassetid://15787337578",
		"rbxassetid://15787337400",
		"rbxassetid://15787530947",
		"rbxassetid://15787337140",
		"rbxassetid://15787542369",
		"rbxassetid://15787336862",
		"rbxassetid://15787336472",
		"rbxassetid://15787336360",
		"rbxassetid://15787336247",
		"rbxassetid://15787336085",
		"rbxassetid://15787335896",
		"rbxassetid://15787335692",
		"rbxassetid://15787335462",
		"rbxassetid://15787335217",
		"rbxassetid://15787334876",
		"rbxassetid://15787334632",
		"rbxassetid://15787334462",
		"rbxassetid://15787334321",
		"rbxassetid://15787334220",
		"rbxassetid://15780038879"
	}
}

LoadAnimations()

return frames