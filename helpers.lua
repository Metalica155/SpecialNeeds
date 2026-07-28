function FindPlayer(name)
    name = name:lower()

    for player in pairs(WatchedPlayers) do
        if player:lower():find(name, 1, true) then
            return player
        end
    end

    return nil
end

function TestPlayer(name, index)
    if not name or name == "" then
        print("|cffff0000Usage: /ds test <player>|r")
        return
    end

    local player = FindPlayer(name)

    if not player then
        print("Unknown player: " .. name)
        return
    end

    local sounds = WatchedPlayers[player]

    if not sounds then
        print("|cffff0000No sounds configured for " .. player .. ".|r")
        return
    end

    local sound

    if index then
        if index < 1 or index > #sounds then
            print(string.format(
                "%s only has %d sounds.",
                player,
                #sounds
            ))
            return
        end

        sound = sounds[index]
    else
        sound = sounds[math.random(#sounds)]
    end

    print("Playing test sound for " .. player)
    print("sound: " .. sound)

    PlaySoundFile(sound, "Master")
end

function Testing(playerName)
    local players = {}

    if playerName then
        local player = FindPlayer(playerName)

        if not player then
            print("Unknown watched player: " .. playerName)
            return
        end

        table.insert(players, player)
    else
        for player in pairs(WatchedPlayers) do
            table.insert(players, player)
        end

        table.sort(players)
    end

    local delay = 0

    for _, player in ipairs(players) do
        local sounds = WatchedPlayers[player]

        for index = 1, #sounds do
            C_Timer.After(delay, function()
                print(string.format(
                    "|cff00ffff[SpecialNeeds]|r %s (%d/%d)",
                    player,
                    index,
                    #sounds
                ))

                TestPlayer(player, index)
            end)

            delay = delay + 2
        end
    end

    C_Timer.After(delay, function()
        print("|cff00ffff[SpecialNeeds]|r Testing complete.")
    end)
end

function PlaySnSound(index)
    local sound

    index = tonumber(index)

    if not index then
        print("Invalid sound index.")
        return
    end

    if index then
        if index < 1 or index > #SnSounds then
            print(string.format(
                "only has %d sounds. For this index %d no sound is set",
                #SnSounds,
                index
            ))
            return
        end

        sound = SnSounds[index]
    else
        print("no index")
        return
    end

    print("Playing test sound for " .. index)
    print("sound: " .. sound)

    PlaySoundFile(sound, "Master")
end

function IsLeaderOrAssistant(name)
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i

            if UnitName(unit) == name then
                return UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i

            if UnitName(unit) == name then
                return UnitIsGroupLeader(unit)
            end
        end

        if UnitName("player") == name then
            return UnitIsGroupLeader("player")
        end
    end

    return false
end

function BroadcastPlaySound(index)
    local message = string.format("PLAY;%d", index)

    if IsInRaid() then
        SendAddonMessage("SpecialNeeds", message, "RAID")
    elseif IsInGroup() then
        SendAddonMessage("SpecialNeeds", message, "PARTY")
    else
        -- No group, just play locally.
        PlaySnSound(index)
    end
end

function BroadcastPlayDeathSound(path)
    local message = string.format("PLAYSOUND;%s", path)
    SendAddonMessage(
        "SpecialNeeds",
        message,
        IsInRaid() and "RAID" or "PARTY"
    )
end

function BroadcastPlayers(players)
    if #players == 0 then
        print("Usage: /sn broadcast <player> [player] ...")
        return
    end

    for _, name in ipairs(players) do
        local player = FindPlayer(name)

        if player then
            local sounds = WatchedPlayers[player]
            local index = math.random(#sounds)

            local message = string.format(
                "PLAYSOUND;%s",
                sounds[index]
            )

            SendAddonMessage(
                "SpecialNeeds",
                message,
                IsInRaid() and "RAID" or "PARTY"
            )

            print(string.format(
                "[SpecialNeeds] Broadcasting %s (sound %d/%d)",
                player,
                index,
                #sounds
            ))
        else
            print(string.format(
                "[SpecialNeeds] Unknown watched player '%s'",
                name
            ))
        end
    end
end
