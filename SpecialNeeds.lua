local frame = CreateFrame("Frame")
local watchedPlayersInGroup = 0

SpecialNeedsDB = SpecialNeedsDB or {}
SpecialNeedsDB.enabled = SpecialNeedsDB.enabled ~= false

RegisterAddonMessagePrefix("SpecialNeeds")

local function CountWatchedPlayersInGroup()
    local count = 0

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)

            if WatchedPlayers[name] then
                count = count + 1
            end
        end
    else
        -- Include yourself
        local player = UnitName("player")
        if WatchedPlayers[player] then
            count = count + 1
        end

        -- Party members
        for i = 1, GetNumSubgroupMembers() do
            local name = UnitName("party" .. i)

            if WatchedPlayers[name] then
                count = count + 1
            end
        end
    end

    return count
end

local function UpdateWatchedPlayersInGroup()
    watchedPlayersInGroup = CountWatchedPlayersInGroup()
end

local function playTheSong(fileName)
    if SpecialNeedsDB.enabled then
        PlaySoundFile(fileName, "master")
    end
end

frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("CHAT_MSG_ADDON")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        UpdateWatchedPlayersInGroup()
        return
    end

    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...

        if prefix ~= "SpecialNeeds" then
            return
        end

        local senderName = sender:match("^[^-]+")

        if not IsLeaderOrAssistant(senderName) then
            print("not lead skipping")
            return
        end

        local command, index = strsplit(";", message)

        if command == "PLAY" then
            PlaySnSound(index)
        end

        return
    end

    local timestamp,
          subEvent,
          hideCaster,
          sourceGUID,
          sourceName,
          sourceFlags,
          sourceRaidFlags,
          destGUID,
          destName,
          destFlags,
          spellId,
          spellName,
          destRaidFlags = ...

    if subEvent == "SPELL_CAST_SUCCESS" then
        if WatchedSpells[spellName] then
            playTheSong(WatchedSpells[spellName])
        end
    end

    if subEvent ~= "UNIT_DIED" then
        return
    end

    if not destName then
        return
    end

    if watchedPlayersInGroup < 2 then
        return
    end

    -- Remove realm name if present
    local player = strsplit("-", destName)

    local sounds = WatchedPlayers[player]

    if WatchedPlayers[player] then
        local sound = sounds[random(#sounds)]
        playTheSong(sound)
    end
end)

