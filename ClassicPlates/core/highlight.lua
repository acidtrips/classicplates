--[[

    highlight.lua

    Contains functions to update unit highlight state.

--]]
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit


local function UnitIsMousedOver(unit)
  return (UnitExists("mouseover") and UnitIsUnit("mouseover", unit) and not UnitIsUnit("target", unit))
end


function NamePlateMixin:Highlight_OnUpdate(elapsed)
  self.elapsed = (self.elapsed + elapsed)
  if ( self.elapsed >= 0.1 ) then
    if ( not UnitIsMousedOver(self.unit) ) then
      self.isHighlighted = false
      self:Update_NameColor()
      self:SetOnUpdate(nil)
    end
    self.elapsed = 0
  end
end


function NamePlateMixin:Update_Highlight()
  if ( UnitIsMousedOver(self.unit) and not self.isInCombat ) then
    self.isHighlighted = true
    self:Update_NameColor()
    self:SetOnUpdate(self.Highlight_OnUpdate, false)
  end
end
