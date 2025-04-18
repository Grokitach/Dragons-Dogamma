local modname="Lucky Scavenger"
local configfile=modname.."/Config.json"
local _config={
    {name="Enable Random Enhancements", type="bool", default=true},
    {name="Enhancement Chance", type="int", default=15, min=0, max=100},
    {name="Max Enhancement Slots", type="int", default=4, min=1, max=4},
    {name="Vermudian Rate", type="int", default=8, min=0, max=10},
    {name="Battahli Rate", type="int", default=5, min=0, max=10},
    {name="Elven Rate", type="int", default=5, min=0, max=10},
    {name="Dwarven Rate", type="int", default=2, min=0, max=10},
    {name="Gear Level Scaling", type="int", default=100, min=50, max=200, tip="Effects chest drop item tiers.  This should be equal to predicted end game levels"},
    {name="Chest Drop Rate",type="int",default=5,min=1,max=100, tip="How often chests are likely to spawn extra items/materials/gear"},
    {name="Body Drop Rate",type="int",default=3,min=1,max=100, tip="How often corpses are likely to spawn extra items/materials/gear"},
    {name="Gimmick Drop Rate",type="int",default=3,min=1,max=10, tip="How often environmental objects are likely to spawn extra items/materials"},
    {name="Super Lucky Find Gear Chance", type="int",default=5,min=1,max=100, tip="On occasion a lucky find will drop higher tier gear than normal"},
    {name="Super Lucky Find Gear Rank Offset", type="int",default=1,min=1,max=3, tip="The number of ranks to make an item available"},
    {name="Bonus Chest Loot",type="bool",default=true, tip="Whether items along with gear also drop from chests."},
    {name="Bonus Chest Loot Chance",type="int",default=25,min=1,max=100, tip="Chance for extra items that aren't gear to drop from chests"},
    {name="Bodies Drop Extra Items",type="bool",default=false, tip="Whether items drop from corpses at all"},
    {name="Bodies Drop Gear",type="bool",default=true, tip="Whether gear drops from corpses at all"},
    {name="Bodies Drop Gear Chance",type="int",default=15,min=1,max=100, tip="Chance for gear to drop from all corpses"},
    {name="Boss Drop Percentage",type="int",default=100,min=1,max=100, tip="Gear Drop Chance from Bosses"},
    {name="Boss Drop Gear Rank Threshold",type="int",default=3,min=1,max=10, tip="Lower Values -> Higher Quality (Tighten's possible gear range of boss)"},
    {name="Effect Body Loot",type="bool",default=true, tip="Enable/Disable extra items corpses"},
    {name="Effect Gimmick Loot",type="bool",default=false, tip="Enable/Disable extra items environmental objects"},
    {name="Enable Notifications",type="bool",default=true},
    {name="TestTextBox", type="bool", default=false},
    {name="DockRight", type="bool", default=false},
    {name="FontSize",type="int",default=40,min=1,max=250,needrestart=true},
    {name="Notification X Offset",type="int",default=35, max=4080},
    {name="Notification Y Offset",type="int",default=300, max=2048},
    {name="Debugger",type="bool",default=false},
    {name="ItemTextColor",type="rgba32",default=4290707455},
    {name="ItemBackgroundColor",type="rgba32",default=4284308829},
    {name="GearTextColor",type="rgba32",default=4290904061},
    {name="GearBackgroundColor",type="rgba32",default=4278228992},
    {name="SuperLuckyTextColor",type="rgba32",default=4285906687},
    {name="SuperLuckyBackgroundColor",type="rgba32",default=4286209062},
    {name="BossDropTextColor",type="rgba32",default=4294967295},
    {name="BossDropBackgroundColor",type="rgba32",default=4278210742}
}

local function recurse_def_settings(tbl, new_tbl)
    for key, value in pairs(new_tbl) do
        if type(tbl[key]) == type(value) then
            if type(value) == "table" then
                tbl[key] = recurse_def_settings(tbl[key], value)
            else
                tbl[key] = value
            end
        end
    end
    return tbl
end
local config = {} 
for key,para in pairs(_config) do
    config[para.name]=para.default
end
config = recurse_def_settings(config, json.load_file(configfile) or {})

