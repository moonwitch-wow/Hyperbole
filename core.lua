------------------------------------------------------------------------
-- Get needed info
------------------------------------------------------------------------
local questtags, tags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "•", Heroic = "H", Repeatable = "∞"}

local function GetTaggedTitle(i)
  local name, level, tag, group, header, _, complete, daily = GetQuestLogTitle(i)
  if header or not name then return end

  if not group or group == 0 then group = nil end
  return string.format("[%s%s%s%s] %s", level, tag and tags[tag] or "", daily and tags.Daily or "",group or "", name), tag, daily, complete
end

------------------------------------------------------------------------
-- Add tags to the quest log
------------------------------------------------------------------------
local function QuestLog_Update()
  for i,butt in pairs(QuestLogScrollFrame.buttons) do
    local qi = butt:GetID()
    local title, tag, daily, complete = GetTaggedTitle(qi)
    if title then butt:SetText("  "..title) end
    if (tag or daily) and not complete then butt.tag:SetText("") end
    QuestLogTitleButton_Resize(butt)
  end
end
hooksecurefunc("QuestLog_Update", QuestLog_Update)
hooksecurefunc(QuestLogScrollFrame, "update", QuestLog_Update)

------------------------------------------------------------------------
-- Add tags to the quest watcher
------------------------------------------------------------------------
hooksecurefunc("WatchFrame_Update", function()
  local questWatchMaxWidth, watchTextIndex = 0, 1

  for i=1,GetNumQuestWatches() do
    local qi = GetQuestIndexForWatch(i)
    if qi then
      local numObjectives = GetNumQuestLeaderBoards(qi)

      if numObjectives > 0 then
        for bi,butt in pairs(WATCHFRAME_QUESTLINES) do
          if butt.text:GetText() == GetQuestLogTitle(qi) then butt.text:SetText(GetTaggedTitle(qi)) end
        end
      end
    end
  end
end)

-- -- Add tags to quest links in chat
-- local function filter(self, event, msg, ...)
--   if msg then
--     return false, msg:gsub("(|c%x+|Hquest:%d+:(%d+))", "(%2) %1"), ...
--   end
-- end
-- for _,event in pairs{"SAY", "GUILD", "GUILD_OFFICER", "WHISPER", "WHISPER_INFORM", "PARTY", "RAID", "RAID_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER"} do ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, filter) end

------------------------------------------------------------------------
-- Make the QuestWatcher Frame Movable and anchor it topleft
------------------------------------------------------------------------
WatchFrame:SetClampedToScreen(true)
WatchFrame:SetMovable(true)
WatchFrame:SetUserPlaced(true)
WatchFrame:ClearAllPoints()
WatchFrame.ClearAllPoints = function() end
WatchFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -10)
WatchFrame.SetPoint = function() end
WatchFrame:SetHeight(UIParent:GetHeight() - 300)
WatchFrameHeader:EnableMouse(true)
WatchFrameHeader:RegisterForDrag("LeftButton")
WatchFrameHeader:SetHitRectInsets(-15, -15, -5, -5)
WatchFrameHeader:SetScript("OnDragStart", function(s)
  local f = s:GetParent()
  f:StartMoving()
end)
WatchFrameHeader:SetScript("OnDragStop", function(s)
  local f = s:GetParent()
  f:StopMovingOrSizing()
end)

------------------------------------------------------------------------
-- Change the font of the QuestWatcher Frame
------------------------------------------------------------------------
local function GetQuestData(self)
  if(self.type == 'QUEST') then
    local questIndex = GetQuestIndexForWatch(self.index)
    if(questIndex) then
      local _, level, _, _, _, _, _, daily = GetQuestLogTitle(questIndex)
      if(daily) then
        return 1/4, 6/9, 1, 'D'
      else
        local color = GetQuestDifficultyColor(level)
        return color.r, color.g, color.b, level
      end
    end
  end

  return 1, 1, 1
end
