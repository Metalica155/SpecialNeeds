SLASH_DEATHSOUND1 = "/sn"
SLASH_DEATHSOUND2 = "/specialneeds"

local function PrintInfo()
    print("|cff00ffffDeathSound Commands:|r")
    print("/sn status")
    print("/sn enable")
    print("/sn disable")
    print("/sn toggle")
    print("/sn test <player> <?index>")
    print("/sn testing <?player>")
end

SlashCmdList["DEATHSOUND"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        args[#args + 1] = word
    end

    local command = (table.remove(args, 1) or ""):lower()

    if command == "" then
        PrintInfo()
        return
    end

    if command == "status" then
        if SpecialNeedsDB.enabled then
            print("|cff00ff00DeathSound is ENABLED.|r")
        else
            print("|cffff0000DeathSound is DISABLED.|r")
        end

    elseif command == "enable" then
        SpecialNeedsDB.enabled = true
        print("|cff00ff00DeathSound enabled.|r")

    elseif command == "disable" then
        SpecialNeedsDB.enabled = false
        print("|cffff0000DeathSound disabled.|r")

    elseif command == "toggle" then
        SpecialNeedsDB.enabled = not SpecialNeedsDB.enabled

        print("DeathSound is now " ..
            (SpecialNeedsDB.enabled and "|cff00ff00ENABLED|r" or "|cffff0000DISABLED|r"))

    elseif command == "test" then
        TestPlayer(args[1], tonumber(args[2]))

    elseif command == "play" then
        BroadcastPlaySound(args[1])

    elseif command == "testing" then
        Testing(args[1])

    elseif command == "testcast" then
        BroadcastPlayers(args)
    else
        PrintInfo()
    end
end