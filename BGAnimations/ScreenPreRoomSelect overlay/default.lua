local t = Def.ActorFrame {
	OnCommand=function(self)
		SL.Global.LinkSpeedmodStatus = {}
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			local pn = ToEnumShortString(player)
			SL.Global.LinkCmodStatus = (SL[pn].ActiveModifiers.SpeedModType == "C")
			ApplyMods(player)
		end
		SL.Global.LinkMatchPlayerList = {}
		SL.Global.LinkTournamentPlayerList = {}
		SL.Global.LinkMatchPlayerNames = {}
		SL.Global.LinkTournamentPlayerNames = {}
		SL.Global.LinkPlayerReady = {}

		SL.Global.LinkRoomList = {}
		SL.Global.LinkRoomTournament = {}
		SL.Global.LinkTimeLeft = {}
		SL.Global.LinkRoomNames = {}
		SL.Global.LinkRoomCounts = {}
		SL.Global.LinkRoomGrades = {}
		SL.Global.LinkRoomLocked = {}
		LoadWS()
	end
}
return t