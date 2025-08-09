local states = {"GradeField", "PasswordField", "ConfirmField"}
local n_grades = 7
local state_index = 1
local password_mode = false
local accepting_input = true
local password = ""

SL.Global.LinkInputCallback = function(event)
	if not event or not event.PlayerNumber or not accepting_input then
		return false
	end
	if event.type ~= "InputEventType_FirstPress" then return false end
	-- Up and Down actions
	if password_mode then
		if event.GameButton == "MenuLeft" then
			password = password .. 0
		elseif event.GameButton == "MenuDown" then
			password = password .. 1
		elseif event.GameButton == "MenuUp" then
			password = password .. 2
		elseif event.GameButton == "MenuRight" then
			password = password .. 3
		elseif event.GameButton == "Start" then
			af:GetChild("GradeTitle"):visible(true)
			af:GetChild("GradeField"):visible(true)
			af:GetChild("PasswordField"):visible(true)
			af:GetChild("ConfirmField"):visible(true)
			password_mode = false
		end
	else
		if event.GameButton == "MenuUp" then
			state_index = state_index + #states - 1
			state_index = (state_index - 1) % #states + 1
			af:playcommand("Refresh")
		elseif event.GameButton == "MenuDown" then
			state_index = state_index + 1
			state_index = (state_index - 1) % #states + 1
			af:playcommand("Refresh")
		elseif event.GameButton == "MenuLeft" then
			if states[state_index] == "GradeField" then
				local current_grade = af:GetChild("GradeField"):getaux()
				current_grade = current_grade + n_grades - 1
				current_grade = (current_grade - 1) % n_grades + 1
				af:GetChild("GradeField"):aux(current_grade)
				af:playcommand("Refresh")
			end
		elseif event.GameButton == "MenuRight" then
			if states[state_index] == "GradeField" then
				local current_grade = af:GetChild("GradeField"):getaux()
				current_grade = current_grade + 1
				current_grade = (current_grade - 1) % n_grades + 1
				af:GetChild("GradeField"):aux(current_grade)
				af:playcommand("Refresh")
			end
		elseif event.GameButton == "Start" then
			if states[state_index] == "PasswordField" then
				af:GetChild("GradeTitle"):visible(false)
				af:GetChild("GradeField"):visible(false)
				af:GetChild("PasswordField"):visible(false)
				af:GetChild("ConfirmField"):visible(false)
				password_mode = true
				password = ""
			elseif states[state_index] == "ConfirmField" then
				data={
					type="WebSocketMessageType_Message",
					data={
						type="create_room",
						player_name=PROFILEMAN:GetPlayerName(PLAYER_1),
						name="Room - " .. PROFILEMAN:GetPlayerName(PLAYER_1),
						grade=af:GetChild("GradeField"):getaux(),
						locked=(true and pwd ~= "" or false),
						pwd=password
					}
				}
				accepting_input = false
				res = LinkSendMessage(data, 10)
				if not res then accepting_input = true end
			end
		end
	end
end

local t = Def.ActorFrame {
	InitCommand=function(self)
		af = self
		self:xy(_screen.cx, _screen.cy)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(SL.Global.LinkInputCallback)
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		for child in ivalues(af:GetChild("")) do
			child:playcommand("Refresh")
		end
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="GradeTitle",
	Text="Grade",
	InitCommand=function(self)
		self:horizalign(1):vertalign(1):y(-120)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="GradeField",
	Text="",
	InitCommand=function(self)
		self:horizalign(1):vertalign(1):y(-110)
	end,
	RefreshCommand=function(self)
		if states[state_index] == "GradeField" then
			self:diffuse(1, 1, 1, 1):zoom(1)
		else
			self:diffuse(0.8, 0.8, 0.8, 1):zoom(0.75)
		end
		self:settext(self:getaux())
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="PasswordField",
	Text="Set password...",
	InitCommand=function(self)
		self:horizalign(1):vertalign(1):y(-80)
	end,
	RefreshCommand=function(self)
		if states[state_index] == "PasswordField" then
			self:diffuse(1, 1, 1, 1):zoom(1)
		else
			self:diffuse(0.8, 0.8, 0.8, 1):zoom(0.75)
		end
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="ConfirmField",
	Text="Confirm",
	InitCommand=function(self)
		self:horizalign(1):vertalign(1):y(-50)
	end,
	RefreshCommand=function(self)
		if states[state_index] == "ConfirmField" then
			self:diffuse(1, 1, 1, 1):zoom(1)
		else
			self:diffuse(0.8, 0.8, 0.8, 1):zoom(0.75)
		end
	end
}


return t