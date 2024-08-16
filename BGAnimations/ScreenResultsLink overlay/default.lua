local t = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

local idx = 1
for tag, score in pairs(SL.Global.LinkPlayerScores) do
	t[#t+1] = LoadActor("./resultbar.lua", {tag, score, -150, -100 + idx*50})
	SCREENMAN:SystemMessage(SL.Global.LinkPlayerTag)
	idx = idx + 1
end

return t