local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SL.Global.LinkGameOver = true
		SM("Back button tripped")
		CloseWS(1)
		top_screen:SetNextScreenName(Branch.TitleMenu()):StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

return t  