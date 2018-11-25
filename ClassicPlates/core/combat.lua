--[[

    combat.lua

    Contains functions to update unit combat state.

--]]
local NamePlate = ClassicPlates.NamePlate

local GetTime, UnitExists, UnitPlayerControlled = GetTime, UnitExists, UnitPlayerControlled


local function IsCombatActionAllowed(unit)
  local targetUnit = unit.."target"
  if ( UnitExists(targetUnit) ) then
    return not (not UnitPlayerControlled(unit) and not UnitPlayerControlled(targetUnit))
  end
  return true
end


function NamePlate:Update_CombatAction(action, amount)
  if ( (action == "WOUND" and amount ~= 0) and IsCombatActionAllowed(self.unit) ) then
    if ( not self.inCombat ) then
      self.inCombat = true
      self:Update_CombatColor()
    end
    self.lastCombatAction = GetTime()
  end
end


function NamePlate:Combat_Update()
  if ( self.inCombat ) then
    if ( (GetTime() - self.lastCombatAction) >= 3 ) then
      self.lastCombatAction = 0
      self.inCombat = false
      self:Update_CombatColor()
    end
  end
end
