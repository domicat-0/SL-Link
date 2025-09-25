local current_index = 2
local pick_stage = 1

local songlist = SL.Global.LinkDraftSongList
local selected_songs = {}
local revisit = false

local prev_songs = {}


-- get previously played songs

for i, stage in ipairs(SL.Global.Stages.Stats) do
	prev_songs[#prev_songs+1] = (stage.song)
end

-- choose player to pick next

SL.Global.LinkActive = false

local pick_stage = 1
local pick_type = {"Pick", "Ban"}

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
end

-- input callbacks
if #songlist == 7 then
	pick_stage = 1
else
	pick_stage = 3
end

local Select = function(type)
	if type == "Pick" then
		for i, child in ipairs( af:GetChild("") ) do
			if i == current_index then
				if child:getaux() ~= 0 then
					return false
				end
				child:finishtweening()
				child:aux(2)
				child:queuecommand("Enable")
				af:GetChild("TopText"):aux(2)
			end
		end	
	elseif type == "Ban" then
		for i, child in ipairs( af:GetChild("") ) do
			if i == current_index then
				if child:getaux() ~= 0 then
					return false
				end
				child:finishtweening()
				child:aux(1)
				child:queuecommand("Enable")
				af:GetChild("TopText"):aux(3)
			end
		end	
	end
	if pick_stage == #pick_type then
		for i, child in ipairs(af:GetChild("")) do
			if child:getaux() == 0 then
				child:aux(3)
				child:playcommand("Enable")
			end
			child:queuecommand("LoseFocus")
		end
	end
	af:GetChild("TopText"):playcommand("Refresh")
	return true
end

 SL.Global.LinkInputCallback = function(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	-- normal input handling
	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			if pick_stage > #pick_type then
				return
			end
			local prev_index = current_index
			GetNextEnabledChoice(event.GameButton=="MenuRight" and 1 or -1)

			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
				else
					child:queuecommand("LoseFocus")
				end
			end
			if prev_index ~= current_index then 
				af:GetChild("Change"):play() 
			end

		elseif event.GameButton == "Start" then
			if pick_stage <= #pick_type then
				local good = Select(pick_type[pick_stage])
				if good == false then
					return
				end
				pick_stage = pick_stage + 1
				af:GetChild("Start"):play()
			else
				if pick_stage > #pick_type + 1 then
					return
				end
				af:queuecommand("Finish", {PlayerNumber=event.PlayerNumber})
				pick_stage = pick_stage + 1
			end
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
		af:GetChild("TopText"):aux(1)
		af:GetChild("TopText"):playcommand("Refresh")
	end,
	OnCommand=function(self)

	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
	end,
	FinishCommand=function(self, params)
		for i=2, #songlist+1 do
			af:GetChild("")[i]:playcommand("Chosen")
		end
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			ApplyMods(player)
		end
		local event = {
			type="WebSocketMessageType_Message",
			data={
				type="ready"
			}
		}
		LinkSendMessage(event, 10)
		af:GetChild("TopText"):aux(0)
		af:GetChild("TopText"):playcommand("Refresh")
	end,
}

local a = LoadActor("./playerModifiers.lua")

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

for i,song in ipairs(songlist) do
	t[#t+1] = LoadActor("./choice.lua", {song, i})
end

t[#t+1] = LoadFont("Common Normal")..{
	Name="TopText",
	Text="",
	InitCommand=function(self)
		self:shadowlength(1):y(-170):aux(0)
	end,
	RefreshCommand=function(self)
		if self:getaux() == 0 then
			self:settext("Waiting...")
		elseif self:getaux() == 1 then
			self:settext("Favor song")
		elseif self:getaux() == 2 then
			self:settext("Disfavor song")
		elseif self:getaux() == 3 then
			self:settext("Confirm picks")
		else
			self:settext("Invalid aux value")
		end
	end
} 

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

return t