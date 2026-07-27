local watchedPlayers = {
    ["Judokick"] = "Interface\\AddOns\\SpecialNeeds\\audio\\ack.mp3",
    ["Prosztakuksi"] = "Interface\\AddOns\\SpecialNeeds\\audio\\fahhhhhhhhhhhhhh.mp3",
    ["Renaldoh"] = "Interface\\AddOns\\SpecialNeeds\\audio\\fahhhhhhhhhhhhhh.mp3",
    ["Plaguebeard"] = "Interface\\AddOns\\SpecialNeeds\\audio\\d-meghal-jobban.mp3",
    ["Rezestóni"] = "Interface\\AddOns\\SpecialNeeds\\audio\\d-meghal-jobban.mp3",
    ["Messacree"] = "Interface\\AddOns\\SpecialNeeds\\audio\\d-meghal-jobban.mp3",
    ["Birdlady"] = "Interface\\AddOns\\SpecialNeeds\\audio\\d-meghal-jobban.mp3",
    ["Itacho"] = "Interface\\AddOns\\SpecialNeeds\\audio\\d-meghal-jobban.mp3",
}

local frame = CreateFrame("Frame")
--local SOUND_COOLDOWN = 1.5
--local lastSoundTime = 0

local function IsPlayerInGroup(playerName)
    local numMembers = GetNumGroupMembers()

    if IsInRaid() then
        for i = 1, numMembers do
            local name = GetRaidRosterInfo(i)
            if name == playerName then
                return true
            end
        end
    else
        if UnitName("player") == playerName then
            return true
        end

        for i = 1, GetNumSubgroupMembers() do
            if UnitName("party"..i) == playerName then
                return true
            end
        end
    end

    return false
end

--local function PlayPlayerSound(sound)
--    local now = GetTime()
--
--    if now - lastSoundTime < SOUND_COOLDOWN then
--        return
--    end
--
--    lastSoundTime = now
--    PlaySoundFile(sound, "Master")
--end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function(self, event, ...)

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
          destRaidFlags = ...

    print(subEvent, destName)

    if subEvent ~= "UNIT_DIED" then
        return
    end

    if not destName then
        return
    end

    if IsPlayerInGroup(destName) == false then
        return
    end

    -- Remove realm name if present
    local player = strsplit("-", destName)

    local sound = watchedPlayers[player]

    if watchedPlayers[player] then
        PlaySoundFile(sound, "Master")
        --PlayPlayerSound(sound)
    end
end)

