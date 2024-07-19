local link_ws = NETWORK:WebSocket{
	url="http://127.0.0.1",
	headers={                                       -- default: {}
		["Accept-Language"]="en-US",
		["Cookie"]="sessionId=42",
	},
	handshakeTimeout=5,
	pingInterval=10,
	automaticReconnect=True,
	onMessage=MessageHandler
}

local GetSongFromHash = function(hash)
	for song in ivalues(SL.Global.LinkSongList) do
		local steps = song:GetOneSteps(0, "Difficulty_Challenge")
		if steps.GetHash() == hash then
			return song
		end
	end
	return nil
end

local ErrorHandler = function(data)
	SCREENMAN:SystemMessage(data["message"])
end

local JoinHandler = function(data)
	SL.Global.LinkPlayerTag = data["tag"]
end

local PlayerUpdateHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	PlayerListUpdate()
end

local DraftStartHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	SL.Global.LinkSongList = data["songs"]
	if SCREENMAN:GetTopScreen():GetName() == ScreenWaitLink then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end

local PickHandler = function(data)
	local hash = data["song"]
	local song = GetSongFromHash(hash)
end

local NextHandler = function(data)
	local player = data["player"]
	if player == SL.Global.LinkPlayerTag then
		SL.Global.LinkActive = true
	end
end

local BanHandler = function(data)
	local hash = data["song"]
	local song = GetSongFromHash(hash)
end

local GameStartHandler = function(data)
end

local ResultUpdateHandler = function(data)
end

local MessageHandler = function(message)
	local data = JsonDecode(message["data"])
	if data["type"] == "join" then
		JoinHandler(data)
	elseif data["type"] == "update" then
		PlayerUpdateHandler(data)
	elseif data["type"] == "start" then
		DraftStartHandler(data)
	end
end

return link_ws