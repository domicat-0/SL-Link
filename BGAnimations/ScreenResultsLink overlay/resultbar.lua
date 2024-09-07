local args = ...
local tag = args[1]
local score = args[2]
local pos_x = args[3]
local pos_y = args[4]

local width = 240
local height = 40
local player_color = color("FF4D4D")
local opponent_color = color("4D4DFF")

local af = Def.ActorFrame {
	InitCommand = function(self)
		self:x(pos_x):y(pos_y)
	end
}


af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width+20, height)
		if tag == SL.Global.LinkPlayerTag then
			self:diffuse(0.3, 0.3, 1, 1)
		else
			self:diffuse(1, 0.3, 0.3, 1)
		end
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width, height)
		self:x(10)
		self:diffuse(0.15, 0.15, 0.15, 1)
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=SL.Global.LinkPlayerNames[tag],
	InitCommand = function(self)
		self:zoom(1)
		self:x(-10)
	end
}
af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=score,
	InitCommand = function(self)
		self:zoom(1.5)
		self:x(110)
	end
}

return af