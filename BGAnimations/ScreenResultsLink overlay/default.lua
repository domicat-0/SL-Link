SL.Global.LinkInputCallback = function(event)
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "Start" and not (SL.Global.LinkRoundExit and not SL.Global.LinkExit) then
			local timer = SCREENMAN:GetTopScreen():GetChild("Timer")
			SL.Global.LinkMatchTimeLeft = timer:GetSeconds()
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
		if SL.Global.LinkRoundStart then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end

		local timer = SCREENMAN:GetTopScreen():GetChild("Timer")
		if timer ~= nil then
			if SL.Global.LinkMatchTimeLeft ~= nil then
				timer:SetSeconds(SL.Global.LinkMatchTimeLeft)
				timer:start()
			else
				timer:stealth(true)
			end
		end
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

local idx = 1
for tag, score in pairs(SL.Global.LinkPlayerScores) do
	t[#t+1] = LoadActor("./resultbar.lua", {tag, score, SL.Global.LinkPlayerResults[tag], 0, -100 + idx*50})
	idx = idx + 1
end

if SL.Global.LinkRoundExit and not SL.Global.LinkExit then
	t[#t+1] = LoadFont("Common Normal")..{
		Text="Waiting for current round to finish...",
		InitCommand=function(self)
			self:shadowlength(1):y(40):zoom(0.8)
		end
	}
end

return t