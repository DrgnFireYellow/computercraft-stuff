-- Created by DrgnFireYellow
-- This program is licensed under the GNU General Public License V3 and is provided with no warranty.

-- Change this to match your server!
local SYSTEM_NAME = "subway"




local function printCentered(monitor, text, y)
    local width, _ = monitor.getSize()
    monitor.setCursorPos(math.ceil((width-#text)/2), y)
    monitor.write(text)
end

local function findItem(inventory, name)
    local items = inventory.list()

    for slot,item in pairs(items) do
        if item.name == name then
            return slot
        end
    end
    
    return nil
end

math.randomseed(os.time())

local monitor = peripheral.find("monitor")
local barrel = peripheral.wrap("left")
local printer = peripheral.find("printer")

monitor.setTextScale(1)

rednet.open("front")

sleep(2)
local serverID = rednet.lookup("subwayAuthority", SYSTEM_NAME)

print("Found server with ID " .. tostring(serverID))

while true do
    monitor.clear()
    if printer.getPaperLevel() == 0 or printer.getInkLevel() == 0 then
        printCentered(monitor, "Out of service.", 4)
        os.shutdown()
    end

    printCentered(monitor, "Welcome!", 4)
    printCentered(monitor, "To buy a ticket, insert", 6)
    printCentered(monitor, "Emeralds in barrel.", 7)
    printCentered(monitor, "1 Emerald per ride", 9)

    -- Check for emeralds in barrel
    while not findItem(barrel, "minecraft:emerald") do
        sleep(5)
    end

    -- Take emeralds
    monitor.clear()
    printCentered(monitor, "Processing payment...", 6)

    local emeralds = 0

    while findItem(barrel, "minecraft:emerald") do
        local emeraldSlot = findItem(barrel, "minecraft:emerald")
        
        emeralds = emeralds + barrel.getItemDetail(emeraldSlot).count

        barrel.pushItems("bottom", emeraldSlot)
    end

    monitor.clear()
    printCentered(monitor, "Thank you!", 6)

    sleep(3)

    -- Print ticket
    if emeralds > 0 then
        monitor.clear()
        printCentered(monitor, "Printing ticket...", 6)

        local ticketID = math.random(10000000, 99999999)

        rednet.send(serverID, { command = "createTicket", id = ticketID, rides = emeralds }, "subwayAuthority")

        printer.newPage()
        printer.setPageTitle("Subway Ticket")
        printer.write("Subway Ticket - " .. tostring(emeralds) .. " rides")
        printer.setCursorPos(1, 2)
        printer.write(tostring(ticketID))
        printer.endPage()
    end

    sleep(5)
    monitor.clear()
    printCentered(monitor, "Ticket printed!", 6)
    printCentered(monitor, "Thank you!", 7)
    printCentered(monitor, "Please remove ticket.", 9)

    sleep(5)
end
