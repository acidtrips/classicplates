--[[

    update.lua

    Contains functions that update nameplate elements.

--]]
local UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, UnitTreatAsPlayerForDisplay, UnitClassification,
      UnitCanAttack, UnitIsTapDenied, GetQuestGreenRange, UnitThreatSituation, UnitReaction, GetRaidTargetIndex, SetRaidTargetIconTexture =
      UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, UnitTreatAsPlayerForDisplay, UnitClassification,
      UnitCanAttack, UnitIsTapDenied, GetQuestGreenRange, UnitThreatSituation, UnitReaction, GetRaidTargetIndex, SetRaidTargetIconTexture


local function GetUnitLevelColor(level)
  local diff = (level - UnitEffectiveLevel("player"))
  if ( diff >= 5 ) then
    return {r = 1.00, g = 0.10, b = 0.10}
  elseif ( diff >= 3 ) then
    return {r = 1.00, g = 0.50, b = 0.25}
  elseif ( diff >= -4 ) then
    return {r = 1.00, g = 1.00, b = 0.10}
  elseif ( -diff <= GetQuestGreenRange() ) then
    return {r = 0.43, g = 0.93, b = 0.43}
  else
    return {r = 0.70, g = 0.70, b = 0.70}
  end
end


local function GetUnitColor(unit)
  local reaction = UnitReaction(unit, "player")
  if ( reaction >= 4 ) then
    return 0.0, 1.0, 0.0
  end
  return 1.0, 0.0, 0.0
end


function NamePlateMixin:Update_Selection()
  local alpha = 1.0
  if ( UnitExists("target") and not UnitIsUnit(self.unit, "target") ) then
    alpha = 0.49
  end
  self:SetAlpha(alpha)
end


function NamePlateMixin:Update_Health()
  local health = UnitHealth(self.unit)
  self.HealthBar:SetValue(health)
end


function NamePlateMixin:Update_MaxHealth()
  local maxHealth = UnitHealthMax(self.unit)
  self.HealthBar:SetMinMaxValues(0, maxHealth)
end


function NamePlateMixin:Update_HealthColor()
  local _, class = UnitClass(self.unit)
  local classColor = RAID_CLASS_COLORS[class]
  local r, g, b = 1.0, 0.0, 0.0
  if ( UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay(self.unit) ) then
    if ( not UnitCanAttack("player", self.unit) ) then
      r, g, b = 0.0, 0.0, 1.0
    elseif ( classColor and ClassicPlatesDB.showClassColors ) then
      r, g, b = classColor.r, classColor.g, classColor.b
    end
  else
    if ( UnitIsTapDenied(self.unit) ) then
      r, g, b = 0.5, 0.5, 0.5
    else
      r, g, b = GetUnitColor(self.unit)
    end
  end
  self.HealthBar:SetStatusBarColor(r, g, b)
end


function NamePlateMixin:Update_Threat()
  local hasAggro = not (UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay(self.unit)) and
        UnitThreatSituation("player", self.unit) or nil
  if ( hasAggro and ClassicPlatesDB.showAggroWarnings ) then
    self.AggroWarning:Show()
  else
    self.AggroWarning:Hide()
  end
end


function NamePlateMixin:Update_Name()
  local name = GetUnitName(self.unit)
  self.NameText:SetText(name)
end


function NamePlateMixin:Update_NameColor()
  local r, g, b = 1.0, 1.0, 1.0
  if ( UnitIsTapDenied(self.unit) ) then
    r, g, b = 0.5, 0.5, 0.5
  else
    if ( self.isInCombat ) then
      r, g, b = 1.0, 0.0, 0.0
    elseif ( self.isHighlighted ) then
      r, g, b = 1.0, 1.0, 0.0
    end
  end
  self.NameText:SetTextColor(r, g, b)
end


function NamePlateMixin:Update_Level()
  local level = UnitEffectiveLevel(self.unit)
  if ( level > 0 ) then
    local color = GetUnitLevelColor(level)
    self.LevelText:SetText(level)
    self.LevelText:SetTextColor(color.r, color.g, color.b)
    self.LevelText:Show()
    self.HighLevelIcon:Hide()
  else
    self.LevelText:Hide()
    self.HighLevelIcon:Show()
  end
end


function NamePlateMixin:Update_Classification()
  local mobType = UnitClassification(self.unit)
  if ( mobType == "rare" or
       mobType == "rareelite" or
       mobType == "elite" or
       mobType == "worldboss" ) then
    self.EliteIcon:Show()
  else
    self.EliteIcon:Hide()
  end
end


function NamePlateMixin:Update_RaidIcon()
  local index = GetRaidTargetIndex(self.unit)
  if ( index ) then
    SetRaidTargetIconTexture(self.RaidTargetIcon, index)
    self.RaidTargetIcon:Show()
  else
    self.RaidTargetIcon:Hide()
  end
end


function NamePlateMixin:Update_CastBar()
  self.CastBar:UpdateIsShown()
end


function NamePlateMixin:Update_All()
  if ( UnitExists(self.unit) ) then
    self:Update_Highlight()
    self:Update_CastBar()
    self:Update_Threat()
    self:Update_RaidIcon()
    self:Update_Selection()
    self:Update_Classification()
    self:Update_Name()
    self:Update_NameColor()
    self:Update_Level()
    self:Update_MaxHealth()
    self:Update_Health()
    self:Update_HealthColor()
  end
end
