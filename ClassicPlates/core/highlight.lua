--[[

    highlight.lua

    Contains functions to update unit highlight state.

--]]
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit


local function IsUnitMousedOver(unit)
  return UnitExists("mouseover") and UnitIsUnit("mouseover", unit) and not UnitIsUnit("target", unit)
end


function NamePlateMixin:HighlightOnUpdate(elapsed)
  self.elapsed = (self.elapsed + elapsed)
  if ( self.elapsed >= 0.1 ) then
    if ( not IsUnitMousedOver(self.unit) ) then
      self.isHighlighted = false
      self:UpdateNameColor()
      self:SetOnUpdate(nil)
    end
    self.elapsed = 0
  end
end


function NamePlateMixin:UpdateHighlight()
  if ( not self.isHighlighted ) then
    if ( IsUnitMousedOver(self.unit) and not self.isInCombat ) then
      self.isHighlighted = true
      self:UpdateNameColor()
      self:SetOnUpdate(self.HighlightOnUpdate, nil)
    end
  end
end
