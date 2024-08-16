local t = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

for tag in ivalues(SL.Global.LinkPlayerList) do
	local score = data[tag]["score"]
	LoadActor("./resultbar.lua", {tag, score})
end

return t