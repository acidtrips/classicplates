--[[

  addon.lua

  Contains addon event handlers.

--]]
local addOnName = ...
local UnitIsUnit, GetNamePlateForUnit, SetCVar, GetCVar, tContains, pairs, tonumber =
      UnitIsUnit, C_NamePlate.GetNamePlateForUnit, SetCVar, GetCVar, tContains, pairs, tonumber


function ClassicPlates:CVarUpdate()
  local cvars = {
    nameplateOtherTopInset = -1, nameplateOtherBottomInset = -1,
    nameplateLargeTopInset = -1, nameplateLargeBottomInset = -1,
    nameplateMaxScale = 1.0, nameplateMinScale = 1.0,
    nameplateLargerScale = 1.0, nameplateSelectedScale = 1.0,
    nameplateShowAll = 1, nameplateShowFriendlyNPCs = 1,
    nameplateMaxDistance = 40, nameplateMotionSpeed = 0.1,
  }
  for cvar, value in pairs(cvars) do
    local curValue = tonumber(GetCVar(cvar))
    if ( curValue ~= value ) then
      SetCVar(cvar, value)
    end
    self.cachedCVars[cvar] = curValue
  end
end


function ClassicPlates:CVarRestore()
  for cvar, value in pairs(self.cachedCVars) do
    local curValue = tonumber(GetCVar(cvar))
    if ( curValue ~= value ) then
      SetCVar(cvar, value)
    end
  end
end


function ClassicPlates:AddOnCheck(name)
  local knownAddOns = {
    "Kui_Nameplates", "Tidy Plates", "Plater",
    "nPlates", "bdNameplates", "EKPlates",
    "NamePlateKAI", "NephilistNameplates",
    "NamePlates", "NiceNameplates", "Threat Plates",
  }
  if ( tContains(knownAddOns, name) ) then
    self:UnregisterAllEvents()
  end
end


function ClassicPlates:ADDON_LOADED(...)
  if ( addOnName == ... and ClassicPlatesDB == nil ) then
    ClassicPlatesDB = {
      showAggroWarnings = true, showClassColors = false,
      showCastBars = true, showCastBarsTargetOnly = false,
      showCastBarsSpellName = false,
    }
  end
  self:AddOnCheck(...)
end


function ClassicPlates:PLAYER_LOGIN()
  self:CVarUpdate()
  self:SetupOptionPanel(addOnName)
end


function ClassicPlates:PLAYER_LOGOUT()
  self:CVarRestore()
end


function ClassicPlates:NAME_PLATE_CREATED(frame)
  self:OnNamePlateCreated(frame)
end


function ClassicPlates:NAME_PLATE_UNIT_ADDED(unit)
  if ( not UnitIsUnit("player", unit) ) then
    local frame = GetNamePlateForUnit(unit)
    self:OnUnitAdded(frame.NamePlate, unit)
  end
end


function ClassicPlates:NAME_PLATE_UNIT_REMOVED(unit)
  local frame = GetNamePlateForUnit(unit)
  self:OnUnitRemoved(frame.NamePlate)
end

