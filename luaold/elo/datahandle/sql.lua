
--	sql.lua

ELO.DataProvider = {}
ELO.DataProvider.Type = "sql"

local tablename = "eloratingsystem"

function ELO.DataProvider:Init ()
	
	if !sql.TableExists ( tablename ) then
		
		local query = string.format ( [[
			CREATE TABLE %s (
				p_SteamID64 TEXT NOT NULL PRIMARY KEY,
				p_DisplayName TEXT,
				
				elo_rating_0 INTEGER DEFAULT 1400,
				elo_rating_1 INTEGER DEFAULT 1400
			);
		]], tablename )
		
		sql.Query ( query )
		
	end
	
	if !sql.TableExists ( string.format ( "%s_logs", tablename ) ) then
		
		local query = string.format ( [[
			CREATE TABLE %s_logs (
				id INTEGER PRIMARY KEY,
				
				unix_time TEXT,
				elo_log_type TEXT,
				elo_data TEXT
				
			);
		]], tablename )
		
		sql.Query ( query )
		
	end
	
end

function ELO.DataProvider:Reset ()
	
	ELO.DataProvider:Init ()
	
	local query = string.format ( [[
		UPDATE %s
		SET elo_rating_0=1400, elo_rating_1=1400
	]], tablename )
	
	sql.Query ( query )
	
	MsgN ( "ELO.DataProvider:Reset () ran" )
	
end

function ELO.DataProvider:Drop ()
	
	ELO.DataProvider:Init ()
	
	local query = string.format ( [[
		DROP TABLE %s
	]], tablename )
	
	sql.Query ( query )
	
	MsgN ( "ELO.DataProvider:Drop () ran" )
	
end

function ELO.DataProvider:Log ( elo_log_data_type, log_data )
	
	local query = string.format ( [[
		INSERT INTO %s_logs ( unix_time, elo_log_type, elo_data )
		VALUES ( %s, %s, %s )
	]],
		tablename,
		SQLStr ( os.time () ),
		SQLStr ( elo_log_data_type ),
		SQLStr ( log_data )
	)
	
	sql.Query ( query )
	
end

function ELO.DataProvider:GetRating ( ply, elo_type )
	
	ELO.DataProvider:Init ()
	
	ply = tostring ( ply )
	
	local query = string.format ( [[
		SELECT * FROM %s
		WHERE p_SteamID64=%s
		LIMIT 1
	]], tablename, SQLStr ( ply ) )
	
	local qData = sql.Query ( query )
	--PrintTable( qData )
	rating = qData[1][string.format ( "elo_rating_%s", elo_type )]
	
	ELO.DataProvider:Log ( "GetRating", string.format ( "%s (%s): %s", ply, elo_type, rating ) )
	
	return rating
	
end

function ELO.DataProvider:SetRating ( ply, elo_type, rating )
	
	ELO.DataProvider:Init ()
	
	ply = tostring ( ply )
	
	if rating == -1 then rating = ELO.DataProvider:GetRating ( ply, elo_type ) or 1400 end
	
	local q1 = string.format ( [[
		SELECT * FROM %s
		WHERE p_SteamID64=%s
		LIMIT 1
	]], tablename, SQLStr ( ply ) )
	
	local q1d = sql.Query ( q1 )
	
	local q2
	
	if !(q1d == nil) then
		
		q2 = string.format ( [[
			UPDATE %s
			SET elo_rating_%s=%s
			WHERE p_SteamID64=%s
		]], tablename, elo_type, rating, SQLStr ( ply )
		)
	
	else
	
		q2 = string.format ( [[
			INSERT INTO %s ( p_SteamID64, p_DisplayName, elo_rating_%s )
			VALUES ( %s, %s, %s )
		]], tablename, elo_type, SQLStr ( ply ), SQLStr ( "unknown" ), rating
		)
	
	end
	
	sql.Query ( q2 )
	
	//ELO.DataProvider:Log ( "SetRating", string.format ( "%s (%s): %s", ply, elo_type, rating ) )
	
