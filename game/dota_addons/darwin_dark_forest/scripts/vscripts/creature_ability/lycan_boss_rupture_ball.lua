
lycan_boss_rupture_ball = class({})

--------------------------------------------------------------------------------

function lycan_boss_rupture_ball:OnAbilityPhaseStart()
	if IsServer() then
		EmitSoundOn( "lycan_lycan_attack_09", self:GetCaster() )
	end

	return true
end

-----------------------------------------------------------------------------

function lycan_boss_rupture_ball:GetPlaybackRateOverride()
	return 0.3
end

--------------------------------------------------------------------------------

function lycan_boss_rupture_ball:OnSpellStart()
	if IsServer() then

		self.attack_speed = self:GetSpecialValueFor( "attack_speed" )
		self.attack_width_initial = self:GetSpecialValueFor( "attack_width_initial" )
		self.attack_width_end = self:GetSpecialValueFor( "attack_width_end" )
		self.attack_distance = self:GetSpecialValueFor( "attack_distance" )
		
		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self.attack_speed = self.attack_speed * ( self.attack_distance / ( self.attack_distance - self.attack_width_initial ) )

		local info = {
			EffectName = "particles/lycanboss_ruptureball_gale.vpcf",
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin(), 
			fStartRadius = self.attack_width_initial,
			fEndRadius = self.attack_width_end,
			vVelocity = vDirection * self.attack_speed,
			fDistance = self.attack_distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		}

		ProjectileManager:CreateLinearProjectile( info )
		EmitSoundOn( "Lycan.RuptureBall", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function lycan_boss_rupture_ball:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) and hTarget:GetUnitName() ~= "npc_dota_forest_camp_chief" then
			EmitSoundOn( "Lycan.RuptureBall.Impact", hTarget );

			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_bloodseeker_rupture", { duration = self:GetSpecialValueFor( "duration" ) } )
		end

		return false
	end
end

--------------------------------------------------------------------------------

