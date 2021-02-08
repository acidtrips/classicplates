--[[

    addon.lua

    Contains addon event handlers and cvar mods.

--]]
local addOnName = ...
local UnitIsUnit, GetNamePlateForUnit, SetCVar, GetCVar, tContains, pairs, tonumber, format =
      UnitIsUnit, C_NamePlate.GetNamePlateForUnit, SetCVar, GetCVar, tContains, pairs, tonumber, format


function ClassicPlates:CVarUpdate()
  local cvars = {
    nameplateOtherTopInset = -1, nameplateOtherBottomInset = -1,
    nameplateLargeTopInset = -1, nameplateLargeBottomInset = -1,
    nameplateMaxScale = 1.0, nameplateMinScale = 1.0,
    nameplateLargerScale = 1.0, nameplateSelectedScale = 1.0,
    nameplateShowAll = 1, nameplateShowFriendlyNPCs = 1,
    nameplateMaxDistance = 40, nameplateMotionSpeed = 0.1,
    nameplateOverlapV = 0.75,
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


function ClassicPlates:ConflictCheck(name)
  local knownAddOns = {
    "Kui_Nameplates", "Tidy Plates", "Plater",
    "nPlates", "bdNameplates", "EKPlates",
    "NamePlateKAI", "NephilistNameplates", "NeatPlates",
    "NamePlates", "NiceNameplates", "Threat Plates",
  }
  if ( tContains(knownAddOns, name) ) then
    print(format("|cffff0000ATTENTION:|r |cFF3782D1%s|r was disabled as it will conflict with |cFF3782D1%s|r", addOnName, name))
    self:UnregisterAllEvents()
  end
end


function ClassicPlates:ADDON_LOADED(name)
  if ( addOnName == name and ClassicPlatesOptions == nil ) then
    ClassicPlatesOptions = {
      showAggroWarnings = true, showClassColors = false,
      showCastBars = true, showCastBarsTargetOnly = false,
      showCastBarsSpellName = false,
    }
  end
  self:ConflictCheck(name)
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
  local frame = GetNamePlateForUnit(unit)
  if ( UnitNameplateShowsWidgetsOnly(unit) ) then
    if ( frame.UnitFrame and frame.UnitFrame.WidgetContainer ) then
      frame.UnitFrame.WidgetContainer:SetParent(frame)
    end
  elseif ( not UnitIsUnit("player", unit) ) then
    if ( frame.UnitFrame and not frame.UnitFrame.isOnShowHooked ) then
      frame.UnitFrame.isOnShowHooked = true
      frame.UnitFrame:HookScript("OnShow", function(_self) _self:Hide() end)
      frame.UnitFrame:Hide()
    end
    self:OnUnitAdded(frame.NamePlate, unit)
  end
end

function ClassicPlates:NAME_PLATE_UNIT_REMOVED(unit)
  local frame = GetNamePlateForUnit(unit)
  self:OnUnitRemoved(frame.NamePlate)
end

