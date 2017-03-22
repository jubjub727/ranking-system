
local table_elo = "elorating"
local table_log = "elologs"

function RANK:Init ()
	
	if !sql.TableExists ( table_elo ) then
		
		sql.Query ( string.format ( [[
		
		CREATE TABLE elorating (
			
			id TEXT NOT NULL PRIMARY KEY,
			name TEXT,
			elo INTEGER DEFAULT 1400,
			wins INTEGER DEFUALT 0,
			losses INTEGER DEFUALT 0,
			kills INTEGER DEFUALT 0,
			deaths INTEGER DEFUALT 0
			
		);
		
		]], table_elo ) )
		
	end
	
	if !sql.TableExists ( table_log ) then
		
		sql.Query ( string.format ( [[
		
			CREATE TABLE %s (
			
				id INTEGER PRIMARY KEY,
				time STRING,
				uid TEXT NOT NULL,
				type TEXT,
				before INTEGER,
				after INTEGER
				
			);
			
		]], table_log ) )
		
	end
	
end

function RANK:Reset ()
	
	RANK:Init ()
	
	sql.Query ( string.format ( [[
		
		UPDATE %s
		SET rating=0
		
	]], table_elo ) )
	
end

function RANK:Log ( uid, before, after )
	
	RANK:Init ()
	
	sql.query ( string.format ( [[
		
		INSERT INTO %s ( time, uid, before, after )
		VALUES ( %s, %s, %s, %s );
		
	]],
	
		table_log,
		SQLStr ( os.time () ),
		SQLStr ( uid ),
		SQLStr ( before ),
		SQLStr ( after )
		
	) )
	
end

function RANK:GetRating ( ply )
	
	RANK:Init ()
	
	
	
end

function RANK:GetRankName( steamid )

	ELO.DataProvider:Init ()
	
	steamid = tostring ( steamid )
	
	local query = string.format ( [[
		SELECT * FROM %s
		WHERE p_SteamID64=%s
		LIMIT 1
	]], table_elo, SQLStr ( steamid ) )
	
	local qData = sql.Query ( query )

	local rating = qData[1]["elo"]
	local wins = qData[1]["wins"]
	
	local query = string.format ( [[
	SELECT p_SteamID64, elo FROM %s ORDER BY elo ASC
	]], table_elo )

	local rs = sql.Query ( query )

	local count = #rs

	if wins < 3 then
		return 1
	else
		for k,v in pairs(RANK.Ranks) do
			if not (k == 1) then 
				if elo >= tonumber(RANK:GetPercentile(v[2], count))
					return k
				end
			end
		end
	end

end

function RANK:GetPercentile( percentile, length )
	local index = math.Round(length * (percentile / 100))
	local query = string.format ( [[SELECT elo FROM %s ORDER BY elo ASC LIMIT 1 OFFSET %s;]], table_elo, index )
	local rs = sql.Query(query)
	for k,v in pairs(rs) do
		return v["elo"]
	end
end