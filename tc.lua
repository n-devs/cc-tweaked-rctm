rednet.open("left")

TITLE = {
    '  ##### ## ## ##### ##### ###   #####',
    '  ##### ## ## ##### ##### ###   #####',
    '   ###  ## ## ## ##  ###  ###   ## ##',
    '   ###  ##### ####   ###  ##### #####',
    '   ###  ##### ## ##  ###  ##### #####',
    '',
    '##### ##### #  ## ##### ##### ### #####',
    '##### ##    ## ## ##    ##        ##',
    '##    ####  ##### ####  ##### ### #####',
    '## ## ##    ## ## ##       ## ###    ##',
    '##### ##### ##  # ##### ##### ### #####',
}

-------------------------------------------+

VEIN_MAX = 64
FUEL_BAR = 20
START_FUEL = 640
TRAVEL_FUEL = 1280
TRAVEL_FUEL_MIN = 400
HOUSEKEEP_FREQUENCY = 10

mProt = "masterRC"
pluginFolder = "mControlPlugins"
myFunction = "Default mControl program!"

-------------------------------------------+
MOVE = {
    forward = turtle.forward,
    up      = turtle.up,
    down    = turtle.down,
    back    = turtle.back,
    left    = turtle.turnLeft,
    right   = turtle.turnRight
}

DETECT = {
    forward = turtle.detect,
    up      = turtle.detectUp,
    down    = turtle.detectDown
}

INSPECT = {
    forward = turtle.inspect,
    up      = turtle.inspectUp,
    down    = turtle.inspectDown
}

DIG = {
    forward = turtle.dig,
    up      = turtle.digUp,
    down    = turtle.digDown
}

PLACE = {
    forward = turtle.place,
    up      = turtle.placeUp,
    down    = turtle.placeDown
}

ATTACK = {
    forward = turtle.attack,
    up      = turtle.attackUp,
    down    = turtle.attackDown
}
-------------------------------------------+
VOWELS = {
    'a', 'a', 'a', 'a', 'a',
    'e', 'e', 'e', 'e', 'e', 'e',
    'i', 'i', 'i',
    'o', 'o', 'o',
    'u', 'u',
    'y',
}
CONSONANTS = {
    'b', 'b', 'b', 'b', 'b', 'b', 'b',
    'c', 'c', 'c', 'c', 'c', 'c', 'c',
    'd', 'd', 'd', 'd', 'd',
    'f', 'f', 'f', 'f', 'f',
    'g', 'g', 'g', 'g',
    'h', 'h', 'h',
    'j',
    'k', 'k',
    'l', 'l', 'l', 'l', 'l',
    'm', 'm', 'm', 'm', 'm', 'm', 'm',
    'n', 'n', 'n', 'n', 'n', 'n', 'n',
    'p', 'p', 'p', 'p', 'p',
    'r', 'r', 'r', 'r', 'r', 'r', 'r',
    's', 's', 's', 's', 's', 's', 's', 's', 's',
    't', 't', 't', 't', 't', 't', 't',
    'v',
    'w',
    'x',
    'y',
    'z', 'z', 'z',
}
DOUBLES = {
    'bl', 'br', 'bw',
    'cr', 'cl',
    'dr', 'dw',
    'fr', 'fl', 'fw',
    'gr', 'gl', 'gw', 'gh',
    'kr', 'kl', 'kw',
    'mw',
    'ng',
    'pr', 'pl',
    'qu',
    'sr', 'sl', 'sw', 'st', 'sh',
    'tr', 'tl', 'tw', 'th',
    'vr', 'vl',
    'wr',
}
CONS_DOUB = {}
for _, c in pairs(CONSONANTS) do
    table.insert(CONS_DOUB, c)
end
for _, c in pairs(DOUBLES) do
    table.insert(CONS_DOUB, c)
