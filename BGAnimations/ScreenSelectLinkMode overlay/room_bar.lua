local args = ...
local tag = nil
local pos_x = args[3]
local pos_y = args[4]

local width = 240
local height = 40
local unlocked_color = color("FF4D4D")
local locked_color = color("4D4DFF")

local af = Def.ActorFrame {
	Name="RoomBar",
	InitCommand = function(self)
		self:x(pos_x):y(pos_y):aux(0)
	end,
	RefreshCommand = function(self)
		local index, selected
		if self:getaux() > 0 then
			index = self:getaux()
			selected = true
		else
			index = -self:getaux()
			selected = false
		end
		if index <= #SL.Global.LinkRoomList then
			tag = SL.Global.LinkRoomList[index]
		elseif index == #SL.Global.LinkRoomList + 1 then
			tag = "create"
		else
			tag = nil
		end
		for child in ivalues(self:GetChild("")) do
			child:GetCommand("refresh")
		end

		if selected then
			self:x(pos_x+20)
			self:zoom(1.1)
			SM(index)
		else
			self:x(pos_x)
		end
	end

}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(width, height)
		self:x(20)
		self:diffuse(0.15, 0.15, 0.15, 1)
	end
}

af[#af+1] = Def.Quad {
	InitCommand = function(self)
		self:horizalign(0)
		self:zoomto(40, height)
		self:x(-140)
	end,
	RefreshCommand = function(self)
		if tag == nil then
			self:diffuse(0, 0, 0, 0)
		elseif tag == "create" then
			self:diffuse(0.15, 0.5, 0.15, 1)
		elseif SL.Global.LinkRoomLocked[tag] then
			self:diffuse(0.15, 0.15, 0.15, 1)
		else
			self:diffuse(0.15, 0.15, 0.5, 1)
		end
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text="",
	InitCommand = function(self)
		self:horizalign(0)
		self:zoom(1.1)
		self:x(-90)
	end,
	RefreshCommand = function(self)
		if tag == nil then
			self:settext("")
		elseif tag == "create" then
			self:settext("Create room")
		else
			self:settext(SL.Global.LinkRoomNames[tag])
		end
	end
}

af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text="",
	InitCommand = function(self)
		self:horizalign(2)
		self:zoom(1.5)
		self:x(130)
	end,
	RefreshCommand = function(self)
		if tag == nil then
			self:settext("")
		elseif tag == "create" then
			self:settext("")
		else
			self:settext("T" .. SL.Global.LinkRoomGrades[tag] .. "-T" .. SL.Global.LinkRoomGrades[tag]+3)
		end
	end
}
af[#af+1] = LoadFont("Common Normal")..{
	Name="",
	Text="",
	InitCommand = function(self)
		self:horizalign(1)
		self:zoom(1.5)
		self:x(-120)
	end,
	RefreshCommand = function(self)
		if tag == nil then
			self:settext("")
		elseif tag == "create" then
			self:settext("")
		else
			self:settext(SL.Global.LinkRoomCounts[tag] .. "/6")
		end
	end
}

return af