--[[

    combat.lua

    Contains functions to update unit combat state.

--]]
local GetTime, UnitIsFriend, UnitPlayerControlled =
      GetTime, UnitIsFriend, UnitPlayerControlled

local COMBAT_ACTION_TIMEOUT = 3


local function UnitIsFriendlyNPC(unit)
  return (UnitIsFriend(unit, "player") and not UnitPlayerControlled(unit))
end


function NamePlateMixin:Combat_OnUpdate(elapsed)
  self.elapsed = (self.elapsed + elapsed)
  if ( self.elapsed >= 1.0 ) then
    if ( (GetTime() - self.lastCombatAction) >= COMBAT_ACTION_TIMEOUT ) then
      self.lastCombatAction = 0
      self.isInCombat = false
      self:Update_NameColor()
      self:SetOnUpdate(nil)
    end
    self.elapsed = 0
  end
end


function NamePlateMixin:Update_Combat(action, amount)
  if ( (action == "WOUND" and amount ~= 0) and not UnitIsFriendlyNPC(self.unit) ) then
    if ( not self.isInCombat ) then
      self.isInCombat = true
      self:Update_NameColor()
      self:SetOnUpdate(self.Combat_OnUpdate, true)
    end
    self.lastCombatAction = GetTime()
  end
end
