local args = ...
local tag = args[1]
local score = args[2]

local width = 70
local height = 30
local player_color = color("FF4D4D")
local opponent_color = color("4D4DFF")

local af = Def.ActorFrame {
	
}


af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width+6, height+2)
		self:diffuse(0.15, 0.15, 0.15, 1)
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width, height)
		self:x(6)
		self:diffuse(0.15, 0.15, 0.15, 1)
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=tag,
	InitCommand = function(self)
		self:zoom(0.7)
		self:x(-20)
	end
}
af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=tag,
	InitCommand = function(self)
		self:zoom(0.7)
		self:x(-20)
	end
}

return af