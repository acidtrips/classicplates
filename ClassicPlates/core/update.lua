--[[

    update.lua

    Contains functions that update nameplate elements.

--]]
local NamePlate = ClassicPlates.NamePlate

local UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, UnitClassification,
      UnitCanAttack, UnitPlayerControlled, UnitIsTapDenied, GetQuestGreenRange, UnitThreatSituation, UnitReaction,
      GetRaidTargetIndex, SetRaidTargetIconTexture, GetNamePlates, CastBar_UpdateIsShown, ipairs =
      UnitIsUnit, UnitEffectiveLevel, UnitExists, UnitClass, UnitHealth, UnitHealthMax, GetUnitName, UnitClassification,
      UnitCanAttack, UnitPlayerControlled, UnitIsTapDenied, GetQuestGreenRange, UnitThreatSituation, UnitReaction,
      GetRaidTargetIndex, SetRaidTargetIconTexture, C_NamePlate.GetNamePlates, CastBar_UpdateIsShown, ipairs

local CLASS_COLORS = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS


local function UnitIsMousedOver(unit)
  return (UnitExists("mouseover") and UnitIsUnit("mouseover", unit) and not UnitIsUnit("target", unit))
end


local function UnitTapIsDenied(unit)
  return (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit))
end


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


function NamePlate:Highlight_Update()
  if ( self.isMouseOver ) then
    if ( not UnitIsMousedOver(self.unit) ) then
      self.NameText:SetTextColor(self.NameText.r, self.NameText.g, self.NameText.b)
      self.isMouseOver = false
    end
  end
end


function NamePlate:Update_Highlight()
  if ( UnitIsMousedOver(self.unit) and not UnitTapIsDenied(self.unit) and not self.inCombat ) then
    self.NameText:SetTextColor(1.0, 1.0, 0.0)
    self.isMouseOver = true
  elseif ( not self.inCombat ) then
    self.NameText:SetTextColor(self.NameText.r, self.NameText.g, self.NameText.b)
  end
end


function NamePlate:Update_Selection()
  local alpha = 1.0
  if ( UnitExists("target") and not UnitIsUnit(self.unit, "target") ) then
    alpha = 0.49
  end
  self:SetAlpha(alpha)
end


function NamePlate:Update_Health()
  local health = UnitHealth(self.unit)
  self.HealthBar:SetValue(health)
end


function NamePlate:Update_MaxHealth()
  local maxHealth = UnitHealthMax(self.unit)
  self.HealthBar:SetMinMaxValues(0, maxHealth)
end


function NamePlate:Update_HealthColor()
  local _, class = UnitClass(self.unit)
  local classColor = CLASS_COLORS[class]
  local r, g, b = 1.0, 0.0, 0.0
  if ( UnitIsPlayer(self.unit) ) then
    if ( not UnitCanAttack("player", self.unit) ) then
      r, g, b = 0.0, 0.0, 1.0
    elseif ( classColor and ClassicPlatesDB.showClassColors ) then
      r, g, b = classColor.r, classColor.g, classColor.b
    end
  else
    if ( UnitTapIsDenied(self.unit) ) then
      r, g, b = 0.5, 0.5, 0.5
    else
      r, g, b = GetUnitColor(self.unit)
    end
  end
  self.HealthBar:SetStatusBarColor(r, g, b)
end


function NamePlate:Update_Threat()
  local hasAggro = not UnitIsPlayer(self.unit) and
        UnitThreatSituation("player", self.unit) or nil
  if ( hasAggro and ClassicPlatesDB.showAggroWarnings ) then
    self.AggroWarning:Show()
  else
    self.AggroWarning:Hide()
  end
end


function NamePlate:Update_Name()
  local name = GetUnitName(self.unit, false)
  local r, g, b = 1.0, 1.0, 1.0
  if ( self.inCombat ) then
    r, g, b = 1.0, 0.0, 0.0
  elseif ( UnitTapIsDenied(self.unit) ) then
    r, g, b = 0.5, 0.5, 0.5
  end
  self.NameText:SetText(name)
  self.NameText:SetTextColor(r, g, b)
  self.NameText.r, self.NameText.g, self.NameText.b = r, g, b
end


function NamePlate:Update_Level()
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


function NamePlate:Update_Classification()
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


function NamePlate:Update_RaidIcon()
  local index = GetRaidTargetIndex(self.unit)
  if ( index ) then
    SetRaidTargetIconTexture(self.RaidTargetIcon, index)
    self.RaidTargetIcon:Show()
  else
    self.RaidTargetIcon:Hide()
  end
end


function NamePlate:Update_CastBar()
  CastBar_UpdateIsShown(self.CastBar)
end


function NamePlate:Update_CombatColor()
  local r, g, b = 1.0, 1.0, 1.0
  if ( self.inCombat ) then
    r, g, b = 1.0, 0.0, 0.0
  elseif ( UnitTapIsDenied(self.unit) ) then
    r, g, b = 0.5, 0.5, 0.5
  end
  self.NameText:SetTextColor(r, g, b)
  self.NameText.r, self.NameText.g, self.NameText.b = r, g, b
end


function NamePlate:Update_All()
  if ( UnitExists(self.unit) ) then
    self:Update_Highlight()
    self:Update_CastBar()
    self:Update_Threat()
    self:Update_RaidIcon()
    self:Update_Selection()
    self:Update_Classification()
    self:Update_Name()
    self:Update_CombatColor()
    self:Update_Level()
    self:Update_MaxHealth()
    self:Update_Health()
    self:Update_HealthColor()
  end
end


function ClassicPlates:CallUpdateFunc(funcName)
  for _, frame in ipairs(GetNamePlates()) do
    frame.NamePlate[funcName](frame.NamePlate)
  end
end


function ClassicPlates:SetUpdateFuncs(frame)
  frame.Update_Highlight = NamePlate.Update_Highlight
  frame.Update_CastBar = NamePlate.Update_CastBar
  frame.Update_Threat = NamePlate.Update_Threat
  frame.Update_RaidIcon = NamePlate.Update_RaidIcon
  frame.Update_Selection = NamePlate.Update_Selection
  frame.Update_Classification = NamePlate.Update_Classification
  frame.Update_Name = NamePlate.Update_Name
  frame.Update_CombatColor = NamePlate.Update_CombatColor
  frame.Update_Level = NamePlate.Update_Level
  frame.Update_MaxHealth = NamePlate.Update_MaxHealth
  frame.Update_Health = NamePlate.Update_Health
  frame.Update_HealthColor = NamePlate.Update_HealthColor
  frame.Update_All = NamePlate.Update_All
  frame.Update_CombatAction = NamePlate.Update_CombatAction
  frame.Highlight_Update = NamePlate.Highlight_Update
  frame.Combat_Update = NamePlate.Combat_Update
end
