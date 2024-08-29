SL.Global.LinkInputCallback = function(event)
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "Start" then
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
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

local idx = 1
for tag, score in pairs(SL.Global.LinkPlayerScores) do
	t[#t+1] = LoadActor("./resultbar.lua", {tag, score, 0, -100 + idx*50})
	idx = idx + 1
end

return t