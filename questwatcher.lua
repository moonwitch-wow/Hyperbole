-- ------------------------------------------------------------------------
-- -- Config
-- ------------------------------------------------------------------------
-- local font = [[STANDARD_TEXT_FONT]]
-- local fontSize = 8
-- local texture = [[Interface\ChatFrame\ChatFrameBackground]]
-- local backdrop = {
--   bgFile = texture, edgeFile = texture, edgeSize = 1,
-- }

-- -- WATCHFRAME_LINEHEIGHT = 16 -- line height, per line (1 line is 1 item)
-- -- WATCHFRAME_TYPE_OFFSET = 2
-- -- WATCHFRAME_MULTIPLE_LINEHEIGHT = 20

-- WATCHFRAME_INITIAL_OFFSET = 2 -- Y-axis between first quest in the questwatcher
-- -- WATCHFRAME_TYPE_OFFSET = 0
-- -- WATCHFRAME_QUEST_OFFSET = 5 -- space between quests, Y-axis, needs to be pos

-- -- WATCHFRAMELINES_FONTSPACING = -1 -- space between the items of a quest, Y-axis, needs to be neg
-- -- WATCHFRAMELINES_FONTHEIGHT = 10 -- no apparent function

-- ------------------------------------------------------------------------
-- -- Font styling function
-- ------------------------------------------------------------------------
-- local function SetFontStyle( textString )
--   textString:SetFont(font, fontSize, 'MONOCHROMEOUTLINE')
--   textString:SetShadowColor(0, 0, 0, .9)
--   textString:SetShadowOffset(1, -1)
-- end

-- ------------------------------------------------------------------------
-- -- Setting the width of things
-- ------------------------------------------------------------------------
-- hooksecurefunc("ObjectiveTrackerFrame_SetWidth", function(width)
--   WATCHFRAME_EXPANDEDWIDTH = 225
--   WATCHFRAME_MAXLINEWIDTH = 215
--   if ObjectiveTrackerFrame:IsShown() and not ObjectiveTrackerFrame.collapsed then
--     ObjectiveTrackerFrame:SetWidth(WATCHFRAME_EXPANDEDWIDTH)
--     ObjectiveTrackerFrame_Update()
--   end
-- end)

-- ------------------------------------------------------------------------
-- -- Skin the Quest Buttons : Thanks to Phanx' code it got shorter!
-- ------------------------------------------------------------------------
-- hooksecurefunc("QuestObjectiveItem_UpdateCooldown", function(button)
--   if(string.match(button:GetName(), 'ObjectiveTrackerFrameItem%d+') and not button.skinned) then
--     button:SetSize(26, 26)
--     button:SetBackdrop(backdrop)
--     button:SetBackdropColor(0, 0, 0)
--     button:SetBackdropBorderColor(0, 0, 0)

--     local icon = _G[button:GetName() .. 'IconTexture']
--     icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

--     _G[button:GetName() .. 'NormalTexture']:SetTexture("")

--     button.skinned = true
--   end
-- end)

-- ------------------------------------------------------------------------
-- -- Add square or hide if there's a Dash
-- -- From Mythology/nibWatcherFrameAdv
-- ------------------------------------------------------------------------
-- hooksecurefunc("ObjectiveTrackerFrame_SetLine", function(line, _, _, isHeader, text, hasDash, _, _, eligible)
--   line.hasDash = hasDash == 1
--   if(line.hasDash and line.square) then
--     line.square:Show()
--   elseif(line.square) then
--     line.square:Hide()
--   end
-- end)

-- ------------------------------------------------------------------------
-- -- Function to colorize the quests and provide level for later on
-- ------------------------------------------------------------------------
-- local tags = {
--   Dungeon = 'D',
--   Elite = '+',
--   Group = 'G',
--   Heroic = 'H',
--   PVP = 'PvP',
--   Raid = 'R',
--   Scenario = 'Sc',
--   Legendary = 'L',
--   ["Raid (10)"] = "R10",
--   ["Raid (25)"] = "R25",
--   Daily = "•",
--   Repeatable = "Rep"
-- }

