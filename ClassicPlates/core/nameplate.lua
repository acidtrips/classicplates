--[[

    nameplate.lua

    Contains functions that drive the nameplate frames.

--]]
local UnitIsUnit, CastBar_SetUnit = UnitIsUnit, CastBar_SetUnit


local function NamePlate_OnEvent(self, event, ...)
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


local function NamePlate_OnUpdate(self, elapsed)
  self.elapsed = (self.elapsed + elapsed)
  if ( self.elapsed > 0.22 ) then
    self:Combat_OnUpdate()
    self:Highlight_OnUpdate()
    self.elapsed = 0
  end
end


local function NamePlate_OnShow(self)
  if ( not UnitIsUnit("player", self.unit) ) then
    self:Hide()
  end
end


function ClassicPlates:OnNamePlateCreated(frame)
  frame.NamePlate = self:NewNamePlate(frame)
  frame.NamePlate:SetScript("OnEvent", NamePlate_OnEvent)
  frame.NamePlate:SetScript("OnUpdate", NamePlate_OnUpdate)
  frame.UnitFrame:HookScript("OnShow", NamePlate_OnShow)
end


function ClassicPlates:OnUnitRemoved(frame)
  frame.unit = nil
  frame.isMouseOver = false
  frame.inCombat = false
  frame.lastCombatAction = 0
  frame.elapsed = 0
  frame:Hide()
  frame:UnregisterAllEvents()
  CastBar_SetUnit(frame.CastBar, nil)
end


function ClassicPlates:OnUnitAdded(frame, unit)
  frame.unit = unit
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
  CastBar_SetUnit(frame.CastBar, unit)
  frame:Show()
end
