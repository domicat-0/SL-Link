local active_song = SL.Global.LinkActiveSong
local songlist = SL.Global.LinkSelectedSongs

t[#t+1] = Def.Quad {
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85):xy(0, 0) end
}

t[#t+1] = LoadActor("./tile.lua", {song, 0, 0})

for i,song in ipairs(songlist) do
	local song_actor = LoadActor("./choice.lua", {song, 100, (250-100*i)})
	song_actor:zoom(0.7)
	if song == active_song then
		song_actor:diffuse(1, 1, 1, 1)
	end
	t[#t+1] = song_actor
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

return t