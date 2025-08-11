-- Debug print
print("PvP Callouts: Addon file is loading...")

-- Create main frame
local frame = CreateFrame("Frame", "PvPCalloutsFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(200, 400)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Title
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
frame.title:SetText("PvP Callouts")

-- Battleground-specific callouts
local bgCallouts = {
    -- Arathi Basin
    ["Arathi Basin"] = {
        "INC STABLES",
        "INC LUMBER", 
        "INC BLACKSMITH",
        "INC GOLD MINE",
        "INC FARM",
        "STABLES CLEAR",
        "LUMBER CLEAR",
        "BLACKSMITH CLEAR",
        "GOLD MINE CLEAR",
        "FARM CLEAR"
    },
	-- Deepwind Gorge
	["Deepwind Gorge"] = {
    		"INC MARKET",
    		"INC SHRINE",
    		"INC QUARRY",
    		"INC RUINS",
    		"INC FARM",
    		"MARKET CLEAR",
    		"SHRINE CLEAR",
    		"QUARRY CLEAR",
    		"RUINS CLEAR",
    		"FARM CLEAR"
	},
    
    -- Warsong Gulch
    ["Warsong Gulch"] = {
        "INC BASE",
        "EFC HAS FLAG",
        "FC NEEDS ESCORT",
        "FC AT TUNNEL",
        "FC AT ROOF", 
        "FC AT RAMP",
        "RETURN FLAG",
        "GET ON EFC",
        "FC DOWN MID",
        "CLEAR ROOF",
        "TURTLE TIME"
    },
    
    -- Eye of the Storm
    ["Eye of the Storm"] = {
        "INC DRAENEI",
        "INC FEL REAVER",
        "INC BLOOD ELF",
        "INC MAGE TOWER",
        "TAKE FLAG"
    },
    
    
    -- Battle for Gilneas
    ["The Battle for Gilneas"] = {
        "INC WATERWORKS",
        "INC LIGHTHOUSE",
        "INC MINES",
        "WW CLEAR",
        "LH CLEAR",
        "MINES CLEAR"
    },
    
    
    -- Generic/Unknown BG
    ["Default"] = {
        "INCOMING 3+",
        "INCOMING 5+", 
        "HELP NEEDED",
        "AREA CLEAR",
        "PUSH NOW",
        "FALL BACK",
        "GROUP UP",
        "SPLIT UP",
        "FOCUS HEALER",
        "CC CASTER"
    }
}

-- Store current buttons
local currentButtons = {}

-- Function to clear existing buttons
local function ClearButtons()
    for i, button in ipairs(currentButtons) do
        button:Hide()
        button:SetParent(nil)
    end
    currentButtons = {}
end

-- Function to create buttons for current BG
local function CreateButtonsForBG(callouts)
    ClearButtons()
    
    local buttonHeight = 22
    local buttonSpacing = 2
    
    for i, callout in ipairs(callouts) do
        local button = CreateFrame("Button", "PvPCallout"..i, frame, "UIPanelButtonTemplate")
        button:SetSize(170, buttonHeight)
        button:SetPoint("TOP", frame, "TOP", 0, -35 - (i-1) * (buttonHeight + buttonSpacing))
        button:SetText(callout)
        
        -- Click handler
        button:SetScript("OnClick", function()
            -- Send to instance/battleground chat
            if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                SendChatMessage(callout, "INSTANCE_CHAT")
            elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
                SendChatMessage(callout, "PARTY") 
            else
                SendChatMessage(callout, "YELL")
            end
            
            -- Visual feedback
            local originalText = callout
            button:SetText("SENT!")
            C_Timer.After(0.5, function()
                button:SetText(originalText)
            end)
        end)
        
        currentButtons[i] = button
    end
    
    -- Resize frame based on number of buttons
    local frameHeight = math.max(100, 70 + #callouts * (buttonHeight + buttonSpacing))
    frame:SetHeight(frameHeight)
end

-- Function to detect current battleground
local function GetCurrentBattleground()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return "Default" end
    
    local mapInfo = C_Map.GetMapInfo(mapID)
    if not mapInfo then return "Default" end
    
    local mapName = mapInfo.name
    
    -- Return the battleground name if we have callouts for it
    if bgCallouts[mapName] then
        return mapName
    else
        return "Default"
    end
end

-- Function to update callouts based on current BG
local function UpdateCallouts()
    local currentBG = GetCurrentBattleground()
    local callouts = bgCallouts[currentBG] or bgCallouts["Default"]
    
    frame.title:SetText("PvP Callouts - " .. currentBG)
    CreateButtonsForBG(callouts)
    
    print("PvP Callouts: Updated for " .. currentBG .. " (" .. #callouts .. " callouts)")
end

-- Event handling for zone changes
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    C_Timer.After(1, UpdateCallouts) -- Small delay to ensure map data is loaded
end)

-- Slash commands
SLASH_PVPCALLOUTS1 = "/pvpcallouts"
SLASH_PVPCALLOUTS2 = "/pco"
SlashCmdList["PVPCALLOUTS"] = function(msg)
    if msg == "update" then
        UpdateCallouts()
    elseif frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Initialize
frame:Hide() -- Start hidden, show when in BG
UpdateCallouts()

print("PvP Callouts addon loaded! Use /pvpcallouts or /pco to toggle. Use /pco update to refresh.")