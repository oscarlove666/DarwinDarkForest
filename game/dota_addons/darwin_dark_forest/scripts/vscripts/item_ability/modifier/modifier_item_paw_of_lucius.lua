modifier_item_paw_of_lucius = class({})

--------------------------------------------------------------------------------

function modifier_item_paw_of_lucius:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_item_paw_of_lucius:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_item_paw_of_lucius:OnCreated( kv )
	if IsServer() then
	  self.rupture_chance = self:GetAbility():GetSpecialValueFor( "rupture_chance" )
	  self.rupture_duration = self:GetAbility():GetSpecialValueFor( "rupture_duration" )
    end
end

--------------------------------------------------------------------------------

function modifier_item_paw_of_lucius:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

--------------------------------------------------------------------------------
function modifier_item_paw_of_lucius:GetModifierAttackSpeedBonus_Constant( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

--------------------------------------------------------------------------------
function modifier_item_paw_of_lucius:GetModifierPreAttack_BonusDamage( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

--------------------------------------------------------------------------------

function modifier_item_paw_of_lucius:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage( self.rupture_chance ) then
			if params.target ~= nil then
				params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_bloodseeker_rupture", { duration = self.rupture_duration } )
				EmitSoundOn( "DOTA_Item.Maim", params.target )
			end
		end
	end
	return 0
end

--------------------------------------------------------------------------------