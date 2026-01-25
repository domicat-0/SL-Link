local songlist = SL.Global.LinkSelectedSongs
local active_song = songlist[SL.Global.LinkRoundNumber]
local accepting_input = true
SL.Global.LinkInputCallback = function(event)
	if not accepting_input then return false end
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type ~= "InputEventType_FirstPress" then return false end
	if event.GameButton == "Start" then
		local ev = {
			type="WebSocketMessageType_Message",
			data={
				type="ready"
			}
		}
		SL.Global.LinkWS:Send(JsonEncode(ev))
		accepting_input = false
	end
end

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		local timer = SCREENMAN:GetTopScreen():GetChild("Timer")
		if timer ~= nil then
			if SL.Global.LinkMatchTimeLeft ~= nil then
				timer:SetSeconds(SL.Global.LinkMatchTimeLeft)
				timer:start()
			else
				timer:stealth(true)
			end
		end
		if SL.Global.LinkRoundStart then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
		for i, child in ipairs(self:GetChild("")) do
			if i-2 == SL.Global.LinkRoundNumber then
				child:diffuse(1, 1, 1, 1)
			end
		end
		if active_song then
			SL.Global.ActiveModifiers.MusicRate = 1
			for player in ivalues(GAMESTATE:GetHumanPlayers()) do
				local pn = ToEnumShortString(player)
				if SL.Global.LinkCmodStatus then
					if (active_song:GetDisplayFullTitle():lower():match("no cmod") or
                    active_song:GetTranslitFullTitle():lower():match("no cmod")) then
						SL[pn].ActiveModifiers.SpeedModType = "M"
					else
						SL[pn].ActiveModifiers.SpeedModType = "C"
					end
				end
				ApplyMods(player)
			end
		end
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		for child in ivalues(self:GetChild("")) do
			child:playcommand("Refresh")
		end
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

t[#t+1] = LoadActor("./tile.lua", {active_song, -200, -80, "main"})

for i,song in ipairs(songlist) do
	local song_actor = LoadActor("./tile.lua", {song, (-400+100*i), 100, "side"})
	t[#t+1] = song_actor
end

for idx=1,6 do
	t[#t+1] = LoadActor("./resultbar.lua", {idx, 0, 100, -195 + idx*50})
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

t[#t+1] = LoadFont("Common Normal")..{
	Name="StartConf",
	InitCommand = function(self)
		self:zoom(1)
		self:y(180)
		self:settext( THEME:GetString("ScreenTitleJoin", "StartConf"))
	end
}

return t
