--[[

    update.lua

    Contains functions that update nameplate elements.

--]]
local UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, GetThreatStatusColor,
      UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitClassification, UnitCanAttack, UnitIsTapDenied,
      UnitThreatSituation, UnitReaction, GetRaidTargetIndex, SetRaidTargetIconTexture, GetCreatureDifficultyColor =
      UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, GetThreatStatusColor,
      UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitClassification, UnitCanAttack, UnitIsTapDenied,
      UnitThreatSituation, UnitReaction, GetRaidTargetIndex, SetRaidTargetIconTexture, GetCreatureDifficultyColor


local function IsUnitTapDenied(unit)
  return not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)
end


local function GetUnitReactionColor(unit)
  local reaction = UnitReaction(unit, "player")
  if ( reaction and reaction >= 4 ) then
    return 0.0, 1.0, 0.0
  end
  return 1.0, 0.0, 0.0
end


function NamePlateMixin:UpdateSelection()
  local alpha = 1.0
  if ( UnitExists("target") and not UnitIsUnit(self.unit, "target") ) then
    alpha = 0.49
  end
  self:SetAlpha(alpha)
end


function NamePlateMixin:UpdateHealth()
  local health = UnitHealth(self.unit)
  self.HealthBar:SetValue(health)
end


function NamePlateMixin:UpdateMaxHealth()
  local maxHealth = UnitHealthMax(self.unit)
  self.HealthBar:SetMinMaxValues(0, maxHealth)
end


function NamePlateMixin:UpdateHealthColor()
  local _, class = UnitClass(self.unit)
  local classColor = RAID_CLASS_COLORS[class]
  local r, g, b = 1.0, 0.0, 0.0
  if ( UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay(self.unit) ) then
    if ( not UnitCanAttack("player", self.unit) ) then
      r, g, b = 0.0, 0.0, 1.0
    elseif ( classColor and self.options.showClassColors ) then
      r, g, b = classColor.r, classColor.g, classColor.b
    end
  else
    if ( IsUnitTapDenied(self.unit) ) then
      r, g, b = 0.5, 0.5, 0.5
    else
      r, g, b = GetUnitReactionColor(self.unit)
    end
  end
  self.HealthBar:SetStatusBarColor(r, g, b)
end


function NamePlateMixin:UpdateThreat()
  if ( not (UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay(self.unit)) ) then
    local status = UnitThreatSituation("player", self.unit)
    if ( status and status > 0 and self.options.showAggroWarnings ) then
      self.AggroWarning:SetVertexColor(GetThreatStatusColor(status))
      self.AggroWarning:Show()
    else
      self.AggroWarning:Hide()
    end
  else
    self.AggroWarning:Hide()
  end
end


function NamePlateMixin:UpdateName()
  local name = GetUnitName(self.unit)
  self.NameText:SetText(name)
end


function NamePlateMixin:UpdateNameColor()
  local r, g, b = 1.0, 1.0, 1.0
  if ( IsUnitTapDenied(self.unit) ) then
    r, g, b = 0.5, 0.5, 0.5
  else
    if ( self.isInCombat ) then
      r, g, b = 1.0, 0.0, 0.0
    elseif ( self.isHighlighted ) then
      r, g, b = 1.0, 1.0, 0.0
    end
  end
  self.NameText:SetVertexColor(r, g, b)
end


function NamePlateMixin:UpdateLevel()
  local level = UnitEffectiveLevel(self.unit)
  if ( level > 0 ) then
    local color = GetCreatureDifficultyColor(level)
    self.LevelText:SetText(level)
    self.LevelText:SetVertexColor(color.r, color.g, color.b)
    self.LevelText:Show()
    self.HighLevelIcon:Hide()
  else
    self.LevelText:Hide()
    self.HighLevelIcon:Show()
  end
end


function NamePlateMixin:UpdateClassification()
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


function NamePlateMixin:UpdateRaidIcon()
  local index = GetRaidTargetIndex(self.unit)
  if ( index ) then
    SetRaidTargetIconTexture(self.RaidTargetIcon, index)
    self.RaidTargetIcon:Show()
  else
    self.RaidTargetIcon:Hide()
  end
end


function NamePlateMixin:UpdateCastBar()
  self.CastBar:UpdateIsShown(self.options)
end


function NamePlateMixin:UpdateAll()
  if ( UnitExists(self.unit) ) then
    self:UpdateHighlight()
    self:UpdateCastBar()
    self:UpdateThreat()
    self:UpdateRaidIcon()
    self:UpdateSelection()
    self:UpdateClassification()
    self:UpdateName()
    self:UpdateNameColor()
    self:UpdateLevel()
    self:UpdateMaxHealth()
    self:UpdateHealth()
    self:UpdateHealthColor()
  end
end
