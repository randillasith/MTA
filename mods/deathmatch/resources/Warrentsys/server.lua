-- Server-Side Script: Handle Warrant Data with Enhanced Error Handling

-- Establish MySQL connection
local db = dbConnect("mysql", "dbname=mta;host=localhost;charset=utf8", "root", "")

if not db then
    outputDebugString("Failed to connect to the MySQL database!", 1)
    return
end

outputDebugString("Connected to MySQL database successfully!", 3)

-- Function to check if the table exists
local function checkTableExists()
    local query = "SHOW TABLES LIKE 'warrants'"
    local result = dbQuery(db, query)
    
    if not result then
        outputDebugString("Failed to execute table existence check query!", 1)
        return false
    end
    
    local rows = dbPoll(result, -1)
    
    if #rows == 0 then
        outputDebugString("Table 'warrants' does not exist. Please create the table.", 1)
        return false
    end
    
    return true
end

-- Ensure the table exists before proceeding
if not checkTableExists() then
    outputDebugString("Cannot proceed without the 'warrants' table.", 1)
    return
end

-- Event handler to add a warrant to the database with enhanced debugging
addEvent("onWarrantAdd", true)
addEventHandler("onWarrantAdd", resourceRoot, function(suspectName, reason, vehiclePlate, officerName)
    -- Validate inputs
    if not suspectName or not reason or suspectName == "" or reason == "" then
        outputChatBox("Suspect Name and Reason are required to add a warrant!", source, 255, 0, 0)
        return
    end

    local query = [[
        INSERT INTO warrants (suspectName, reason, vehiclePlate, officerName)
        VALUES (?, ?, ?, ?)
    ]]

    local success, err = dbExec(db, query, suspectName, reason, vehiclePlate or "N/A", officerName or "Unknown")
    
    if not success then
        outputChatBox("Error adding warrant to the database. Please try again later.", source, 255, 0, 0)
        outputDebugString("Failed to insert warrant into database: " .. tostring(err), 1)
        return
    end

    outputChatBox("Warrant for " .. suspectName .. " has been added!", source, 0, 255, 0)
end)



-- Command to delete a warrant with enhanced debugging
addCommandHandler("removeWarrant", function(player, cmd, warrantID)
    if not tonumber(warrantID) then
        outputChatBox("Invalid warrant ID.", player, 255, 0, 0)
        return
    end

    local query = "DELETE FROM warrants WHERE id = ?"
    local success, err = dbExec(db, query, tonumber(warrantID))
    
    if not success then
        outputChatBox("Error deleting warrant from the database. Please try again later.", player, 255, 0, 0)
        outputDebugString("Failed to delete warrant from database: " .. tostring(err), 1)
        return
    end

    outputChatBox("Warrant ID " .. warrantID .. " has been removed.", player, 0, 255, 0)
end)

-- Command to drop all warrants with enhanced debugging
addCommandHandler("dropWarrants", function(player)
    local query = "DELETE FROM warrants"
    local success, err = dbExec(db, query)
    
    if not success then
        outputChatBox("Error dropping all warrants from the database. Please try again later.", player, 255, 0, 0)
        outputDebugString("Failed to drop warrants from database: " .. tostring(err), 1)
        return
    end
    
    outputChatBox("All warrants have been removed.", player, 0, 255, 0)
end)



