local args = ...
local tag = args[1]
local score = args[2]
local result = args[3]
local pos_x = args[4]
local pos_y = args[5]

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
		self:zoomto(width, height)
		self:x(20)
		self:diffuse(0.15, 0.15, 0.15, 1)
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:horizalign(0)
		self:zoomto(40, height)
		self:x(-140)
		if tag == SL.Global.LinkPlayerTag then
			self:diffuse(0.15, 0.15, 0.5, 1)
		else
			self:diffuse(0.5, 0.15, 0.15, 1)
		end
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=SL.Global.LinkPlayerNames[tag],
	InitCommand = function(self)
		self:horizalign(0)
		self:zoom(1.1)
		self:x(-90)
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=result,
	InitCommand = function(self)
		self:horizalign(2)
		self:zoom(1.5)
		self:x(130)
	end
}
af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text=score,
	InitCommand = function(self)
		self:horizalign(1)
		self:zoom(1.5)
		self:x(-120)
	end
}

return af