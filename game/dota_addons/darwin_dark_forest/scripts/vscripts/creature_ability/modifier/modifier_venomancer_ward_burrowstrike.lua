modifier_venomancer_ward_burrowstrike = class ({})

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:OnCreated( kv )
	if IsServer() then
		self.vTarget =  Vector( kv["x"], kv["y"], kv["z"] )
		self.vDir = self.vTarget - self:GetParent():GetOrigin()
		self.vDir = self.vDir:Normalized()
		self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
 		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
        self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
        self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
        self.knockback_distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )
        self.knockback_height = self:GetAbility():GetSpecialValueFor( "knockback_height" )


		self:GetParent():AddEffects( EF_NODRAW )
		self.nFXIndex = -1
		self.nFXIndex2 = -1
		self.nFXIndex3 = -1
		self:OnIntervalThink()
		self:StartIntervalThink( 0.33 )
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
			return
		end
	end
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveEffects( EF_NODRAW )
		
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false then
				local damageInfo = 
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
				}

				ApplyDamage( damageInfo )
				local kv =
				{
					center_x = self:GetParent():GetOrigin().x,
					center_y = self:GetParent():GetOrigin().y,
					center_z = self:GetParent():GetOrigin().z,
					should_stun = true, 
					duration = self.stun_duration,
					knockback_duration = self.stun_duration,
					knockback_distance = self.knockback_distance,
					knockback_height = self.knockback_height,
				}
				enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", kv )

				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_impact_physical.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
				local vDirection = enemy:GetOrigin() - self:GetParent():GetOrigin()
				vDirection.z = 0.0
				vDirection = vDirection:Normalized()

				ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
				ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end	
	end
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:OnIntervalThink()
	if IsServer() then
		if self.nFXIndex ~= -1 then
			ParticleManager:DestroyParticle( self.nFXIndex, false )
		end
		if self.nFXIndex2 ~= -1 then
			ParticleManager:DestroyParticle( self.nFXIndex2, false )
		end
		if self.nFXIndex3 ~= -1 then
			ParticleManager:DestroyParticle( self.nFXIndex3, false )
		end

		self.nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControlForward( self.nFXIndex, 0, self:GetParent():GetForwardVector() )
		self.nFXIndex2 = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex2, 0, self:GetParent():GetOrigin() + RandomVector( 1 ) * RandomInt( 25, 75 ) )
		ParticleManager:SetParticleControlForward( self.nFXIndex2, 0, self:GetParent():GetRightVector() )
		self.nFXIndex3 = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex3, 0, self:GetParent():GetOrigin() + RandomVector( 1 ) * RandomInt( 25, 75 ) )
		ParticleManager:SetParticleControlForward( self.nFXIndex3, 0, -self:GetParent():GetRightVector() )

		EmitSoundOn( "Hero_NyxAssassin.Burrow.In", self:GetParent() )

	end
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		local vNewLocation = self:GetParent():GetOrigin() + self.vDir * self.speed * dt
		me:SetOrigin( vNewLocation )
	end
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_venomancer_ward_burrowstrike:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end


