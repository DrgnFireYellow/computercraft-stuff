-- Change this!
local SYSTEM_NAME = "subway"




local dataFile = fs.open("subwayAuthorityData.txt", "r")

if dataFile then
    data = textutils.unserialize(dataFile.readAll())
    dataFile.close()
end

local function saveData()
    local dataFile = fs.open("subwayAuthorityData.txt", "w")

    dataFile.write(textutils.serialize(data))

    dataFile.close()
end

if data == nil then
    data = { tickets = {} }
    saveData()
end


local function createTicket(id, rides)
    data.tickets[id] = rides
    print("Registered ticket " .. tostring(id) .. " with " .. tostring(rides) .. " rides")
    saveData()
    return true
end

local function useTicket(id)
    if data.tickets[id] ~= nil and data.tickets[id] > 0 then
        data.tickets[id] =  data.tickets[id] - 1
        print("Used ticket " .. tostring(id))
        saveData()
        return true
    end
    return false
end


rednet.open("top")
rednet.host("subwayAuthority", SYSTEM_NAME)

while true do
    local client, message = rednet.receive("subwayAuthority")


    if message.command == "createTicket" then
        rednet.send(client, createTicket(message.id, message.rides), "subwayAuthority")
    elseif message.command == "useTicket" then
        rednet.send(client, useTicket(message.id), "subwayAuthority")
    end
end
