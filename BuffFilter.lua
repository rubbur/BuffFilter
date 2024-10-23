-- Initializes the database if it doesn't exist
if not BuffFilterDB then
    BuffFilterDB = {}
end

-- Hides specific auras from the player's buff/debuff bar and reorganizes them
local function hideSpecificBuffs()
    local buffFrames = { BuffFrame.AuraContainer:GetChildren() } -- Get all buff frames
    if #buffFrames == 0 then
        print("|cFFFF0000No buff frames found.|r")
        return
    end

    local visibleCount = 0

    for i = 1, 200 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i)

        if not aura then
            break -- No more auras to check
        end

        -- local name = aura.name -- Name of the buff
        local spellID = aura.spellId

        -- Check if the aura (buff or debuff) is in the filter and hide it
        if BuffFilterDB[spellID] then
            local buff = buffFrames[i]
            if buff then
                buff:Hide()
            end
        else
            visibleCount = visibleCount + 1
            local buff = buffFrames[i]
            if buff then
                buff:SetPoint("TOPLEFT", BuffFrame.AuraContainer, "TOPLEFT", (visibleCount - 1) * 40, 0)
            end
        end
    end
end

-- Adds a spell ID to the filter
local function addBuff(spellId)
    if spellId and tonumber(spellId) then
        BuffFilterDB[tonumber(spellId)] = true
        print("|cFF00FF00Added|r spell ID " .. spellId .. " to the filter.")
        C_Timer.After(1, hideSpecificBuffs)
    else
        print("Invalid spell ID.")
    end
end

-- Removes a spell ID from the filter
local function removeBuff(spellId)
    if spellId and tonumber(spellId) then
        spellId = tonumber(spellId)
        if BuffFilterDB[spellId] then
            BuffFilterDB[spellId] = nil
            print("|cFFFF0000Removed|r spell ID " .. spellId .. " from the filter.")
            C_Timer.After(1, hideSpecificBuffs)
        else
            print("Spell ID " .. spellId .. " not found in the filter.")
        end
    else
        print("Invalid spell ID.")
    end
end

-- Lists all spell IDs currently being filtered
local function listBuffs()
    if next(BuffFilterDB) == nil then
        print("No buffs are being filtered.")
    else
        local count = 1
        print("Filtered Buffs:")
        for spellId in pairs(BuffFilterDB) do
            if spellId and tonumber(spellId) then
                print("|cFFFFFF00" .. count .. "|r - Spell ID: " .. spellId)
                count = count + 1
            end
        end
    end
end

-- Resets the filter database
local function resetBuffFilter()
    BuffFilterDB = {}
    print("|cFF00FF00Buff Filter has been reset.|r")
end

-- Confirmation dialog for resetting the buff filter
StaticPopupDialogs["BUFFFILTER_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset the filter list?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        resetBuffFilter()
        C_Timer.After(1, hideSpecificBuffs)
    end,
    OnCancel = function()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Handles slash commands
local function handleSlashCommands(msg)
    local command, spellID = strsplit(" ", msg, 2)
    if command == "add" then
        addBuff(spellID)
    elseif command == "remove" then
        removeBuff(spellID)
    elseif command == "list" then
        listBuffs()
    elseif command == "reset" then
        StaticPopup_Show("BUFFFILTER_RESET_CONFIRM")
    else
        print("BuffFilter Usage:")
        print("/bf add [SpellID] - Add a buff to hide.")
        print("/bf remove [SpellID] - Remove a buff from the hidden list.")
        print("/bf list - List hidden buffs.")
        print("/bf reset - Reset the filter list.")
    end
end

-- Defines slash commands
SLASH_BUFFFILTER1 = "/bf"
SLASH_BUFFFILTER2 = "/buffs"
SLASH_BUFFFILTER3 = "/bufffilter"
SLASH_BUFFFILTER4 = "/buffsfilter"
SlashCmdList["BUFFFILTER"] = handleSlashCommands

-- Event listener
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterUnitEvent("UNIT_AURA") -- Event == aura applied/removed from player

eventFrame:SetScript("OnEvent", hideSpecificBuffs)

-- TODO: Add a way to filter by buff name
-- TODO: Figure out why the filter only works after one buff is applied/removed
-- TODO: Fix icon positioning when some buffs are hidden
-- TODO: Filter debuffs

-- Delayed manual filter
C_Timer.After(5, hideSpecificBuffs)
