-- song indices start at 2, since bg must be drawn first

local current_index = 2

-- load songs to be played
-- SL.Global.SongList contains the list of songs drawn

if SL.Global.SongList == nil then
	local songlist = LoadActor("./setup.lua")
	SL.Global.SongList = songlist
end
local songlist = SL.Global.SongList

local prev_songs = {}
local scores_p1 = {}
local scores_p2 = {}


-- choose player to pick next

local selector
if #prev_songs % 2 == 0 then
	selector = "PlayerNumber_P1"
else
	selector = "PlayerNumber_P2"
end

-- get previously played songs and scores

for i, stage in ipairs(SL.Global.Stages.Stats) do
	prev_songs[#prev_songs+1] = (stage.song)
	scores_p1[#scores_p1+1] = SL["P1"].Stages.Stats[i].score
	scores_p2[#scores_p2+1] = SL["P2"].Stages.Stats[i].score
end


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
		local song = songlist[i-1]
		for j, prev in ipairs(prev_songs) do
			if song == prev then
				if scores_p1[j] > scores_p2[j] then
					child:aux(1)
				else
					child:aux(2)
				end
			end
		end
	end
end

-- input callbacks

local function input(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	SCREENMAN:SystemMessage(event.PlayerNumber)
	if event.PlayerNumber ~= selector then
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
			StyleSelected = true
			af:GetChild("Start"):play()
			for player in ivalues(GAMESTATE:GetHumanPlayers()) do
				ApplyMods(player)

			end
			af:playcommand("Finish", {PlayerNumber=event.PlayerNumber})

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			SL.Global.SongList = nil
			topscreen:Cancel()
		end
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
		for i=1, #songlist do
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
t[#t+1] = LoadActor("./scoreboard.lua")

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

return t