-- local function GetQuestData(self)
--   if(self.type == 'QUEST') then
--     local questIndex = GetQuestIndexForWatch(self.index)
--     local numEntries = GetNumQuestLogEntries()
--     if (questIndex) then
--       local titleText, level, questTag, groupSize, isHeader, _, isComplete, isDaily, questID = GetQuestLogTitle(questIndex)
--       if (isDaily) then
--         return 15/255, 215/255, 215/255, level..'•'
--       elseif (questTag) and (level) then
--         local color = GetQuestDifficultyColor(level)
--         return color.r, color.g, color.b, level..tags[questTag]
--       elseif (level) then
--         local color = GetQuestDifficultyColor(level)
--         return color.r, color.g, color.b, level
--       end
--     end
--   end

--   return 0.85, 0.45, 0
-- end

-- ------------------------------------------------------------------------
-- -- Is the quest being tracked on the map?
-- ------------------------------------------------------------------------
-- local function IsSuperTracked(self)
--   if(self.type ~= 'QUEST') then return end

--   local questIndex = GetQuestIndexForWatch(self.index)
--   if(questIndex) then
--     local _, _, _, _, _, _, _, _, id = GetQuestLogTitle(questIndex)
--     if(id and GetSuperTrackedQuestID() == id) then
--       return true
--     end
--   end
-- end

-- ------------------------------------------------------------------------
-- -- Colorize the square
-- ------------------------------------------------------------------------
-- local function HighlightLine(self, highlight)
--   for index = self.startLine, self.lastLine do
--     local line = self.lines[index]
--     if(line) then
--       if(index == self.startLine) then
--         local r, g, b, prefix = GetQuestData(self)
--         local text = line.text:GetText()
--         if(text and string.sub(text, -1) ~= '\032' and prefix) then
--           line.text:SetFormattedText('[%s] %s\032', prefix, text) -- adding the [xx] in front
--         end

--         if(highlight) then
--           line.text:SetTextColor(r, g, b)
--         else
--           line.text:SetTextColor(r * 6/7, g * 6/7, b * 6/7)
--         end
--       else
--         if(highlight) then
--           line.text:SetTextColor(6/7, 6/7, 6/7)

--           if(line.square) then
--             line.square:SetBackdropColor(1/5, 1/2, 4/5)
--           end
--         else
--           line.text:SetTextColor(5/7, 5/7, 5/7)

--           if(line.square) then
--             if(IsSuperTracked(self)) then
--               line.square:SetBackdropColor(5/7, 1/5, 1/5)
--             else
--               line.square:SetBackdropColor(4/5, 4/5, 1/5)
--             end
--           end
--         end
--       end
--     end
--   end
-- end

-- ------------------------------------------------------------------------
-- -- Actual skinning of quests (also creating squares)
-- ------------------------------------------------------------------------
-- local nextLine = 1
-- local function SkinLine()
--   for index = nextLine, 50 do
--     local line = _G['ObjectiveTrackerFrameLine' .. index]
--     if(line) then
--       SetFontStyle(line.text)
--       line.dash:SetAlpha(0)

--       local square = CreateFrame('Frame', nil, line)
--       square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 6, -6)
--       square:SetSize(6, 6)
--       square:SetBackdrop(backdrop)
--       square:SetBackdropColor(4/5, 4/5, 1/5)
--       square:SetBackdropBorderColor(0, 0, 0)
--       line.square = square

--       if(line.hasDash) then
--         square:Show()
--       else
--         square:Hide()
--       end
--     else
--       nextLine = index
--       break
--     end
--   end

--   for index = 1, #WATCHFRAME_LINKBUTTONS do
--     HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
--   end
-- end

-- local nextScenarioLine = 1
-- local function SkinScenarioLine()
--   for index = nextScenarioLine, 50 do
--     local line = _G['ObjectiveTrackerFrameScenarioLine' .. index]
--     if(line) then
--       SetFontStyle(line.text)

--       local square = CreateFrame('Frame', nil, line)
--       square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 6, -6)
--       square:SetSize(6, 6)
--       square:SetBackdrop(backdrop)
--       square:SetBackdropColor(4/5, 4/5, 1/5)
--       square:SetBackdropBorderColor(0, 0, 0)
--       line.square = square

