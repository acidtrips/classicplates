--[[

  addon.lua

  Contains addon event handlers.

--]]
local addonName = ...
local GetNamePlateForUnit, UnitIsUnit, SetCVar, tContains =
       C_NamePlate.GetNamePlateForUnit, UnitIsUnit, SetCVar, tContains


function ClassicPlates:AddOnCheck(name)
  -- hacky way to stop conflicts with other nameplate addons
  -- add to list as others are found
  local knownAddOns = {
    "Kui_Nameplates", "Tidy Plates", "Plater",
    "nPlates", "bdNameplates", "EKPlates",
    "NamePlateKAI", "NephilistNameplates",
    "NamePlates", "NiceNameplates", "Threat Plates",
  }
  if ( tContains(knownAddOns, name) ) then
    self:UnregisterAllEvents()
    SendSystemMessage(format("%s Detected. Disabling %s", name, addonName))
  end
end


function ClassicPlates:ADDON_LOADED(...)
  if ( addonName == ... and ClassicPlatesDB == nil ) then
    ClassicPlatesDB = self:GetDefaultOptions()
  end
  self:AddOnCheck(...)
end


function ClassicPlates:PLAYER_LOGIN()
  if ( ClassicPlatesDB.setupCVars ) then
    SetCVar("nameplateMaxDistance", 40)
    SetCVar("nameplateOtherTopInset", -1)
    SetCVar("nameplateOtherBottomInset", -1)
    SetCVar("nameplateLargeTopInset", -1)
    SetCVar("nameplateLargeBottomInset", -1)
    SetCVar("nameplateMaxScale", 1.0)
    SetCVar("nameplateMinScale", 1.0)
    SetCVar("nameplateLargerScale", 1.0)
    SetCVar("nameplateMotionSpeed", 0.08)
    SetCVar("nameplateShowAll", 1)
    SetCVar("nameplateShowFriendlyNPCs", 1)
    SetCVar("nameplateMinAlpha", 1.0)
    SetCVar("nameplateOccludedAlphaMult", 1.0)
    ClassicPlatesDB.setupCVars = false
  end
  self:SetupOptionPanel(addonName)
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
  self:OnUnitRemoved(frame.NamePlate, unit)
end

