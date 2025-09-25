local t = Def.ActorFrame {
	OnCommand=function(self)
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			ApplyMods(player)
		end
		SL.Global.LinkMatchPlayerList = {}
		SL.Global.LinkTournamentPlayerList = {}
		SL.Global.LinkMatchPlayerNames = {}
		SL.Global.LinkTournamentPlayerNames = {}
		SL.Global.LinkPlayerReady = {}
		LoadWS()
	end
}
return t