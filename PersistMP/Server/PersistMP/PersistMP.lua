------ Server -------
---------------------
----- PersistMP -----
---------------------
---- Authored by ----
-- Beams of Norway --
---------------------

-- Stores and restores player location and vehicle between sessions.

local PersistMPInfo = {}

function handlePersistMPOnPlayerJoin(player_id) 
    -- player_id: number
    local beamMPid = MP.GetPlayerIdentifiers(player_id).beammp
    if PersistMPInfo[beamMPid] ~= nil then
        MP.TriggerClientEventJson(player_id, "onPersistMPJoin", PersistMPInfo[beamMPid])
    end
end

function handlePersistMPOnPlayerDisconnect(player_id) 
    -- player_id: number
    updateVehicleInfo(player_id)
end

function handlePersistMPonVehicleSpawn(player_id) 
    -- player_id: number
    updateVehicleInfo(player_id)
end

function handlePersistMPonVehicleEdited(player_id) 
    -- player_id: number
    updateVehicleInfo(player_id)
end

function updateVehicleInfo(player_id)
	local playerVehicles = MP.GetPlayerVehicles(player_id)
    if playerVehicles == nil then return end
    local beamMPid = MP.GetPlayerIdentifiers(player_id).beammp
    if beamMPid == nil then return end
    PersistMPInfo[beamMPid] = {}
    PersistMPInfo[beamMPid].Vehicles = {}
    
    for key, value in pairs(playerVehicles) do
        PersistMPInfo[beamMPid].Vehicles[key] = {}
        PersistMPInfo[beamMPid].Vehicles[key].config = Util.JsonDecode(value:match("{.*}"))
        PersistMPInfo[beamMPid].Vehicles[key].positionRaw = MP.GetPositionRaw(player_id, key)
    end
end

function onInit()
    MP.RegisterEvent("onPlayerJoin", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onVehicleSpawn", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onVehicleEdited", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onPlayerDisconnect", "handlePersistMPOnPlayerDisconnect")
    print("PersistMP loaded...")
end
