
--	init.lua

util.AddNetworkString ( "ELO.RankingRequest" )
util.AddNetworkString ( "ELO.RankingReturn" )


net.Receive ( "ELO.RankingRequest", function ( len, ply )
	
	local reqID = net.ReadString ()
	local eloType = net.ReadString ()
	
	local plyRank = ELO.DataProvider:GetRank ( reqID, eloType )
	
	net.Start ( "ELO.RankingReturn" )
	net.WriteString ( plyRank )
	net.Send ( ply )
	
end )