--[[--------------------------------------------------------------------
        I've taken this from PhanxWatchFrame,
        with Phanx' permission to do so.
----------------------------------------------------------------------]]

local FADE_IN_ALPHA = 1
local FADE_IN_DELAY = 0.1
local FADE_IN_DURATION = 0.2

local FADE_OUT_ALPHA = 0.4
local FADE_OUT_DELAY = 0.2
local FADE_OUT_DURATION = 0.4

local GetMouseFocus = GetMouseFocus
local WorldFrame = WorldFrame

local fadeGroup = WatchFrame:CreateAnimationGroup()
local fadeAnim = fadeGroup:CreateAnimation("Alpha")
fadeGroup:SetLooping("NONE")
fadeGroup:SetScript("OnFinished", function(self) WatchFrame:SetAlpha(self.targetAlpha) end)
WatchFrame:SetAlpha(FADE_OUT_ALPHA)

local pcall = pcall
local descendants = setmetatable({}, { __index = function(t, f)
        local ok, parent = pcall(f.GetParent, f) -- stupid fucking StoreFrame
        while ok and parent do
                if parent == WatchFrame then
                        t[f] = true
                        return true
                end
                ok, parent = pcall(parent.GetParent, parent)
        end
        t[f] = false
        return false
end })

local hasMouseFocus = false
WatchFrame:HookScript("OnUpdate", function(self, elapsed)
        local mouseFocus = GetMouseFocus()
        if not mouseFocus then
                return
        end
        local gotMouseFocus = mouseFocus == self or descendants[mouseFocus] or (mouseFocus == WorldFrame and self:IsMouseOver(10, -10, -10, 10))
        if gotMouseFocus == hasMouseFocus then
                return
        end
        hasMouseFocus = gotMouseFocus
        fadeGroup:Stop()
        if gotMouseFocus then
                -- Fade in
                local a = floor(self:GetAlpha() * 100 + 0.5) / 100
                local d = FADE_IN_ALPHA - a
                local t = (FADE_IN_DURATION * d) / (FADE_IN_ALPHA - FADE_OUT_ALPHA)
                if d < 0.05 or t < 0.05 then
                        -- Don't bother animating
                        return self:SetAlpha(FADE_IN_ALPHA)
                end
                fadeAnim:SetChange(d)
                fadeAnim:SetStartDelay(a == FADE_OUT_ALPHA and FADE_IN_DELAY or 0)
                fadeAnim:SetDuration(t)
                fadeGroup.targetAlpha = FADE_IN_ALPHA
                fadeGroup:Play()
        else
                -- Fade out
                local a = floor(self:GetAlpha() * 100 + 0.5) / 100
                local d = a - FADE_OUT_ALPHA
                local t = (FADE_OUT_DURATION * d) / (FADE_IN_ALPHA - FADE_OUT_ALPHA)
                if d < 0.05 or t < 0.05 then
                        -- Don't bother animating
                        return self:SetAlpha(FADE_OUT_ALPHA)
                end
                fadeAnim:SetChange(-d)
                fadeAnim:SetStartDelay(a == FADE_IN_ALPHA and FADE_OUT_DELAY or 0)
                fadeAnim:SetDuration(t)
                fadeGroup.targetAlpha = FADE_OUT_ALPHA
                fadeGroup:Play()
        end
end)