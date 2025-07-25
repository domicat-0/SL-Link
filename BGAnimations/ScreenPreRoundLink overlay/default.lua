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

t[#t+1] = LoadActor("./tile.lua", {active_song, -200, -80, "main"})

for i,song in ipairs(songlist) do
	local song_actor = LoadActor("./tile.lua", {song, (-400+100*i), 100, "side"})
	t[#t+1] = song_actor
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