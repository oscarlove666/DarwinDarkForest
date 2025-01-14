
modifier_item_lifestone = class({})

------------------------------------------------------------------------------

function modifier_item_lifestone:IsHidden() 
	return true
end

--------------------------------------------------------------------------------

function modifier_item_lifestone:IsPurgable()
	return false
end

----------------------------------------

function modifier_item_lifestone:OnCreated( kv )
	self.hp_regen = self:GetAbility():GetSpecialValueFor( "hp_regen" )
	self.bonus_health = self:GetAbility():GetSpecialValueFor( "bonus_health" )
	if IsServer() then
    	AddHealthBonus(self:GetCaster(),self.bonus_health)
    end
end

--------------------------------------------------------------------------------
function modifier_item_lifestone:OnDestroy()
    if IsServer() then
    	RemoveHealthBonus(self:GetCaster(),self.bonus_health)
    end
end
--------------------------------------------------------------------------------

function modifier_item_lifestone:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_item_lifestone:GetModifierConstantHealthRegen( params )
	return self.hp_regen
end

--------------------------------------------------------------------------------

