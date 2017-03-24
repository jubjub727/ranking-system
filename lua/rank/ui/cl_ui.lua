
local ranks = {}

hook.Add("Think", "thinkstuff", function()
    net.Receive("scoreboardrank", function()
        ranks = net.ReadTable()
    end )
end )

local function getRankName(ply)
    for k,v in pairs(ranks) do
        if ply:SteamID64() == v[0] then
            return v
        end
    end
    return { "Failed To Get Rank", nil, Color(240, 240, 240) }
end

hook.Add( "TTTScoreboardColumns", "ScoreBoardStuff", function ( pnl )
	pnl:AddColumn("Elo Rank", function (ply, label)
        local rank = getRankName(ply)
        if rank[1] == "Unranked" then
            return ""
        else
            label:SetTextColor( rank[3] )
            return rank[1]
        end
	end, 210 )
end )