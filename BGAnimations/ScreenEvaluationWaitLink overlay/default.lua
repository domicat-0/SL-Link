local ScoreCalc = function()
	local exc = SL["P1"].Stages.Stats[#SL["P1"].Stages.Stats].ex_counts
	local link_weights = {
		W010 = 10,
		W110 = 9,
		W2 = 6,
		W3 = 3,
		W4 = 0,
		W5 = 0,
		Miss = 0,
		Held = 10,
		LetGo = 0,
		HitMine = -6,
	}
	local total_score = 0
	for key, val in pairs(exc) do
		if link_weights[key] then
			total_score = total_score + link_weights[key] * val
		end
	end

	player = PLAYER_1
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local totalSteps = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	local totalHolds = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Holds" )
	local totalRolls = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Rolls" )
	local max_score = totalSteps * 10 + (totalHolds + totalRolls) * 10

	return math.max(0, math.floor(total_score/max_score * 10000) / 100), total_points, total_possible
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		event = {
			type="WebSocketMessageType_Message",
			data={
				type="song_result",
				score=ScoreCalc()
			}
		}
		SL.Global.LinkWS:Send(JsonEncode(event))
	end
}


t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text="Waiting for players to finish...",
	InitCommand=function(self)
		self:shadowlength(1):y(40):zoom(0.8)
	end
}

return t  