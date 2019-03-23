--[[

    highlight.lua

    Contains functions to update unit highlighted state.

--]]
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit
local NamePlate = ClassicPlates.NamePlate


local function UnitIsMousedOver(unit)
  return (UnitExists("mouseover") and UnitIsUnit("mouseover", unit) and not UnitIsUnit("target", unit))
end


function NamePlate:Highlight_OnUpdate()
  if ( self.isMouseOver ) then
    if ( not UnitIsMousedOver(self.unit) ) then
      self.isMouseOver = false
      self:Update_NameColor()
    end
  end
end


function NamePlate:Update_Highlight()
  if ( UnitIsMousedOver(self.unit) and not self.inCombat ) then
    self.isMouseOver = true
    self:Update_NameColor()
  end
end
