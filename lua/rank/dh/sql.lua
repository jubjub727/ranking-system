
-- sql.lua

RANK.dp = "sql"

local table_elo = "elorating"
local table_log = "elologs"
function RANK:Init ()
	
	if !sql.TableExists ( table_elo ) then
		
		sql.Query ( string.format ( [[
		
		CREATE TABLE %s (
			
			id TEXT NOT NULL PRIMARY KEY,
			name TEXT,
			elo INTEGER DEFAULT 1400,
			wins INTEGER DEFUALT 0,
			losses INTEGER DEFUALT 0,
			kills INTEGER DEFUALT 0,
			deaths INTEGER DEFUALT 0
			
		);
		
		]], table_elo )
		
	end
	
	if !sql.TableExists ( string.format ( "%s_log", table_log ) ) then
		
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
