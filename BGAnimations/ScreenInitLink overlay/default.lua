SL.Global.LinkInputCallback = function(event)
	if SL.Global.LinkPlayerReady[SL.Global.LinkPlayerTag] then return false end
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
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		SL.Global.LinkSongMasterList = GetLinkSongs()
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		for child in ivalues(self:GetChild("")) do
			child:playcommand("Refresh")
		end
	end

}

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

for idx=1,6 do
	t[#t+1] = LoadActor("./resultbar.lua", {idx, 0, 0, -195 + idx*50})
end

t[#t+1] = LoadFont("Common Normal")..{
	Name="StartConf",
	InitCommand = function(self)
		self:zoom(1)
		self:y(180)
		self:settext( THEME:GetString("ScreenTitleJoin", "StartConf"))
	end
}

return t  