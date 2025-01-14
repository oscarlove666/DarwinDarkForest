local particles = {
    "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_necro_souls_hero.vpcf",    
    "particles/econ/events/ti6/hero_levelup_ti6_godray.vpcf",
    "particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf",
    "particles/items2_fx/veil_of_discord.vpcf",
    "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf",
    "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf",
    "particles/items2_fx/rod_of_atos.vpcf",
    "particles/items4_fx/combo_breaker_buff.vpcf",
    "particles/units/heroes/hero_centaur/centaur_return.vpcf",
    'particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf',
    'particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf',
    'particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf',
    'particles/units/heroes/hero_meepo/meepo_geostrike_ambient.vpcf',
    'particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf',

}

local sounds = {
    "soundevents/game_sounds.vsndevts",
    "soundevents/game_sounds_ambient.vsndevts",
    "soundevents/game_sounds_items.vsndevts",
    "soundevents/soundevents_dota.vsndevts",
    "soundevents/game_sounds_dungeon.vsndevts",
    "soundevents/game_sounds_dungeon_enemies.vsndevts",
    "soundevents/game_sounds_winter_2018.vsndevts",
    "soundevents/game_sounds_creeps.vsndevts",
    "soundevents/game_sounds_ui.vsndevts",
}



local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            --忽略那些预载入单位
            if not string.find(key, "npc_precache_") then
               PrecacheEverythingFromTable( context, value )
            end
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
            end
            if string.find(value, "vsndevts") then            
                PrecacheResource( "soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_heroes_custom.txt",
        "scripts/npc/npc_items_custom.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            --print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end



return function(context)

    PrecacheEverythingFromKV(context)
    
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end

    PrecacheUnitByNameSync("npc_dota_hero_broodmother", context, -1)

end

