-- Client-Side Script: Warrant System GUI

local screenW, screenH = guiGetScreenSize()

-- Create main GUI window
local window = guiCreateWindow((screenW - 400) / 2, (screenH - 300) / 2, 400, 300, "Active Warrant System", false)
guiWindowSetSizable(window, false)
guiSetVisible(window, false) -- Start with the window hidden

-- Labels and input fields
local nameLabel = guiCreateLabel(20, 30, 80, 20, "Suspect Name:", false, window)
local nameInput = guiCreateEdit(110, 30, 250, 20, "", false, window)

local reasonLabel = guiCreateLabel(20, 70, 80, 20, "Reason:", false, window)
local reasonInput = guiCreateEdit(110, 70, 250, 20, "", false, window)

local plateLabel = guiCreateLabel(20, 110, 80, 20, "Vehicle Plate:", false, window)
local plateInput = guiCreateEdit(110, 110, 250, 20, "", false, window)

local submitButton = guiCreateButton(20, 150, 340, 30, "Add Warrant", false, window)

-- Close Button
local closeButton = guiCreateButton(340, 10, 40, 20, "X", false, window)

-- Warrant List
local warrantList = guiCreateGridList(20, 190, 340, 90, false, window)
guiGridListAddColumn(warrantList, "Suspect Name", 0.3)
guiGridListAddColumn(warrantList, "Reason", 0.3)
guiGridListAddColumn(warrantList, "Vehicle Plate", 0.3)
guiGridListAddColumn(warrantList, "Officer", 0.3) -- Column for officer name

-- Table to store warrants data
local warrantsTable = {}

-- Disable default MTA binds when editing warrant
local function disableBinds()
    guiSetInputMode("no_binds_when_editing")
end

-- Re-enable default MTA binds when closing panel
local function enableBinds()
    guiSetInputMode("allow_binds")
end

-- Function to handle closing the panel
local function closePanel()
    guiSetVisible(window, false)
    showCursor(false)
    enableBinds()  -- Re-enable binds on close
end

-- Close panel when "X" button is clicked
addEventHandler("onClientGUIClick", closeButton, function()
    closePanel()
end, false)

-- Fetch officer name (Owl Gaming specific function, adapt to your integration system)
local function getOfficerName()
    if exports.integration then
        local officerName = exports.integration:getPlayerName(localPlayer)
        if officerName and officerName ~= "" then
            return officerName
        end
    end
    return getPlayerName(localPlayer)
end

-- Event handler to add a warrant
addEventHandler("onClientGUIClick", submitButton, function()
    local suspectName = guiGetText(nameInput)
    local reason = guiGetText(reasonInput)
    local vehiclePlate = guiGetText(plateInput)

    local officerName = getOfficerName() -- Fetch officer's name

    -- Input validation
    if suspectName == "" or reason == "" then
        outputChatBox("Suspect Name and Reason are required!", 255, 0, 0)
        return
    end

    -- Add warrant to the local table
    table.insert(warrantsTable, {
        suspectName = suspectName,
        reason = reason,
        vehiclePlate = vehiclePlate ~= "" and vehiclePlate or "N/A",
        officerName = officerName
    })

    -- Update GUI with new data
    local row = guiGridListAddRow(warrantList)
    guiGridListSetItemText(warrantList, row, 1, suspectName, false, false)
    guiGridListSetItemText(warrantList, row, 2, reason, false, false)
    guiGridListSetItemText(warrantList, row, 3, vehiclePlate ~= "" and vehiclePlate or "N/A", false, false)
    guiGridListSetItemText(warrantList, row, 4, officerName, false, false)

    -- Send data to the server
    triggerServerEvent("onWarrantAdd", resourceRoot, suspectName, reason, vehiclePlate, officerName)

    -- Clear inputs
    guiSetText(nameInput, "")
    guiSetText(reasonInput, "")
    guiSetText(plateInput, "")
end, false)

-- Command to show the warrant window
addCommandHandler("warrants", function()
    guiSetVisible(window, not guiGetVisible(window))
    showCursor(guiGetVisible(window))
    if guiGetVisible(window) then
        disableBinds()  -- Disable default MTA binds while GUI is open
    end
end)



-- local screenW, screenH = guiGetScreenSize()

-- -- Create main GUI window for checking warrants
-- local checkWarrantsWindow = guiCreateWindow((screenW - 600) / 2, (screenH - 400) / 2, 600, 400, "Check Existing Warrants", false)
-- guiWindowSetSizable(checkWarrantsWindow, false)
-- guiSetVisible(checkWarrantsWindow, false) -- Start with the window hidden

-- -- Warrant List GUI elements
-- local warrantGridList = guiCreateGridList(20, 30, 560, 300, false, checkWarrantsWindow)
-- guiGridListAddColumn(warrantGridList, "Suspect Name", 0.3)
-- guiGridListAddColumn(warrantGridList, "Reason", 0.3)
-- guiGridListAddColumn(warrantGridList, "Vehicle Plate", 0.2)
-- guiGridListAddColumn(warrantGridList, "Officer", 0.2)

-- local refreshWarrantsButton = guiCreateButton(20, 340, 100, 30, "Refresh", false, checkWarrantsWindow)
-- local closeWarrantsButton = guiCreateButton(480, 340, 100, 30, "Close", false, checkWarrantsWindow)

-- -- Function to handle closing the check warrants panel
-- local function closeCheckWarrantsPanel()
--     guiSetVisible(checkWarrantsWindow, false)
--     showCursor(false)
-- end

-- -- Close the check warrants window when "Close" button is clicked
-- addEventHandler("onClientGUIClick", closeWarrantsButton, function()
--     closeCheckWarrantsPanel()
-- end, false)

-- -- Refresh the warrant list when "Refresh" button is clicked
-- addEventHandler("onClientGUIClick", refreshWarrantsButton, function()
--     -- Trigger server to fetch and update the warrant list
--     triggerServerEvent("requestWarrantList", localPlayer)
-- end, false)

-- -- Event to update the warrant list in the GUI
-- addEvent("updateWarrantList", true)
-- addEventHandler("updateWarrantList", root, function(warrants)
--     guiGridListClear(warrantGridList)
    
--     for _, warrant in ipairs(warrants) do
--         local row = guiGridListAddRow(warrantGridList)
--         guiGridListSetItemText(warrantGridList, row, 1, warrant.suspectName or "Unknown", false, false)
--         guiGridListSetItemText(warrantGridList, row, 2, warrant.reason or "No reason provided", false, false)
--         guiGridListSetItemText(warrantGridList, row, 3, warrant.vehiclePlate or "N/A", false, false)
--         guiGridListSetItemText(warrantGridList, row, 4, warrant.officerName or "Unknown", false, false)
--     end
-- end)

-- -- Command to show/hide the check warrants GUI panel
-- addCommandHandler("checkWarrantsPanel", function()
--     local isVisible = guiGetVisible(checkWarrantsWindow)
--     if not isVisible then
--         guiSetVisible(checkWarrantsWindow, true)
--         showCursor(true)
--     else
--         closeCheckWarrantsPanel()
--     end
-- end)
