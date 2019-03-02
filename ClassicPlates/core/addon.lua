--[[

  addon.lua

  Contains addon event handlers.

--]]
local addonName = ...
local SendSystemMessage, GetNamePlateForUnit, UnitIsUnit, SetCVar, GetCVar, tContains, pairs, tonumber =
      SendSystemMessage, C_NamePlate.GetNamePlateForUnit, UnitIsUnit, SetCVar, GetCVar, tContains, pairs, tonumber


function ClassicPlates:CVarUpdate()
  local cvars = {
    ["nameplateOtherTopInset"] = -1, ["nameplateOtherBottomInset"] = -1,
    ["nameplateLargeTopInset"] = -1, ["nameplateLargeBottomInset"] = -1,
    ["nameplateMaxScale"] = 1.0, ["nameplateMinScale"] = 1.0,
    ["nameplateLargerScale"] = 1.0, ["nameplateMotionSpeed"] = 0.08,
    ["nameplateShowAll"] = 1, ["nameplateShowFriendlyNPCs"] = 1,
    ["nameplateMinAlpha"] = 1.0, ["nameplateOccludedAlphaMult"] = 1.0,
    ["nameplateMaxDistance"] = 40,
  }
  for cvar, value in pairs(cvars) do
    local curValue = tonumber(GetCVar(cvar))
    if ( curValue ~= value ) then
      SetCVar(cvar, value)
    end
  end
end


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
    self:CVarUpdate()
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
  self:OnUnitRemoved(frame.NamePlate)
end