end
-------------------------------------------+
functions = {
    status = { upload = 1, download = 1, ls = 1, redstone = 1, move = 1, dig = 1, position = 1 },
    helpTable = {
        upload = "upload a file to connected computer",
        download = "download a file from connected computer",
        ls = "list files on connected computer",
        redstone = "control sides of connected computer to emit redstone on",
        move = "move <forward> <number>",
        dig = "dig <number>",
        position = "position status"
    },
    functionTable = {
        help = function()
            rednet.send(connectID, help, mProt)
        end,
        upload = function(item)
            if fs.exists(item[2]) == false then
                rednet.send(connectID, "send", mProt)
                uselessID, downloadedFile = rednet.receive(mProt)
                openFile = fs.open(item[2], 'w')
                openFile.write(downloadedFile)
                openFile.close()
            else
                rednet.send(connectID, "File already exists on connected computer.", mProt)
            end
            -- Handles the upload function
        end,
        download = function(item)
            if fs.exists(item[1]) == true and fs.isDir(item[1]) == false then
                fileOpen = fs.open(item[1], 'r')
                stringSend = fileOpen.readAll()
                fileOpen.close()
                tableSend = { stringSend, "Successfully downloaded file." }
                rednet.send(connectID, tableSend, mProt)
            else
                rednet.send(connectID, "File does not exist on connected computer.", mProt)
            end
            -- Handles the download function
        end,
        ls = function()
            programList = fs.list("")
            files = ""

            for i = 1, #programList do
                if fs.isDir(programList[i]) == false then
                    if files == "" then
                        files = programList[i]
                    else
                        files = files .. ", " .. programList[i]
                    end
                end
            end
            -- Handles the fileList function by sending a list of files (not directories) through

            rednet.send(connectID, files, mProt)
        end,
        redstone = function(item)
            if item[1] == "top" or item[1] == "down" or item[1] == "back" or item[1] == "front" or item[1] == "left" or item[1] == "right" then
                if item[2] == "on" then
                    -- First checks to see if item[1] is a valid side then checks if item[2] is a valid state
                    redstone.setOutput(item[1], true)
                    rednet.send(connectID, "Set output " .. item[1] .. " to " .. item[2], mProt)
                    -- Turns the side in item[1] on
                elseif item[2] == "off" then
                    redstone.setOutput(item[1], false)
                    rednet.send(connectID, "Set output " .. item[1] .. " to " .. item[2], mProt)
                    -- Turns the side in item[1] off
                else
                    rednet.send(connectID, 'Invalid syntax. Use "redstone [side] [on/off]"', mProt)
                end
            else
                rednet.send(connectID, 'Invalid side. Available sides are: top, down, back, front, left, right', mProt)
            end
            -- Error messages to catch every combination
        end,
        move = function(item)
            if (item[1] == "forward") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            elseif (item[1] == "up") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            elseif (item[1] == "down") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            elseif (item[1] == "back") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            elseif (item[1] == "left") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            elseif (item[1] == "right") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                    rednet.send(connectID, "ok! move " .. item[1] .. " block " .. item[i] .. " to block " .. item[2],
                        mProt)
                end
            end
        end,
        dig = function(item)
            for i = 1, item[1] do
                DIG.forward()
                MOVE.forward()
                DIG.up()
                DIG.down()
                rednet.send(connectID, "ok! move dig block " .. item[i] .. " to block " .. item[1], mProt)
            end
        end,
        position = function()
            local expect = dofile("rom/modules/main/cc/expect.lua").expect
            --- The channel which GPS requests and responses are broadcast on.
            CHANNEL_GPS = 65534

            local function trilaterate(A, B, C)
                local a2b = B.vPosition - A.vPosition
                local a2c = C.vPosition - A.vPosition

                if math.abs(a2b:normalize():dot(a2c:normalize())) > 0.999 then
                    return nil
                end

                local d = a2b:length()
                local ex = a2b:normalize()
                local i = ex:dot(a2c)
                local ey = (a2c - ex * i):normalize()
                local j = ey:dot(a2c)
                local ez = ex:cross(ey)

                local r1 = A.nDistance
                local r2 = B.nDistance
                local r3 = C.nDistance

                local x = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
                local y = (r1 * r1 - r3 * r3 - x * x + (x - i) * (x - i) + j * j) / (2 * j)

                local result = A.vPosition + ex * x + ey * y

                local zSquared = r1 * r1 - x * x - y * y
                if zSquared > 0 then
                    local z = math.sqrt(zSquared)
                    local result1 = result + ez * z
                    local result2 = result - ez * z

                    local rounded1, rounded2 = result1:round(0.01), result2:round(0.01)
                    if rounded1.x ~= rounded2.x or rounded1.y ~= rounded2.y or rounded1.z ~= rounded2.z then
                        return rounded1, rounded2
                    else
                        return rounded1
                    end
                end
                return result:round(0.01)
            end

            local function narrow(p1, p2, fix)
                local dist1 = math.abs((p1 - fix.vPosition):length() - fix.nDistance)
                local dist2 = math.abs((p2 - fix.vPosition):length() - fix.nDistance)

                if math.abs(dist1 - dist2) < 0.01 then
                    return p1, p2
                elseif dist1 < dist2 then
                    return p1:round(0.01)
                else
                    return p2:round(0.01)
                end
            end

            --- Tries to retrieve the computer or turtles own location.
            --
            -- @tparam[opt=2] number timeout The maximum time in seconds taken to establish our
            -- position.
            -- @tparam[opt=false] boolean debug Print debugging messages
            -- @treturn[1] number This computer's `x` position.
            -- @treturn[1] number This computer's `y` position.
            -- @treturn[1] number This computer's `z` position.
            -- @treturn[2] nil If the position could not be established.
            function locate(_nTimeout, _bDebug)
                expect(1, _nTimeout, "number", "nil")
                expect(2, _bDebug, "boolean", "nil")
                -- Let command computers use their magic fourth-wall-breaking special abilities
                if commands then
                    return commands.getBlockPosition()
                end

                -- Find a modem
                local sModemSide = nil
                for _, sSide in ipairs(rs.getSides()) do
                    if peripheral.getType(sSide) == "modem" and peripheral.call(sSide, "isWireless") then
                        sModemSide = sSide
                        break
                    end
                end

                if sModemSide == nil then
                    if _bDebug then
                        rednet.send(connectID, "No wireless modem attached", mProt)
                    end
                    return nil
                end

                if _bDebug then
                    rednet.send(connectID, "Finding position...", mProt)
                end

                -- Open GPS channel to listen for ping responses
                local modem = peripheral.wrap(sModemSide)
                local bCloseChannel = false
                if not modem.isOpen(CHANNEL_GPS) then
                    modem.open(CHANNEL_GPS)
                    bCloseChannel = true
                end

                -- Send a ping to listening GPS hosts
                modem.transmit(CHANNEL_GPS, CHANNEL_GPS, "PING")

                -- Wait for the responses
                local tFixes = {}
                local pos1, pos2 = nil, nil
                local timeout = os.startTimer(_nTimeout or 2)
                while true do
                    local e, p1, p2, p3, p4, p5 = os.pullEvent()
                    if e == "modem_message" then
                        -- We received a reply from a modem
                        local sSide, sChannel, sReplyChannel, tMessage, nDistance = p1, p2, p3, p4, p5
                        if sSide == sModemSide and sChannel == CHANNEL_GPS and sReplyChannel == CHANNEL_GPS and nDistance then
                            -- Received the correct message from the correct modem: use it to determine position
                            if type(tMessage) == "table" and #tMessage == 3 and tonumber(tMessage[1]) and tonumber(tMessage[2]) and tonumber(tMessage[3]) then
                                local tFix = {
                                    vPosition = vector.new(tMessage[1], tMessage[2], tMessage[3]),
                                    nDistance =
                                        nDistance
                                }
                                if _bDebug then
                                    rednet.send(connectID, tFix.nDistance .. " metres from " .. tostring(tFix.vPosition),
                                        mProt)
                                end
                                if tFix.nDistance == 0 then
                                    pos1, pos2 = tFix.vPosition, nil
                                else
                                    -- Insert our new position in our table, with a maximum of three items. If this is close to a
                                    -- previous position, replace that instead of inserting.
                                    local insIndex = math.min(3, #tFixes + 1)
                                    for i, older in pairs(tFixes) do
                                        if (older.vPosition - tFix.vPosition):length() < 5 then
                                            insIndex = i
                                            break
                                        end
                                    end
                                    tFixes[insIndex] = tFix

                                    if #tFixes >= 3 then
                                        if not pos1 then
                                            pos1, pos2 = trilaterate(tFixes[1], tFixes[2], tFixes[3])
                                        else
                                            pos1, pos2 = narrow(pos1, pos2, tFixes[3])
                                        end
                                    end
                                end
                                if pos1 and not pos2 then
                                    break
                                end
                            end
                        end
                    elseif e == "timer" then
                        -- We received a timeout
                        local timer = p1
                        if timer == timeout then
                            break
                        end
                    end
                end

                -- Close the channel, if we opened one
                if bCloseChannel then
                    modem.close(CHANNEL_GPS)
                end

                -- Return the response
                if pos1 and pos2 then
                    if _bDebug then
                        rednet.send(connectID, "Ambiguous position", mProt)
                        rednet.send(connectID, "Could be " ..
                            pos1.x ..
                            "," .. pos1.y .. "," .. pos1.z .. " or " .. pos2.x .. "," .. pos2.y .. "," .. pos2.z, mProt)
                    end
                    return nil
                elseif pos1 then
                    if _bDebug then
                        rednet.send(connectID, "Position is " .. pos1.x .. "," .. pos1.y .. "," .. pos1.z, mProt)
                    end
                    return pos1.x, pos1.y, pos1.z
                else
                    if _bDebug then
                        rednet.send(connectID, "Could not determine position", mProt)
                    end
                    return nil
                end
            end

            locate()
        end
    }
}
-------------------------------------------+
-- ============================ Plugin handling below =============================

local args = { ... }

if args[1] then
    pluginFolder = args[1] .. "/" .. pluginFolder
end
-- Seeing if when running the program you have specified a folder in the arguments

tablesToMerge = { "status", "helpTable", "functionTable" }
-- Defining what tables are okay to merge with the plugin's table

function mergeTable(mergeTab, tabName)
    for key, value in pairs(mergeTab) do
        functions[tabName][key:lower()] = value
    end
end

-- Function for merging 2 tables

if not fs.exists(pluginFolder) then
    fs.makeDir(pluginFolder)
end
-- Checking if the plugin folder is a directory yet or not and if its not then it creates it

pluginFiles = fs.list(pluginFolder)

for i = 1, #pluginFiles do
    if not fs.isDir(pluginFolder .. pluginFiles[i]) then
        os.loadAPI(pluginFolder .. "/" .. pluginFiles[i])

        for j = 1, #tablesToMerge do
            if _G[pluginFiles[i]][tablesToMerge[j]] then
                mergeTable(_G[pluginFiles[i]][tablesToMerge[j]], tablesToMerge[j])
            end
        end
    end
end
-- Merging the existing table with the plugin's table

-------------------------------------------+
-- ========================== Help string handling below ==========================

help = "exit - Disconnects from current connected computer\n"

for program, progHelp in pairs(functions.helpTable) do
    if functions.status[program] == 1 then
        help = help .. program .. " - " .. progHelp .. "\n"
    end
end

help = help:sub(1, string.len(help) - 1)
-- Creates the help variable from the programs that are active
-------------------------------------------+
-- ====================== Putting everything together below =======================

function progRunning()
    local terminate = false
    -- Declaring the terminate variable as false

    repeat
        local ID, newMsg = rednet.receive(mProt)
        -- Getting the connected computer's messages

        if ID == sendID and connected then
            -- Checking if the computer that sent the message is the connected computer aswell as seeing if the connected variable is still true

            local newMsgIsWord = newMsg ~= ""
            -- Checking if the incoming message is a word or not

            if newMsgIsWord and newMsg[1]:lower() == "terminate" then
                terminate = true
                rednet.send(ID, "Terminated " .. funcToRun .. ".", mProt)
                -- Seeing if the connected computer has sent "terminate" through and setting the terminate variable to true if they have
            elseif newMsgIsWord and newMsg[1]:lower() == "exit" then
                connected = false
                rednet.send(ID, "Disconnecting from current computer but continuing to run " .. funcToRun .. ".", mProt)
                -- Still executing current function even if connected computer has exitted
            elseif newMsgIsWord and newMsg[1]:lower() == "fuel" and turtle then
                rednet.send(ID, "Fuel level currently at: " .. turtle.getFuelLevel(), mProt)
                -- Sending the current fuel level through to the connected computer
            else
                local sendMessage = "Currently executing " ..
                    funcToRun ..
                    ". Available commands are -\nterminate: terminate current function\nexit: continue to run function but disconnect."
                -- Defining the message variable to send

                if turtle and turtle.getFuelLevel() ~= "unlimited" then
                    sendMessage = sendMessage .. "\nfuel: get the fuel level"
                end
                -- Adding fuel to the help if the connected computer is a turtle

                rednet.send(ID, sendMessage, mProt)
                -- Responding to the user if they send a message
            end
        end
    until terminate
    -- Runs until the terminate variable is true
end

-- Function to respond to the connected computer while the local computer is running a function
function callFunc()
    functions.functionTable[funcToRun](msg, connectID, mProt)
end

-- Function for calling the correct function

-------------------------------------------+



function manualRefuel(desired_level)
    print('Please insert coal...')

    local cursor_x, cursor_y = term.getCursorPos()
    local current_level = turtle.getFuelLevel()
    local slot = 1

    printFuelBar(cursor_y, current_level, desired_level)

    while current_level < desired_level do
        for i = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and item.name == 'minecraft:coal' then
                turtle.select(slot)
                if turtle.refuel(5) then break end
            end
            slot = (slot % 16) + 1
        end

        current_level = turtle.getFuelLevel()
        printFuelBar(cursor_y, current_level, desired_level)
        sleep(0)
    end

    sleep(1)
    print('\nFueling complete.')
end

function printFuelBar(cursor_y, current_level, desired_level)
    term.setCursorPos(1, cursor_y)
    local progress = math.min(math.floor(FUEL_BAR * current_level / desired_level), FUEL_BAR)
    term.write('[')
    for i = 1, progress do
        term.write('+')
    end
    for i = 1, FUEL_BAR - progress do
        term.write('-')
    end
    term.write('] ')
    term.write(tostring(current_level))
    term.write('/')
    term.write(tostring(desired_level))
end

function printTitle()
    for y_offset, line in pairs(TITLE) do
        term.setCursorPos(1, y_offset)
        for char in line:gmatch "." do
            if char == '#' then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
            end
            term.write(' ')
        end
    end
    term.setBackgroundColor(colors.black)
end

function userInit()
    term.clear()
    printTitle()
    print('\n      press return to continue...')
    read()

    term.clear()
    term.setCursorPos(1, 1)
    manualRefuel(START_FUEL)

    sleep(1)
    print('\nTurtle preparation complete.')
    sleep(1)
    print('\nFinal confirmation...')
    sleep(0.5)
    print('Initiate global turtle colonization?')
    term.write('(Y/N) > ')

    if string.upper(read()) ~= 'Y' then
        print('Shutdown...')
        os.shutdown()
        return
    end

    term.clear()
    term.setCursorPos(1, 1)

    print('Beginning...')
    sleep(1)
    for i = 5, 1, -1 do
        print(i)
        sleep(1)
    end

    term.clear()
    term.setCursorPos(1, 1)
end

function genRandName()
    local name = ''
    local count = math.random(3, 6)

    for i = 0, count - 1 do
        if i % 2 == 1 then
            name = name .. VOWELS[math.random(#VOWELS)]
        else
            if (i == count - 1) then
                name = name .. CONSONANTS[math.random(#CONSONANTS)]
            else
                name = name .. CONS_DOUB[math.random(#CONS_DOUB)]
            end
        end
    end

    return string.upper(name:sub(1, 1)) .. name:sub(2, -1)
end

function nameTurtle()
    if not os.getComputerLabel() then
        os.setComputerLabel(genRandName())
    end
end

-------------------------------------------+


-------------------------------------------+

while true do
    sendID, msg = rednet.receive(mProt)

    if msg == "list" then
        rednet.send(sendID, myFunction, mProt)
        -- Will respond to computers that are running list unless running connect
    elseif msg == "connect" then
        rednet.send(sendID, { "Connected!", functions.status }, mProt)
        -- Making the link from the mRemote program to the mControl program

        connected = true
        nameTurtle()
        userInit()
        while connected do
            invalid = true
            connectID, msg = rednet.receive(mProt)
            -- Getting the new message from the connected computer

            if connectID == sendID then
                -- Comparing the connectID with the sendID to see if its the same id so no other computer can send messages
                if msg[1] ~= nil then
                    msg[1] = msg[1]:lower()
                end

                if msg[1] == "exit" then
                    rednet.send(connectID, "Disconnecting from current computer.", mProt)
                    invalid = false
                    connected = false
                    -- Exits the connect cycle so that it will respond to list and for other computers to connect to it
                end

                for key, value in pairs(functions.functionTable) do
                    if key == msg[1] then
                        invalid = false
                        table.remove(msg, 1)
                        funcToRun = key
                        parallel.waitForAny(callFunc, progRunning)
                    end
                end

                if invalid then
                    rednet.send(connectID, 'Invalid command. Type "help" for options.', mProt)
                    -- Default path if msg[1] doesn't get caught by the for loop
                end
            end
        end
    end
end
