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


local GetVersusGroups = function()
	local path = THEME:GetCurrentThemeDirectory() .. "Other/VersusMode-Groups.txt"
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
		return groups
	else
		return nil
	end
end


-- helper for GetRandomSongs - shuffles songlist to allow for random sample without replacement
local shuffle = function(arr)
  for i = 1, #arr - 1 do
    local j = math.random(i, #arr)
    arr[i], arr[j] = arr[j], arr[i]
  end
end

local GetRandomSongs = function(group, n_songs)
	local songs = SONGMAN:GetSongsInGroup(group)

	if #songs < n_songs then
		return nil
	end
	shuffle(songs)

	local selected = {}
	for i = 1, n_songs do 
		selected[i] = songs[i]
	end
	return selected
end

-----
GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')

local groups = GetVersusGroups()
local songlist = GetRandomSongs(groups[1], 5)
local current_song = songlist[1]
GAMESTATE:SetCurrentSong(current_song)
local steps = current_song:GetOneSteps(0, "Difficulty_Challenge")
GAMESTATE:SetCurrentSteps(PLAYER_1, steps)
GAMESTATE:SetCurrentSteps(PLAYER_2, steps)

LoadActor("./playerModifiers.lua")
return songlist