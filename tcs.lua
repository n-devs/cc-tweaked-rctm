-- This is eniallator's Control program.
-- It works by trying to run commands sent by the remote computer.
-- The remote program (the program that can run this) is http://pastebin.com/MY9HDL52 and runs like a command line.
--
-- ================================================================================
--
-- An on going project that im still working on.
--
-- ================================================================================
--
-- This program can use plugins!
-- The reason i have made it able to use plugins is so that you can easily install multiple function packs/functions by simply downloading the pastebin into the plugin folder
-- To create a plugin, follow the plugin template guide here: http://pastebin.com/YmmnaqXP
--
-- ================================================================================
--
-- To create a new function in this file do the following steps.
-- In the helpTable table put the following value.
--
-- *insert your function name here* = "*insert your function's help here*"
--
-- To make your function just add a new key/value to the functionTable on line 66 where the key is how you are going to call your function in the remote command line. For example inputting "testFunc arg1 arg2" would call the function testfunc from the functionTable and in the function argument it would then pass the following arguments: ({"arg1","arg2"},*ID of remote computer thats connected*,*protocol thats being used*).
--
-- If you want to send an output to the remote program from your function then use the following rednet code:
--
-- rednet.send(connectID, "*insert string you want to send here*", mProt)
--
-- If you would like to modify the prefix of the remote's command line then instead of sending a string through to the remote, send the following table:
--
-- {"*insert output you want to send here*","*insert prefix you want to send here*"}
--
-- If you want people to be able to turn on/off your function then do the following step.
--
-- *insert your function name here* = 1
--
-- The program will automatically detect if theres a status key/value for your function so thats all you need to do.

version = "1.20.4"
-- Version is used for the updater program i've made here: http://pastebin.com/jSWFQsA1

mProt = "masterRC"
rednet.open("left")
-- mProt is the protocol the computer will be using. You can also configure what side the wireless modem is on

pluginFolder = "mControlPlugins"
-- Where the plugins for the program are read from. Plugins are easily installable functions for the control program

myFunction = "Default mControl program!"
-- Called when the remote computer lists available computers it can connect with

-- ======================= Default function declaring below =======================

functions = {

status = {upload = 1, download = 1, filelist = 1, redstone = 1},
-- Easily configure which programs you want running and which ones you don't by simply setting 1 for those you want running and 0 for those you don't want running.

helpTable = {
  upload = "upload a file to connected computer",
  download = "download a file from connected computer",
  filelist = "list files on connected computer",
  redstone = "control sides of connected computer to emit redstone on"
},
-- Default help messages for each program

functionTable = {

help = function()

  rednet.send(connectID,help,mProt)
end,

upload = function (item)
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

download = function (item)
  if fs.exists(item[1]) == true and fs.isDir(item[1]) == false then

    fileOpen = fs.open(item[1], 'r')
    stringSend = fileOpen.readAll()
    fileOpen.close()
    tableSend = {stringSend, "Successfully downloaded file."}
    rednet.send(connectID, tableSend, mProt)
  else

    rednet.send(connectID, "File does not exist on connected computer.", mProt)
  end
  -- Handles the download function
end,

filelist = function ()

  programList = fs.list("")
  files = ""

  for i=1,#programList do
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
end
}
}

-- ============================ Plugin handling below =============================

local args = { ... }

if args[1] then

pluginFolder = args[1] .. "/" .. pluginFolder
end
-- Seeing if when running the program you have specified a folder in the arguments

tablesToMerge = {"status", "helpTable", "functionTable"}
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

for i=1,#pluginFiles do
if not fs.isDir(pluginFolder .. pluginFiles[i]) then

  os.loadAPI(pluginFolder .. "/" .. pluginFiles[i])

  for j=1,#tablesToMerge do
    if _G[pluginFiles[i]][tablesToMerge[j]] then

      mergeTable(_G[pluginFiles[i]][tablesToMerge[j]], tablesToMerge[j])
    end
  end
end
end
-- Merging the existing table with the plugin's table

-- ========================== Help string handling below ==========================

help = "exit - Disconnects from current connected computer\n"

for program, progHelp in pairs(functions.helpTable) do
if functions.status[program] == 1 then
  help = help .. program .. " - " .. progHelp .. "\n"
end
end

help = help:sub(1,string.len(help) - 1)
-- Creates the help variable from the programs that are active

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

      local sendMessage = "Currently executing " .. funcToRun .. ". Available commands are -\nterminate: terminate current function\nexit: continue to run function but disconnect."
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

while true do
sendID, msg = rednet.receive(mProt)

  if msg == "list" then
    rednet.send(sendID, myFunction, mProt)
    -- Will respond to computers that are running list unless running connect

  elseif msg == "connect" then
    rednet.send(sendID, {"Connected!",functions.status}, mProt)
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

          rednet.send(connectID,"Disconnecting from current computer.",mProt)
          invalid = false
          connected = false
          -- Exits the connect cycle so that it will respond to list and for other computers to connect to it
        end

        for key,value in pairs(functions.functionTable) do
          if key == msg[1] then

            invalid = false
            table.remove(msg,1)
            funcToRun = key
            parallel.waitForAny(callFunc,progRunning)
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