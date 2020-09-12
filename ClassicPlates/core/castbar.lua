--[[

    castbar.lua

    Contains functions that drive the nameplate castbar frames.

--]]
local UnitIsUnit, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo, GetTime =
      UnitIsUnit, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo, GetTime

CastBarMixin = {}


function CastBarMixin:ShouldShowCastBar(options)
  if ( options.showCastBars ) then
    if ( options.showCastBarsTargetOnly ) then
      return UnitIsUnit("target", self.unit)
    end
    return true
  end
  return false
end


function CastBarMixin:UpdateIsShown(options)
  self.showCastBar = self:ShouldShowCastBar(options)
  if ( self.showCastBar and (self.isCasting or self.isChanneling) ) then
    self:Initialize()
  else
    self:Hide()
  end
  self.CastBarTextBG:SetShown(options.showCastBarsSpellName)
  self.CastBarText:SetShown(options.showCastBarsSpellName)
end


function CastBarMixin:UpdateBorder(notInterruptible)
  local yOffset = notInterruptible and -30 or -20
  self:SetPoint("BOTTOMLEFT", self:GetParent().HealthBar, "BOTTOMLEFT", 16, yOffset)
  self.CastBarFrameShield:SetShown(notInterruptible)
  self.CastBarBorder:SetShown(not notInterruptible)
end


function CastBarMixin:CastStart()
  local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unit)
  if ( not name or isTradeSkill ) then
    self:Hide()
    return
  end
  self.value = (GetTime() - (startTime / 1000))
  self.maxValue = ((endTime - startTime) / 1000)
  self:SetMinMaxValues(0, self.maxValue)
  self:SetValue(self.value)
  self.CastBarText:SetText(text or name)
  self.CastBarSpellIcon:SetTexture(texture)
  self:SetAlpha(1.0)
  self.fadeOut = nil
  self.holdTime = 0
  self.castID = castID
  self.isCasting = true
  self.isChanneling = nil
  self:UpdateBorder(notInterruptible)
  if ( self.showCastBar ) then
    self:Show()
  end
end


function CastBarMixin:CastChannelStart()
  local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit)
  if ( not name or isTradeSkill ) then
    self:Hide()
    return
  end
  self.value = ((endTime / 1000) - GetTime())
  self.maxValue = ((endTime - startTime) / 1000)
  self:SetMinMaxValues(0, self.maxValue)
  self:SetValue(self.value)
  self.CastBarText:SetText(text or name)
  self.CastBarSpellIcon:SetTexture(texture)
  self:SetAlpha(1.0)
  self.fadeOut = nil
  self.holdTime = 0
  self.isCasting = nil
  self.isChanneling = true
  self:UpdateBorder(notInterruptible)
  if ( self.showCastBar ) then
    self:Show()
  end
end


function CastBarMixin:CastStop(castID)
  if ( self.isCasting and castID == self.castID ) then
    self:SetValue(self.maxValue)
    self.isCasting = nil
    self:CastFinish()
  end
end


function CastBarMixin:CastChannelStop()
  if ( self.isChanneling ) then
    self:SetValue(self.maxValue)
    self.isChanneling = nil
    self:CastFinish()
  end
end


function CastBarMixin:CastFail(event, castID)
  if ( self:IsShown() and (self.isCasting and castID == self.castID) and not self.fadeOut ) then
    self:SetValue(self.maxValue)
    self.CastBarText:SetText((event == "UNIT_SPELLCAST_FAILED") and "Failed" or "Interrupted")
    self.isCasting = nil
    self.isChanneling = nil
    self:CastFinish(true)
  end
end


function CastBarMixin:CastDelayed()
  if ( self:IsShown() ) then
    local name, _, _, startTime, endTime, isTradeSkill = UnitCastingInfo(self.unit)
    if ( not name or isTradeSkill ) then
      self:Hide()
      return
    end
    self.value = (GetTime() - (startTime / 1000))
    self.maxValue = ((endTime - startTime) / 1000)
    self:SetMinMaxValues(0, self.maxValue)
    if ( not self.isCasting ) then
      self.isCasting = true
      self.isChanneling = nil
      self.fadeOut = nil
    end
  end
