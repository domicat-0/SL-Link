local args = ...
local song = args[1]
local pos_x = args[2]
local pos_y = args[3]
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
 
local fn = song:GetOneSteps(0, "Difficulty_Challenge"):GetFilename()
local steps_hash = BinaryToHex(CRYPTMAN:MD5File(fn))

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:x(pos_x):y(pos_y)
		self:diffuse(0.5, 0.5, 0.5, 0.7)
	end
}

af[#af+1] = LoadActor(path)..{
	InitCommand=function(self)
		self:setsize(120, 120):zoom(1)
	end
}
return af