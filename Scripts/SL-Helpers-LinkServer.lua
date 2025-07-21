local GetFileContents = function(path)
	local contents = ""

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 1) then
			contents = file:Read()
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	-- split the contents of the file on newline
	-- to create a table of lines as strings
	local lines = {}
	for line in contents:gmatch("[^\r\n]+") do
		lines[#lines+1] = line
	end

	return lines
end



GetLinkSongs = function()
	local path = THEME:GetCurrentThemeDirectory() .. "Other/LinkMode-Groups.txt"
	local preliminary_groups = GetFileContents(path)

	-- if the file didn't exist or was empty or contained no valid groups,
	-- return the full list of groups available to SM
	if preliminary_groups == nil or #preliminary_groups == 0 then
		return nil
	end

	local groups = {}
	-- some Groups found in the file may not actually exist due to human error, typos, etc.
	for prelim_group in ivalues(preliminary_groups) do
		-- if this group exists
		if SONGMAN:DoesSongGroupExist( prelim_group ) then
			-- add this preliminary group to the table of finalized groups
			groups[#groups+1] = prelim_group
		end
	end

	if #groups > 0 then
		local songs = SONGMAN:GetSongsInGroup(groups[1])
		return songs
	else
		return nil
	end
end

-- NOTE: Currently O(N) due to not creating hash table first
local GetSongFromHash = function(hash)
	for j, song in ipairs(SL.Global.LinkSongMasterList) do
		local steps = song:GetOneSteps(0, "Difficulty_Challenge")
		local fn = steps:GetFilename()
		local steps_hash = BinaryToHex(CRYPTMAN:MD5File(fn))
		if steps_hash == hash then
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
	SL.Global.LinkPlayerNames = data["names"]
	if SCREENMAN:GetTopScreen() then
		SCREENMAN:GetTopScreen():playcommand("Refresh")
	end
end

local PlayerReadyHandler = function(data)
	local tag = data["player"]
	SL.Global.LinkPlayerReady[tag] = true
	if SCREENMAN:GetTopScreen() then
		SCREENMAN:GetTopScreen():playcommand("Refresh")
	end
end

local DraftStartHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	SL.Global.LinkPlayerNames = data["names"]
	local song_hashes = data["songs"]
	SL.Global.LinkDraftSongList = {}
	for tag in ivalues(SL.Global.LinkPlayerList) do
		SL.Global.LinkPlayerReady[tag] = false
	end
	for i, hash in ipairs(song_hashes) do
		SL.Global.LinkDraftSongList[i] = GetSongFromHash(hash)
	end
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


local GameStartHandler = function(data)
	local song_hashes = data["songs"]
	SL.Global.LinkSelectedSongs = {}
	for i, hash in ipairs(song_hashes) do
		SL.Global.LinkSelectedSongs[i] = GetSongFromHash(hash)
	end
	SL.Global.LinkRoundNumber = 1
	SL.Global.LinkPlayerScores = {}
	SL.Global.LinkPlayerResults = {}
	for tag in ivalues(SL.Global.LinkPlayerList) do
		SL.Global.LinkPlayerScores[tag] = 0
	end
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local RoundStartHandler = function(data)
	local songlist = SL.Global.LinkSelectedSongs
	local active_song = songlist[SL.Global.LinkRoundNumber]
	GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')
	GAMESTATE:SetCurrentSong(active_song)
	local steps = active_song:GetOneSteps(0, "Difficulty_Challenge")
	GAMESTATE:SetCurrentSteps(PLAYER_1, steps)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	for tag in ivalues(SL.Global.LinkPlayerList) do
		SL.Global.LinkPlayerReady[tag] = false
	end
end

local RoundEndHandler = function(data)
	for tag in ivalues(SL.Global.LinkPlayerList) do
		SL.Global.LinkPlayerScores[tag] = data[tag]["score"]
		SL.Global.LinkPlayerResults[tag] = data[tag]["result"]
	end
	SL.Global.LinkRoundNumber = SL.Global.LinkRoundNumber + 1
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local GameEndHandler = function(data)
	SL.Global.LinkGameOver = true
	SM("Game end message sent")
	CloseWS(data["exit"])
end

local MessageHandler = function(message)
	local data = JsonDecode(message["data"])
	-- SCREENMAN:SystemMessage(message["data"])
	if data["type"] == "join" then
		JoinHandler(data)
	elseif data["type"] == "player_update" then
		PlayerUpdateHandler(data)
	elseif data["type"] == "player_ready" then
		PlayerReadyHandler(data)
	elseif data["type"] == "draft_start" then
		DraftStartHandler(data)
	elseif data["type"] == "round_start" then
		RoundStartHandler(data)
	elseif data["type"] == "game_start" then
		GameStartHandler(data)
	elseif data["type"] == "round_end" then
		RoundEndHandler(data)
	elseif data["type"] == "game_end" then
		GameEndHandler(data)
	elseif data["type"] == "error" then
		ErrorHandler(data)
	end
end

LoadWS = function()
	if SL.Global.LinkWS then
		local event = {
			type="WebSocketMessageType_Close",
		}
		SL.Global.LinkWS:Send(JsonEncode(event))
	end
	SL.Global.LinkWS = NETWORK:WebSocket{
		url="wss://link-server.fly.dev",
		headers={                                       -- default: {}
			["Accept-Language"]="en-US",
			["Cookie"]="sessionId=42",
		},
		handshakeTimeout=2,
		pingInterval=2,
		automaticReconnect=false,
		onMessage=function(message)
			local msgType = ToEnumShortString(message.type)
			if msgType == "Open" then
				local event = {
					type="WebSocketMessageType_Open"
				}
				SL.Global.LinkWS:Send(JsonEncode(event))
				local event = {
					type="WebSocketMessageType_Message",
					data={
							type="join",
						name=PROFILEMAN:GetPlayerName(PLAYER_1)
					}
				}
				SL.Global.LinkWS:Send(JsonEncode(event))
			elseif msgType == "Message" then
				MessageHandler(message)
			elseif msgType == "Close" then
				SM("Close message sent")
				CloseWS(1)
			end
		end,
	}
	SL.Global.LinkConnected = true
end

CloseWS = function(exit_code)
	if SL.Global.LinkWS then
		local event = {
			type="WebSocketMessageType_Close",
		}
		SL.Global.LinkWS:Send(JsonEncode(event))
	end
	SL.Global.LinkConnected = false
	SL.Global.LinkGameOver = nil
	SL.Global.LinkWS = nil
	SL.Global.LinkPlayerTag = nil
	SL.Global.LinkPlayerList = nil
	SL.Global.LinkMasterSongList = nil
	SL.Global.LinkDraftSongList = nil
	if SL.Global.GameMode == "Link" and exit_code ~= 0 then
	-- back to title screen
		local top_screen = SCREENMAN:GetTopScreen()
			top_screen:SetNextScreenName(Branch.TitleMenu()):StartTransitioningScreen("SM_GoToNextScreen")
	end
end



LinkSendMessage = function(event, retries)
	if retries == 0 then
		return false
	end

	local msg_sent = SL.Global.LinkWS:Send(JsonEncode(event))

	if not msg_sent then
		local good = LinkSendMessage(event, retries - 1)
		return good
	else
		return true
	end
end

