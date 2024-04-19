-- This is eniallator's Remote program.
-- The way it works is by using a command line interface where you can run commands to perform various tasks.
-- The purpose of this program is to be able to control other computers which are running http://pastebin.com/ss0BX2mM (which i have also made).
-- if you don't know what to do there is a help list and you get it by simply typing "help" and that will list all of the available commands that you can run.

version = "1.1.1"
-- Version is used for the updater program i've made here: http://pastebin.com/jSWFQsA1

rednet.open("back")
local mProt = "masterRC"
-- mProt is the protocol the computer will be using. You can also configure what side the wireless modem is on

local logScreen = true
local logFolder = "mRemoteLogs"
-- logScreen is a boolean variable where you can configure if you want the program to log whats displayed on the screen in the command line. The log folder is configurable to any folder of your choice just make sure its not one you are already using!

local typeStartup = "startup "
local typeError = "error   "
local typeInfoMSG = "infoMSG "
local typeReceived = "received"
local typeInput = "input   "
-- The different types of messages as displayed in the log output

local help = {"list - list available computers to connect with","connect - connect to a computer","exit - exit the program","protocol - change the rednet protocol","clear - clear the screen"}
-- The help table

function printMessage(logType, colour, toPrint)
  term.setTextColor(colour)
  print(toPrint)
  log("[" .. logType .. "] " .. toPrint)
end
-- This function handles any printing to the console and also what colour you want the message in

function wordSplit(string)
   local out = {}
   for word in string:gmatch("%S+") do
      table.insert(out, word:lower())
   end
   return out
end
-- This function splits up a string that's passed as an argument into a table at the spaces

function log(logMessage)
  if logScreen then
    if fs.exists(logFolder) and fs.isDir(logFolder) then
      openLogFile = fs.open(logFile,"a")
      openLogFile.writeLine(logMessage)
      openLogFile.close()
    end
  end
end
-- This function handles the logging to the logfile in the logFolder folder

function prefix(write)
  term.setTextColor(colors.yellow)
  term.write(write)
  term.setTextColor(colors.white)
  prefixLog = write
end
-- Makes a prefix where you call functions on the command line

function startUp()
  shell.run("clear")
  printMessage(typeStartup,colors.blue,"Type in a command you want to run or type 'help' for a list of commands.")
end
-- Message displayed when you start up the program

function invalidID()
  printMessage(typeError, colors.red, 'Invalid ID. Type "list" to list computers nearby.')
end
-- This is called when the connect function fails

if logScreen then
  if fs.exists(logFolder) == false then
    fs.makeDir(logFolder)
  end

  if fs.isDir(logFolder) then
    local files = fs.list(logFolder)

    if files[1] == nil then
      logFile = logFolder .. "/log#0"
    else
      logFile = logFolder .. "/log#" .. #files
    end
  end
end
-- Makes log folder if there it is not made already and also makes log file

