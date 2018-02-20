tsBridgeUrl = CreateConVar("ttt_ts3_bridge_url", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The URL for the TS3 bridge")
tsBridgeKey = CreateConVar("ttt_ts3_bridge_key", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "The API key for the TS3 bridge")
GetConVarString ( "ttt_ts3_bridge_url" )
GetConVarString ( "ttt_ts3_bridge_key" )
local function isempty(s)
	return s == nil or s == ''
end
if not isempty(tsBridgeUrl:GetString()) then
	MsgC( Color( 0 ,178, 238 ), "[TS3Bridge] ", Color( 255, 255, 255 ), "Loaded TS3Bridge!" .. "\n" )
	gameevent.Listen( "entity_killed" )
	gameevent.Listen( "TTTBeginRound" )
	hook.Add("TTTBeginRound", "TTTBeginRound_ts3bridge", function()
		hook.Add( "entity_killed", "entity_killed_ts3bridge", function( data )
			for k, v in pairs( player.GetAll() ) do
				if ( v:Alive() && not v:IsSpec() ) then
					-- Do nothing
				else
					http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=mute&steamID=" .. v:SteamID())
				end
			end
		end)
		for k, v in pairs( player.GetAll() ) do
			if ( v:Alive()  && not v:IsSpec() ) then
				http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=unmute&steamID=" .. v:SteamID())
			else
				-- Do Nothing
			end
		end
	end)
	gameevent.Listen( "TTTEndRound" )
	hook.Add("TTTEndRound", "TTTEndRound_ts3bridge", function()
		hook.Remove( "entity_killed", "entity_killed_ts3bridge")
		timer.Simple(0.3, function()
			for k, v in pairs( player.GetAll() ) do
					http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=unmute&steamID=" .. v:SteamID())
			end
		end)
	end)
	gameevent.Listen( "player_spawn" )
	hook.Add("player_spawn", "player_spawn_ts3bridge", function(data)
		local steamID
		for _, ply in pairs(player.GetAll()) do
			if ply:UserID() == data["userid"] then
				steamID=ply:SteamID()
			end
		end
		for k, v in pairs( player.GetAll() ) do
			if ( v:Alive() && not v:IsSpec() ) then
				http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=unmute&steamID=" .. v:SteamID())
			else
				-- Do Nothing
			end
		end
		http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=connect&steamID=" .. steamID,
			function( body, len, headers, code )
				if(body ~= "OK") then
					for _, ply in pairs(player.GetAll()) do
						if ply:SteamID() == steamID then
							if not ply:IsBot() then
								ply:Kick( body )
							end
						end
					end
					http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=kick&steamID=" .. steamID)
				end
			end,
			function( error )
				-- Do nothing
			end
		)
		for k, v in pairs( player.GetAll() ) do
			if ( v:Alive() && not v:IsSpec() ) then
				http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=unmute&steamID=" .. v:SteamID())
			else
				-- Do Nothing
			end
		end
	end)
	gameevent.Listen( "player_disconnect" )
	hook.Add("player_disconnect", "player_disconnect_ts3bridge", function(data)
		http.Fetch( tsBridgeUrl:GetString() .. "?key=" .. tsBridgeKey:GetString() .. "&action=kick&steamID=" .. data["networkid"])		
	end)
else
	ServerLog( "TS3 Bridge URL not valid" .. "\r\n")
end