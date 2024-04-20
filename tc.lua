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

functions = {
    status = { upload = 1, download = 1, ls = 1, redstone = 1, move = 1, dig = 1, position = 1, battery = 1 },
    helpTable = {
        upload = "upload a file to connected computer",
        download = "download a file from connected computer",
        ls = "list files on connected computer",
        redstone = "control sides of connected computer to emit redstone on",
        move = "move <forward> <number>",
        dig = "dig <number>",
        position = "position status",
        battery = "battery status"
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
                end
            elseif (item[1] == "up") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                end
            elseif (item[1] == "down") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                end
            elseif (item[1] == "back") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                end
            elseif (item[1] == "left") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                end
            elseif (item[1] == "right") then
                for i = 1, item[2] do
                    MOVE[item[1]]()
                end
            end
        end,
        dig = function(item)
            for i = 1, item[1] do
                DIG.forward()
                MOVE.forward()
                DIG.up()
                DIG.down()
            end
        end,
        position = function()
            shell.run("gps", "locale")
        end,
        battery = function()
            manualRefuel(START_FUEL)
        end
    }
}
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

function nameTurtle()
    if not os.getComputerLabel() then
        os.setComputerLabel(genRandName())
    end
end

function start()
    rednet.open("left")

    nameTurtle()
    userInit()
    while true do
        sendID, msg = rednet.receive(mProt)

        if msg == "list" then
            rednet.send(sendID, myFunction, mProt)
            -- Will respond to computers that are running list unless running connect
        elseif msg == "connect" then
            rednet.send(sendID, { "Connected!", functions.status }, mProt)
            -- Making the link from the mRemote program to the mControl program

            connected = true

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
end

-------------------------------------------+


-------------------------------------------+
start()