startUp()
while true do
  local status = {upload = 1,download = 1}
  prefix(": ")
  local input = read()
  local inputTable = wordSplit(input)
  log("[" .. typeInput .. '] "' .. prefixLog .. input .. '"')
  -- Displays the prefix on screen aswell as gets an input using read()

  if inputTable[1] == "help" then
    for l=1,#help do
      if l%2 == 1 then
        printMessage(typeInfoMSG, colors.lightBlue, help[l])
      else
        printMessage(typeInfoMSG, colors.blue, help[l])
      end
    end
    -- Displays the help table

  elseif inputTable[1] == "exit" then
    shell.run("clear")
    break
    -- Exit the program

  elseif inputTable[1] == "clear" then
    shell.run("clear")

  elseif inputTable[1] == "protocol" or inputTable[1] == "prot" then
    if inputTable[2] == nil then
      printMessage(typeInfoMSG,colors.blue,"Type in the new rednet protocol you want to set or leave blank to not set. Current protocol is:")
      printMessage(typeInfoMSG,colors.lightBlue,mProt)
      prefix("protocol: ")
      newProt = read()
    else
      newProt = inputTable[2]
    end
    -- Gets the newProt variable assigned to the user input whether if its in the second argument or gotten from when it prompts you

    log('[' .. typeInput .. '] "' .. prefixLog .. newProt .. '"')

    if newProt == "" then
      printMessage(typeError,colors.red,"Nil is not a valid protocol.")
    else
      printMessage(typeInfoMSG,colors.green,"Updated protocol.")
      mProt = newProt
    end
    -- Change the rednet protocol from the default

  elseif inputTable[1] == "list" or inputTable[1] == "ls" then
    rednet.broadcast("list", mProt)
    printMessage(typeInfoMSG,colors.blue,"id: description")

    while true do
      local sendID, msg = rednet.receive(mProt, 0.1)
      if sendID == nil then break end
      printMessage(typeReceived,colors.green,sendID .. ": " .. msg)

    end
    -- List all the available computers in the area that are running mControl and that aren't already connected

  elseif inputTable[1] == "connect" then
    if inputTable[2] == nil then

      printMessage(typeInfoMSG,colors.blue,"Type in the id of the computer you want to connect with")
      prefix("connect: ")
      computerID = read()
    else

      computerID = inputTable[2]
    end

    log('[' .. typeInput .. '] "' .. prefixLog .. computerID .. '"')
    -- Connect to a computer

    if not tonumber(computerID) or tonumber(computerID) > 65535 then
      invalidID()

    else
      local computerID = tonumber(computerID)
      rednet.send(computerID, "connect", mProt)
      local connectID, msg = rednet.receive(mProt, 0.1)
      -- Trying to connect to computer using computer ID

      if connectID == nil then
        invalidID()
      else

        if msg[1] ~= nil then
          printMessage(typeReceived,colors.green,msg[1])
          status = msg[2]

        else
          printMessage(typeReceived,colors.green,msg)

        end
        -- Displays the message received from computer connecting to. By default this is "Connected!"

        local disconnected = false

        while true do
        if message ~= nil and #message ~= 0 then
          if message[2] == nil then
            prefix(connectID .. ": ")

          else
            prefix(connectID .. "/" .. message[2] .. ": ")

          end
        else
          prefix(connectID .. ": ")

        end
        -- Checks to see if connected computer sent a table, this is for if the connected computer wants to put something in the following prefix then it can

        local command = read()
        local commandTable = wordSplit(command)
        log("[" .. typeInput .. '] "' .. prefixLog .. command .. '"')
        -- Gets a new user input

          if commandTable[1] == "exit" then

            rednet.send(connectID, {"exit"}, mProt)
            _, exitMessage = rednet.receive(mProt, 0.1)

            if exitMessage ~= nil then

              printMessage(typeReceived,colors.green,exitMessage)
              break
            else
            -- if connected computer responds then it will break the while loop that connects with the connected computer.

              printMessage(typeError,colors.red,'No message received. Do you want to forcibly close this connection?')
              printMessage(typeInfoMSG,colors.blue,'Type "Yes" or leave blank to keep the connection.')
              prefix("exit/Force: ")
              answer = read()
              log("[" .. typeInput .. ']"' .. prefixLog .. answer .. '"')
              -- if connected computer does not respond then you can forcibly close the connection by typing "Yes" with or without capitals or leave blank to stay connected

              if  answer:lower() == "yes" or answer:lower() == "y" then

                break
              end
            end
            -- Disconnects from connected computer

          elseif commandTable[1] == "upload" and status.upload == 1 then
            if commandTable[2] ~= nil and commandTable[3] ~= nil then
              if fs.exists(commandTable[2]) == true and fs.isDir(commandTable[2]) == false then

                rednet.send(connectID, commandTable, mProt)
                local _, output = rednet.receive(mProt, 0.1)
                if output == "send" then

                  local fileOpen = fs.open(commandTable[2], 'r')
                  local fileSend = fileOpen.readAll()
                  fileOpen.close()
                  rednet.send(connectID, fileSend, mProt)
                  printMessage(typeReceived,colors.green,"Successfully uploaded file.")
                  -- If everything goes right when using the upload function it will send the file to connected computer
                elseif output == nil then

                  printMessage(typeError,colors.red,"Lost connection.")
                else

                  printMessage(typeReceived,colors.green,output)
                end
              else

                printMessage(typeError,colors.red,"File does not exist on local computer.")
              end
            else

              printMessage(typeError,colors.red,'Invalid syntax. Correct syntax is - "upload [file to upload] [name of file to upload as]"')
            end
            -- Various different error messages in case something went wrong while using the upload function

          elseif commandTable[1] == "download" and status.download == 1 then
            if commandTable[2] ~= nil and commandTable[3] ~= nil then
              if fs.exists(commandTable[3]) == false then

                rednet.send(connectID, commandTable, mProt)
                local _, fileOutput = rednet.receive(mProt, 0.1)

                if fileOutput[1] then

                  fileOpen = fs.open(commandTable[3], "w")
                  fileOpen.write(fileOutput[1])
                  fileOpen.close()
                  printMessage(typeReceived,colors.green,fileOutput[2])
                  -- If everything goes right when using the download function it will receive a file from connected computer
                else

                  printMessage(typeReceived,colors.green,fileOutput)
                end
              else

                printMessage(typeError,colors.red,"File already exists on local computer.")
              end
            else

              printMessage(typeError,colors.red,'Invalid syntax. Correct syntax is - "download [file to download] [file name to download as]"')
            end
            -- Various different error messages in case something went wrong while using the download function

          elseif commandTable[1] == "reconnect" and disconnected then

            rednet.send(connectID, "connect", mProt)
            local _, connectMessage = rednet.receive(mProt,0.1)

            if connectMessage then
              -- If the connected computer replies then this will catch it

              if connectMessage[1] ~= nil then

                printMessage(typeReceived,colors.green,connectMessage[1])
                status = connectMessage[2]
              else

                printMessage(typeReceived,colors.green,connectMessage)
              end
              -- Displaying the connection message

              disconnected = false
            else
              -- If you can't reconnect then this will catch it

              printMessage(typeError, colors.red, "Unable to reconnect.")
            end

          else
            rednet.send(connectID, commandTable, mProt)
            local ID, message = rednet.receive(mProt, 0.1)

            -- Sends command through if anything before hasn't caught it
            if message ~= nil and #message ~= 0 then
              if message[1] == nil then
                printMessage(typeReceived,colors.green,message)

              else
                printMessage(typeReceived,colors.green,message[1])

              end

              disconnected = false
            else
              printMessage(typeError,colors.red,"No message received.")
              disconnected = true

              if commandTable[1] == "help" then

                printMessage(typeInfoMSG,colors.blue,"Available unconnected commands are:")
                printMessage(typeInfoMSG,colors.lightBlue,"reconnect - reconnect to computer if connection has been lost")
                printMessage(typeInfoMSG,colors.blue,"exit - breaks the connection between computers")
              else
                
                printMessage(typeInfoMSG,colors.blue,'Type "help" for options.')
              end
            end
            -- Displays message received from connected computer after command has gone through
          end
        end
      end
    end

  else
    printMessage(typeError,colors.red,'Invalid command. Type "help" for options.')
  end
  -- Before connection occurs this is the default route for anything that's not recognised
end