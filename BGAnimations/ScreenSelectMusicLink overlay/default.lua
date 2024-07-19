-- song indices start at 2, since bg must be drawn first

local current_index = 2
local pick_stage = 1

-- load songs to be played

local songlist = LoadActor("./setup.lua")
local revisit = false

if SL.Global.FirstVisit then
	SL.Global.SongList = songlist
	SL.Global.SelectedSongs = {}
else
	songlist = SL.Global.SongList
	pick_stage = 99
	revisit = true
end

local prev_songs = {}


-- get previously played songs

for i, stage in ipairs(SL.Global.Stages.Stats) do
	prev_songs[#prev_songs+1] = (stage.song)
end

-- choose player to pick next

SL.Global.LinkActive = false

local pick_order = {1, 2, 2, 1, 1, 2, 2}
local pick_type = {"Ban", "Ban", "Pick", "Pick", "Ban", "Ban", "Pick"}

local GetNextEnabledChoice = function(dir)
	local start = dir > 0 and current_index+1 or #songlist+current_index-1
	local stop = dir > 0 and #songlist+current_index-1 or current_index+1
	for i=start, stop, dir do
		local index = ((i-2) % #songlist) + 2
		if af:GetChild("")[index]:getaux()==0 then
			current_index = index
			return
		end
	end
end

local EnableChoices = function()
	for i, child in ipairs(af:GetChild("")) do
		child:aux(0)
	end
	if revisit then
		for i, child in ipairs(af:GetChild("")) do
			if songlist[i-1] ~= SL.Global.SelectedSongs[#SL.Global.Stages.Stats+1] then
				child:aux(3)
			end
		end
	end
end

-- input callbacks
if not pick_stage then
	local pick_stage = 1
end

local Select = function(song, type)
	if type == "Pick" then
		for i, child in ipairs( af:GetChild("") ) do
			if child then
				if child:getaux() ~= 0 then
					return false
				end
				child:aux(pick_order[pick_stage])
				child:playcommand("Enable")
				SL.Global.SelectedSongs[#(SL.Global.SelectedSongs)+1] = songlist[current_index-1]
			end
		end	
	else
		for i, child in ipairs( af:GetChild("") ) do
			if i == current_index then
				if child:getaux() ~= 0 then
					return false
				end
				child:aux(3)
				child:playcommand("Enable")
			end
		end	
	end

local function input(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	if SL.Global.LinkActive = false then
		return false
	end

	-- normal input handling
	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			local prev_index = current_index
			GetNextEnabledChoice(event.GameButton=="MenuRight" and 1 or -1)

			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
				else
					child:queuecommand("LoseFocus")
				end
			end
			if prev_index ~= current_index then af:GetChild("Change"):play() end

		elseif event.GameButton == "Start" then
			if pick_stage <= #pick_order then
				
				pick_stage = pick_stage + 1
				af:GetChild("Start"):play()
			else
				for player in ivalues(GAMESTATE:GetHumanPlayers()) do
					ApplyMods(player)
				end
				af:playcommand("Finish", {PlayerNumber=event.PlayerNumber})
			end
		end
		if pick_order[pick_stage] == 1 then
			selector = "PlayerNumber_P1"
		elseif pick_order[pick_stage] == 2 then
			selector = "PlayerNumber_P2"
		else
			selector = nil
		end
	return false
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
		af = self
		self:queuecommand("Capture")
		EnableChoices() 
		self:playcommand("Enable")

		for i, child in ipairs( self:GetChild("") ) do
			if i == current_index then
				child:queuecommand("GainFocus")
			end
		end
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	FinishCommand=function(self, params)
		for i=2, #songlist+1 do
			if i ~= current_index then
				af:GetChild("")[i]:playcommand("NotChosen")
			else
				af:GetChild("")[i]:playcommand("Chosen")
			end
		end

		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

for i,song in ipairs(songlist) do

	t[#t+1] = LoadActor("./choice.lua", {song, i})
end

if revisit then
	t[#t+1] = LoadActor("./scoreboard.lua")
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

return t