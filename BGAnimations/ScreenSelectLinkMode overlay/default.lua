local current_page = 1
local current_index = 1
local tag = nil
local page_length = 6 -- fixed
local accepting_input = true
local password_mode = false
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
		elseif event.GameButton == "MenuStart" then

			data={
				type="WebSocketMessageType_Message",
				data={
					type="join",
					name=PROFILEMAN:GetPlayerName(PLAYER_1)
				}
			}
			accepting_input = false
			res = LinkSendMessage(data, 10)
			if not res then 
				accepting_input = true 
				for i, child in ipairs(af:GetChild("RoomBar")) do
					child:visible(true)
				end
			end
		end
	else
		if event.GameButton == "MenuUp" then
			if page_length * (current_page - 1) + current_index > 1 then
				current_index = current_index - 1
				if current_index <= 0 then
					current_page = current_page - 1
					current_index = current_index + page_length
				end
			end
			af:playcommand("Refresh")
		elseif event.GameButton == "MenuDown" then
			if page_length * (current_page - 1) + current_index < #SL.Global.LinkRoomList + 1 then
				current_index = current_index + 1
				if current_index > page_length then
					current_page = current_page + 1
					current_index = current_index - page_length
				end
			end
			af:playcommand("Refresh")
		elseif event.GameButton == "Start" then
			local id = page_length * (current_page - 1) + current_index
			if id <= #SL.Global.LinkRoomList then
				tag = SL.Global.LinkRoomList[id]
				if SL.Global.LinkRoomLocked[tag] then
					for i, child in ipairs(af:GetChild("RoomBar")) do
						child:visible(false)
					end
					password_mode = true
					password = ""
				else
					data={
						type="WebSocketMessageType_Message",
						data={
							type="join",
							name=PROFILEMAN:GetPlayerName(PLAYER_1)
						}
					}
					accepting_input = false
					res = LinkSendMessage(data, 10)
					if not res then accepting_input = true end
				end
			elseif page_length * (current_page - 1) + current_index == #SL.Global.LinkRoomList + 1 then
				SL.Global.LinkCreateRoom = true
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
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
		for i, child in ipairs(self:GetChild("RoomBar")) do
			-- Aux values denote place in SL.Global.LinkRoomList
			-- Positive if selected, negative otherwise
			local idx = (page_length * (current_page - 1) + i)
			local auxval = idx * ((page_length * (current_page - 1) + current_index) == idx and 1 or -1)
			child:aux(auxval)
			child:playcommand("Refresh")
		end
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self) 
		self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) 
	end
}

for idx=1,6 do
	t[#t+1] = LoadActor("./room_bar.lua", {idx, 0, 0, -175 + idx*50})
end

return t