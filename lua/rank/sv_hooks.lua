
hook.Add( "PostGamemodeLoaded", "ranking-system" function ()
	
	local handle = string.format ( "rank/dh/%s.lua", RANK.Handler or "sql" )
	include ( handler )
	
end )

-- Initialise Player when they join
hook.Add ( "PlayerInitialSpawn", "ranking-system", function ( ply )
	
	
	
end )
