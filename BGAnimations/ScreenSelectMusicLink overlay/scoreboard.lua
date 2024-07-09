local prev_songs = {}
local scores_p1 = {}
local scores_p2 = {}

for i, stage in ipairs(SL.Global.Stages.Stats) do
	prev_songs[#prev_songs+1] = (stage.song)
	scores_p1[#scores_p1+1] = SL["P1"].Stages.Stats[i].score
	scores_p2[#scores_p2+1] = SL["P2"].Stages.Stats[i].score
end

local function GetScoreP1() 
	local sp1 = 0
	for i, stage in ipairs(SL.Global.Stages.Stats) do
		if scores_p1[i] > scores_p2[i] then
			sp1 = sp1 + 1
		end
	end
	return sp1
end

local function GetScoreP2() 
	local sp2 = 0
	for i, stage in ipairs(SL.Global.Stages.Stats) do
		if scores_p2[i] > scores_p1[i] then
			sp2 = sp2 + 1
		end
	end
	return sp2
end

local af = Def.ActorFrame {
	InitCommand=function(self)
		self:y(-200)
	end
}

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Text=GetScoreP1(),
	InitCommand=function(self)
		self:shadowlength(1):x(-40):zoom(1):diffuse(1, 0.3, 0.3, 1)
	end
}
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Text=GetScoreP2(),
	InitCommand=function(self)
		self:shadowlength(1):x(40):zoom(1):diffuse(0.3, 0.3, 1, 1)
	end
}

SCREENMAN:SystemMessage("F")
return af