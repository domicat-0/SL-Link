SL.Global.LinkWebSocket = NETWORK:WebSocket{
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
	return nil

local ErrorHandler = function(data)
	SCREENMAN:SystemMessage(data["message"])

local JoinHandler = function(data)
	SL.Global.LinkPlayerTag = data["tag"]

local PlayerUpdateHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	PlayerListUpdate()

local DraftStartHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	SL.Global.LinkSongList = data["songs"]
	if SCREENMAN:GetTopScreen():GetName() == ScreenWaitLink then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")

local PickHandler = function(data)
	local hash = data["song"]
	local song = GetSongFromHash(hash)

local NextHandler = function(data)
	local player = data["player"]
	if player == SL.Global.LinkPlayerTag then
		SL.Global.LinkActive = true

local BanHandler = function(data)
	local hash = data["song"]
	local song = GetSongFromHash(hash)

local GameStartHandler = function(data)

local ResultUpdateHandler = function(data)


local MessageHandler = function(message)
	local data = JsonDecode(message["data"])
	if data["type"] == "join" then
		JoinHandler(data)
	elseif data["type"] == "update" then
		PlayerUpdateHandler(data)
	elseif data["type"] == "start" then
		DraftStartHandler(data)