local ChestFind = 0
local BodyFind = 0
local GimmickFind = 0
local EndGameExperienceScaler = 25000
local EndGameLevel = config["Gear Level Scaling"]
local EnableNotifications = config["Enable Notifications"]
local GimmickDropRate = config["Gimmick Drop Rate"]
local BodyDropRate = config["Body Drop Rate"]
local ChestDropRate = config["Chest Drop Rate"]
local SuperLuckyFindGearDropChance = config["Super Lucky Find Gear Chance"]
local SuperLuckyFindGearLevelingFactor = config["Super Lucky Find Gear Rank Offset"]
local EffectBodyLoot = config["Effect Body Loot"]
local EffectGimmickLoot = config["Effect Gimmick Loot"]
local BonusChestLoot = config["Bonus Chest Loot"]
local BonusChestLootChance = config["Bonus Chest Loot Chance"]
local BonusBodyLoot = config["Bodies Drop Gear"]
local BonusBodyLootChance = config["Bodies Drop Gear Chance"]
local BodiesDropExtraItems = config["Bodies Drop Extra Items"]
local GauranteedBossDrops = config["Boss Drop Percentage"]
local BossDropGearScale = config["Boss Drop Gear Rank Threshold"]
local EnableRandomEnhancements = config["Enable Random Enhancements"]
local EnhancementChance = config["Enhancement Chance"]
local MaxEnhancementSlots = config["Max Enhancement Slots"]
local VermudianRate = config["Vermudian Rate"]
local BattahliRate = config["Battahli Rate"]
local ElvenRate = config["Elven Rate"]
local DwarvenRate = config["Dwarven Rate"]
local WyrmfireRate = config["Wyrmfire Rate"]
local MonsterExperience = {}
local MonsterIsBoss = {}
local MonsterHP = {}
local messageQueue = {}
local maxMessages = 5
local messageDuration = 10
local messageTimestamps = {}
local isLootingGimmick=false
local tmpForage = json.load_file(modname .. "/Forage.json")
local tmpCuratives = json.load_file(modname .. "/Curatives.json")
local tmpMaterials = json.load_file(modname .. "/Materials.json")
local tmpImplements = json.load_file(modname .. "/Implements.json")
local tmpHeadArmor = json.load_file(modname .. "/HeadArmor.json")
local tmpBodyArmor = json.load_file(modname .. "/BodyArmor.json")
local tmpLegArmor = json.load_file(modname .. "/LegArmor.json")
local tmpRings = json.load_file(modname .. "/Rings.json")
local tmpCloaks = json.load_file(modname .. "/Cloaks.json")
local tmpArchistaffs = json.load_file(modname .. "/Archistaffs.json")
local tmpBows = json.load_file(modname .. "/Bows.json")
local tmpCensers = json.load_file(modname .. "/Censers.json")
local tmpDaggers = json.load_file(modname .. "/Daggers.json")
local tmpDuospears = json.load_file(modname .. "/Duospears.json")
local tmpGreatSwords = json.load_file(modname .. "/GreatSwords.json")
local tmpHammers = json.load_file(modname .. "/Hammers.json")
local tmpMaces = json.load_file(modname .. "/Maces.json")
local tmpMagickalBows = json.load_file(modname .. "/MagickalBows.json")
local tmpStaffs = json.load_file(modname .. "/Staffs.json")
local tmpSwords = json.load_file(modname .. "/Swords.json")
local tmpShields = json.load_file(modname .. "/Shields.json")
local GimmickItems = {tmpMaterials, tmpForage}
local BodyItems = {tmpCuratives, tmpMaterials, tmpImplements}
local ChestItems = {tmpHeadArmor, tmpBodyArmor, tmpLegArmor, tmpRings, tmpCloaks, tmpArchistaffs, tmpBows, tmpCensers, 
    tmpDaggers, tmpDuospears, tmpGreatSwords, tmpHammers, tmpMaces, tmpMagickalBows, tmpStaffs, tmpSwords, tmpShields
}
local HArmors = {tmpHeadArmor}
local BArmors = {tmpBodyArmor}
local LArmors = {tmpLegArmor}
local Weapons = {tmpArchistaffs, tmpBows, tmpCensers, tmpDaggers, tmpDuospears, tmpGreatSwords, tmpHammers, tmpMaces, tmpMagickalBows, tmpStaffs, tmpSwords, tmpShields}
local BonusChestItems = {tmpCuratives, tmpMaterials, tmpImplements}
math.randomseed(os.time())

local function Log(msg,tc,bgc)
    if #messageQueue >= maxMessages then
        table.remove(messageQueue, 1)
        table.remove(messageTimestamps, 1)
    end
    table.insert(messageQueue, {text=msg,textColor=tc,backgroundColor=bgc})
    table.insert(messageTimestamps, os.clock())
end

local function Debug(msg)
    if config.Debugger then
        if #messageQueue >= maxMessages then
            table.remove(messageQueue, 1)
            table.remove(messageTimestamps, 1)
        end
        local bgc = (0x4133c9 & 0xFFFFFF) + (alphaInt << 24)
        table.insert(messageQueue, {text=msg,textColor=0xffffff,backgroundColor=bgc})
        table.insert(messageTimestamps, os.clock())
    end
end


local function DumpSaveData()
    local saveData = {
        ChestFind = ChestFind,
        BodyFind = BodyFind,
        GimmickFind = GimmickFind,
    }
    local filepath = modname .. "/SaveData.json"
    local success = json.dump_file(filepath, saveData, 4)
end

local function loadSaveData()
    local filepath = modname .. "/SaveData.json"
    local loadedData = json.load_file(filepath)
    
    if loadedData and loadedData.ChestFind then
        ChestFind = loadedData.ChestFind
        BodyFind = loadedData.BodyFind
        GimmickFind = loadedData.GimmickFind
    else
        ChestFind = 0
        BodyFind = 0
        GimmickFind = 0
    end
end
loadSaveData()

local Wakestone=77
local WakestoneShards=78

