--[[

    nameplate.lua

    Contains functions that drive the nameplate frames.

--]]
local CreateFrame = CreateFrame

NamePlateMixin = {}


function NamePlateMixin:OnEvent(event, ...)
  if ( event == "UNIT_MAXHEALTH" ) then
    self:UpdateMaxHealth()
  elseif ( event == "UNIT_HEALTH" ) then
    self:UpdateHealth()
  elseif ( event == "UNIT_LEVEL" ) then
    self:UpdateLevel()
  elseif ( event == "UNIT_NAME_UPDATE" ) then
    self:UpdateName()
    self:UpdateNameColor()
  elseif ( event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_THREAT_SITUATION_UPDATE" ) then
    self:UpdateThreat()
  elseif ( event == "RAID_TARGET_UPDATE" ) then
    self:UpdateRaidIcon()
  elseif ( event == "PLAYER_TARGET_CHANGED" ) then
    if ( self.options.showCastBarsTargetOnly ) then
      self:UpdateCastBar()
    end
    self:UpdateHighlight()
    self:UpdateSelection()
  elseif ( event == "PLAYER_ENTERING_WORLD" ) then
    self:UpdateAll()
  elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
    self:UpdateHighlight()
  elseif ( event == "UNIT_COMBAT" ) then
    local _, action, _, amount = ...
    self:UpdateCombat(action, amount)
  elseif ( event == "UNIT_FACTION" ) then
    self:UpdateNameColor()
    self:UpdateHealthColor()
  elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
    self:UpdateClassification()
  end
end


function NamePlateMixin:SetOnUpdate(updateFunc, lockOnUpdate)
  if ( updateFunc ) then
    if ( not self:IsOnUpdateLocked() ) then
      self.elapsed = 0
      self:SetScript("OnUpdate", updateFunc)
    end
  else
    self:SetScript("OnUpdate", nil)
  end
  self.isOnUpdateLocked = lockOnUpdate
end


function NamePlateMixin:IsOnUpdateLocked()
  return self.isOnUpdateLocked
end


function NamePlateMixin:SetOptions()
  self.options = ClassicPlatesOptions
end


function NamePlateMixin:UpdateOption(var, value, updateFunc, doUpdate)
  self.options[var] = value
  if ( doUpdate ) then
    self[updateFunc](self)
  end
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
  frame.options = nil
  frame.CastBar:SetUnit(nil)
  frame:SetOnUpdate(nil)
  frame:UnregisterAllEvents()
  frame:Hide()
end


function ClassicPlates:OnUnitAdded(frame, unit)
  frame.unit = unit
  frame:SetOptions()
  frame.CastBar:SetUnit(unit)
  frame:UpdateAll()
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("RAID_TARGET_UPDATE")
  frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  frame:RegisterUnitEvent("UNIT_COMBAT", unit)
  frame:RegisterUnitEvent("UNIT_FACTION", unit)
  frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
  frame:RegisterUnitEvent("UNIT_HEALTH", unit)
  frame:RegisterUnitEvent("UNIT_LEVEL", unit)
  frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", unit)
  frame:Show()
end
