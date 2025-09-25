local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SL.Global.LinkExit = true
		CloseWS(1)
		top_screen = SCREENMAN:GetTopScreen()
		top_screen:SetNextScreenName(Branch.TitleMenu()):StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

return t  