local function AddItem(Item)
    local im=sdk.get_managed_singleton("app.ItemManager")
    local player_man=sdk.get_managed_singleton("app.CharacterManager")
    local player=player_man:get_ManualPlayer()
    if im==nil or player_man==nil or player==nil then return end
    local type=sdk.find_type_definition("app.ItemManager.GetItemEventType"):get_field("TreasureBox"):get_data()
    local getItemMethod=im:get_type_definition():get_method("getItem(System.Int32, System.Int32, app.Character, System.Boolean, System.Boolean, System.Boolean, app.ItemManager.GetItemEventType, System.Boolean, System.Boolean)")
    if Item.ItemID == WakestoneShards then
        local getNumMethod=im:get_type_definition():get_method("getHaveNum(System.Int32, app.Character)")
        local deleteMethod=im:get_type_definition():get_method("deleteItem(System.Int32, System.Int32, app.Character)")
        local ct=getNumMethod:call(im,WakestoneShards,player)
        local total_ct=math.floor(Item.ItemNum)+ct
        local stone_ct=math.floor(total_ct/3)
        local left_ct=total_ct-stone_ct*3

        if left_ct >ct then
            getItemMethod:call(im,WakestoneShards,left_ct-ct,player,true,false,false,1,false,false)
        elseif left_ct<ct then
            deleteMethod:call(im,WakestoneShards,ct-left_ct,player)
        end
        if stone_ct>0 then
            getItemMethod:call(im,Wakestone,stone_ct,player,true,false,false,1,false,false)           
        end
    else
        getItemMethod:call(im,Item.ItemId,Item.ItemNum,player,true,false,false,1,false,false)
    end
end

local bat_mgr = sdk.get_managed_singleton("app.BattleManager")
local em_mgr = sdk.get_managed_singleton("app.EnemyManager")

local function getC(gameobj, component_name)
	return gameobj:call("getComponent(System.Type)", sdk.typeof(component_name))
end

local recent_danger_rank = ""
local recent_experience_calculation = 0

local function get_EnemyDangerousRank()
    local rank = bat_mgr:call("get_EnemyDangerousRank")
    if rank == 1 then
        recent_danger_rank = "Chick"
    elseif rank == 2 then
        recent_danger_rank = "Weak"
    elseif rank == 3 then
        recent_danger_rank = "Normal"
    elseif rank == 4 then
        recent_danger_rank = "Hard"
    else
        recent_danger_rank = "Danger"
    end
    return recent_danger_rank
end

function get_userdata_int(userdata)
    local userdataStr = tostring(userdata)
    local hexStr = userdataStr:gsub("userdata: ","")
    local intValue = tonumber(hexStr,16)
    return intValue
end

local function get_experience_amount(charID)
    local char_mgr = sdk.get_managed_singleton("app.CharacterManager")
    local exp_table = char_mgr:get_CharacterExperiencePointsTable()
    local exp_rows = exp_table:get_field("ExpDataList")
    for i=0, exp_rows:get_Count()-1 do
        if exp_rows[i]:get_GetCharaID() == charID then 
            return exp_rows[i]:get_GetExpAmount() 
        end
    end
end

local function get_AverageEnemyExperience()
    local total_experience = 0
    local count = 0
    for i, enemy in pairs(em_mgr._EnemyList._items) do
        if enemy then
            local enemy_character = enemy:get_Chara()
            local experience = get_experience_amount(enemy_character:get_CharaID())
            if experience then
                total_experience = total_experience + experience
                count = count + 1
            end
        end 
    end
    return math.ceil(total_experience / count)
end

local function get_HighestEnemyExperience()
    local highest_experience = 0
    for i, enemy in pairs(em_mgr._EnemyList._items) do
        if enemy then
            local enemy_character = enemy:get_Chara()
            local experience = get_experience_amount(enemy_character:get_CharaID())
            if experience < highest_experience then highest_experience = experience end
        end 
    end
    return math.ceil(highest_experience)
end

local font = imgui.load_font("Lucky Scavenger.otf", config.FontSize)

