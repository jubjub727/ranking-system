
util.AddNetworkString("scoreboardrank")


hook.Add( "Think", "scoreboardthink", function()

	local players = {}

	for k,v in pairs(player.GetAll()) do
		local data = {}

		data[0] = v:SteamID64()
		data[1] = RANK:GetRankName(v:SteamID64())
		
        players[k] = data
	end

	net.Start("scoreboardrank")
	net.WriteTable(players)
	net.Broadcast()
end )