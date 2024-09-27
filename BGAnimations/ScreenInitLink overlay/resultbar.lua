local args = ...
local idx = args[1]
local tag = SL.Global.LinkPlayerList[idx]
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
		self:aux(idx)
	end,
	RefreshCommand = function(self)
		local tag = SL.Global.LinkPlayerList[self:getaux()]
		local pname = SL.Global.LinkPlayerNames[tag]

		if pname == nil then
			self:GetChild("PlayerName"):settext("")
			self:diffuse(1, 1, 1, 0.3)
		else
			self:GetChild("PlayerName"):settext(pname)
			self:diffuse(1, 1, 1, 1)
		end

		for child in ivalues(self:GetChild("")) do
			child:playcommand("Refresh")
		end
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(20, height)
		self:x(-width/2)
	end,
	RefreshCommand = function(self)
		local tag = SL.Global.LinkPlayerList[self:GetParent():getaux()]
		if SL.Global.LinkPlayerReady[tag] then
			self:diffuse(0.3, 0.7, 0.3, 1)
		else
			self:diffuse(0.12, 0.12, 0.12, 1)
		end
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width, height)
		self:x(10)
	end,
	RefreshCommand = function(self)
		SCREENMAN:SystemMessage(SL.Global.LinkPlayerTag)
		local tag = SL.Global.LinkPlayerList[self:GetParent():getaux()]
		if tag == SL.Global.LinkPlayerTag then
			self:diffuse(0.1, 0.4, 0.7, 1)
		else
			self:diffuse(0.2, 0.2, 0.2, 1)
		end
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerName",
	Text=SL.Global.LinkPlayerNames[tag],
	InitCommand = function(self)
		self:zoom(1)
		self:x(-10)
	end
}

return af