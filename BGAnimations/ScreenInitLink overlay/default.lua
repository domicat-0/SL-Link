local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
		LoadWS()
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text="Waiting for players...",
	InitCommand=function(self)
		self:shadowlength(1):y(40):zoom(0.8)
	end
}

return t 