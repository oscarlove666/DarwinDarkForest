modifier_item_preserved_skull = class({})

--------------------------------------------------------------------------------

function modifier_item_preserved_skull:IsHidden() 
	return true
end

--------------------------------------------------------------------------------

function modifier_item_preserved_skull:IsPurgable()
	return false
end

----------------------------------------

function modifier_item_preserved_skull:IsAura()
	return true
end

----------------------------------------

function modifier_item_preserved_skull:GetModifierAura()
	return  "modifier_item_preserved_skull_effect"
end

----------------------------------------

function modifier_item_preserved_skull:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

----------------------------------------

function modifier_item_preserved_skull:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

----------------------------------------

function modifier_item_preserved_skull:GetAuraRadius()
	return self.radius
end

----------------------------------------

function modifier_item_preserved_skull:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