re.on_frame(function()
    EndGameLevel = config["Gear Level Scaling"]
    EnableNotifications = config["Enable Notifications"]
    GimmickDropRate = config["Gimmick Drop Rate"]
    BodyDropRate = config["Body Drop Rate"]
    ChestDropRate = config["Chest Drop Rate"]
    SuperLuckyFindGearDropChance = config["Super Lucky Find Gear Chance"]
    SuperLuckyFindGearLevelingFactor = config["Super Lucky Find Gear Rank Offset"]
    EffectBodyLoot = config["Effect Body Loot"]
    EffectGimmickLoot = config["Effect Gimmick Loot"]
    BonusChestLoot = config["Bonus Chest Loot"]
    BonusChestLootChance = config["Bonus Chest Loot Chance"]
    BonusBodyLoot = config["Bodies Drop Gear"]
    BonusBodyLootChance = config["Bodies Drop Gear Chance"]
    BodiesDropExtraItems = config["Bodies Drop Extra Items"]
    GauranteedBossDrops = config["Boss Drop Percentage"]
    BossDropGearScale = config["Boss Drop Gear Rank Threshold"]
    EnhancementChance = config["Enhancement Chance"]
    MaxEnhancementSlots = config["Max Enhancement Slots"]
    VermudianRate = config["Vermudian Rate"]
    BattahliRate = config["Battahli Rate"]
    ElvenRate = config["Elven Rate"]
    DwarvenRate = config["Dwarven Rate"]
    WyrmfireRate = config["Wyrmfire Rate"]
    if EnableNotifications == false then return end
    imgui.push_font()
    if config.TestTextBox then
        local message1 = "Extra Item Drops"
        local message2 = "Extra Gear Drops"
        local message3 = "Super Lucky Drops"
        local message4 = "Boss Drops"
        Log(message1, config.ItemTextColor, config.ItemBackgroundColor)
        Log(message2, config.GearTextColor, config.GearBackgroundColor)
        Log(message3, config.SuperLuckyTextColor, config.SuperLuckyBackgroundColor)
        Log(message4, config.BossDropTextColor, config.BossDropBackgroundColor)
    end
    local currentTime = os.clock()
    local textBoxPadding = config.FontSize *.75
    local baseOffsetY = config["Notification Y Offset"]
    local baseOffsetX = config["Notification X Offset"]
    local offsetYIncrement = textBoxPadding
    local screenWidth= imgui.get_display_size().x
    local rightPadding = config["Notification X Offset"]
    for i, message in ipairs(messageQueue) do
        if message.backgroundColor == nil then
            message.backgroundColor = config.ItemBackgroundColor
        end
        if message.textColor == nil then
            message.textColor = config.ItemTextColor
        end
        if message.text == nil then
            message.text = "???"
        end
        local messageAge = currentTime - messageTimestamps[i]
        local alpha = 1.0 - (messageAge / messageDuration)
        if config.Debugger then
            alpha = 1.0
        end
        alpha = math.max(0, alpha)
        local alphaInt = math.floor(alpha * 255)
        local backgroundColor = (message.backgroundColor & 0xFFFFFF) + (alphaInt << 24)
        local textColor = (message.textColor & 0xFFFFFF) + (alphaInt << 24)

        local size = imgui.calc_text_size(message.text)
        local offsetY = baseOffsetY + (i-1) * (config.FontSize + textBoxPadding * 0.5 + 5) + 10 -- Updated for dynamic spacing
        local baseOffsetX
    
        if config.DockRight then
            baseOffsetX = screenWidth - size.x - textBoxPadding - rightPadding
        else
            baseOffsetX = config["Notification X Offset"]
        end
    
        draw.filled_rect(baseOffsetX - textBoxPadding * 0.5, offsetY - textBoxPadding * 0.25, size.x + textBoxPadding, size.y + textBoxPadding * 0.5, backgroundColor)
        draw.text(message.text, baseOffsetX, offsetY, textColor)
    end
    if config.TestTextBox then
        for i = #messageTimestamps, 1, -1 do
            table.remove(messageQueue, i)
            table.remove(messageTimestamps, i)
        end    
    end
    if config.Debugger == false then
        for i = #messageTimestamps, 1, -1 do
            if currentTime - messageTimestamps[i] > messageDuration then
                table.remove(messageQueue, i)
                table.remove(messageTimestamps, i)
            end
        end
    end
    imgui.pop_font()
end)

local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end
local PlayerManager = sdk.get_managed_singleton("app.CharacterManager")
local function GetPlayerManager()
    if PlayerManager == nil then PlayerManager = sdk.get_managed_singleton("app.CharacterManager") end
	return PlayerManager
end

local function GetPlayer()
    local playerMgr = GetPlayerManager();
    if playerMgr then
        return playerMgr:call("get_ManualPlayer()");
    end
end
local ItemManager = nil
local itemID = nil
local itemNum = nil
local itemEventType = nil

local PawnManager = sdk.get_managed_singleton("app.PawnManager")
local function GetPawnManager()
    if PawnManager == nil then PawnManager = sdk.get_managed_singleton("app.PawnManager") end
	return PawnManager
end

local function GetPawn()
    local pawnMgr = GetPawnManager();
    if pawnMgr and ItemManager then
        local list = pawnMgr:call("get_PawnCharacterList()")
        if list then
            local len = list:call("get_Count")
            for i = 0, len - 1, 1 do
                local pawnChar = list:call("get_Item", i)
                if pawnChar then
                    return pawnChar
                end
            end
        end
    end
end

local function generateWeightedList(maxSlots, rarityFactor)
    local list = {}
    for slot = 1, maxSlots do
        -- Calculate the weight (number of occurrences in the list) for this slot
        local weight = math.floor(rarityFactor ^ (maxSlots - slot))
        
        -- Add the slot to the list based on its weight
        for w = 1, weight do
            table.insert(list, slot)
        end
    end
    return list
end

