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
	SCREENMAN:SystemMessage("Error: " .. data["message"])
end

local JoinHandler = function(data)
	SL.Global.LinkPlayerTag = data["tag"]
	SL.Global.LinkMatch= true
	SL.Global.LinkCreateRoom = false
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local JoinTournamentHandler = function(data)
	SL.Global.LinkPlayerTag = data["tag"]
	SL.Global.LinkTournament = true
	SL.Global.LinkCreateRoom = false
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local JoinFailedHandler = function(data)
	SM("Room join failed...")
end

local RoomInfoHandler = function(data)
	SL.Global.LinkRoomList = data["tags"]
	SL.Global.LinkRoomTournament = data["is_tournament"]
	SL.Global.LinkTimeLeft = data["time_left"]
	SM(SL.Global.LinkRoomTournament)
	SL.Global.LinkRoomNames = data["names"]
	SL.Global.LinkRoomCounts = data["player_counts"]
	SL.Global.LinkRoomGrades = data["grades"]
	SL.Global.LinkRoomLocked = data["locked"]
	if SCREENMAN:GetTopScreen():GetName() == "ScreenPreRoomSelect" then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	elseif SCREENMAN:GetTopScreen():GetName() == "ScreenSelectLinkMode" then
		SCREENMAN:GetTopScreen():playcommand("Refresh")
	end
end


local PlayerUpdateHandler = function(data)
	SL.Global.LinkMatchPlayerList = data["players"]
	SL.Global.LinkMatchPlayerNames = data["names"]
	if SCREENMAN:GetTopScreen() then
		SCREENMAN:GetTopScreen():playcommand("Refresh")
	end
end

local TournamentPlayerUpdateHandler = function(data)
	SL.Global.LinkTournamentPlayerList = data["players"]
	SL.Global.LinkTournamentPlayerNames = data["names"]
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

local TournamentStartHandler = function(data)
	SL.Global.LinkTournamentPlayerList = data["players"]

	SL.Global.LinkTournamentRoundNumber = 1
	SL.Global.LinkPlayerTournamentScores = {}
	SL.Global.LinkPlayerTournamentPositions = {}
	for tag in ivalues(SL.Global.LinkTournamentPlayerList) do
		SL.Global.LinkPlayerTournamentScores[tag] = 0
	end
end

local TournamentRoundStartHandler = function(data)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local DraftStartHandler = function(data)
	SL.Global.LinkMatchPlayerList = data["players"]
	local song_hashes = data["songs"]
	SL.Global.LinkDraftSongList = {}
	for tag in ivalues(SL.Global.LinkMatchPlayerList) do
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
	for tag in ivalues(SL.Global.LinkMatchPlayerList) do
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
	local ScreenName = SCREENMAN:GetTopScreen():GetName()
	SL.Global.LinkRoundStart = true
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	for tag in ivalues(SL.Global.LinkMatchPlayerList) do
		SL.Global.LinkPlayerReady[tag] = false
	end
end

local RoundEndHandler = function(data)
	for tag in ivalues(SL.Global.LinkMatchPlayerList) do
		SL.Global.LinkPlayerScores[tag] = data[tag]["score"]
		SL.Global.LinkPlayerResults[tag] = data[tag]["result"]
	end
	SL.Global.LinkRoundNumber = SL.Global.LinkRoundNumber + 1
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local TournamentRoundEndHandler = function(data)
	for tag in ivalues(SL.Global.LinkTournamentPlayerList) do
		SL.Global.LinkPlayerTournamentScores[tag] = data[tag]["points"]
		SL.Global.LinkPlayerTournamentPositions[tag] = data[tag]["position"]
	end
	SL.Global.LinkTournamentRoundNumber = SL.Global.LinkTournamentRoundNumber + 1
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local GameEndHandler = function(data)
	if SL.Global.LinkTournament then
		SL.Global.LinkRoundExit = true
	else
		SL.Global.LinkExit = true
	end
end

local TournamentEndHandler = function(data)
	SL.Global.LinkExit = true
end

local MessageHandler = function(message)
	local data = JsonDecode(message["data"])
	if data["type"] == "join_room" then
		JoinHandler(data)
	elseif data["type"] == "join_tournament" then
		JoinTournamentHandler(data)
	elseif data["type"] == "room_info" then
		RoomInfoHandler(data)
	elseif data["type"] == "match_info" then
		PlayerUpdateHandler(data)
	elseif data["type"] == "tournament_info" then
		TournamentPlayerUpdateHandler(data)
	elseif data["type"] == "player_ready" then
		PlayerReadyHandler(data)
	elseif data["type"] == "tournament_start" then
		TournamentStartHandler(data)
	elseif data["type"] == "tournament_round_start" then
		TournamentRoundStartHandler(data)
	elseif data["type"] == "draft_start" then
		DraftStartHandler(data)
	elseif data["type"] == "round_start" then
		RoundStartHandler(data)
	elseif data["type"] == "tournament_round_end" then
		TournamentRoundEndHandler(data)
	elseif data["type"] == "game_start" then
		GameStartHandler(data)
	elseif data["type"] == "round_end" then
		RoundEndHandler(data)
	elseif data["type"] == "match_end" then
		GameEndHandler(data)
	elseif data["type"] == "tournament_end" then
		TournamentEndHandler(data)
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
		url="ws://192.168.4.21:8080",
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
				SL.Global.LinkMatch = false
				SL.Global.LinkTournament = false
				SL.Global.LinkExit = false
				local event = {
					type="WebSocketMessageType_Open"
				}
				SL.Global.LinkWS:Send(JsonEncode(event))
				local event = {
					type="WebSocketMessageType_Message",
					data={
						type="request_rooms",
						name=PROFILEMAN:GetPlayerName(PLAYER_1)
					}
				}
				SL.Global.LinkWS:Send(JsonEncode(event))
			elseif msgType == "Message" then
				MessageHandler(message)
			elseif msgType == "Close" then
				SM("Close message sent")
				if SL.Global.GameMode == "Link" then
					if not (SL.Global.LinkMatch or SL.Global.LinkTournament) then
						local top_screen = SCREENMAN:GetTopScreen()
						top_screen:SetNextScreenName(Branch.TitleMenu()):StartTransitioningScreen("SM_GoToNextScreen")
					end
					SL.Global.LinkExit = true
				end
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
	SL.Global.LinkWS = nil
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

