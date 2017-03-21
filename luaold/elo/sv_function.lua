
--	sv_function.lua

function ELO:Calculate ( elo_win, elo_loss, score_worth, overallelo, overallply )
 
    differential = 56
   
    if elo_win > elo_loss then
       
        differential = differential - ( ( elo_win - elo_loss ) / 10 )
       
    elseif elo_loss > elo_win then
       
        differential = differential + ( ( elo_loss - elo_win ) / 10 )
       
    end
   
    if differential < 10 then
        differential = 10
    end
    
    offset = ( ( overallelo - (overallply * 1400))) / 4	-- offset = ( ( ( overallply * 1400 ) - overallelo ) / 100 ) / 2
    
    elo_change = ( differential * score_worth / 100 )
	
    return elo_change, offset
 
end

function ELO:CalculateGroup ( elo_w, elo_l, score_worth, overallelo, overallply )
   
    differential = 56
   
    elo_collective_w = 0
    elo_collective_l = 0
   
    for k, v in pairs ( elo_w ) do
        elo_collective_w = elo_collective_w + v
    end
   
    for k, v in pairs ( elo_l ) do
        elo_collective_l = elo_collective_l + v
    end
   
    elo_avrg_w = elo_collective_w / #elo_w
    elo_avrg_l = elo_collective_l / #elo_l
   
    if elo_avrg_w > elo_avrg_l then
        differential = differential - ( ( elo_avrg_w - elo_avrg_l ) / 10 )
    elseif elo_avrg_l > elo_avrg_w then
        differential = differential + ( ( elo_avrg_l - elo_avrg_w ) / 10 )
    end
   
    if differential < 10 then
        differential = 10
    end
    
	offset = ( ( overallelo - (overallply * 1400)))	-- offset = ( ( ( overallply * 1400 ) - overallelo ) / 100 ) / 2
	
    elo_offset = ( differential * score_worth / 100 )
   
    return elo_offset, offset
   
end

local plymeta = FindMetaTable( "Player" )

function plymeta:GetELO_score ( elo_type )

	return ELO.DataProvider:GetRating ( self:SteamID64 (), elo_type ) or -1

end
