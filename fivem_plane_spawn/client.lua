-- Plane Location Settings
local model = "cargoplane"
local pedModel = "s_m_y_prisoner_01"
local coords = vector3(-2923.865, -1955.533, 874.047)
local heading = 72.976
local planeZoneActivated = false
local pilotPed = nil
local plane = nil

-- Player Screen Shake Settings
local zone = PolyZone:Create({
  vector2(-2976.4162597656, -1923.5380859375),
  vector2(-2990.8125, -1947.9401855469),
  vector2(-2845.345703125, -2000.9357910156),
  vector2(-2830.7106933594, -1967.5487060547)
}, {
    name = "airplane_cam_shake",
    minZ = 871.0,
	maxZ = 887.0,
    debugPoly = false
})

-- Particle Effect Settings
local fireEffects = {
-- Cockpit
	{ coords = vector3(-2951.887, -1946.991, 882.30), particle = "core", fx = "ent_amb_sparking_wires" },
-- Inside Plane
	{ coords = vector3(-2948.592, -1945.508, 877.641), particle = "core", fx = "ent_amb_fire_ring" },
	{ coords = vector3(-2948.592, -1945.508, 877.141), particle = "core", fx = "exp_grd_grenade_smoke" },
	{ coords = vector3(-2948.592, -1945.508, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	
	{ coords = vector3(-2936.799, -1954.208, 877.58), particle = "core", fx = "ent_amb_fire_ring" },
	{ coords = vector3(-2936.799, -1954.208, 877.58), particle = "core", fx = "exp_grd_grenade_smoke" },
	-- { coords = vector3(-2936.799, -1954.208, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	
	{ coords = vector3(-2930.345, -1951.083, 877.582), particle = "core", fx = "ent_amb_fire_ring" },
	{ coords = vector3(-2930.345, -1951.083, 877.141), particle = "core", fx = "exp_grd_grenade_smoke" },
	{ coords = vector3(-2930.345, -1951.083, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	
	{ coords = vector3(-2919.115, -1959.662, 877.58), particle = "core", fx = "ent_amb_fire_ring" },
	{ coords = vector3(-2919.115, -1959.662, 877.141), particle = "core", fx = "exp_grd_grenade_smoke" },
	{ coords = vector3(-2919.115, -1959.662, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	
	{ coords = vector3(-2907.456, -1958.034, 877.641), particle = "core", fx = "ent_amb_fire_ring" },
	{ coords = vector3(-2907.456, -1958.034, 877.641), particle = "core", fx = "exp_grd_grenade_smoke" },
	-- { coords = vector3(-2907.456, -1958.034, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	
	{ coords = vector3(-2902.052, -1964.879, 877.141), particle = "core", fx = "ent_amb_sparking_wires" },
	{ coords = vector3(-2902.052, -1964.879, 877.141), particle = "core", fx = "exp_grd_grenade_smoke" },
	
-- Outside Plane
	{ coords = vector3(-2903.71, -1933.088, 879.05), particle = "scr_exile1", fx = "scr_ex1_cargo_engine_trail" },
	{ coords = vector3(-2920.938, -1988.103, 879.05), particle = "scr_exile1", fx = "scr_ex1_cargo_engine_trail" },
	
}

-- Script Logic
local function spawnPilot()
    if not DoesEntityExist(pilotPed) then
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do Wait(100) end
        pilotPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z, heading, true, true)
        TaskWarpPedIntoVehicle(pilotPed, plane, -1)
        SetEntityInvincible(pilotPed, true)
        SetBlockingOfNonTemporaryEvents(pilotPed, true)
        SetPedCanBeDraggedOut(pilotPed, false)
        SetPedConfigFlag(pilotPed, 32, false)
        SetPedCombatAttributes(pilotPed, 46, true)
        SetModelAsNoLongerNeeded(pedModel)
    end
end

AddStateBagChangeHandler("plane_engine_state", nil, function(bagName, key, value, _reserved, replicated)
    if key == "plane_engine_state" and DoesEntityExist(plane) then
        SetVehicleEngineOn(plane, value, true, false)
    end
end)

local function spawnPlane()
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end
    
	Wait(5000)
    plane = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    
    local netId = NetworkGetNetworkIdFromEntity(plane)
    if netId == 0 then
        return
    end
    
    Entity(plane).state:set("plane_engine_state", true, true)

    spawnPilot()
    
    SetVehicleEngineOn(plane, true, true, false)
    SetVehicleFuelLevel(plane, 1000.0)
    SetHeliBladesSpeed(plane, 1.0)
    SetVehicleDoorOpen(plane, 2, false, false)
    ControlLandingGear(plane, 1)
    SetVehicleLandingGear(plane, 3)
    SetEntityInvincible(plane, true)
    FreezeEntityPosition(plane, true)
    SetModelAsNoLongerNeeded(model)

end

local function spawnFireEffects()
    CreateThread(function()
        for _, effect in ipairs(fireEffects) do
            RequestNamedPtfxAsset(effect.particle)
            while not HasNamedPtfxAssetLoaded(effect.particle) do Wait(10) end
            UseParticleFxAssetNextCall(effect.particle)
            StartParticleFxLoopedAtCoord(effect.fx, effect.coords.x, effect.coords.y, effect.coords.z, 0.0, 0.0, 69.0, 1.0, false, false, false, false)
        end
    end)
end

local function manageShakeEffcts()
    local shakeActive = false

    CreateThread(function()
        while true do
            Wait(500)
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)

            if zone:isPointInside(playerCoords) then
                if not shakeActive then
                    ShakeGameplayCam("SKY_DIVING_SHAKE", 0.6)
                    shakeActive = true
                end
            else
                if shakeActive then
                    StopGameplayCamShaking(true)
                    shakeActive = false
                end
            end
        end
    end)
end

local function spawnPlaneScene()
    if planeZoneActivated then return end
    planeZoneActivated = true
    spawnPlane()
    spawnFireEffects()
	manageShakeEffcts()
end

spawnPlaneScene()
