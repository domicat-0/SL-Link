local t = Def.ActorFrame {
	OnCommand=function(self)
		SL.Global.LinkMatchPlayerList = {}
		SL.Global.LinkTournamentPlayerList = {}
		SL.Global.LinkMatchPlayerNames = {}
		SL.Global.LinkTournamentPlayerNames = {}
		SL.Global.LinkPlayerReady = {}
		LoadWS()
	end
}
return t