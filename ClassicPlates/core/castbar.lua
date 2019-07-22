--[[

    castbar.lua

    Contains functions that drive the castbar.

--]]
local UnitIsUnit, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo, GetTime =
      UnitIsUnit, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo, GetTime

CastBarMixin = {}


function CastBarMixin:StopCasting(holdTime)
  if ( not UnitIsPlayer(self.unit) ) then
    self.holdTime = holdTime and (GetTime() + 1) or 0
    self.fadeOut = true
  else
    self:Hide()
  end
end


function CastBarMixin:UpdateBorder(notInterruptible)
  local yOffset = notInterruptible and -30 or -20
  self:SetPoint("BOTTOMLEFT", self:GetParent().HealthBar, "BOTTOMLEFT", 17, yOffset)
  self.CastBarFrameShield:SetShown(notInterruptible)
  self.CastBarBorder:SetShown(not notInterruptible)
end


function CastBarMixin:ShouldShowCastBar()
  if ( ClassicPlatesDB.showCastBars ) then
    if ( ClassicPlatesDB.showCastBarsTargetOnly ) then
      return UnitIsUnit("target", self:GetParent().unit)
    end
    return true
  end
  return false
end


function CastBarMixin:UpdateIsShown()
  self.showCastBar = self:ShouldShowCastBar()
  if ( self.showCastBar and (self.isCasting or self.isChanneling) ) then
    self:OnEvent("PLAYER_ENTERING_WORLD")
  else
    self:Hide()
  end
  self.CastBarTextBG:SetShown(ClassicPlatesDB.showCastBarsSpellName)
  self.CastBarText:SetShown(ClassicPlatesDB.showCastBarsSpellName)
end


function CastBarMixin:SetUnit(unit)
  if ( self.unit ~= unit ) then
    self.unit = unit
    self.isCasting = nil
    self.isChanneling = nil
    self.holdTime = 0
    self.fadeOut = nil
    if ( unit ) then
      self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
      self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
      self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
      self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
      self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
      self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
      self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
      self:RegisterEvent("PLAYER_ENTERING_WORLD")
      self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
      self:OnEvent("PLAYER_ENTERING_WORLD")
    else
      self:UnregisterAllEvents()
      self:Hide()
    end
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
  local unit = ...
  if ( event == "PLAYER_ENTERING_WORLD" ) then
    if ( UnitChannelInfo(self.unit) ) then
      event = "UNIT_SPELLCAST_CHANNEL_START"
      unit = self.unit
    elseif ( UnitCastingInfo(self.unit) ) then
      event = "UNIT_SPELLCAST_START"
      unit = self.unit
    else
      self.isCasting = nil
      self.isChanneling = nil
      self:StopCasting()
    end
  end
  if ( unit ~= self.unit ) then
    return
  end
  if ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" ) then
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible
    if ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
      name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
      self.value = ((endTime / 1000) - GetTime())
      self.maxValue = ((endTime - startTime) / 1000)
      self.isCasting = nil
      self.isChanneling = true
    else
      name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
      self.value = (GetTime() - (startTime / 1000))
      self.maxValue = ((endTime - startTime) / 1000)
      self.isCasting = true
      self.isChanneling = nil
      self.castID = castID
    end
    if ( not name or isTradeSkill ) then
      self:Hide()
      return
    end
    self:SetMinMaxValues(0, self.maxValue)
    self:SetValue(self.value)
    self.CastBarText:SetText(text)
    self.CastBarSpellIcon:SetTexture(texture)
    self:SetAlpha(1.0)
    self.fadeOut = nil
    self.holdTime = 0
    self:UpdateBorder(notInterruptible)
    if ( self.showCastBar ) then
      self:Show()
    end
  elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
    local _, castID = ...
    if ( not self:IsVisible() ) then
      self:Hide()
    end
    if ( (self.isCasting and event == "UNIT_SPELLCAST_STOP" and castID == self.castID) or
         (self.isChanneling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
      self:SetValue(self.maxValue)
      if ( event == "UNIT_SPELLCAST_STOP" ) then
        self.isCasting = nil
      else
        self.isChanneling = nil
      end
      self:StopCasting()
    end
  elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
    local _, castID = ...
    if ( self:IsShown() and (self.isCasting and castID == self.castID) and not self.fadeOut ) then
      self:SetValue(self.maxValue)
      self.CastBarText:SetText((event == "UNIT_SPELLCAST_FAILED") and "Failed" or "Interrupted")
      self.isCasting = nil
      self.isChanneling = nil
      self:StopCasting(true)
    end
  elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
    if ( self:IsShown() ) then
      local name, _, _, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
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
  elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
    if ( self:IsShown() ) then
      local name, _, _, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)
      if ( not name or isTradeSkill ) then
        self:Hide()
        return
      end
      self.value = ((endTime / 1000) - GetTime())
      self.maxValue = ((endTime - startTime) / 1000)
      self:SetMinMaxValues(0, self.maxValue)
      self:SetValue(self.value)
    end
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
      self:StopCasting()
      return
    end
    self:SetValue(self.value)
  elseif ( self.isChanneling ) then
    self.value = (self.value - elapsed)
    if ( self.value <= 0 ) then
      self.isCasting = nil
      self.isChanneling = nil
      self:StopCasting()
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
    self:Hide()
  end
end
