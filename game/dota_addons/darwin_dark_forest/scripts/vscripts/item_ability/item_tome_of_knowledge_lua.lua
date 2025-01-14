item_tome_of_knowledge_lua = class({})


function item_tome_of_knowledge_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()

        hCaster:EmitSound("Item.TomeOfKnowledge")
        self.xp_bonus = self:GetSpecialValueFor( "xp_bonus" )

        if GameRules.bPveMap then
           self.xp_bonus=self.xp_bonus*0.333
        end

        self:SpendCharge()
        local nPlayerId = hCaster:GetMainControllingPlayer()
        local hHero =  PlayerResource:GetSelectedHeroEntity(nPlayerId)
        
        if hHero then
          hHero.nCustomExp=hHero.nCustomExp+self.xp_bonus
          --计算等级
          local nNewLevel=CalculateNewLevel(hHero)
          --如果 升级
       	  if nNewLevel~=hHero.nCurrentCreepLevel then
       	   	 hHero.nCurrentCreepLevel=nNewLevel
	         LevelUpAndEvolve(nPlayerId,hHero)
	         end
            --更新UI显示
           CustomNetTables:SetTableValue( "player_info", tostring(nPlayerId), {current_exp=hHero.nCustomExp-vEXP_TABLE[nNewLevel],next_level_need=vEXP_TABLE[nNewLevel+1]-vEXP_TABLE[nNewLevel],perk_table=GameMode.vPlayerPerk[nPlayerId] } )       
        end
	end
end
