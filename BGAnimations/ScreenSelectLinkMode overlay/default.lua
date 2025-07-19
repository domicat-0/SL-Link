SL.Global.LinkInputCallback = function(event)
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type ~= "InputEventType_FirstPress" then return false end
	if event.GameButton == "Start" then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		for i, child in ipairs(self:GetChild("")) do
			if i-2 == SL.Global.LinkRoundNumber then
				child:diffuse(1, 1, 1, 1)
			end
		end
	end,
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="PlayerName",
	InitCommand = function(self)
		self:zoom(1)
		self:settext( THEME:GetString("ScreenTitleJoin", "Press Start"))
	end
}

return t