--       line.icon:Hide()
--     else
--       nextScenarioLine = index
--       break
--     end
--   end

--   local _, _, numCriteria = C_Scenario.GetStepInfo()
--   for index = 1, numCriteria do
--     local text, _, completed = C_Scenario.GetCriteriaInfo(index)
--     for lineIndex = 1, nextScenarioLine do
--       local line = _G['ObjectiveTrackerFrameScenarioLine' .. lineIndex]
--       if(line and string.find(line.text:GetText(), text)) then
--         if(completed) then
--           line.square:SetBackdropColor(0, 1, 0)
--         else
--           line.square:SetBackdropColor(4/5, 4/5, 4/5)
--         end
--       end
--     end
--   end
-- end

-- ------------------------------------------------------------------------
-- -- Modifying the click track behavior
-- -- Taken from Mythology
-- ------------------------------------------------------------------------
-- local origClick
-- local function ClickLine(self, button, ...)
--   if(button == 'RightButton' and not IsShiftKeyDown() and self.type == 'QUEST') then
--     local _, _, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
--     QuestPOI_SelectButtonByQuestId('ObjectiveTrackerFrameLines', questID, true)

--     if(WorldMapFrame:IsShown()) then
--       WorldMapFrame_SelectQuestById(questID)
--     end

--     SetSuperTrackedQuestID(questID)

--     for index = 1, #WATCHFRAME_LINKBUTTONS do
--       if(index ~= self.index) then
--         HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
--       end
--     end
--   else
--     origClick(self, button, ...)
--   end
-- end

-- ------------------------------------------------------------------------
-- -- Removing the circled ?
-- ------------------------------------------------------------------------
-- hooksecurefunc('QuestPOI_DisplayButton', function(name, type, index)
--   if(name == 'ObjectiveTrackerFrameLines') then
--     _G['poi' .. name .. type .. '_' .. index]:Hide()
--   end
-- end)

-- local function null() end

-- ------------------------------------------------------------------------
-- -- The actual Setup
-- ------------------------------------------------------------------------
-- local Handler = CreateFrame('Frame')
-- Handler:RegisterEvent('PLAYER_LOGIN')
-- Handler:SetScript('OnEvent', function(self, event)
--   hooksecurefunc('ObjectiveTrackerFrame_Update', SkinLine)
--   hooksecurefunc('ObjectiveTrackerFrameScenario_UpdateScenario', SkinScenarioLine)

--   -----------------------------
--   -- Click behavior
--   origClick = ObjectiveTrackerFrameLinkButtonTemplate_OnClick
--   ObjectiveTrackerFrameLinkButtonTemplate_OnClick = ClickLine
--   ObjectiveTrackerFrameLinkButtonTemplate_Highlight = HighlightLine

  -----------------------------
  -- -- Positioning
  -- ObjectiveTrackerFrame:ClearAllPoints()
  -- ObjectiveTrackerFrame:SetPoint('TOPLEFT', 15, -10)
  -- ObjectiveTrackerFrame:SetHeight(UIParent:GetHeight() - 300)

  -- ObjectiveTrackerFrame.SetPoint = null
  -- ObjectiveTrackerFrame.ClearAllPoints = null

--   -----------------------------
--   -- Changing the header
--   SetFontStyle(ObjectiveTrackerFrameTitle)
--   SetFontStyle(ObjectiveTrackerFrameScenarioFrame.ScrollChild.TextHeader.text)
--   ObjectiveTrackerFrameScenarioFrame.ScrollChild.TextHeader.text:SetTextColor(0.85, 0.85, 0)

--   -----------------------------
--   -- Skinning the button
--   ObjectiveTrackerFrameCollapseExpandButton:SetNormalTexture([[Interface\AddOns\Hyperbole\UI-Panel-QuestHideButton]])
--   ObjectiveTrackerFrameCollapseExpandButton:SetPushedTexture([[Interface\AddOns\Hyperbole\UI-Panel-QuestHideButton]])


--   SkinScenarioLine()

--   WorldMapPlayerUpper:EnableMouse(false)
--   WorldMapPlayerLower:EnableMouse(false)
-- end)