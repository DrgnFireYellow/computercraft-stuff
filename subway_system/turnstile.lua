-- Created by DrgnFireYellow
-- This program is licensed under the GNU General Public License V3 and is provided with no warranty.

-- Change this to match your server!
local SYSTEM_NAME = "subway"




local function printCentered(monitor, text)
    local width, height = monitor.getSize()
    monitor.setCursorPos(math.floor((width-#text)/2) + 1, math.ceil(height/2))
    monitor.write(text)
end

local monitor = peripheral.wrap("top")
local reader = peripheral.wrap("bottom")
local gate_relay = peripheral.find("redstone_relay")

peripheral.find("modem", rednet.open)
local serverID = rednet.lookup("subwayAuthority", SYSTEM_NAME)


while true do
    monitor.setBackgroundColor(colors.lightBlue)
    monitor.clear()
    printCentered(monitor, "READY")

    turtle.suck()
    sleep(0.5)

    local item = turtle.getItemDetail()
    
    if item ~= nil then
        if item.name ~= "computercraft:printed_page" then
            turtle.drop()
    
        else
            local ticketID = tonumber(reader.getBlockData().Items[1].tag.Text1)
            turtle.drop()

            rednet.send(serverID, { command = "useTicket", id = ticketID }, "subwayAuthority")
            local _, response = rednet.receive("subwayAuthority")

            if response then
                monitor.setBackgroundColor(colors.lime)
                
                monitor.clear()
                printCentered(monitor, "GO")
                gate_relay.setOutput("front", true)

                sleep(5)

                gate_relay.setOutput("front", false)

            else
                monitor.setBackgroundColor(colors.red)

                monitor.clear()
                printCentered(monitor, "DENIED")
                sleep(3)
            end
        end
    end
end
