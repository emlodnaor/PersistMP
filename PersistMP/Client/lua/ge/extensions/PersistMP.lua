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
	if M.PersistMPInfo ~= nil then
		local vehName = M.PersistMPInfo.Vehicles[1].config.vcf.model
		local vehConfigFile = M.PersistMPInfo.Vehicles[1].config.vcf.partConfigFilename
		local pos = M.PersistMPInfo.Vehicles[1].positionRaw.pos
		local rot = M.PersistMPInfo.Vehicles[1].positionRaw.rot
		core_vehicles.spawnNewVehicle(vehName, {config = vehConfigFile})
		be:getPlayerVehicle(0):setPositionRotation( pos[1], pos[2], pos[3], rot[1], rot[2], rot[3], rot[4]) 
	end
  end
  print(M)
end

function onPersistMPJoin(data)
	M.PersistMPInfo = jsonDecode(data)
end

AddEventHandler("onPersistMPJoin", onPersistMPJoin) 

M.onInit = function() setExtensionUnloadMode(M, "manual") end
M.onPersistMPJoin = onPersistMPJoin
M.onWorldReadyState = onWorldReadyState

print("PersistMP Client loaded...")
return M