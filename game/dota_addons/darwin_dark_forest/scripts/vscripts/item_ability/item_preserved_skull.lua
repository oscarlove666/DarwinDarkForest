item_preserved_skull = class({})
LinkLuaModifier( "modifier_item_preserved_skull", "item_ability/modifier/modifier_item_preserved_skull", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_preserved_skull_effect", "item_ability/modifier/modifier_item_preserved_skull_effect", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_preserved_skull:GetIntrinsicModifierName()
	return "modifier_item_preserved_skull"
end

--------------------------------------------------------------------------------