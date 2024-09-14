-- Function to get a player by ID
function getPlayerFromID(id)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "playerid") == id then
            return player
        end
    end
    return nil
end

-- Function to find the nearest vehicle
function getNearestVehicle(player)
    local px, py, pz = getElementPosition(player)
    local vehicles = getElementsByType("vehicle")
    local nearestVehicle
    local shortestDistance = 10 -- Maximum distance to consider

    for _, vehicle in ipairs(vehicles) do
        local vx, vy, vz = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
        if distance < shortestDistance then
            shortestDistance = distance
            nearestVehicle = vehicle
        end
    end

    return nearestVehicle
end

-- Function to warp player into the nearest vehicle in a passenger seat
function warpPlayerIntoNearestVehicle(player, commandingPlayer)
    local px, py, pz = getElementPosition(player)
    local cpx, cpy, cpz = getElementPosition(commandingPlayer)
    local distance = getDistanceBetweenPoints3D(px, py, pz, cpx, cpy, cpz)

    if distance <= 10 then -- Check if the player is within 10 units of the commanding player
        local vehicle = getNearestVehicle(player)
        if vehicle then
            local seat = 1 -- Passenger seat
            warpPedIntoVehicle(player, vehicle, seat)
            outputChatBox("Warped into the nearest vehicle in a passenger seat!", player)
        else
            outputChatBox("No vehicle nearby to warp into.", player)
        end
    else
        outputChatBox("Player is not close enough to warp.", commandingPlayer)
    end
end

-- Example: Command to warp a player by ID into the nearest vehicle in a passenger seat
addCommandHandler("warpbyid", function(commandingPlayer, _, id)
    local playerID = tonumber(id)
    if playerID then
        local player = getPlayerFromID(playerID)
        if player then
            warpPlayerIntoNearestVehicle(player, commandingPlayer)
        else
            outputChatBox("No player with that ID found.", commandingPlayer)
        end
    else
        outputChatBox("Invalid ID.", commandingPlayer)
    end
end)