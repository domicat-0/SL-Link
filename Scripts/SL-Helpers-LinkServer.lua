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

-- NOTE: Currently O(N^2) due to not creating hash table first
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
	PlayerListUpdate()
end

local DraftStartHandler = function(data)
	SL.Global.LinkPlayerList = data["players"]
	local song_hashes = data["songs"]
	SL.Global.LinkDraftSongList = {}
	for i, hash in ipairs(song_hashes) do
		SL.Global.LinkDraftSongList[i] = GetSongFromHash(hash)
	end
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")

	
end


local GameStartHandler = function(data)
	SL.Global.LinkSelectedSongs = data["songs"]
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local RoundEndHandler = function(data)
end

local MessageHandler = function(message)
	local data = JsonDecode(message["data"])
	SCREENMAN:SystemMessage(data["type"])
	if data["type"] == "join" then
		JoinHandler(data)
	elseif data["type"] == "update" then
		PlayerUpdateHandler(data)
	elseif data["type"] == "draft_start" then
		DraftStartHandler(data)
	elseif data["type"] == "game_start" then
		GameStartHandler(data)
	elseif data["type"] == "round_end" then
		RoundEndHandler(data)
	elseif data["type"] == "error" then
		ErrorHandler(data)
	end
end

LoadWS = function()
	SL.Global.LinkWS = NETWORK:WebSocket{
		url="ws://192.168.4.35:8001",
		headers={                                       -- default: {}
			["Accept-Language"]="en-US",
			["Cookie"]="sessionId=42",
		},
		handshakeTimeout=5,
		pingInterval=60,
		automaticReconnect=true,
		onMessage=function(message)
			-- SCREENMAN:SystemMessage(message.type)
			local msgType = ToEnumShortString(message.type)
			if msgType == "Open" then
				local event = {
					type="WebSocketMessageType_Message",
					data={
						type="join"
					}
				}
				SL.Global.LinkWS:Send(JsonEncode(event))
				SL.Global.LinkWS:Send(JsonEncode(event))
			elseif msgType == "Message" then
				MessageHandler(message)
			elseif msgType == "Close" then
				local topscreen = SCREENMAN:GetTopScreen()
				topscreen:RemoveInputCallback(input)
				SL.Global.LinkWS = nil
				SL.Global.LinkPlayerTag = nil
				SL.Global.LinkPlayerList = nil
				SL.Global.LinkMasterSongList = nil
				Sl.Global.LinkDraftSongList = nil
				topscreen:Cancel()
			end
		end,
	}
end



