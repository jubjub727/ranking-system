
--	rating_elo.lua

ELO = ELO or {}

if SERVER then

	include ( "elo/config.lua" )
	include ( "elo/sv_function.lua" )
	include ( "elo/init.lua" )
	include ( "elo/sv_hook.lua" )

else 
	AddCSLuaFile( "cl_hooks.lua" )
	include ( "cl_hooks.lua" )
end
