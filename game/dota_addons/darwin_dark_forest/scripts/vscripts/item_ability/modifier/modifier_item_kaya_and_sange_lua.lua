
modifier_item_kaya_and_sange_lua = class({})

function modifier_item_kaya_and_sange_lua:IsHidden()
	return true
end
----------------------------------------
function modifier_item_kaya_and_sange_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

----------------------------------------

function modifier_item_kaya_and_sange_lua:OnCreated( kv )

	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.bonus_health = self:GetAbility():GetSpecialValueFor( "bonus_health" )
    self.bonus_health_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )

    self.spell_amplify = self:GetAbility():GetSpecialValueFor( "spell_amplify" )
    self.mana_regen_bonus = self:GetAbility():GetSpecialValueFor( "mana_regen_bonus" )
    self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" )


    self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resist" )
    self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" )
    self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" )


    if IsServer() then
    	AddHealthBonus(self:GetCaster(),self.bonus_health)
    end

end
--------------------------------------------
function modifier_item_kaya_and_sange_lua:OnDestroy()
    if IsServer() then
    	RemoveHealthBonus(self:GetCaster(),self.bonus_health)
    end
end
--------------------------------------------

function modifier_item_kaya_and_sange_lua:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE
	}

	return funcs
end


----------------------------------------

function modifier_item_kaya_and_sange_lua:GetModifierPreAttack_BonusDamage( params )
	return self.bonus_damage
end
----------------------------------------
function modifier_item_kaya_and_sange_lua:GetModifierMagicalResistanceBonus( params )
	return self.magic_resist
end
-----------------------------------------
function modifier_item_kaya_and_sange_lua:GetModifierConstantHealthRegen( params )
	return self.bonus_health_regen
end
-----------------------------------------

function modifier_item_kaya_and_sange_lua:GetModifierSpellAmplify_Percentage( params )
	return self.spell_amplify
end

----------------------------------------


function modifier_item_kaya_and_sange_lua:GetModifierConstantManaRegen( params )
	return self.mana_regen_bonus
end

----------------------------------------


function modifier_item_kaya_and_sange_lua:GetModifierPercentageManacost( params )
	return self.manacost_reduction
end

----------------------------------------


function modifier_item_kaya_and_sange_lua:OnAttackLanded( params )
	if IsServer() then
		local hAttacker = params.attacker
		local hTarget = params.target

		if hAttacker == nil or hAttacker ~= self:GetParent() or hTarget == nil then
			return 0
		end

		if RandomInt(1, 100) < self.maim_chance then

			hTarget:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_item_kaya_and_sange_lua_debuff", { duration = self.maim_duration } )

		end

	end
	return 0
end



