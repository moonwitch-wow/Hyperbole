------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------
local font = [[STANDARD_TEXT_FONT]]
local texture = [[Interface\ChatFrame\ChatFrameBackground]]
local backdrop = {
  bgFile = texture, edgeFile = texture, edgeSize = 1,
}

------------------------------------------------------------------------
-- Font styling function
------------------------------------------------------------------------
local function SetFontStyle( textString )
  textString:SetFont(font, 8, 'MONOCHROMEOUTLINE')
  textString:SetShadowColor(0, 0, 0, .9)
  textString:SetShadowOffset(1, -1)
end

------------------------------------------------------------------------
-- Skin the Quest Buttons
-- From Mythology/nibWatcherFrameAdv
------------------------------------------------------------------------
local function SkinButton(button, texture)
  if(string.match(button:GetName(), 'WatchFrameItem%d+') and not button.skinned) then
    button:SetSize(26, 26)
    button:SetBackdrop(backdrop)
    button:SetBackdropColor(0, 0, 0)
    button:SetBackdropBorderColor(0, 0, 0)

    local icon = _G[button:GetName() .. 'IconTexture']
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetPoint('TOPLEFT', 1, -1)
    icon:SetPoint('BOTTOMRIGHT', -1, 1)

    _G[button:GetName() .. 'NormalTexture']:SetTexture()

    button.skinned = true
  end
end

------------------------------------------------------------------------
-- Add square or hide if there's a Dash
-- From Mythology/nibWatcherFrameAdv
------------------------------------------------------------------------
local function SetLine(...)
  local line, _, _, isHeader, _, hasDash = ...
  line.hasDash = hasDash == 1

  if(line.hasDash and line.square) then
    line.square:Show()
  elseif(line.square) then
    line.square:Hide()
  end
end

------------------------------------------------------------------------
-- Colorizing the quests
-- To Do Add all tags into this as well
------------------------------------------------------------------------
local tags = {
  Dungeon = 'D',
  Elite = '+',
  Group = 'G',
  Heroic = 'H',
  PVP = 'PvP',
  Raid = 'R',
  Scenario = 'Sc',
  Legendary = 'Legend'
}

local function GetQuestData(self)
  if(self.type == 'QUEST') then
    local questIndex = GetQuestIndexForWatch(self.index)
    if(questIndex) then
      local _, level, questTag, _, _, _, _, isDaily, _, _, _ = GetQuestLogTitle(questIndex)
      if (isDaily) then
        return 15/255, 215/255, 215/255, level..'•'
      elseif (questTag) then
        local color = GetQuestDifficultyColor(level)
        return color.r, color.g, color.b, level..tags[questTag]
      else
        local color = GetQuestDifficultyColor(level)
        return color.r, color.g, color.b, level
      end
    end
  end

  return 0.85, 0.45, 0
end

------------------------------------------------------------------------
-- Is the quest being tracked on the map?
------------------------------------------------------------------------

local function IsSuperTracked(self)
  if(self.type ~= 'QUEST') then return end

  local questIndex = GetQuestIndexForWatch(self.index)
  if(questIndex) then
    local _, _, _, _, _, _, _, _, id = GetQuestLogTitle(questIndex)
    if(id and GetSuperTrackedQuestID() == id) then
      return true
    end
  end
end

------------------------------------------------------------------------
-- Colorize the square
------------------------------------------------------------------------
local function HighlightLine(self, highlight)
  for index = self.startLine, self.lastLine do
    local line = self.lines[index]
    if(line) then
      if(index == self.startLine) then
        local r, g, b, prefix = GetQuestData(self)
        local text = line.text:GetText()
        if(text and string.sub(text, -1) ~= '\032' and prefix) then
          line.text:SetFormattedText('[%s] %s\032', prefix, text)
        end

        if(highlight) then
          line.text:SetTextColor(r, g, b)
        else
          line.text:SetTextColor(r * 6/7, g * 6/7, b * 6/7)
        end
      else
        if(highlight) then
          line.text:SetTextColor(6/7, 6/7, 6/7)

          if(line.square) then
            line.square:SetBackdropColor(1/5, 1/2, 4/5)
          end
        else
          line.text:SetTextColor(5/7, 5/7, 5/7)

          if(line.square) then
            if(IsSuperTracked(self)) then
              line.square:SetBackdropColor(5/7, 1/5, 1/5)
            else
              line.square:SetBackdropColor(4/5, 4/5, 1/5)
            end
          end
        end
      end
    end
  end
end

