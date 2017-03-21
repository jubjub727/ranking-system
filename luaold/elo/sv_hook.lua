
--	sv_hook.lua

util.AddNetworkString("scoreboardrank")

hook.Add( "Think", "scoreboardthink", function()
	local players = {}
	for k,v in pairs(player.GetAll()) do
		local data = {}
		data[0] = v:SteamID64()
		data[1] = ranks[ELO.DataProvider:GetRankName(tonumber(ELO.DataProvider:GetRating( v:SteamID64(), 0 )))]
		players[k] = data
	end
	net.Start("scoreboardrank")
	net.WriteTable(players)
	net.Broadcast()
end )

hook.Add ( "PostGamemodeLoaded", "PostGamemodeLoaded.elo", function ()
	
	-- Get the data handler
	local handler = string.format ( "elo/datahandle/%s.lua", ELO.provider or "sql" )
	include ( handler )
	
	-- Sync to SQL Server
	if ELO.SQL_sync then
		
		local file_SQL_Query = ELO.DataProvider:ExportSQL ( exportLog )
		ELO.DataProvider:SyncToServer ( file_SQL_Query, ELO.SQL_host, ELO.SQL_database, ELO.SQL_username, ELO.SQL_password )
		
	end
	
end )

hook.Add ( "PlayerInitialSpawn", "PlayerInitialSpawn.elo", function ( ply )

	ELO.DataProvider:PlayerInit ( ply:SteamID64 (), ply:GetName () )

end )

CAN_GAIN_KILLING_ELO = false

hook.Add ( "DoPlayerDeath", "DoPlayerDeath.elo", function ( victim, killer, dmginfo )
	
	if IsValid ( victim ) and IsValid ( killer ) then
		
		kRole = killer:GetRole ()
		vRole = victim:GetRole ()
		
		if victim:IsGhost () then
			
			elo_total, elo_plys = ELO.DataProvider:Stats ( 1 )
			
			killer_Elo = ELO.DataProvider:GetRating ( killer:SteamID64 (), 1 )
			victim_Elo = ELO.DataProvider:GetRating ( victim:SteamID64 (), 1 )
			
			elo_change, offset = ELO:Calculate ( killer_Elo, victim_Elo, ELO.killValue, elo_total, elo_plys )
			
			ELO.DataProvider:SubRating ( victim:SteamID64 (), 1, elo_change+offset )
			ELO.DataProvider:AddRating ( killer:SteamID64 (), 1, elo_change-offset )
			
		else
			
			elo_total, elo_plys = ELO.DataProvider:Stats ( 0 )
			
			killer_Elo = ELO.DataProvider:GetRating ( killer:SteamID64 (), 0 )
			victim_Elo = ELO.DataProvider:GetRating ( victim:SteamID64 (), 0 )
			
			elo_change, offset = ELO:Calculate ( killer_Elo, victim_Elo, ELO.killValue, elo_total, elo_plys )
			
			if kRole == ROLE_TRAITOR and vRole ~= ROLE_TRAITOR and CAN_GAIN_KILLING_ELO then
				ELO.DataProvider:AddRating ( killer:SteamID64 (), 0, elo_change-offset )
				ELO.DataProvider:SubRating ( victim:SteamID64 (), 0, elo_change+offset )
			elseif kRole ~= ROLE_TRAITOR and vRole == ROLE_TRAITOR and CAN_GAIN_KILLING_ELO then
				ELO.DataProvider:AddRating ( killer:SteamID64 (), 0, elo_change-offset )
				ELO.DataProvider:SubRating ( victim:SteamID64 (), 0, elo_change+offset )
			end
			
		end
		
	end
	
end )

ELO.CURRENT_ACTIVE_TRAITOR = {}
ELO.CURRENT_ACTIVE_INNOCENT = {}

hook.Add ( "TTTBeginRound", "TTTBeginRound.elo", function ()
	
	CAN_GAIN_KILLING_ELO = true
	
	table.Empty ( ELO.CURRENT_ACTIVE_TRAITOR )
	table.Empty ( ELO.CURRENT_ACTIVE_INNOCENT )
	
	for k, v in pairs ( player.GetAll () ) do
	
		if v:IsTerror () and v:Alive () then
		
			if v:GetTraitor() then
				table.insert ( ELO.CURRENT_ACTIVE_TRAITOR, { v, v:SteamID64 (), ELO.DataProvider:GetRating ( v:SteamID64 (), 0 ) } )
			else
				table.insert ( ELO.CURRENT_ACTIVE_INNOCENT, { v, v:SteamID64 (), ELO.DataProvider:GetRating ( v:SteamID64 (), 0 ) } )
			end
		
		end
	
	end
	
end )

hook.Add ( "TTTEndRound", "TTTEndRound.elo", function ( ROUND_WINNER )
	
	CAN_GAIN_KILLING_ELO = false
	if #player.GetAll () < 4 then return end
	
	collective_Traitor = {}
	collective_Innocent = {}
	
	for k, v in pairs ( ELO.CURRENT_ACTIVE_TRAITOR ) do
		table.insert ( collective_Traitor, v[3] )
	end
	
	for k, v in pairs ( ELO.CURRENT_ACTIVE_INNOCENT ) do
		table.insert ( collective_Innocent, v[3] )
	end
	
	elo_total, elo_plys = ELO.DataProvider:Stats ( 0 )
	collective_Elo = ELO:CalculateGroup ( collective_Traitor, collective_Innocent, ELO.roundValue, elo_total, elo_plys )
	
	if ROUND_WINNER == WIN_TRAITOR then
		
		for k, v in pairs ( ELO.CURRENT_ACTIVE_TRAITOR ) do
			ELO.DataProvider:AddRating ( v[2], 0, collective_Elo )
		end
		
		for k, v in pairs ( ELO.CURRENT_ACTIVE_INNOCENT ) do
			ELO.DataProvider:SubRating ( v[2], 0, collective_Elo )
		end
		
	else
		
		for k, v in pairs ( ELO.CURRENT_ACTIVE_TRAITOR ) do
			ELO.DataProvider:SubRating ( v[2], 0, collective_Elo )
		end
		
		for k, v in pairs ( ELO.CURRENT_ACTIVE_INNOCENT ) do
			ELO.DataProvider:AddRating ( v[2], 0, collective_Elo )
		end
		
	end
	
	ELO.CURRENT_ACTIVE_INNOCENT = {}
	ELO.CURRENT_ACTIVE_TRAITOR = {}
	
end )