end

function ELO.DataProvider:SetDBName ( ply, name )
	
	ELO.DataProvider:Init ()
	
	local query = string.format ( [[
		UPDATE %s
		SET p_DisplayName=%s
		WHERE p_SteamID64=%s
	]], tablename, SQLStr ( name ), SQLStr ( ply ) )
	
	sql.Query ( query )
	
	ELO.DataProvider:Log ( "SetDBName", string.format ( "%s: %s", ply, name ) )
	
end

function ELO.DataProvider:AddRating ( ply, elo_type, rating )
	
	ELO.DataProvider:Init ()
	ply = tostring ( ply )
	
	data = ELO.DataProvider:GetRating ( ply, elo_type )
	ELO.DataProvider:SetRating ( ply, elo_type, data+rating )
	
	ELO.DataProvider:Log ( "AddRating", string.format ( "%s (%s): %s", ply, elo_type, name ) )
	
end

function ELO.DataProvider:SubRating ( ply, elo_type, rating )
	
	ELO.DataProvider:Init ()
	ply = tostring ( ply )
	
	data = ELO.DataProvider:GetRating ( ply, elo_type )
	ELO.DataProvider:SetRating ( ply, elo_type, data-rating )
	
	ELO.DataProvider:Log ( "SubRating", string.format ( "%s (%s): %s", ply, elo_type, name ) )
	
end

function ELO.DataProvider:RowExists ( ply )
	
	local q1 = string.format ( [[
		SELECT EXISTS ( SELECT 1 FROM %s WHERE p_SteamID64=%s )
	]], tablename, SQLStr ( ply ) )
	
	rs = sql.Query ( q1 )
	rtnValue = 0
	
	for k, v in pairs ( rs ) do
		for kk, vv in pairs ( v ) do
			rtnValue = vv
		end
	end
	
	ELO.DataProvider:Log ( "RowExists", string.format ( "%s", ply ) )
	
	if tonumber ( rtnValue ) == 0 then
		return false
	else
		return true
	end
	
end

function ELO.DataProvider:PlayerInit ( ply, plyName )

	ELO.DataProvider:Init ()
	
	if ELO.DataProvider:RowExists ( ply ) then
		ELO.DataProvider:SetDBName ( ply, plyName )
	else
		ELO.DataProvider:SetRating ( ply, 0, 1400 )
		ELO.DataProvider:SetRating ( ply, 1, 1400 )
		ELO.DataProvider:SetDBName ( ply, plyName )
	end
	
	ELO.DataProvider:Log ( "PlayerInit", string.format ( "%s (%s)", ply, plyName ) )
	
end

function ELO.DataProvider:Stats ( type_ )
	
	local query = string.format ( [[
		SELECT * FROM %s
	]], tablename )
	
	local rs = sql.Query ( query )
	
	local total_elo = 0
	
	for k, v in pairs ( rs ) do
		total_elo = total_elo + v[string.format("elo_rating_%s", type_)]
	end
	
	ELO.DataProvider:Log ( "Stats", string.format ( "%s", type_ ) )
	
	return total_elo, #rs

end

function ELO.DataProvider:GetRank ( steamid, elo_type )
	
	local query = string.format ( [[
		SELECT * FROM %s ORDER BY elo_rating_%s DESC
	]], tablename, elo_type )
	
	local rs = sql.Query ( query )
	
	local rank = #rs
	
	for k, v in pairs ( rs ) do
		if v["p_SteamID64"] == steamid then
			rank = k
		end
	end
	
	return rank, #rs
	
end

