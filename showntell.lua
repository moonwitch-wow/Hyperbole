------------------------------------------------------------------------
-- Setting up the local scope
------------------------------------------------------------------------
local _, Hyperbole = ...
local handler = CreateFrame("Frame")

local function null() end

------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------
function Hyperbole.PLAYER_LOGIN(...)
   print('Hyperbole Loaded') -- debugging purposes

   ObjectiveTrackerFrame:ClearAllPoints()
   ObjectiveTrackerFrame:SetPoint('TOPLEFT', 25, -10)
   ObjectiveTrackerFrame:SetHeight(UIParent:GetHeight() - 300)

   ObjectiveTrackerFrame.SetPoint = null
   ObjectiveTrackerFrame.ClearAllPoints = null
end

------------------------------------------------------------------------
-- Many Whelps, handle Events
------------------------------------------------------------------------
handler:SetScript('OnEvent', function(self, event, ...)
  Hyperbole[event](self, event, ...)
end)

for k, v in pairs(Hyperbole) do
  handler:RegisterEvent(k) -- Register all events for which handlers have been defined
end
