item_mystic_staff_lua = class({})
LinkLuaModifier( "modifier_item_mystic_staff_lua", "item_ability/modifier/modifier_item_mystic_staff_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function item_mystic_staff_lua:GetIntrinsicModifierName()
	return "modifier_item_mystic_staff_lua"
end

--------------------------------------------------------------------------------