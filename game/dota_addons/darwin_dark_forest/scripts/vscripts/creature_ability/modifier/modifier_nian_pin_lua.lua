modifier_nian_pin_lua = class({})

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:OnCreated( kv )
	self.dismember_damage = self:GetAbility():GetSpecialValueFor( "dismember_damage" )
	self.tick_rate = self:GetAbility():GetSpecialValueFor( "tick_rate" )
	self.strength_damage_scepter = self:GetAbility():GetSpecialValueFor( "strength_damage_scepter" )

	if IsServer() then
		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:OnDestroy()
	if IsServer() then
		self:GetCaster():InterruptChannel()
	end
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:OnIntervalThink()
	if IsServer() then
		local flDamage = self.dismember_damage

		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}

		ApplyDamage( damage )
		EmitSoundOn( "Hero_Pudge.Dismember", self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_nian_pin_lua:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

