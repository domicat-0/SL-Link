local current_page = 1
local page_length = 6

SL.Global.LinkInputCallback = function(event)
	if SL.Global.LinkPlayerReady[SL.Global.LinkPlayerTag] then return false end
	if not event or not event.PlayerNumber then
		return false
	end
	if event.type ~= "InputEventType_FirstPress" then return false end
	if event.GameButton == "MenuLeft" then
		if current_page > 1 then
			current_page = current_page - 1
			af:playcommand("Refresh")
		end
	elseif event.GameButton == "MenuRight" then
		if #SL.Global.LinkTournamentPlayerList >= page_length*current_page + 1 then
			current_page = current_page + 1
			af:playcommand("Refresh")
		end
	elseif event.GameButton == "Back" then
		local ev = {
			type="WebSocketMessageType_Message",
			data={
				type="leave_room"
			}
		}
		SL.Global.LinkWS:Send(JsonEncode(ev))
		topscreen = SCREENMAN:GetTopScreen()
		topscreen:RemoveInputCallback(SL.Global.LinkInputCallback)
		topscreen:Cancel()	
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		af = self
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		SL.Global.LinkSongMasterList = GetLinkSongs()
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		for i, child in ipairs(self:GetChild("ResultBar")) do
			local idx = (page_length * (current_page - 1) + i)
			child:aux(idx)
			child:playcommand("Refresh")
		end
	end

}

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

for idx=1,6 do
	t[#t+1] = LoadActor("./resultbar.lua", {idx + (current_page - 1) * 6, 0, 0, -195 + idx*50})..{
		Name="ResultBar"
	}
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