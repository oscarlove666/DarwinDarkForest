LinkLuaModifier( "modifier_item_bottle_lua_effect", "item_ability/modifier/modifier_item_bottle_lua_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_bottle_lua_texture_controller", "item_ability/modifier/modifier_item_bottle_lua_texture_controller", LUA_MODIFIER_MOTION_NONE )




item_bottle_lua = class({})


function item_bottle_lua:GetIntrinsicModifierName() return "modifier_item_bottle_lua_texture_controller" end


function item_bottle_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
      local nCharges = self:GetCurrentCharges()
      if nCharges > 0 then
        hCaster:AddNewModifier(hCaster, self, "modifier_item_bottle_lua_effect", {duration = self:GetSpecialValueFor("restore_time")})
        self:SetCurrentCharges(nCharges - 1)
        hCaster:EmitSound("Bottle.Drink")
        self.nCharges=nCharges-1
      end
	end
end




function item_bottle_lua:GetAbilityTextureName()
    return self.sTextureName
end
