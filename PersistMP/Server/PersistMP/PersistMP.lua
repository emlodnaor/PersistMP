------ Server -------
---------------------
----- PersistMP -----
---------------------
---- Authored by ----
-- Beams of Norway --
---------------------

-- Stores and restores player location and vehicle between sessions.

local PersistMP_Info = {}

function handle_PersistMP_RequestStoredInfo(player_id) 
    -- player_id: number
    local beamMPid = MP.GetPlayerIdentifiers(player_id).beammp
    if PersistMP_Info[beamMPid] ~= nil then
        MP.TriggerClientEventJson(player_id, "onPersistMP_GetAndApplyStoredInfo", PersistMP_Info[beamMPid])
    end
end

function handle_PersistMP_OnPlayerDisconnect(player_id) 
    -- player_id: number
    PersistMPupdateVehicleInfo(player_id)
    PersistMP_updateStoredInfo()
end

function handlePersistMPonVehicleSpawn(player_id) 
    -- player_id: number
    PersistMPupdateVehicleInfo(player_id)
    PersistMP_updateStoredInfo()
end

function handlePersistMPonVehicleEdited(player_id) 
    -- player_id: number
    PersistMPupdateVehicleInfo(player_id)
    PersistMP_updateStoredInfo()
end

function PersistMPupdateVehicleInfo(player_id)
	local playerVehicles = MP.GetPlayerVehicles(player_id)
    if playerVehicles == nil then return end
    local beamMPid = MP.GetPlayerIdentifiers(player_id).beammp
    if beamMPid == nil then return end
    PersistMP_Info[beamMPid] = {}
    PersistMP_Info[beamMPid].Vehicles = {}
    
    for key, value in pairs(playerVehicles) do
        PersistMP_Info[beamMPid].Vehicles[key] = {}
        PersistMP_Info[beamMPid].Vehicles[key].config = Util.JsonDecode(value:match("{.*}"))
        PersistMP_Info[beamMPid].Vehicles[key].positionRaw = MP.GetPositionRaw(player_id, key)
    end
end

local function tableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function onInit()
    MP.RegisterEvent("PersistMP_RequestStoredInfo", "handle_PersistMP_RequestStoredInfo")
    -- MP.RegisterEvent("onVehicleSpawn", "handle_PersistMP_OnPlayerJoin")
    -- MP.RegisterEvent("onVehicleEdited", "handle_PersistMP_OnPlayerJoin")
    MP.RegisterEvent("onPlayerDisconnect", "handle_PersistMP_OnPlayerDisconnect")
    MP.RegisterEvent("onShutdown", "handle_PersistMP_OnShutdown")
    PersistMP_Info = restorePersistMPInfo()
    print("PersistMP mod loaded.")
    print(tableCount(PersistMP_Info) .. " PersistMP users found...")
end

function handle_PersistMP_OnShutdown()
    PersistMP_storeAllActiveUsers()
    PersistMP_updateStoredInfo()
end

function PersistMP_storeAllActiveUsers()
    local players = MP.GetPlayers()
    for player_id, username in pairs(players) do
        PersistMPupdateVehicleInfo(player_id)
    end
end

function PersistMP_updateStoredInfo()
	local persistInfo = Util.JsonEncode(PersistMP_Info)
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

function restorePersistMPInfo()
    local file = io.open("PersistMPInfo.json", "r")
    if file == nil then
        return {}        
    end
    local content = file:read("*all")
    file:close()
    local contentTable = Util.JsonDecode(content)
    return contentTable    
end
