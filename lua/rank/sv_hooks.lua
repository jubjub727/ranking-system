
-- Initialise Player when they join
hook.Add ( "PlayerInitialSpawn", "rank.spawn", function ( ply )
	
	-- Init player from sql funcs
	
end )

-- Handle player death
RANK.canGainElo = false
hook.Add ( "DoPlayerDeath", "rank.death", function ( vict, killer, dmginfo )
	
	if IsValid ( vict ) and IsValid ( killer ) then
	
		kRole = killer:GetRole ()
		vRole = vict:GetRole ()
		
		local shouldAffect = false
		
		if SpecDM then
			
			if vict:IsGhost () == false then
				
				shouldAffect = true
				
			end
			
		else
			shouldAffect = true
		end
		
		if shouldAffect and RANK.canGainElo then
			
			ELO_overall, ELO_players = RANK.GetStats ()
			
			ELO_killer = RANK.getRating ( killer:SteamID64() )
			ELO_victim = RANK.getRating ( vict:SteamID64 () )
			
			ELO_change, ELO_offset = calc ( killerelo, victelo, RANK.valueKill, ELO_overall,  ELO_players )
			
			local RDM = false
			
			if kRole == vRole then
				RDM = true
			end
			
			if RDM then
				RANK.AddRating ( vict:SteamID64 (), ELO_change+offset )
				RANK.SubRating ( killer:SteamID64(), ELO_change-offset )
			else
				RANK.AddRating ( killer:SteamID64 (), ELO_change+offset )
				RANK.SubRating ( vict:SteamID64 (), ELO_change-offset )
			end
			
		end
	
	end
	
end )

-- Handle round elo changes
RANK.ACT_TRAITOR = {}
RANK.ACT_INNOCENT = {}

hook.Add ( "TTTBeginRound", "rank.tttbegin", function ()
	
	table.Empty ( RANK.ACT_TRAITOR )
	table.Empty ( RANK.ACT_INNOCENT )
	
	for k, v in pairs ( player.GetAll () ) do
		
		if v:IsTerror () and v:Alive () then
			
			if v:GetTraitor () then
				table.insert ( RANK.ACT_TRAITOR, { v, v:SteamID64 (), RANK.getRating ( v:SteamID64 () ) } )
			else
				table.insert ( RANK.ACT_INNOCENT, { v, v:SteamID64 (), RANK.getRating ( v:SteamID64 () ) } )
			end
		end
	end
end )

-- Handle post round elo changes
hook.Add ( "TTTEndRound", "rank.tttend", function ( RND_WINNER )
	
	RANK.canGainElo = false
	
	if #player.GetAll () < RANK.minimumPlayers then
		return
	end
	
	groupT = {}
	groupI = {}
	
	for k, v in pairs ( RANK.ACT_TRAITOR ) do
		table.insert ( groupT, v[3] )
	end
	
	for k, v in pairs ( RANK.ACT_INNOCENT ) do
		table.insert ( groupI, v[3] )
	end
	
	ELO_overall, ELO_players = RANK.GetStats ()
	ELO_groups = RANK.calculateGroup ( groupT, groupI, ELO.valueRound, ELO_overall, ELO_players )
	
	
	if RND_WINNER == WIN_TRAITOR then
		for k, v in pairs ( RANK.ACT_TRAITOR ) do
			RANK.AddRating ( v[2], 0, ELO_groups )
		end
		
		for k, v in pairs ( RANK.ACT_INNOCENT ) do
			RANK.SubRating ( v[2], 0, ELO_groups )
		end
		
	else
		
		for k, v in pairs ( RANK.ACT_TRAITOR ) do
			RANK.SubRating ( v[2], 0, ELO_groups )
		end
		
		for k, v in pairs ( RANK.ACT_INNOCENT ) do
			RANK.AddRating ( v[2], 0, ELO_groups )
		end
		
	end
	
	table.Empty ( RANK.ACT_TRAITOR )
	table.Empty ( RANK.ACT_INNOCENT )
	
end )
