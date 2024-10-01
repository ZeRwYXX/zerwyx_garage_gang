local currentPed = nil
local spawnedVehicles = {}

function Draw3DText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z - 1)
    local camCoords = GetGameplayCamCoords()
    local distance = #(camCoords - coords)

    local scale = (1 / distance) * 1.5
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.5 * scale)
        SetTextFont(4) -- Police plus moderne
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end



Citizen.CreateThread(function()
    local model = GetHashKey(Config.PedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    for _, pedInfo in pairs(Config.PedLocations) do
        local ped = CreatePed(4, model, pedInfo.coords.x, pedInfo.coords.y, pedInfo.coords.z -1, pedInfo.coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        pedInfo.pedEntity = ped 
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000) 

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestDistance = -1
            local closestPedInfo = nil

            for _, pedInfo in pairs(Config.PedLocations) do
                local distance = #(playerCoords - vector3(pedInfo.coords.x, pedInfo.coords.y, pedInfo.coords.z))
                if closestDistance == -1 or distance < closestDistance then
                    closestDistance = distance
                    closestPedInfo = pedInfo
                end
            end

            if closestPedInfo and not closestPedInfo.targetAdded then
                exports.ox_target:addModel(model, {
                    {
                        name = "access_rent",
                        icon = "fa-solid fa-car",
                        label = "Accéder à la location",
                        onSelect = function()
                            currentPed = closestPedInfo
                            SetNuiFocus(true, true) 
                            SendNUIMessage({ action = "requestCode" }) 
                        end
                    }
                })
                closestPedInfo.targetAdded = true
            end
        end
    end)
end)


RegisterNUICallback("submitCode", function(data)
    if currentPed and data.code == currentPed.code then
        SendNUIMessage({ action = "showNotification", type = "success", message = "Code correct" })
        SendNUIMessage({ action = "hideCodePanel" })

        SendNUIMessage({ action = "openMenu", vehicles = currentPed.vehicles })
    else
        SendNUIMessage({ action = "showNotification", type = "error", message = "Code incorrect" })
    end
end)

function GetClosestPedLocation(playerPos)
    local closestDistance = nil
    local closestPed = nil
    
    for _, pedInfo in pairs(Config.PedLocations) do
        local pedPos = vector3(pedInfo.coords.x, pedInfo.coords.y, pedInfo.coords.z)
        local distance = #(playerPos - pedPos)

        if not closestDistance or distance < closestDistance then
            closestDistance = distance
            closestPed = pedInfo
        end
    end
    
    return closestPed
end

RegisterNUICallback("rentVehicle", function(data)
    local vehicleType = data.vehicle
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    local closestPed = GetClosestPedLocation(playerPos)
    
    if closestPed and closestPed.vehicles[vehicleType] and closestPed.vehicles[vehicleType].stock > 0 then
      
        closestPed.vehicles[vehicleType].stock = closestPed.vehicles[vehicleType].stock - 1
        
        local closestSpawn = {
            position = vector3(closestPed.spawnVehicle.x, closestPed.spawnVehicle.y, closestPed.spawnVehicle.z),
            heading = closestPed.spawnVehicle.w
        }
        
        RequestModel(GetHashKey(vehicleType))
        while not HasModelLoaded(GetHashKey(vehicleType)) do
            Citizen.Wait(0)
        end

        local vehicle = CreateVehicle(GetHashKey(vehicleType), closestSpawn.position.x, closestSpawn.position.y, closestSpawn.position.z, closestSpawn.heading, true, false)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        local vehicleColor = closestPed.vehicles[vehicleType].color
        if vehicleColor and #vehicleColor == 3 then
            SetVehicleCustomPrimaryColour(vehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
            SetVehicleCustomSecondaryColour(vehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
        end
        
        table.insert(spawnedVehicles, { vehicle = vehicle, model = vehicleType, deleterPos = closestPed.spawnDeleter })

        local plate = GetVehicleNumberPlateText(vehicle)
       -- exports['ak47_vehiclekeys']:GiveKey(plate, false)

        SendNUIMessage({ action = "showNotification", type = "success", message = "Vous avez loué un(e) " .. vehicleType })
        
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "closeMenu" })
    else
        SendNUIMessage({ action = "showNotification", type = "error", message = "Plus de véhicules disponibles." })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local inVehicle = IsPedInAnyVehicle(playerPed, false)

        if inVehicle then
            local currentVehicle = GetVehiclePedIsIn(playerPed, false)

            for i, data in ipairs(spawnedVehicles) do
                local vehicle = data.vehicle
                if DoesEntityExist(vehicle) and vehicle == currentVehicle then
                    local deleterPos = data.deleterPos
                    local distance = #(playerPos - vector3(deleterPos.x, deleterPos.y, deleterPos.z - 1))

                    if distance < 5.0 then
                        Draw3DText(vector3(deleterPos.x, deleterPos.y, deleterPos.z + 1), "[E] Supprimer le véhicule 🚗 ")

                        if IsControlJustReleased(0, 38) then 
                            local plate = GetVehicleNumberPlateText(vehicle)
                            
                            DeleteEntity(vehicle)
                            table.remove(spawnedVehicles, i)
                            
                          --  exports['ak47_vehiclekeys']:RemoveVirtualKey(plate) 
                            
                            if currentPed.vehicles[data.model] and currentPed.vehicles[data.model].stock then
                                currentPed.vehicles[data.model].stock = currentPed.vehicles[data.model].stock + 1
                            else
                                print("Erreur: La valeur de stock du véhicule est incorrecte ou manquante pour le modèle:", data.model)
                            end
                            
                            SendNUIMessage({ action = "showNotification", type = "info", message = data.model .. " a été retourné au stock." })
                            break
                        end
                    end
                end
            end
        end
    end
end)


RegisterNUICallback("closeMenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeMenu" })
end)
