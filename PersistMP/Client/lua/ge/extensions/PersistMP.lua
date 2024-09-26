------ Client -------
---------------------
----- PersistMP -----
---------------------
---- Authored by ----
-- Beams of Norway --
---------------------

-- Stores and restores player location and vehicle between sessions.

local M = {}

local function onWorldReadyState(worldReadyState)
  if worldReadyState == 2 then
	TriggerServerEvent("PersistMP_RequestStoredInfo", "")
  end
end

function onPersistMP_GetAndApplyStoredInfo(json)
	data = jsonDecode(json)
	if data ~= nil then
		local vehName = data.Vehicles[1].config.vcf.model
		local vehConfigFile = data.Vehicles[1].config.vcf.partConfigFilename
		local pos = data.Vehicles[1].positionRaw.pos
		local rot = data.Vehicles[1].positionRaw.rot
		core_vehicles.spawnNewVehicle(vehName, {config = vehConfigFile})
		be:getPlayerVehicle(0):setPositionRotation( pos[1], pos[2], pos[3], rot[1], rot[2], rot[3], rot[4]) 
	end
end

AddEventHandler("onPersistMP_GetAndApplyStoredInfo", onPersistMP_GetAndApplyStoredInfo) 

M.onInit = function() setExtensionUnloadMode(M, "manual") end
M.onPersistMP_GetAndApplyStoredInfo = onPersistMP_GetAndApplyStoredInfo
M.onWorldReadyState = onWorldReadyState

print("PersistMP Client loaded...")
return M