function ELO.DataProvider:GetRankName( steamid )
	
	ELO.DataProvider:Init ()
	
	ply = tostring ( ply )
	
	local query = string.format ( [[
		SELECT * FROM %s
		WHERE p_SteamID64=%s
		LIMIT 1
	]], tablename, SQLStr ( steamid ) )
	
	local qData = sql.Query ( query )

	local rating = qData[1]["elo"]
	local wins = qData[1]["wins"]

	local query = string.format ( [[
	SELECT elo FROM %s ORDER BY elo ASC
	]], tablename )

	local rs = sql.Query ( query )

	local count = #rs

	if wins < 3 then
		return 1
	end

	for k,v in pairs(ranks) do
		if k == 1 then
		elseif (elo >= tonumber(ELO.DataProvider:GetPercentile(v[2], count))) then
			return k
		end
	end
end

function ELO.DataProvider:GetPercentile( percentile, length )
	local index = math.Round(length * (percentile / 100))
	local query = string.format ( [[SELECT elo FROM elorating ORDER BY elo ASC LIMIT 1 OFFSET %s;]], index )
	local rs = sql.Query(query)
	for k,v in pairs(rs) do
		return v["elo"]
	end
end

function ELO.DataProvider:DumpStats ()
	
	local query = string.format ( [[
		SELECT * FROM %s ORDER BY elo_rating_0 DESC LIMIT 3
	]], tablename )
	
	local rs = sql.Query ( query )
	
	PrintTable ( rs )
	
	ELO.DataProvider:Log ( "DumpStats", "Stats Dumped" )
	
end

function ELO.DataProvider:ExportSQL ( exportLog )

	local tName = tablename
	if exportLog then
		tName = tablename .. "_logs"
	end
	
	local rs = sql.Query ( string.format ( "SELECT * FROM %s",  tName ) )
	
	local time = os.time ()
	
	file.CreateDir ( "rating_elo_sql" )
	
	local fName = string.format ( "rating_elo_sql/sql_export_%s.txt", time )
	
	local tIndex = {}
	local tIndexRun = false
	
	for k, v in pairs ( rs ) do
		
		if !tIndexRun then
			tIndexRun = true
			for kk, vv in pairs ( v ) do
				table.insert ( tIndex, kk )
			end
		end
		
	end
	
	local tData = {}
	
	for k, v in pairs ( rs ) do
		
		for kk, vv in pairs ( v ) do
			table.insert ( tData, SQLStr ( vv ) )
		end
		
	end
	
	file.Append ( fName, string.format ( "INSERT INTO %s (%s) VALUES\n", tName, table.concat ( tIndex, ", " ) ) )
	
	local tData_sub = {}
	
	for i=1, #tData, 4 do
		
		sepType = ","
		
		if i > (#tData-4) then
			sepType = ";"
		end
		
		tData_sub[i] = string.format ( "( %s )%s\n", table.concat ( tData, ", ", i, i+3 ), sepType )
		file.Append ( fName, tData_sub[i] )
		
	end
	
	return fName
	
end

require ( "mysqloo" )

function ELO.DataProvider:SyncToServer ( fileName, sqlHost, sqlDatabase, sqlUser, sqlPass )

	fileData = file.Read ( fileName )
	
	local db = mysqloo.connect( sqlHost, sqlUser, sqlPass, sqlDatabase, 3306 )
	
	function db:onConnected()
		
		MsgN ( "SyncToServer: Connected to Database" )
		
		local q = self:query ( string.format ( "TRUNCATE TABLE %s;", tablename ) )
		
		function q:onSuccess( data )
			
			print( "SyncToServer Delete: Query ran" )
			PrintTable( data )
			
		end
		
		function q:onError( err, sql )
			
			print( "SyncToServer Delete: Query errored" )
			print( "Query:", sql )
			print( "Error:", err )
			
		end
		
		q:start()
		
		local q = self:query( fileData )
		
		function q:onSuccess( data )
			
			print( "SyncToServer: Query ran" )
			PrintTable( data )
			
		end
		
		function q:onError( err, sql )
			
			print( "SyncToServer: Query errored" )
			print( "Query:", sql )
			print( "Error:", err )
			
		end
		
		q:start()
	
	end
	
	function db:onConnectionFailed( err )
		
		print( "SyncToServer: Connection to server failed" )
		print( "Error:", err )
		
	end
	
	db:connect()

end