end


function CastBarMixin:CastChannelUpdate()
  if ( self:IsShown() ) then
    local name, _, _, startTime, endTime, isTradeSkill = UnitChannelInfo(self.unit)
    if ( not name or isTradeSkill ) then
      self:Hide()
      return
    end
    self.value = ((endTime / 1000) - GetTime())
    self.maxValue = ((endTime - startTime) / 1000)
    self:SetMinMaxValues(0, self.maxValue)
    self:SetValue(self.value)
  end
end


function CastBarMixin:CastFinish(holdTime)
  if ( not UnitIsPlayer(self.unit) ) then
    self.holdTime = holdTime and (GetTime() + 1) or 0
    self.fadeOut = true
  else
    self:Hide()
  end
end


function CastBarMixin:SetUnit(unit)
  if ( self.unit ~= unit ) then
    self.unit = unit
    self.isCasting = nil
    self.isChanneling = nil
    self.holdTime = 0
    self.fadeOut = nil
    if ( unit ) then
      self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
      self:RegisterEvent("PLAYER_ENTERING_WORLD")
      self:Initialize()
    else
      self:UnregisterAllEvents()
      self:Hide()
    end
  end
end


function CastBarMixin:Initialize()
  if ( UnitChannelInfo(self.unit) ) then
    self:CastChannelStart()
  elseif ( UnitCastingInfo(self.unit) ) then
    self:CastStart()
  else
    self.isCasting = nil
    self.isChanneling = nil
    self:CastFinish()
  end
end


function CastBarMixin:OnShow()
  if ( self.unit ) then
    if ( self.isCasting ) then
      local _, _, _, startTime = UnitCastingInfo(self.unit)
      if ( startTime ) then
        self.value = (GetTime() - (startTime / 1000))
      end
    else
      local _, _, _, _, endTime = UnitChannelInfo(self.unit)
      if ( endTime ) then
        self.value = ((endTime / 1000) - GetTime())
      end
    end
  end
end


function CastBarMixin:OnEvent(event, ...)
  if ( event == "PLAYER_ENTERING_WORLD" ) then
    self:Initialize()
  elseif ( event == "UNIT_SPELLCAST_START" ) then
    self:CastStart()
  elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
    self:CastChannelStart()
  elseif ( event == "UNIT_SPELLCAST_STOP" ) then
    local _, castID = ...
    self:CastStop(castID)
  elseif ( event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
    self:CastChannelStop()
  elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
    local _, castID = ...
    self:CastFail(event, castID)
  elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
    self:CastDelayed()
  elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
    self:CastChannelUpdate()
  elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
    self:UpdateBorder((event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"))
  end
end


function CastBarMixin:OnUpdate(elapsed)
  if ( self.isCasting ) then
    self.value = (self.value + elapsed)
    if ( self.value >= self.maxValue ) then
      self:SetValue(self.maxValue)
      self.isCasting = nil
      self.isChanneling = nil
      self:CastFinish()
      return
    end
    self:SetValue(self.value)
  elseif ( self.isChanneling ) then
    self.value = (self.value - elapsed)
    if ( self.value <= 0 ) then
      self.isCasting = nil
      self.isChanneling = nil
      self:CastFinish()
      return
    end
    self:SetValue(self.value)
  elseif ( GetTime() < self.holdTime ) then
    return
  elseif ( self.fadeOut ) then
    local alpha = (self:GetAlpha() - 0.05)
    if ( alpha > 0 ) then
      self:SetAlpha(alpha)
    else
      self.fadeOut = nil
      self:Hide()
    end
  else
    self.isCasting = nil
    self.isChanneling = nil
    self:Hide()
  end
end
