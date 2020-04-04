--[[

    combat.lua

    Contains functions to update unit combat state.

--]]
local GetTime, UnitIsFriend, UnitPlayerControlled = GetTime, UnitIsFriend, UnitPlayerControlled


local function IsUnitFriendlyNPC(unit)
  return not UnitPlayerControlled(unit) and UnitIsFriend(unit, "player")
end


function NamePlateMixin:CombatOnUpdate(elapsed)
  self.elapsed = (self.elapsed + elapsed)
  if ( self.elapsed >= 1.0 ) then
    if ( (GetTime() - self.lastCombatAction) >= 3 ) then
      self.lastCombatAction = 0
      self.isInCombat = false
      self:UpdateNameColor()
      self:SetOnUpdate(nil)
    end
    self.elapsed = 0
  end
end


function NamePlateMixin:UpdateCombat(action, amount)
  if ( (action == "WOUND" and amount ~= 0) and not IsUnitFriendlyNPC(self.unit) ) then
    if ( not self.isInCombat ) then
      self.isInCombat = true
      self:UpdateNameColor()
      self:SetOnUpdate(self.CombatOnUpdate, true)
    end
    self.lastCombatAction = GetTime()
  end
end
