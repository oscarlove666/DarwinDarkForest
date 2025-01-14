modifier_slark_shadow_dance_lua_invisible = class({})

--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_lua_invisible:IsHidden() return false end
function modifier_slark_shadow_dance_lua_invisible:IsPurgable() return false end

--------------------------------------------------------------------------------
function modifier_slark_shadow_dance_lua_invisible:DeclareFunctions()
	local funcs = 
	{
         MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end



function modifier_slark_shadow_dance_lua_invisible:CheckState()
	local state = {
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		[MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end

function modifier_slark_shadow_dance_lua_invisible:OnCreated()
     
     if IsServer() then

     	  self.bonus_movement_speed=self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
     	  local nPX = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		  ParticleManager:SetParticleControlEnt(nPX, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		  ParticleManager:SetParticleControlEnt(nPX, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeR", self:GetParent():GetAbsOrigin(), true)
		  ParticleManager:SetParticleControlEnt(nPX, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeL", self:GetParent():GetAbsOrigin(), true)
		  self:AddParticle(nPX,true,false,0,false,false)
          --隐身以后例子特效隐藏了，需要加一个马甲来显示
          self.hDummy = CreateModifierThinker(self:GetParent(), nil, "modifier_dummy_thinker", {duration = self:GetDuration() + 0.1}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
          local nPX2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_CUSTOMORIGIN, self.hDummy)
		  ParticleManager:SetParticleControlEnt(nPX2, 1, self.hDummy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.hDummy:GetAbsOrigin(), true)
		  local hThinker = self.hDummy:FindModifierByName("modifier_dummy_thinker")
		  hThinker:AddParticle(nPX2, false, false, 15, false, false)
		  self:StartIntervalThink(FrameTime())
     end

end

function modifier_slark_shadow_dance_lua_invisible:GetModifierMoveSpeedBonus_Constant()
	if IsServer() then 
        return self.bonus_movement_speed
	end
end


function modifier_slark_shadow_dance_lua_invisible:OnIntervalThink()
	if self.hDummy and not self.hDummy:IsNull() then
		self.hDummy:SetAbsOrigin(self:GetParent():GetAbsOrigin())
	end
end