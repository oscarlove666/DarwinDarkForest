creature_gaoler_shock = class({})
LinkLuaModifier( "modifier_gaoler_shock", "creature_ability/modifier/modifier_gaoler_shock", LUA_MODIFIER_MOTION_NONE )
-----------------------------------------------------------------------

function creature_gaoler_shock:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

--------------------------------------------------------------------------------

function creature_gaoler_shock:GetPlaybackRateOverride()
	return 1
end

--------------------------------------------------------------------------------

function creature_gaoler_shock:OnAbilityPhaseStart()
	if IsServer() then
		self.nChannelFX = ParticleManager:CreateParticle( "particles/act_2/storegga_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end

-----------------------------------------------------------------------

function creature_gaoler_shock:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
	end
end

-----------------------------------------------------------------------

function creature_gaoler_shock:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_gaoler_shock", {} )
		EmitSoundOn( "Hero_Razor.SeveringCrest.Loop", self:GetCaster() )
	end
end

-----------------------------------------------------------------------

function creature_gaoler_shock:OnChannelFinish( bInterrpted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_gaoler_shock" )
		StopSoundOn( "Hero_Razor.SeveringCrest.Loop", self:GetCaster() )
	end
end