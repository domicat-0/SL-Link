local args = ...
local idx = args[1]
local pos_x = args[2]
local pos_y = args[3]

local width = 240
local height = 40
local player_color = color("FF4D4D")
local opponent_color = color("4D4DFF")

local tag = SL.Global.LinkTournamentPlayerList[idx]

local af = Def.ActorFrame {
	InitCommand = function(self)
		self:x(pos_x):y(pos_y)
	end,
	RefreshCommand = function(self)
		local tag = SL.Global.LinkTournamentPlayerList[self:getaux()]
		local pname = SL.Global.LinkTournamentPlayerNames[tag]
		local score = SL.Global.LinkPlayerTournamentScores[tag]

		if score == nil then
			if pname == nil then
				self:GetChild("PlayerName"):settext("")
			else
				self:GetChild("PlayerName"):settext(pname)
			end
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
	Name="PlayerName",
	Text=SL.Global.LinkTournamentPlayerNames[tag],
	InitCommand = function(self)
		self:horizalign(0)
		self:zoom(1.1)
		self:x(-90)
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="Score",
	Text=SL.Global.LinkPlayerTournamentScores[tag],
	InitCommand = function(self)
		self:horizalign(2)
		self:zoom(1.5)
		self:x(130)
	end,
	RefreshCommand = function(self)
		local tag = SL.Global.LinkTournamentPlayerList[self:GetParent():getaux()]
		local score = SL.Global.LinkPlayerTournamentScores[tag]

		if score == nil then
			self:settext("")
		else
			self:settext(score)
		end
	end
}
af[#af+1] = LoadFont("Common Normal")..{
	Name="Position",
	Text=SL.Global.LinkPlayerTournamentPositions[tag],
	InitCommand = function(self)
		self:horizalign(1)
		self:zoom(1.5)
		self:x(-120)
	end,
	RefreshCommand = function(self)
		local tag = SL.Global.LinkTournamentPlayerList[self:GetParent():getaux()]
		local tpos = SL.Global.LinkPlayerTournamentPositions[tag]
		if tpos == nil then
			self:settext("")
		else
			self:settext(tpos)
		end
		
	end
}

return af