local args = ...
local song = args[1]
local index = args[2]
local max_chars = 28

local path = nil
local type = nil
if song:HasJacket() then
	path = song:GetJacketPath()
	type = "Jacket"
elseif song:HasBackground() then
	path = song:GetBackgroundPath()
	type = "Background"
elseif song:HasBanner() then
	path = song:GetBannerPath()
	type = "Banner"
else
	path = THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/no-jacket.png")
end


local af = Def.ActorFrame{
	Song=song,
	InitCommand=function(self)
		self:aux(0):x(-400+(100*index))
		if index % 2 == 0 then
			self:y(100)
		else
			self:y(-60)
		end
	end,
	GainFocusCommand=function(self)
		self:finishtweening():linear(0.125):zoom(1)
		GAMESTATE:SetCurrentSong(song)
		local steps = song:GetOneSteps(0, "Difficulty_Challenge")
		GAMESTATE:SetCurrentSteps(PLAYER_1, steps)
		GAMESTATE:SetCurrentSteps(PLAYER_2, steps)
	end,
	LoseFocusCommand=function(self)
		self:finishtweening():linear(0.125):zoom(0.8):effectmagnitude(0,0,0)
	end,
	EnableCommand=function(self)
		if self:getaux() == 0 then
			self:diffusealpha(1)
		elseif self:getaux() == 1 then
			self:diffuse(0.5, 0.25, 0.25, 0.6)
		elseif self:getaux() == 2 then
			self:diffuse(0.25, 0.25, 0.5, 0.6)
		else
			self:diffuse(0, 0, 0, 0.4)
		end
	end,
	ChosenCommand=function(self)
		-- if this choice was chosen, fluidly zoom in a tiny amount then zoom to 0
		-- similar to animation from SelectProfile
		self:finishtweening():bouncebegin(0.415):zoom(0)
	end,
	NotChosenCommand=function(self)
		-- if this choice wasn't chosen, fade out
		self:finishtweening():sleep(0.1):smooth(0.2):diffusealpha(0)
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Text=song:GetDisplayMainTitle(),
	InitCommand=function(self)
		self:shadowlength(1):y(40):zoom(0.8)
	end
}  

af[#af+1] = LoadActor(path)..{
	InitCommand=function(self)
		self:y(-40):setsize(120, 120):zoom(1)
	end
}

return af