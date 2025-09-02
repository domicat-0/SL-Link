SL.Global.LinkInputCallback = function(event)
	if SL.Global.LinkPlayerReady[SL.Global.LinkPlayerTag] then return false end
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type ~= "InputEventType_FirstPress" then return false end
	if event.GameButton == "MenuLeft" then
		if page > 1 then
			page = page - 1
			af:playcommand("Refresh")
		end
	elseif event.GameButton == "MenuRight" then
		if #SL.Global.LinkTournamentPlayerList >= 6*page + 1 then
			page = page + 1
			af:playcommand("Refresh")
		end
	elseif event.GameButton == "Start" then
		if SL.Global.LinkExit then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		SM(SL.Global.LinkPlayerTournamentScores)
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

for idx=1,6 do
	t[#t+1] = LoadActor("./resultbar.lua", {idx + (page - 1) * 6, 0, -195 + idx*50})
end

return t