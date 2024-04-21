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

VEIN_MAX = 64
FUEL_BAR = 20
START_FUEL = 640
TRAVEL_FUEL = 1280
TRAVEL_FUEL_MIN = 400
HOUSEKEEP_FREQUENCY = 10

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

function manualRefuel(desired_level)
    print('Please insert coal...')

    local cursor_x, cursor_y = term.getCursorPos()
    local current_level = turtle.getFuelLevel()
    local slot = 1

    printFuelBar(cursor_y, current_level, desired_level)

    while current_level < desired_level do
        for i = 1, 16 do
            local arg = turtle.getargDetail(slot)
            if arg and arg.name == 'minecraft:coal' or arg.name == "minecraft:charcoal" then
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

function userInit()
    term.clear()
    term.setCursorPos(1, 1)
    manualRefuel(START_FUEL)

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

local programName = arg[0] or fs.getName(shell.getRunningProgram())
if (programName == "dig" or programName == fs.getName(shell.getRunningProgram())) then
    userInit()
    if (arg[1] == "f") then
        for i = 1, arg[2] do
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()
        end
    elseif (arg[1] == "d") then
        for i = 1, arg[2] do
            turtle.digDown()
            turtle.down()
        end
    elseif (arg[1] == "u") then
        for i = 1, arg[2] do
            turtle.digUp()
            turtle.up()
        end
    elseif (arg[1] == "f_3x3") then
        for i = 1, arg[2] do
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.left()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()

            turtle.right()
            turtle.right()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()

            turtle.left()
        end
    elseif (arg[1] == "f_3x5") then
        for i = 1, arg[2] do
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.left()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()
            turtle.back()

            turtle.right()
            turtle.right()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()
            turtle.back()

            turtle.left()
        end
    elseif (arg[1] == "fu_3x3") then
        for i = 1, arg[2] do
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.left()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()

            turtle.right()
            turtle.right()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.up()
            turtle.digUp()

            turtle.back()
            turtle.digUp()

            turtle.back()
            turtle.digUp()

            turtle.forward()
            turtle.left()
        end
    elseif (arg[1] == "fd_3x3") then
        for i = 1, arg[2] do
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.left()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.back()

            turtle.right()
            turtle.right()

            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()

            turtle.down()
            turtle.digDown()

            turtle.back()
            turtle.digDown()

            turtle.back()
            turtle.digDown()

            turtle.forward()
            turtle.left()
        end
    end
end
