--[[

    combat.lua

    Contains functions to update unit combat state.

--]]
local GetTime, UnitIsFriend, UnitPlayerControlled = GetTime, UnitIsFriend, UnitPlayerControlled
local NamePlate = ClassicPlates.NamePlate


local function UnitCombatActionAllowed(unit)
  return not (UnitIsFriend(unit, "player") and not UnitPlayerControlled(unit))
end


function NamePlate:Combat_OnUpdate()
  if ( self.inCombat ) then
    if ( (GetTime() - self.lastCombatAction) >= 3 ) then
      self.lastCombatAction = 0
      self.inCombat = false
      self:Update_NameColor()
    end
  end
end


function NamePlate:Update_Combat(action, amount)
  if ( (action == "WOUND" and amount ~= 0) and UnitCombatActionAllowed(self.unit) ) then
    if ( not self.inCombat ) then
      self.inCombat = true
      self:Update_NameColor()
    end
    self.lastCombatAction = GetTime()
  end
end
