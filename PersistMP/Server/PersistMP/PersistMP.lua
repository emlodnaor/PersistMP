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
    
    updateStoredInfo()
end

function onInit()
    MP.RegisterEvent("onPlayerJoin", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onVehicleSpawn", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onVehicleEdited", "handlePersistMPOnPlayerJoin")
    MP.RegisterEvent("onPlayerDisconnect", "handlePersistMPOnPlayerDisconnect")
    PersistMPInfo = restorePersistInfo()
    print("PersistMP loaded...")
end

function onShutdown()
    updateStoredInfo()
end

function updateStoredInfo()
	persistInfo = Util.JsonEncode(PersistMPInfo)
    -- Open the file for writing
    local file = io.open("PersistMPInfo.json", "w")

    if file == nil then
        print("Error opening file for writing.")
    else
        -- Write content to the file
        file:write(persistInfo)

        -- Close the file
        file:close()
    end
end

function restorePersistInfo()
    local file = io.open("PersistMPInfo.json", "r")
    if file == nil then
        return {}        
    end
    local content = file:read("*all")
    file:close()
    local contentTable = Util.JsonDecode(content)
    return contentTable
    
end
