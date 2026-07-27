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