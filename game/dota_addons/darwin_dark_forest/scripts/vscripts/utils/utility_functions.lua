--[[ utility_functions.lua ]]

---------------------------------------------------------------------------
-- Handle messages
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

--将常数字符串转为Int
function ConvertConstStrToInt(sConstant)
    if sConstant=="DOTA_UNIT_CAP_NO_ATTACK" then
        return DOTA_UNIT_CAP_NO_ATTACK
    end
    if sConstant=="DOTA_UNIT_CAP_MELEE_ATTACK" then
        return DOTA_UNIT_CAP_MELEE_ATTACK
    end
    if sConstant=="DOTA_UNIT_CAP_RANGED_ATTACK" then
        return DOTA_UNIT_CAP_RANGED_ATTACK
    end
end

function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end


function GetRandomValidPosition(vTopLeft,vDownRight)
    
    local minx = GetWorldMinX()
    local maxx = GetWorldMaxX()
    local miny = GetWorldMinY()
    local maxy = GetWorldMaxY()

    if vTopLeft and vDownRight then
       
       minx=vTopLeft.x
       maxx=vDownRight.x 
       miny=vTopLeft.y
       maxy=vDownRight.y

    end

    local function getRandomPos()
            return Vector(RandomFloat(minx, maxx), RandomFloat(miny, maxy), 0)
          end
    local randomPos = getRandomPos()
    while not GridNav:CanFindPath(GameRules.vWorldCenterPos,randomPos) do
        randomPos = getRandomPos()
    end
    return randomPos
end


--以空格拆分字符串
function SpliteStr(str)
    local arr = {}
    for w in string.gmatch(str, "%S+") do
       table.insert(arr,w)
    end
    return arr
end

function string.trim(s)
    return s:match "^%s*(.-)%s*$"
end

--数组去重
function RemoveRepetition(TableData)
    local bExist = {}
    for v, k in pairs(TableData) do
        bExist[k] = true
    end
    local result = {}
    for v, k in pairs(bExist) do
        table.insert(result, v)
    end

    return result
end


function RemoveItemFromList(vList,item)
   --将同名技能从技能池移除  
    local i,max=1,#vList
    while i<=max do
        if vList[i] == item then
            table.remove(vList,i)
            i = i-1
            max = max-1
        end
        i= i+1
    end
    return vList
end


function FloatKeepOneDecimal(flDecimal)
    flDecimal = flDecimal * 10

    if flDecimal % 1 >= 0.5 then 
        flDecimal=math.ceil(flDecimal)
    else
        flDecimal=math.floor(flDecimal)
    end

    return  flDecimal * 0.1
end


function ContainsValue(nSum,nValue)

   if bit:_and(nSum,nValue)==nValue then
        return true
    else
      return false
    end

end

function ContainsValue(nSum,nValue)

   if bit:_and(nSum,nValue)==nValue then
        return true
    else
      return false
    end

end


--移除无敌类的buff
function RemoveInvulnerableModifier(hUnit)
    if hUnit then
        if hUnit:HasModifier("modifier_ember_spirit_sleight_of_fist_caster_invulnerability") then
           hUnit:RemoveModifierByName("modifier_ember_spirit_sleight_of_fist_caster_invulnerability")
        end
    end
end


function ConvertToTime( value )
    local value = tonumber( value )

    if value <= 0 then
        return "00:00:00";
    else
        hours = string.format( "%02.f", math.floor( value / 3600 ) );
        mins = string.format( "%02.f", math.floor( value / 60 - ( hours * 60 ) ) );
        secs = string.format( "%02.f", math.floor( value - hours * 3600 - mins * 60 ) );
        if math.floor( value / 3600 ) == 0 then
            return mins .. ":" .. secs
        end
        return hours .. ":" .. mins .. ":" .. secs
    end
end
