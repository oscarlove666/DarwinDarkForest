--此modifier对普通单位无用
--LinkLuaModifier( "modifier_item_mute", "modifiers/modifier_item_mute", LUA_MODIFIER_MOTION_NONE )

--[物品控制器，控制物品掉落，继承等规则]


if ItemController == nil then
  ItemController = {}
  ItemController.__index = ItemController
end


function ItemController:Init()
    
    ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(ItemController, "OnItemPickUp"), self)
    ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(ItemController, "OnNpcGoalReached"), self)
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(ItemController, "OnGameRulesStateChange"), self)


    --载入物品
    local vItemsKV = LoadKeyValues('scripts/npc/npc_items_custom.txt')

    -- 携带物品的概率
    self.flItemCarryChance=1

    -- Tie 总数
    self.nTotalTieNum=6

    --掉落物品的概率
    self.flItemDropChance=0.65

    --二维数组
    self.vItemsTieTable = {}
    for i=1,self.nTotalTieNum do
        self.vItemsTieTable[i]={}
    end

    --大于价格2950，但是归于Tie5的物品
    local vTie5Exception={
        item_reaver_lua=true,
        item_relic=true,
        item_eagle_lua=true,
    }

    -- 处理物品 kv 首先排序
    local vItems={}
    local vToDoItems={}

    self.vTextureNameMap={}

    for sItemName, vData in pairs(vItemsKV) do
        if vData and type(vData) == "table" then
            if vData.ItemCost~=nil and (1~=vData.ItemRecipe)  then
                vData.sItemName=sItemName
                table.insert(vItems,vData)
                self.vTextureNameMap[sItemName]=vData.AbilityTextureName
            end
        end
    end
    -- 按照 物品价格排序
    table.sort(vItems,function(a,b) return a.ItemCost<b.ItemCost end )

    --大于3200的加入 Tie6 ，其他加入1-5的预处理分组
    for _,v in pairs(vItems) do
        if v.ItemCost>2950 and vTie5Exception[v.sItemName]==nil then
           table.insert(self.vItemsTieTable[6],v.sItemName)
        else
           table.insert(vToDoItems,v)
        end
    end       

    -- 剩下五组 平分物品
    for i=1,self.nTotalTieNum-1 do
        local nPerTieNum= math.floor(#vToDoItems/(self.nTotalTieNum-1))
        local nTemp=1+(i-1)*nPerTieNum
        for j=nTemp,nTemp+nPerTieNum-1 do
              table.insert(self.vItemsTieTable[i],vToDoItems[j].sItemName)
        end
        -- 将多余出来的一并加入最高Tie
        if i ==self.nTotalTieNum-1 then
          for j=1+i*nPerTieNum,#vToDoItems do
             table.insert(self.vItemsTieTable[i],vToDoItems[j].sItemName)
          end
        end
    end

    for k,v in pairs(self.vItemsTieTable) do
        print("Tie----"..k.."--------")
        for kt,vt in pairs(self.vItemsTieTable[k]) do
            print(vt)
        end
    end
  
end



function ItemController:OnGameRulesStateChange()

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    self:Begin()
  end

end

function ItemController:Begin()
  
    --PVE模式不出信使
    if not GameRules.bPveMap then
        Timers:CreateTimer(110, function()
            ItemController:SpawnCourier()
            return 110
        end)
    end

    --清理地面过期物品
    Timers:CreateTimer(5, function()
        ItemController:TryRemoveOverTimeItems()
        return 5
    end)

end



function ItemController:CreateItemForNeutraulByChance(hUnit)

    --对信使无效
    if hUnit:GetAttackCapability() == 0 then
        return
    end

    if RandomInt(1, 100)/100 <= self.flItemCarryChance then
        
        local nTieNum =  math.ceil(hUnit:GetLevel()/2)
        if nTieNum >self.nTotalTieNum then nTieNum=self.nTotalTieNum end
        local sItemName = self.vItemsTieTable[nTieNum][RandomInt(1, #self.vItemsTieTable[nTieNum])]
        hUnit:AddItemByName( sItemName )

    end
    
end


function ItemController:DropItemByChance(hUnit)
       
    for i=0,11 do --遍历物品
        local hItem = hUnit:GetItemInSlot(i)
        if hItem and self:RollDiceToDrop(hUnit) then
          local hNewItem = CreateItem( hItem:GetName(), nil, nil )
          hNewItem:SetPurchaseTime( 0 )
          if hNewItem:IsPermanent() and hNewItem:GetShareability() == ITEM_FULLY_SHAREABLE then
             hNewItem:SetStacksWithOtherOwners( true )
          end
          local hNewWorldItem = CreateItemOnPositionSync( hUnit:GetOrigin(), hNewItem )
          hNewItem:LaunchLoot( false, RandomFloat( 300, 450 ), 0.5, hUnit:GetOrigin() + RandomVector( RandomFloat( 200, 300 ) ) )
          Timers:CreateTimer({
            endTime = 0.5, 
            callback = function()
            EmitGlobalSound( "ui.inv_drop_highvalue" )
            end
          })
          UTIL_Remove(hItem)             
        end

    end

end


function ItemController:RollDiceToDrop(hUnit)

    local bDropItem = false

    --玩家与野怪掉率不同,信使必掉物品
    if hUnit:GetUnitName()== "npc_dota_treasure_courier" then
      bDropItem=true
    elseif hUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
       if RandomInt(1, 100)/100 < self.flItemDropChance then
           bDropItem=true
       end
    else
       --根据玩家等级 计算掉率
       local flPlayerItemDropChance = CalculateItemDropChance(hUnit)
       if RandomInt(1, 100)/100 < flPlayerItemDropChance then
           bDropItem=true
       end
    end

    return bDropItem

end




-- 将当前物品信息 （名，堆叠，冷却）作为数组记录到英雄身上，进化或者退化的时候 重新给单位加上物品
function ItemController:RecordItemsInfo(hHero)

    local vItemInfos={}
    if not hHero.hCurrentCreep:IsNull() then
        for i=0,11 do --遍历物品
            local hItem = hHero.hCurrentCreep:GetItemInSlot(i)
            local vItemInfo={}
            if hItem then
               vItemInfo.sItemName =hItem:GetName()
               vItemInfo.flRemainingCoolDown = hItem:GetCooldownTimeRemaining()
               vItemInfo.nCurrentCharges=hItem:GetCurrentCharges()
               table.insert(vItemInfos,vItemInfo)
               --圣剑移除掉
               if hItem:GetName()=="item_rapier" then
                     UTIL_Remove(hItem)     
               end
            end
        end
    end
    hHero.vItemInfos=vItemInfos
end



-- 还原物品
function ItemController:RestoreItems(hHero)
    
    if hHero.vItemInfos and hHero.hCurrentCreep and (not hHero.hCurrentCreep:IsNull()) and hHero.hCurrentCreep:IsAlive() then

        for _,vItemInfo in pairs(hHero.vItemInfos) do
            
            local hNewItem =  hHero.hCurrentCreep:AddItemByName(vItemInfo.sItemName)
            hNewItem:SetCurrentCharges(vItemInfo.nCurrentCharges)
            hNewItem:StartCooldown(vItemInfo.flRemainingCoolDown)
            hNewItem:SetPurchaser(hHero)
        end
    end
    
end


-- 物品捡起 重新添加 这样才能触发合成
function ItemController:OnItemPickUp(event)

  local hItem = EntIndexToHScript( event.ItemEntityIndex )
  if event.UnitEntityIndex then 
      local hUnit=EntIndexToHScript( event.UnitEntityIndex )
      local sItemName=hItem:GetName()
      local nCharges=hItem:GetCurrentCharges()

      local nPlayerId = hUnit:GetOwner():GetPlayerID()
      local hHero =  PlayerResource:GetSelectedHeroEntity(nPlayerId)
      
      local hPurchaser=hItem:GetPurchaser()
      
      --不处理 神符
      if string.find(sItemName,"item_rune_") ~= 1 then
          --1共享物品  2无拥有者 3拥有者是自己 4拥有者是敌人 可以拾取

          --拾取成功的标志位
          local bSuccessFlag=false
          if  hItem:GetShareability() == ITEM_FULLY_SHAREABLE or (hPurchaser ==nil) or (hPurchaser==hHero)  or (PlayerResource:GetTeam(hPurchaser:GetPlayerID())~= PlayerResource:GetTeam(nPlayerId)) then
             bSuccessFlag=true
          --队友的物品 不允许拾取 直接摧毁
          else
            local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, hUnit )
            ParticleManager:SetParticleControl( nFXIndex, 0, hUnit:GetOrigin() )
            ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
            ParticleManager:ReleaseParticleIndex( nFXIndex )
            Notifications:BottomToTeam(PlayerResource:GetTeam(nPlayerId), {text="#not_allow_teammate_item", duration=2, style={color="Red"}})
            hUnit:EmitSound("DOTA_Item.VeilofDiscord.Activate")
          end

          --先移除
          UTIL_Remove(hItem)
          --再添加
          if  bSuccessFlag then
             local hNewItem=hUnit:AddItemByName(sItemName)
             hNewItem:SetPurchaser(hHero)
             hNewItem:SetCurrentCharges(nCharges)
          end
      end
  end
  
end



--计算 生物的物品掉率
function CalculateItemDropChance(hUnit)
              
    local flItemDropChance = 0.4

    if hUnit and hUnit.GetLevel and GameRules.nAverageLevel then

        if hUnit:GetLevel() >= GameRules.nAverageLevel+3 then
           flItemDropChance=0.48
        end
        
        if hUnit:GetLevel() == GameRules.nAverageLevel+2 then
           flItemDropChance=0.4
        end

        if hUnit:GetLevel() == GameRules.nAverageLevel+1 then
           flItemDropChance=0.32
        end

        if hUnit:GetLevel() == GameRules.nAverageLevel then
           flItemDropChance=0.16
        end

        if hUnit:GetLevel() == GameRules.nAverageLevel-1 then
           flItemDropChance=0.08
        end

        if hUnit:GetLevel() <= GameRules.nAverageLevel-2 then
           flItemDropChance=0
        end
    end

    print("AverageLevel: "..GameRules.nAverageLevel.."flItemDropChance: "..flItemDropChance)
    return  flItemDropChance
end



--计算信使落点
function ItemController:FindCourierDestination()
    local maxTry = 10
    local vRandomPos = GetRandomValidPosition()
    local vCenter = Vector(0,0,0)

    while (vRandomPos - vCenter):Length2D() < 2000 do
        vRandomPos =GetRandomValidPosition()
        maxTry = maxTry - 1
        if maxTry <= 0 then
            vRandomPos =GetRandomValidPosition()
            break
        end
    end
    return vRandomPos
end

--随机选择 信使携带的物品
function ItemController:ChooseCourierItem()

    local nTieNum =  math.ceil(GameRules.nAverageLevel/2)
    nTieNum=nTieNum+2
    if nTieNum >self.nTotalTieNum then nTieNum=self.nTotalTieNum end
    local sItemName = self.vItemsTieTable[nTieNum][RandomInt(1, #self.vItemsTieTable[nTieNum])]
    return sItemName

end




function ItemController:SpawnCourier()

  EmitGlobalSound( "powerup_05" )

  -- spawn the item
  local startLocation = Vector( 0, 0, 700 )
  local treasureCourier = CreateUnitByName( "npc_dota_treasure_courier" , startLocation, true, nil, nil, DOTA_TEAM_NEUTRALS )
  local treasureAbility = treasureCourier:FindAbilityByName( "dota_ability_treasure_courier" )
  treasureAbility:SetLevel( 1 )
   
  local sCourierItemName = ItemController:ChooseCourierItem()
  local hItem=treasureCourier:AddItemByName(sCourierItemName)

  local  vDestinationLocation = ItemController:FindCourierDestination()
  
  local vDeStinationData =
  {
    origin = "0 0 384",
    targetname = "item_spawn"
  }

  local vDestination = Entities:FindByName( nil, "item_spawn" )

  if vDestination == nil then
    vDestination = SpawnEntityFromTableSynchronous( "path_track", vDeStinationData )
  end
  
  vDestination:SetAbsOrigin(vDestinationLocation)

  treasureCourier:SetInitialGoalEntity(vDestination)

  CustomGameEventManager:Send_ServerToAllClients( "courier_spawned", {item_texture_name=(ItemController.vTextureNameMap[sCourierItemName] or sCourierItemName)  } )

  EmitGlobalSound( "powerup_05" )

  local particleTreasure = ParticleManager:CreateParticle( "particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN, treasureCourier )
  ParticleManager:SetParticleControlEnt( particleTreasure, PATTACH_ABSORIGIN, treasureCourier, PATTACH_ABSORIGIN, "attach_origin", treasureCourier:GetAbsOrigin(), true )
  treasureCourier:Attribute_SetIntValue( "particleID", particleTreasure )

  Timers:CreateTimer(0.1, function()
        if  treasureCourier and not treasureCourier:IsNull() and treasureCourier:IsAlive() then
          for nTeam = 0, (DOTA_TEAM_COUNT-1) do
              AddFOWViewer(nTeam, treasureCourier:GetAbsOrigin(), 700, 0.35, false)
          end
          return 0.3
        else
          return nil
        end
   end)

end


function ItemController:OnNpcGoalReached( event )
  local npc = EntIndexToHScript( event.npc_entindex )
  if npc:GetUnitName() == "npc_dota_treasure_courier" then
    ItemController:TreasureDrop( npc )
  end
end



function ItemController:TreasureDrop( treasureCourier )
  --Create the death effect for the courier

  local spawnPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
  spawnPoint.z = 400
  local fxPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
  fxPoint.z = 400
  local deathEffects = ParticleManager:CreateParticle( "particles/treasure_courier_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
  ParticleManager:SetParticleControl( deathEffects, 0, fxPoint )
  ParticleManager:SetParticleControlOrientation( deathEffects, 0, treasureCourier:GetForwardVector(), treasureCourier:GetRightVector(), treasureCourier:GetUpVector() )
  EmitGlobalSound( "lockjaw_Courier.Impact" )
  EmitGlobalSound( "lockjaw_Courier.gold_big" )
   
  --信使携带的物品掉落出来
  ItemController:DropItemByChance(treasureCourier)

  --Knock people back from the treasure
  ItemController:KnockBackFromTreasure( spawnPoint, 350, 0.25, 250, 75 )
    
  --Destroy the courier
  UTIL_Remove( treasureCourier )
end



function ItemController:KnockBackFromTreasure( center, radius, knockback_duration, knockback_distance, knockback_height )

  local knockBackUnits = FindUnitsInRadius( DOTA_TEAM_NOTEAM, center, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
 
  local modifierKnockback =
  {
    center_x = center.x,
    center_y = center.y,
    center_z = center.z,
    duration = knockback_duration,
    knockback_duration = knockback_duration,
    knockback_distance = knockback_distance,
    knockback_height = knockback_height,
  }

  for _,unit in pairs(knockBackUnits) do
     -- print( "knock back unit: " .. unit:GetName() )
    unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback );
  end
end



function ItemController:TryRemoveOverTimeItems()
  
  for _,hItem in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
      if hItem and hItem.GetCreationTime and GameRules:GetGameTime()-hItem:GetCreationTime() > 180 then
          local hContainedItem = hItem:GetContainedItem()
          local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
          ParticleManager:SetParticleControl( nFXIndex, 0, hItem:GetOrigin() )
          ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
          ParticleManager:ReleaseParticleIndex( nFXIndex )
          local hInventoryItem = hItem:GetContainedItem()
          if hInventoryItem then
             print("Removing item "..hInventoryItem:GetName()) 
             UTIL_Remove( hInventoryItem )
          end
          UTIL_Remove( hItem )
      end
  end

end