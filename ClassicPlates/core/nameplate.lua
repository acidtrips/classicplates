--[[

    nameplate.lua

    Contains functions that drive the nameplate frames.

--]]
local UnitIsUnit, CreateFrame = UnitIsUnit, CreateFrame

NamePlateMixin = {}


function NamePlateMixin:OnShow()
  if ( self.unit and not UnitIsUnit("player", self.unit) ) then
    self:Hide()
  end
end


function NamePlateMixin:OnEvent(event, ...)
  if ( event == "UNIT_MAXHEALTH" ) then
    self:Update_MaxHealth()
  elseif ( event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" ) then
    self:Update_Health()
  elseif ( event == "UNIT_LEVEL" ) then
    self:Update_Level()
  elseif ( event == "UNIT_NAME_UPDATE" ) then
    self:Update_Name()
    self:Update_NameColor()
  elseif ( event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_THREAT_SITUATION_UPDATE" ) then
    self:Update_Threat()
  elseif ( event == "RAID_TARGET_UPDATE" ) then
    self:Update_RaidIcon()
  elseif ( event == "PLAYER_TARGET_CHANGED" ) then
    if ( ClassicPlatesDB.showCastBarsTargetOnly ) then
      self:Update_CastBar()
    end
    self:Update_Highlight()
    self:Update_Selection()
  elseif ( event == "PLAYER_ENTERING_WORLD" ) then
    self:Update_All()
  elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
    self:Update_Highlight()
  elseif ( event == "UNIT_COMBAT" ) then
    local _, action, _, amount  = ...
    self:Update_Combat(action, amount)
  elseif ( event == "UNIT_FACTION" ) then
    self:Update_HealthColor()
  end
end


function NamePlateMixin:SetOnUpdate(updateFunc, lockUpdate)
  if ( updateFunc ) then
    if ( not self.isUpdateLocked ) then
      self.elapsed = 0
      self:SetScript("OnUpdate", updateFunc)
    end
  else
    self:SetScript("OnUpdate", nil)
  end
  self.isUpdateLocked = lockUpdate
end


function ClassicPlates:OnNamePlateCreated(frame)
  CreateFrame("Frame", nil, frame, "ClassicPlateTemplate")
end


function ClassicPlates:OnUnitRemoved(frame)
  frame.unit = nil
  frame.isHighlighted = false
  frame.isInCombat = false
  frame.lastCombatAction = 0
  frame.elapsed = 0
  frame.CastBar:SetUnit(nil)
  frame:SetOnUpdate(nil)
  frame:UnregisterAllEvents()
  frame:Hide()
end


function ClassicPlates:OnUnitAdded(frame, unit)
  frame.unit = unit
  frame.CastBar:SetUnit(unit)
  frame:Update_All()
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("RAID_TARGET_UPDATE")
  frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  frame:RegisterUnitEvent("UNIT_COMBAT", unit)
  frame:RegisterUnitEvent("UNIT_FACTION", unit)
  frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
  frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
  frame:RegisterUnitEvent("UNIT_HEALTH", unit)
  frame:RegisterUnitEvent("UNIT_LEVEL", unit)
  frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
  frame:Show()
end
