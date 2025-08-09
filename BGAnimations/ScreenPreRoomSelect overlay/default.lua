local t = Def.ActorFrame {
	OnCommand=function(self)
		SL.Global.LinkPlayerList = {}
		SL.Global.LinkPlayerNames = {}
		SL.Global.LinkPlayerReady = {}
		LoadWS()
	end
}
return t