local function get_enhance_slots()
    local weightedList = generateWeightedList(MaxEnhancementSlots, 3)
    local index = math.random(#weightedList)
    return weightedList[index]
end

local function enhance_item(ret)
    if EnableRandomEnhancements == false then return ret end
    if math.random(0,100) > EnhancementChance then return ret end
    local player = GetPlayer()
    local playerID = player:get_CharaID()
    local slots = get_enhance_slots()
    local types = {}
    for i = 1, VermudianRate do
        table.insert(types, 0)
    end
    for i = 1, BattahliRate do
        table.insert(types, 1)
    end
    for i = 1, ElvenRate do
        table.insert(types, 2)
    end
    for i = 1, DwarvenRate do
        table.insert(types, 3)
    end
    shuffleTable(types)
    if itemID ~= nil then
        local storageData = ItemManager:getStorageData(itemID, playerID)
        if storageData and storageData._ItemData then
            storageData:get_Enhance():set_Num(slots)
            -- ItemManager:enhanceEquip(storageData, 0)
            for i=1, math.min(3, slots) do
                local type_id = types[math.random(0,#types)]
                ItemManager:enhanceEquip(storageData,type_id)
            end
            if slots == 4 then
                ItemManager:enhanceEquip(storageData,4)
            end
        end
    end
    return ret
end

sdk.hook(sdk.find_type_definition("app.ItemManager"):get_method("getItem(System.Int32, System.Int32, app.Character, System.Boolean, System.Boolean, System.Boolean, app.ItemManager.GetItemEventType, System.Boolean, System.Boolean)"),
function (args)
    local player = GetPlayer()
    local chara = sdk.to_managed_object(args[5])
    if chara and player then
        if chara:get_CharaID() == player:get_CharaID() then
            ItemManager = sdk.to_managed_object(args[2])
            itemID = sdk.to_int64(args[3])
            itemNum = sdk.to_int64(args[4])
            itemEventType = sdk.to_int64(args[9])
        end
    else
        ItemManager = nil
        itemID = nil
        itemNum = nil
        itemEventType = nil
    end
end, enhance_item)

local function get_PlayerLevel()
    local CharacterManagerSingleton = sdk.get_managed_singleton('app.AppSingleton`1<app.CharacterManager>')
    local CharacterManager = CharacterManagerSingleton:call('get_Instance')
    local ManualPlayer = CharacterManager:call("get_ManualPlayer")
    local Human = ManualPlayer:call("get_Human")
    local StatusContext = Human:call("get_StatusContext")
    local level = StatusContext:call("get_Level")
    return level
end

local function getItemByLevel(itemList)
    local sortedItems = itemList -- itemList is already an array

    local item_pool_size = #sortedItems
    local current_level = get_PlayerLevel()
    local available_items = {}

    for index, item in ipairs(sortedItems) do
        local super_lucky = math.random(0,99)
        local super_lucky_factor = 0
        if super_lucky < SuperLuckyFindGearDropChance then
            super_lucky_factor = math.random(1,SuperLuckyFindGearLevelingFactor)
        end
        local item_name = item.item_name
        local itemId = item.id
        local level_requirement = EndGameLevel / item_pool_size * (index-1) + 1

        if current_level >= level_requirement - super_lucky_factor then
            table.insert(available_items, {name=item_name, id=itemId, item_index=index, level=level_requirement, pool_size=item_pool_size})
        end
    end

    if #available_items > 0 then
        local i = math.random(1, #available_items)
        return available_items[i]
    end

    return nil
end

local function getItemByExperience(itemList, experience, isBoss)
    local available_items = {}
    if experience == nil then
        experience = 1
    end
    for index, item in ipairs(itemList) do
        local super_lucky = math.random(0, 99)
        local super_lucky_factor = 0
        if super_lucky < SuperLuckyFindGearDropChance then
            super_lucky_factor = math.random(1, SuperLuckyFindGearLevelingFactor)
        end
        local rank_adjuster = math.ceil(#itemList * .25)
        if isBoss then
            rank_adjuster = BossDropGearScale or 1
            super_lucky_factor = 0
        end
        local experience_offset = EndGameExperienceScaler / #itemList
        local item_rank = (experience_offset * index) / experience_offset
        local item_rank_allowed = math.floor(experience / experience_offset) + 1
        --and math.abs(experience - experience_requirement) <= experienceThreshold 
        if item_rank_allowed >= item_rank - (super_lucky_factor) and item_rank >= item_rank_allowed - rank_adjuster then
            Debug("name: " .. item.item_name .. " rank: " .. item_rank)
            Debug("experience offset: " .. experience_offset)
            table.insert(available_items, {name = item.item_name, id = item.id, item_index = index, level = item_rank})
        end
    end

    -- Select a random item from the filtered list of available items
    if #available_items > 0 then
        local selectedIndex = math.random(1, #available_items)
        return available_items[selectedIndex]
    else
        return nil
    end
end

local function getRandomItem(itemList)
    math.randomseed(os.time())
    local sortedItems = itemList -- itemList is already an array

    local item_pool_size = #sortedItems
    local available_items = {}

    for index, item in ipairs(sortedItems) do
        local item_name = item.item_name
        local itemId = item.id
        local level_requirement = EndGameLevel / item_pool_size * index
        table.insert(available_items, {name=item_name, id=itemId, item_index=index, level=level_requirement, pool_size=item_pool_size})
    end

    if #available_items > 0 then
        local i = math.random(1, #available_items)
        return available_items[i]
    end

    return nil
end
--ItemEquipParam:get_Lv()


sdk.hook(
    sdk.find_type_definition("app.ItemDropParam.Table"):get_method("getLotItemSub"),
    nil,
    function (retval)
        local item=sdk.to_managed_object(retval)
        if item._Id==398 then
            return retval
        end
        if EffectGimmickLoot and isLootingGimmick and math.random(0, 99) < GimmickFind then
            shuffleTable(GimmickItems)
            local randomIndex = math.random(1, #GimmickItems)
            local tmp = GimmickItems[randomIndex]
            local selectedItem = getRandomItem(tmp)
            if selectedItem ~= nil then
                local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                newItem.ItemId = selectedItem.id
                newItem.ItemNum = 1
                local itemName = selectedItem.name
                local txtColor = config.ItemTextColor
                local bgColor = config.ItemBackgroundColor
                Log("Lucky Find!: Received " .. itemName .. " ( " .. string.format("%d", math.floor(selectedItem.level)) .. " Rarity )", txtColor, bgColor)
                GimmickFind = 0
                DumpSaveData()
                AddItem(newItem)
                return sdk.to_ptr(retval)
            end
        end
        return retval
    end
)

sdk.hook(
    sdk.find_type_definition("app.gm80_001"):get_method("getItem"),
    function(args)
        shuffleTable(ChestItems)
        local randomIndex = math.random(1, #ChestItems)
        local tmp = ChestItems[randomIndex]
        local experience = get_AverageEnemyExperience()
        local selectedItem = nil 
        if experience > 0 then 
            selectedItem = getItemByExperience(tmp, experience, false) 
        else
            selectedItem = getItemByLevel(tmp)
        end
        local this = sdk.to_managed_object(args[2])
        local ItemList = this.ItemList
        if ItemList ~= nil then
            if selectedItem ~= nil and math.random(0, 99) < ChestFind then
                local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                newItem.ItemId = selectedItem.id
                newItem.ItemNum = 1
                local itemName = selectedItem.name
                local txtColor = config.GearTextColor
                local bgColor = config.GearBackgroundColor
                Log("Lucky Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                ItemList:Add(newItem)
                ChestFind = 0
                randomIndex = math.random(1, #BonusChestItems)
                tmp = BonusChestItems[randomIndex]
                selectedItem = getRandomItem(tmp)
                if BonusChestLoot and selectedItem ~= nil and math.random(0, 99) < BonusChestLootChance then
                    newItem = sdk.create_instance("app.gm80_001.ItemParam")
                    newItem.ItemId = selectedItem.id
                    newItem.ItemNum = 1
                    --getItemData(System.Int32)
                    itemName = selectedItem.name
                    local txtColor = config.ItemTextColor
                    local bgColor = config.ItemBackgroundColor
                    Log("Lucky Find!: Received " .. itemName .. " ( " .. string.format("%d", math.floor(selectedItem.level)) .. " Rarity ! )",txtColor,bgColor)
                    ItemList:Add(newItem)
                end
                DumpSaveData()
            else
                ChestFind = ChestFind + ChestDropRate
                DumpSaveData()
            end
        end
    end, nil
)

local AlreadyLooted = {}

local function get_attacker(DamageInfo)
	local AttackHitController = DamageInfo["<AttackHitController>k__BackingField"]
	if not AttackHitController then return nil end
	local shell = AttackHitController["<CachedShell>k__BackingField"]
	local attacker
	
	if shell then
		attacker = shell["<OwnerCharacter>k__BackingField"]
	else
		attacker = AttackHitController["<CachedCharacter>k__BackingField"]
	end
	
	return attacker
end

local function get_receiver(DamageInfo)
	local DamageHitController = DamageInfo["<DamageHitController>k__BackingField"]
	if not DamageHitController then return nil end
	local receiver = DamageHitController["<CachedCharacter>k__BackingField"]

	return receiver
end

  local function on_post_calc_damage(DamageInfo,field)
	local attacker = get_attacker(DamageInfo)
	local receiver = get_receiver(DamageInfo)
	if not receiver then return end
	if attacker and (not attacker:get_Valid() or not attacker:get_GameObject():get_Valid()) then return end
	if receiver and (not receiver:get_Valid() or not receiver:get_GameObject():get_Valid()) then return end
	
	local attackerName = attacker and string.sub(attacker:get_GameObject():get_Name(),1,8)
	local receiverName = receiver and string.sub(receiver:get_GameObject():get_Name(),1,8)
	local attackerType = attackerName and string.sub(attackerName,1,3)
	local receiverType = receiverName and string.sub(receiverName,1,3)
	
	-- Direct damage includes fall damage, debilitation damage, ragdoll damage and throwing enemies against a wall (which IS ragdoll damage)
	-- It does NOT include throwing enemies at each other, or throwing stuff at enemies
	if DamageInfo.IsDirectDamage then
		local damageType = DamageInfo.DamageType
		local damageActType = DamageInfo.DamageActType
		local elementType = DamageInfo.OverwriteElementType._Value
		
		local isFallDamage = damageType == 14 or damageType == 15
		if isFallDamage then
			return	 
		end
		
		local isRagdollDamage = damageType == -1 and damageActType == 0 and elementType == 0
		if isRagdollDamage then
			-- We only allow it for enemies because throwing enemies against the wall should be affected
			if receiverType == "ch0" or receiverType == "ch1" then
				return
			end
		end
		-- Not actually accurate for all debilitation damage
		-- local isDebilitationDamage = damageType == -1 and damageActType == 0 and elementType == -1
	end

	-- Hits received by NPCs are excluded 
	-- This is to avoid poor NPCs always dying to monsters on harsher settings
	local isNPCHit = receiverType == "ch3"
	if isNPCHit then
		return
	end
	
	if receiver:get_IsBoss() then
		receiverType = "boss"
        MonsterIsBoss[receiver:get_CharaID()] = true
    else
        MonsterIsBoss[receiver:get_CharaID()] = false
    end

    if receiverName == "ch250000" or receiverName == "ch252000" or receiverName == "ch226003" then
        MonsterIsBoss[receiver:get_CharaID()] = true
    end
	
	local mult = 1.0
	if field == "Damage" then
		mult = 1
		mult = 1
		-- If an enemy hits another enemy, we shouldn't apply the damage dealt multiplier. This is because
		-- 1) When throwing enemies at each other, attacker is the thrown enemy, not the thrower
		-- 2) We don't want enemies to friendly fire each other to death
		-- We do want to keep damage received mults, so e.g. humble offringe doesn't become OP because it bypasses them when throwing enemies at each other
		local isEnemyToEnemy = attackerType == "ch2" and receiverType == "ch2"
		if attackerName and not isEnemyToEnemy then
			mult = 1
		end
	end
	if field == "DamageReaction" then
		mult = 1
		mult = 1
	end
	DamageInfo[field] = mult * DamageInfo[field]
end


sdk.hook(
	sdk.find_type_definition("app.HitController"):get_method("calcDamageValue(app.HitController.DamageInfo)"),
	function(args)
		local storage = thread.get_hook_storage()
		storage.DamageInfo = sdk.to_managed_object(args[3])
	end,
	function(retval)
		local DamageInfo = thread.get_hook_storage().DamageInfo
		on_post_calc_damage(DamageInfo,"Damage")	
		return retval
	end
)

sdk.hook(
    sdk.find_type_definition("app.ExpDispenser.ExpGranter"):get_method("evaluateExpAmount"),
    function (args)
        local this = sdk.to_managed_object(args[2])
        
        local e_mgr = sdk.get_managed_singleton("app.EnemyManager")
        for i, enemy in pairs(e_mgr._EnemyList._items) do
            if enemy then
                local enemy_character = getC(enemy:get_GameObject(), "app.Monster")
                if enemy_character == nil then
                    enemy_character = getC(enemy:get_GameObject(), "app.Character")
                else
                    enemy_character = getC(enemy:get_GameObject(), "app.Monster"):get_Chara()
                end
                local hp = enemy_character:get_OriginalMaxHp()
                local expGranter = enemy_character:tryGetExpGranter()
                local contextHolder = enemy_character:get_Context()
                if expGranter == this then
                    AlreadyLooted[enemy_character:get_CharaID()] = false
                    break
                end
            end 
        end
    end
)

sdk.hook(
    sdk.find_type_definition("app.ItemDropParam"):get_method("getFumbleLotItem"),
    function(args)
        local this=sdk.to_managed_object(args[2])
        local gid=this:get_GimmickId()
        --get_CharaID
        if gid ~=0 then
        elseif AlreadyLooted[this:get_CharaId()] ~= true then
            local isBoss = MonsterIsBoss[this:get_CharaId()]
            local wasLooted = AlreadyLooted[this:get_CharaId()]
--            Debug("Monster HP: "..tostring(hp).." is Boss: " ..tostring(isBoss) .." was Looted: " ..tostring(wasLooted))
            local dropChance = math.random(0, 99)
            local super_lucky = math.random(0,99)
            local tryDrop = EffectBodyLoot and dropChance < BodyFind
            local tryBonusBodyDrop = BonusBodyLoot and super_lucky < BonusBodyLootChance
            if isBoss then
                tryDrop = dropChance < GauranteedBossDrops
            end
            if tryDrop then
                local experience = get_AverageEnemyExperience(this:get_CharaId())
                if isBoss then
                    experience = experience * 6
                end
                shuffleTable(BodyItems)
                local randomIndex = math.random(1, #BodyItems)
                local tmp = BodyItems[randomIndex]
                if not tmp then
                    shuffleTable(BodyItems)
                    randomIndex = math.random(1, #BodyItems)
                    tmp = BodyItems[randomIndex]
                end
                local selectedItem = getRandomItem(tmp)
                if BodiesDropExtraItems and selectedItem ~= nil then
                    local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                    newItem.ItemId = selectedItem.id
                    newItem.ItemNum = 1
                    local itemName = selectedItem.name
                    local txtColor = config.ItemTextColor
                    local bgColor = config.ItemBackgroundColor
                    Log("Lucky Find!: Received " .. itemName .. " ( " .. string.format("%d", math.floor(selectedItem.level)) .. " Rarity )",txtColor,bgColor)
                    DumpSaveData()
                    AddItem(newItem)
                end
                if  tryBonusBodyDrop then
                    shuffleTable(ChestItems)
                    randomIndex = math.random(1, #ChestItems)
                    tmp = ChestItems[randomIndex]
                    if not tmp then
                        shuffleTable(ChestItems)
                        randomIndex = math.random(1, #ChestItems)
                        tmp = ChestItems[randomIndex]
                    end
                    selectedItem = getItemByExperience(tmp, experience, isBoss)
                    if not selectedItem then
                        selectedItem = getItemByExperience(tmp, experience, isBoss)
                    end
                    local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                    newItem.ItemId = selectedItem.id
                    newItem.ItemNum = 1
                    local itemName = selectedItem.name
                    local txtColor = config.SuperLuckyTextColor
                    local bgColor = config.SuperLuckyBackgroundColor
                    if isBoss then
                        txtColor = config.BossDropTextColor
                        txtColor = config.BossDropBackgroundColor
                    end
                    if isBoss then
                        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                    else
                        Log("Super Lucky Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                    end
                    AddItem(newItem)
                end

                if isBoss then
                    Hdrop = math.random(1,99)
                    Bdrop = math.random(1,99)
                    Ldrop = math.random(1,99)
                    Wdrop = math.random(1,99)
                    if  Wdrop <= 40 then
                        experience_mult = math.random(10,20) / 10
                        shuffleTable(Weapons)
                        randomIndex = math.random(1, #Weapons)
                        tmp = Weapons[randomIndex]
                        if not tmp then
                            shuffleTable(Weapons)
                            randomIndex = math.random(1, #Weapons)
                            tmp = Weapons[randomIndex]
                        end
                        selectedItem = getItemByExperience(tmp, experience, isBoss)
                        if not selectedItem then
                            selectedItem = getItemByExperience(tmp, experience, isBoss)
                        end
                        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                        newItem.ItemId = selectedItem.id
                        newItem.ItemNum = 1
                        local itemName = selectedItem.name
                        local txtColor = config.SuperLuckyTextColor
                        local bgColor = config.SuperLuckyBackgroundColor
                        if isBoss then
                            txtColor = config.BossDropTextColor
                            txtColor = config.BossDropBackgroundColor
                        end
                        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                        AddItem(newItem)
                    end
                    if  Ldrop <= 40 then
                        experience_mult = math.random(10,20) / 10
                        shuffleTable(LArmors)
                        randomIndex = math.random(1, #LArmors)
                        tmp = LArmors[randomIndex]
                        if not tmp then
                            shuffleTable(LArmors)
                            randomIndex = math.random(1, #LArmors)
                            tmp = LArmors[randomIndex]
                        end
                        selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        if not selectedItem then
                            selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        end
                        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                        newItem.ItemId = selectedItem.id
                        newItem.ItemNum = 1
                        local itemName = selectedItem.name
                        local txtColor = config.SuperLuckyTextColor
                        local bgColor = config.SuperLuckyBackgroundColor
                        if isBoss then
                            txtColor = config.BossDropTextColor
                            txtColor = config.BossDropBackgroundColor
                        end
                        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                        AddItem(newItem)
                    end
                    if  Hdrop <= 40 then
                        experience_mult = math.random(10,20) / 10
                        shuffleTable(HArmors)
                        randomIndex = math.random(1, #HArmors)
                        tmp = HArmors[randomIndex]
                        if not tmp then
                            shuffleTable(HArmors)
                            randomIndex = math.random(1, #HArmors)
                            tmp = HArmors[randomIndex]
                        end
                        selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        if not selectedItem then
                            selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        end
                        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                        newItem.ItemId = selectedItem.id
                        newItem.ItemNum = 1
                        local itemName = selectedItem.name
                        local txtColor = config.SuperLuckyTextColor
                        local bgColor = config.SuperLuckyBackgroundColor
                        if isBoss then
                            txtColor = config.BossDropTextColor
                            txtColor = config.BossDropBackgroundColor
                        end
                        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                        AddItem(newItem)
                    end
                    if  Bdrop <= 40 then
                        experience_mult = math.random(10,20) / 10
                        shuffleTable(BArmors)
                        randomIndex = math.random(1, #BArmors)
                        tmp = BArmors[randomIndex]
                        if not tmp then
                            shuffleTable(BArmors)
                            randomIndex = math.random(1, #BArmors)
                            tmp = BArmors[randomIndex]
                        end
                        selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        if not selectedItem then
                            selectedItem = getItemByExperience(tmp, experience * experience_mult, isBoss)
                        end
                        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
                        newItem.ItemId = selectedItem.id
                        newItem.ItemNum = 1
                        local itemName = selectedItem.name
                        local txtColor = config.SuperLuckyTextColor
                        local bgColor = config.SuperLuckyBackgroundColor
                        if isBoss then
                            txtColor = config.BossDropTextColor
                            txtColor = config.BossDropBackgroundColor
                        end
                        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. " )", txtColor, bgColor)
                        AddItem(newItem)
                    end
                end
                BodyFind = 0
                AlreadyLooted[this:get_CharaId()] = true
                return sdk.to_ptr(retval)
            end
            BodyFind = BodyFind + BodyDropRate
        end
    end,
    function (retval)
        isLootingBody=false
        return retval
    end
)

sdk.hook(
    sdk.find_type_definition("app.Gm82_009"):get_method("giveItem"),
    function(args)
        local this=sdk.to_managed_object(args[2])
        local gid=this.GimmickId
        if gid ~=0 and gid~=161 then
            isLootingGimmick=true
            GimmickFind = GimmickFind + GimmickDropRate
        end
    end,
    function (retval)
        isLootingGimmick=false
        return retval
    end
)

local function OnChanged() end
local function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    return nil
end
local myapi = prequire("_XYZApi/_XYZApi")
if myapi ~= nil then myapi.DrawIt(modname, configfile, _config, config, nil) end