------------------------------------------------------------------------
-- Actual skinning of quests
------------------------------------------------------------------------
local nextLine = 1
local function SkinLine()
  for index = nextLine, 50 do
    local line = _G['WatchFrameLine' .. index]
    if(line) then
      SetFontStyle(line.text)
      line.dash:SetAlpha(0)

      local square = CreateFrame('Frame', nil, line)
      square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 6, -6)
      square:SetSize(6, 6)
      square:SetBackdrop(backdrop)
      square:SetBackdropColor(4/5, 4/5, 1/5)
      square:SetBackdropBorderColor(0, 0, 0)
      line.square = square

      if(line.hasDash) then
        square:Show()
      else
        square:Hide()
      end
    else
      nextLine = index
      break
    end
  end

  for index = 1, #WATCHFRAME_LINKBUTTONS do
    HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
  end
end

local nextScenarioLine = 1
local function SkinScenarioLine()
  for index = nextScenarioLine, 50 do
    local line = _G['WatchFrameScenarioLine' .. index]
    if(line) then
      SetFontStyle(line.text)

      local square = CreateFrame('Frame', nil, line)
      square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 6, -6)
      square:SetSize(6, 6)
      square:SetBackdrop(backdrop)
      square:SetBackdropColor(4/5, 4/5, 1/5)
      square:SetBackdropBorderColor(0, 0, 0)
      line.square = square

      line.icon:Hide()
    else
      nextScenarioLine = index
      break
    end
  end

  local _, _, numCriteria = C_Scenario.GetStepInfo()
  for index = 1, numCriteria do
    local text, _, completed = C_Scenario.GetCriteriaInfo(index)
    for lineIndex = 1, nextScenarioLine do
      local line = _G['WatchFrameScenarioLine' .. lineIndex]
      if(line and string.find(line.text:GetText(), text)) then
        if(completed) then
          line.square:SetBackdropColor(0, 1, 0)
        else
          line.square:SetBackdropColor(4/5, 4/5, 4/5)
        end
      end
    end
  end
end

------------------------------------------------------------------------
-- Modifying the click track behavior
-- Taken from Mythology
------------------------------------------------------------------------
local origClick
local function ClickLine(self, button, ...)
  if(button == 'RightButton' and not IsShiftKeyDown() and self.type == 'QUEST') then
    local _, _, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
    QuestPOI_SelectButtonByQuestId('WatchFrameLines', questID, true)

    if(WorldMapFrame:IsShown()) then
      WorldMapFrame_SelectQuestById(questID)
    end

    SetSuperTrackedQuestID(questID)

    for index = 1, #WATCHFRAME_LINKBUTTONS do
      if(index ~= self.index) then
        HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
      end
    end
  else
    origClick(self, button, ...)
  end
end

------------------------------------------------------------------------
-- Removing the circled ?
------------------------------------------------------------------------
local function QuestPOI(name, type, index)
  if(name == 'WatchFrameLines') then
    _G['poi' .. name .. type .. '_' .. index]:Hide()
  end
end

local function null() end

------------------------------------------------------------------------
-- The actual Setup
------------------------------------------------------------------------
local Handler = CreateFrame('Frame')
Handler:RegisterEvent('PLAYER_LOGIN')
Handler:SetScript('OnEvent', function(self, event)
  hooksecurefunc('WatchFrame_SetLine', SetLine)
  hooksecurefunc('WatchFrame_Update', SkinLine)
  hooksecurefunc('WatchFrameScenario_UpdateScenario', SkinScenarioLine)
  hooksecurefunc('QuestPOI_DisplayButton', QuestPOI)
  hooksecurefunc('SetItemButtonTexture', SkinButton)

  -----------------------------
  -- Click behavior
  origClick = WatchFrameLinkButtonTemplate_OnClick
  WatchFrameLinkButtonTemplate_OnClick = ClickLine
  WatchFrameLinkButtonTemplate_Highlight = HighlightLine

  -----------------------------
  -- Positioning
  local origSet = WatchFrame.SetPoint
  local origClear = WatchFrame.ClearAllPoints

  WatchFrame.SetPoint = null
  WatchFrame.ClearAllPoints = null

  origClear(WatchFrame)
  origSet(WatchFrame, 'TOPLEFT', UIParent, 15, -10)

  WatchFrame:SetHeight(UIParent:GetHeight() - 300)

  -----------------------------
  -- Changing the header
  SetFontStyle(WatchFrameTitle)
  SetFontStyle(WatchFrameScenarioFrame.ScrollChild.TextHeader.text)
  WatchFrameScenarioFrame.ScrollChild.TextHeader.text:SetTextColor(0.85, 0.85, 0)

  -----------------------------
  -- Skinning the button
  WatchFrameCollapseExpandButton:SetNormalTexture([[Interface\AddOns\Hyperbole\UI-Panel-QuestHideButton]])
  WatchFrameCollapseExpandButton:SetPushedTexture([[Interface\AddOns\Hyperbole\UI-Panel-QuestHideButton]])


  SkinScenarioLine()

  WorldMapPlayerUpper:EnableMouse(false)
  WorldMapPlayerLower:EnableMouse(false)
end)