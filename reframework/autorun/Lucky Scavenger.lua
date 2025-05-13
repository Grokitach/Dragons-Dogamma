local modname="Lucky Scavenger"
local WeatherManager = sdk.get_managed_singleton("app.WeatherManager")
--printlog = require("CustomDifficulty/logger").Log
local configfile=modname.."/Config.json"
local _config={
    {name="Archer Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Archer gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Fighter Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Fighter gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Mage Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Mage gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Magick Archer Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Magick Archer gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Mystic Spearhand Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Mystic Spearhand gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Sorcerer Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Sorcerer gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Thief Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Thief gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Trickster Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Trickster gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
    {name="Warrior Gear Chance", type="int", default=10, min=0, max=100, tip="How often chests and bosses will drop Warrior gear. If all vocations have the same value, they will all have an equal chance of being picked when loot is generated."},
--    {name="Enable Random Enhancements", type="bool", default=true},
--    {name="Enhancement Chance", type="int", default=15, min=0, max=100},
--    {name="Max Enhancement Slots", type="int", default=4, min=1, max=4},
--    {name="Vermudian Rate", type="int", default=8, min=0, max=10},
--    {name="Battahli Rate", type="int", default=5, min=0, max=10},
--    {name="Elven Rate", type="int", default=5, min=0, max=10},
--    {name="Dwarven Rate", type="int", default=2, min=0, max=10},
--    {name="Body Drop Rate",type="int",default=3,min=1,max=100, tip="How often corpses are likely to spawn extra items/materials/gear"},
--    {name="Super Lucky Find Gear Chance", type="int",default=5,min=1,max=100, tip="On occasion a lucky find will drop higher tier gear than normal"},
--    {name="Super Lucky Find Gear Rank Offset", type="int",default=1,min=1,max=3, tip="The number of ranks to make an item available"},
    {name="Boss Gear Drop Chance",type="int",default=100,min=1,max=100, tip="Gear Drop Chance from Bosses. 100 means bosses will all drop 4 pieces of equipement (4 rolls are made versus the boss gear drop chance)."},
    {name="Chest Drop Rate",type="int",default=5,min=1,max=100, tip="How often chests are likely to spawn gear."},
    {name="Bonus Chest Loot",type="bool",default=true, tip="Whether items along with gear also drop from chests."},
    {name="Bonus Chest Loot Chance",type="int",default=25,min=1,max=100, tip="Chance for extra items that aren't gear to drop from chests."},
    {name="Chests Static Gear",type="bool",default=false, tip="Whether normal static gear drop in chests. If unticked, usual gear items in chests are replaced by useful consumables."},
    {name="Chests Static Gear Replacement Swapped to Random Gear",type="bool",default=true, tip="If 'Chest Static Gear' is unticked while this option is ticked, makes so it that static gear is replaced by random gear (according to chest area danger) rather than useful consumables."},
--    {name="Bodies Drop Extra Items",type="bool",default=false, tip="Whether items drop from corpses at all"},
--    {name="Bodies Drop Gear",type="bool",default=true, tip="Whether gear drops from corpses at all"},
--    {name="Bodies Drop Gear Chance",type="int",default=15,min=1,max=100, tip="Chance for gear to drop from all corpses"},

--    {name="Boss Drop Gear Rank Threshold",type="int",default=3,min=1,max=10, tip="Lower Values -> Higher Quality (Tighten's possible gear range of boss)"},
--    {name="Effect Body Loot",type="bool",default=true, tip="Enable/Disable extra items corpses"},
    {name="Effect Gimmick Loot",type="bool",default=false, tip="Enable/Disable extra items environmental objects."},
    {name="Gimmick Drop Rate",type="int",default=3,min=1,max=10, tip="How often environmental objects are likely to spawn extra items/materials."},
    {name="Enable Notifications",type="bool",default=true, tip="Enable looting system notifications."},
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

local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

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
local EndGameLevel = 80
local archer = config["Archer Gear Chance"]
local fighter = config["Fighter Gear Chance"]
local mage = config["Mage Gear Chance"]
local magick_archer = config["Magick Archer Gear Chance"]
local mystic_spearhand = config["Mystic Spearhand Gear Chance"]
local sorcerer = config["Sorcerer Gear Chance"]
local thief = config["Thief Gear Chance"]
local trickster = config["Trickster Gear Chance"]
local warrior = config["Warrior Gear Chance"]

local EnableNotifications = config["Enable Notifications"]
local GimmickDropRate = config["Gimmick Drop Rate"]
--local BodyDropRate = config["Body Drop Rate"]
local ChestDropRate = config["Chest Drop Rate"]
--local SuperLuckyFindGearDropChance = config["Super Lucky Find Gear Chance"]
--local SuperLuckyFindGearLevelingFactor = config["Super Lucky Find Gear Rank Offset"]
--local EffectBodyLoot = config["Effect Body Loot"]
local EffectGimmickLoot = config["Effect Gimmick Loot"]
local BonusChestLoot = config["Bonus Chest Loot"]
local BonusChestLootChance = config["Bonus Chest Loot Chance"]
local EnableStaticGear = config["Chests Static Gear"]
local EnableStaticGearRandomGear = config["Chests Static Gear Replacement Swapped to Random Gear"]
--local BonusBodyLoot = config["Bodies Drop Gear"]
--local BonusBodyLootChance = config["Bodies Drop Gear Chance"]
--local BodiesDropExtraItems = config["Bodies Drop Extra Items"]
local GauranteedBossDrops = config["Boss Gear Drop Chance"]
--local BossDropGearScale = config["Boss Drop Gear Rank Threshold"]
local EnableRandomEnhancements = false
local EnhancementChance = 0
local MaxEnhancementSlots = 0
local VermudianRate = 0
local BattahliRate = 0
local ElvenRate = 0
local DwarvenRate = 0
local WyrmfireRate = 0
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

local tmpBArmorsArcher = json.load_file(modname .. "/BArmorsArcher.json")
local tmpBArmorsFighter = json.load_file(modname .. "/BArmorsFighter.json")
local tmpBArmorsMage = json.load_file(modname .. "/BArmorsMage.json")
local tmpBArmorsMagickArcher = json.load_file(modname .. "/BArmorsMagickArcher.json")
local tmpBArmorsMystic = json.load_file(modname .. "/BArmorsMystic.json")
local tmpBArmorsSorcerer = json.load_file(modname .. "/BArmorsSorcerer.json")
local tmpBArmorsThief = json.load_file(modname .. "/BArmorsThief.json")
local tmpBArmorsTrickster = json.load_file(modname .. "/BArmorsTrickster.json")
local tmpBArmorsWarrior = json.load_file(modname .. "/BArmorsWarrior.json")

local tmpHArmorsArcher = json.load_file(modname .. "/HArmorsArcher.json")
local tmpHArmorsFighter = json.load_file(modname .. "/HArmorsFighter.json")
local tmpHArmorsMage = json.load_file(modname .. "/HArmorsMage.json")
local tmpHArmorsMagickArcher = json.load_file(modname .. "/HArmorsMagickArcher.json")
local tmpHArmorsMystic = json.load_file(modname .. "/HArmorsMystic.json")
local tmpHArmorsSorcerer = json.load_file(modname .. "/HArmorsSorcerer.json")
local tmpHArmorsThief = json.load_file(modname .. "/HArmorsThief.json")
local tmpHArmorsTrickster = json.load_file(modname .. "/HArmorsTrickster.json")
local tmpHArmorsWarrior = json.load_file(modname .. "/HArmorsWarrior.json")

local tmpLArmorsArcher = json.load_file(modname .. "/LArmorsArcher.json")
local tmpLArmorsFighter = json.load_file(modname .. "/LArmorsFighter.json")
local tmpLArmorsMage = json.load_file(modname .. "/LArmorsMage.json")
local tmpLArmorsMagickArcher = json.load_file(modname .. "/LArmorsMagickArcher.json")
local tmpLArmorsMystic = json.load_file(modname .. "/LArmorsMystic.json")
local tmpLArmorsSorcerer = json.load_file(modname .. "/LArmorsSorcerer.json")
local tmpLArmorsThief = json.load_file(modname .. "/LArmorsThief.json")
local tmpLArmorsTrickster = json.load_file(modname .. "/LArmorsTrickster.json")
local tmpLArmorsWarrior = json.load_file(modname .. "/LArmorsWarrior.json")

local GimmickItems = {tmpMaterials, tmpForage}
local BodyItems = {tmpCuratives, tmpMaterials, tmpImplements}
local ChestItems = {tmpHeadArmor, tmpBodyArmor, tmpLegArmor, tmpRings, tmpCloaks, tmpArchistaffs, tmpBows, tmpCensers, 
    tmpDaggers, tmpDuospears, tmpGreatSwords, tmpMagickalBows, tmpStaffs, tmpSwords, tmpShields}
local HArmors = {tmpHeadArmor}
local BArmors = {tmpBodyArmor}
local LArmors = {tmpLegArmor}
local Weapons = {tmpArchistaffs, tmpBows, tmpCensers, tmpDaggers, tmpDuospears, tmpGreatSwords, tmpMagickalBows, tmpStaffs, tmpSwords, tmpShields}
local BonusChestItems = {tmpCuratives, tmpMaterials, tmpImplements, tmpCloaks}

local ArcherLoot = {tmpBArmorsArcher, tmpHArmorsArcher, tmpLArmorsArcher, tmpBows}
local FighterLoot = {tmpBArmorsFighter, tmpHArmorsFighter, tmpLArmorsFighter, tmpSwords, tmpShields}
local MageLoot = {tmpBArmorsMage, tmpHArmorsMage, tmpLArmorsMage, tmpStaffs}
local MagickArcherLoot = {tmpBArmorsMagickArcher, tmpHArmorsMagickArcher, tmpLArmorsMagickArcher, tmpMagickalBows}
local MysticLoot = {tmpBArmorsMystic, tmpHArmorsMystic, tmpLArmorsMystic, tmpDuospears}
local SorcererLoot = {tmpBArmorsSorcerer, tmpHArmorsSorcerer, tmpLArmorsSorcerer, tmpArchistaffs}
local ThiefLoot = {tmpBArmorsThief, tmpHArmorsThief, tmpLArmorsThief, tmpDaggers}
local TricksterLoot = {tmpBArmorsTrickster, tmpHArmorsTrickster, tmpLArmorsTrickster, tmpCensers}
local WarriorLoot = {tmpBArmorsWarrior, tmpHArmorsWarrior, tmpLArmorsWarrior, tmpGreatSwords}

local VocationToLoot = {
    ["Archer"] = ArcherLoot,
    ["Fighter"] = FighterLoot,
    ["Mage"] = MageLoot,
    ["MagickArcher"] = MagickArcherLoot,
    ["Mystic"] = MysticLoot,
    ["Sorcerer"] = SorcererLoot,
    ["Thief"] = ThiefLoot,
    ["Trickster"] = TricksterLoot,
    ["Warrior"] = WarriorLoot
}

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

local function pick_a_class()
    local ClassRollTable = {}
    if archer > 0 then
        for i = 1,archer do
            table.insert(ClassRollTable, "Archer")
        end
    end

    if fighter > 0 then
        for i = 1,fighter do
            table.insert(ClassRollTable, "Fighter")
        end
    end

    if mage > 0 then
        for i = 1,mage do
            table.insert(ClassRollTable, "Mage")
        end
    end

    if magick_archer > 0 then
        for i = 1,magick_archer do
            table.insert(ClassRollTable, "MagickArcher")
        end
    end

    if mystic_spearhand > 0 then
        for i = 1,mystic_spearhand do
            table.insert(ClassRollTable, "Mystic")
        end
    end

    if sorcerer > 0 then
        for i = 1,sorcerer do
            table.insert(ClassRollTable, "Sorcerer")
        end
    end

    if thief > 0 then
        for i = 1,thief do
            table.insert(ClassRollTable, "Thief")
        end
    end

    if trickster > 0 then
        for i = 1,trickster do
            table.insert(ClassRollTable, "Trickster")
        end
    end

    if warrior > 0 then
        for i = 1,warrior do
            table.insert(ClassRollTable, "Warrior")
        end
    end

    shuffleTable(ClassRollTable)
    local ClassRoll = math.random(1,#ClassRollTable)
    local ClassPicked = ClassRollTable[ClassRoll]

    --printlog("Vocation picked: " .. ClassPicked)

    return ClassPicked
end

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
local font = imgui.load_font("Lucky Scavenger.otf", config.FontSize)

re.on_frame(function()
    archer = config["Archer Gear Chance"]
    fighter = config["Fighter Gear Chance"]
    mage = config["Mage Gear Chance"]
    magick_archer = config["Magick Archer Gear Chance"]
    mystic_spearhand = config["Mystic Spearhand Gear Chance"]
    sorcerer = config["Sorcerer Gear Chance"]
    thief = config["Thief Gear Chance"]
    trickster = config["Trickster Gear Chance"]
    warrior = config["Warrior Gear Chance"]
    EffectGimmickLoot = config["Effect Gimmick Loot"]
    GimmickDropRate = config["Gimmick Drop Rate"]
--    BodyDropRate = config["Body Drop Rate"]
--    SuperLuckyFindGearDropChance = config["Super Lucky Find Gear Chance"]
--    SuperLuckyFindGearLevelingFactor = config["Super Lucky Find Gear Rank Offset"]
--    EffectBodyLoot = config["Effect Body Loot"]
    ChestDropRate = config["Chest Drop Rate"]
    BonusChestLoot = config["Bonus Chest Loot"]
    BonusChestLootChance = config["Bonus Chest Loot Chance"]
    EnableStaticGear = config["Chests Static Gear"]
    EnableStaticGearRandomGear = config["Chests Static Gear Replacement Swapped to Random Gear"]
--    BonusBodyLoot = config["Bodies Drop Gear"]
--    BonusBodyLootChance = config["Bodies Drop Gear Chance"]
--    BodiesDropExtraItems = config["Bodies Drop Extra Items"]
    GauranteedBossDrops = config["Boss Gear Drop Chance"]
--    BossDropGearScale = config["Boss Drop Gear Rank Threshold"]
--    EnhancementChance = config["Enhancement Chance"]
--    MaxEnhancementSlots = config["Max Enhancement Slots"]
--    VermudianRate = config["Vermudian Rate"]
--    BattahliRate = config["Battahli Rate"]
--    ElvenRate = config["Elven Rate"]
--    DwarvenRate = config["Dwarven Rate"]
--    WyrmfireRate = config["Wyrmfire Rate"]
    EnableNotifications = config["Enable Notifications"]
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

local GuiManager = sdk.get_managed_singleton("app.GuiManager")

local UsefulItemsToReplaceBans = {1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 37, 38, 39, 41, 42, 43, 45, 46, 47, 49, 50, 52, 53, 55, 56, 57, 59, 60, 61, 62, 64, 65, 66, 67, 72, 73, 74, 80}

local StaticLootToBan = {
    [7000] = true,
    [5088] = true,
    [5040] = true,
    [5000] = true,
    [5074] = true,
    [5046] = true,
    [5001] = true,
    [5081] = true,
    [5019] = true,
    [5043] = true,
    [5091] = true,
    [5065] = true,
    [5004] = true,
    [5104] = true,
    [5122] = true,
    [5128] = true,
    [5132] = true,
    [5045] = true,
    [5041] = true,
    [5006] = true,
    [5016] = true,
    [5053] = true,
    [5130] = true,
    [5090] = true,
    [5034] = true,
    [5007] = true,
    [5119] = true,
    [5075] = true,
    [5125] = true,
    [5078] = true,
    [5137] = true,
    [5067] = true,
    [5123] = true,
    [5050] = true,
    [5032] = true,
    [5018] = true,
    [5097] = true,
    [5013] = true,
    [5139] = true,
    [5031] = true,
    [5106] = true,
    [5092] = true,
    [5052] = true,
    [5066] = true,
    [5105] = true,
    [5054] = true,
    [5024] = true,
    [5133] = true,
    [5134] = true,
    [5009] = true,
    [5035] = true,
    [5048] = true,
    [5055] = true,
    [5058] = true,
    [5102] = true,
    [5113] = true,
    [5068] = true,
    [5115] = true,
    [5083] = true,
    [5136] = true,
    [5095] = true,
    [5129] = true,
    [5124] = true,
    [5064] = true,
    [5012] = true,
    [5127] = true,
    [5135] = true,
    [5026] = true,
    [5116] = true,
    [5107] = true,
    [5073] = true,
    [5062] = true,
    [5039] = true,
    [5126] = true,
    [5131] = true,
    [5014] = true,
    [5096] = true,
    [5087] = true,
    [5085] = true,
    [5051] = true,
    [5060] = true,
    [5038] = true,
    [5015] = true,
    [5071] = true,
    [5028] = true,
    [5114] = true,
    [5029] = true,
    [5103] = true,
	[7001] = true,
	[6088] = true,
	[6040] = true,
	[6074] = true,
	[6000] = true,
	[6041] = true,
	[6075] = true,
	[6016] = true,
	[6104] = true,
	[6043] = true,
	[6046] = true,
	[6001] = true,
	[6091] = true,
	[6065] = true,
	[6004] = true,
	[6090] = true,
	[6045] = true,
	[6018] = true,
	[6095] = true,
	[6031] = true,
	[6006] = true,
	[6119] = true,
	[6092] = true,
	[6081] = true,
	[6097] = true,
	[6116] = true,
	[6060] = true,
	[6053] = true,
	[6007] = true,
	[6123] = true,
	[6058] = true,
	[6052] = true,
	[6078] = true,
	[6050] = true,
	[6102] = true,
	[6055] = true,
	[6122] = true,
	[6009] = true,
	[6067] = true,
	[6024] = true,
	[6013] = true,
	[6048] = true,
	[6062] = true,
	[6085] = true,
	[6073] = true,
	[6032] = true,
	[6113] = true,
	[6114] = true,
	[6012] = true,
	[6034] = true,
	[6028] = true,
	[6071] = true,
	[6035] = true,
	[6064] = true,
	[6015] = true,
	[6115] = true,
	[6103] = true,
	[6014] = true,
	[6019] = true,
	[6096] = true,
	[6087] = true,
	[6026] = true,
	[6068] = true,
	[6051] = true,
	[6038] = true,
	[6029] = true,
	[7001] = true,
	[6088] = true,
	[6040] = true,
	[6074] = true,
	[6000] = true,
	[6041] = true,
	[6075] = true,
	[6117] = true,
	[6016] = true,
	[6104] = true,
	[6043] = true,
	[6046] = true,
	[6124] = true,
	[6001] = true,
	[6091] = true,
	[6065] = true,
	[6004] = true,
	[6090] = true,
	[6045] = true,
	[6018] = true,
	[6095] = true,
	[6031] = true,
	[6006] = true,
	[6119] = true,
	[6092] = true,
	[6081] = true,
	[6097] = true,
	[6116] = true,
	[6060] = true,
	[6053] = true,
	[6007] = true,
	[6123] = true,
	[6058] = true,
	[6052] = true,
	[6078] = true,
	[6050] = true,
	[6102] = true,
	[6055] = true,
	[6122] = true,
	[6009] = true,
	[6067] = true,
	[6024] = true,
	[6013] = true,
	[6048] = true,
	[6062] = true,
	[6085] = true,
	[6073] = true,
	[6032] = true,
	[6113] = true,
	[6114] = true,
	[6012] = true,
	[6034] = true,
	[6028] = true,
	[6071] = true,
	[6035] = true,
	[6064] = true,
	[6015] = true,
	[6115] = true,
	[6103] = true,
	[6014] = true,
	[6019] = true,
	[6096] = true,
	[6087] = true,
	[6026] = true,
	[6068] = true,
	[6051] = true,
	[6038] = true,
	[6029] = true,
	[4000] = true,
	[4088] = true,
	[4074] = true,
	[4040] = true,
	[4001] = true,
	[4075] = true,
	[4090] = true,
	[4004] = true,
	[4043] = true,
	[4065] = true,
	[4019] = true,
	[4081] = true,
	[4007] = true,
	[4091] = true,
	[4130] = true,
	[4016] = true,
	[4122] = true,
	[4053] = true,
	[4123] = true,
	[4129] = true,
	[4041] = true,
	[4018] = true,
	[4031] = true,
	[4092] = true,
	[4078] = true,
	[4046] = true,
	[4106] = true,
	[4034] = true,
	[4105] = true,
	[4131] = true,
	[4124] = true,
	[4032] = true,
	[4045] = true,
	[4013] = true,
	[4097] = true,
	[4050] = true,
	[4134] = true,
	[4104] = true,
	[4067] = true,
	[4022] = true,
	[4052] = true,
	[4035] = true,
	[4064] = true,
	[4128] = true,
	[4133] = true,
	[4126] = true,
	[4085] = true,
	[4048] = true,
	[4009] = true,
	[4055] = true,
	[4006] = true,
	[4125] = true,
	[4024] = true,
	[4132] = true,
	[4012] = true,
	[4083] = true,
	[4095] = true,
	[4058] = true,
	[4066] = true,
	[4068] = true,
	[4060] = true,
	[4135] = true,
	[4102] = true,
	[4087] = true,
	[4115] = true,
	[4038] = true,
	[4071] = true,
	[4014] = true,
	[4062] = true,
	[4103] = true,
	[4073] = true,
	[4029] = true,
	[4026] = true,
	[4051] = true,
	[4039] = true,
	[4096] = true,
	[4015] = true,
    [1611] = true,
    [1601] = true,
    [1602] = true,
    [1603] = true,
    [1604] = true,
    [1607] = true,
    [1605] = true,
    [1608] = true,
    [1609] = true,
    [1612] = true,
    [1610] = true,
    [1606] = true,
    [1700] = true,
	[1701] = true,
	[1702] = true,
	[1705] = true,
	[1704] = true,
	[1703] = true,
	[1707] = true,
	[1709] = true,
	[1708] = true,
	[1803] = true,
	[1801] = true,
	[1802] = true,
	[1800] = true,
	[1706] = true,
	[1805] = true,
	[1804] = true,
    [2100] = true,
	[2101] = true,
	[2102] = true,
	[2103] = true,
	[2104] = true,
	[2105] = true,
    [1400] = true,
	[1401] = true,
	[8100] = true,
	[1403] = true,
	[1405] = true,
	[1406] = true,
	[1407] = true,
	[1404] = true,
	[1408] = true,
	[1410] = true,
	[1409] = true,
	[1415] = true,
	[1413] = true,
	[1417] = true,
	[1416] = true,
	[1412] = true,
	[1414] = true,
	[1411] = true,
    [2000] = true,
	[2001] = true,
	[2003] = true,
	[2002] = true,
	[2006] = true,
	[2005] = true,
	[2004] = true,
	[2009] = true,
	[2007] = true,
	[2010] = true,
	[1300] = true,
	[1202] = true,
	[1301] = true,
	[1201] = true,
	[1304] = true,
	[1205] = true,
	[1204] = true,
	[1206] = true,
	[1203] = true,
	[1302] = true,
	[1208] = true,
	[1303] = true,
	[1207] = true,
    [1900] = true,
	[1902] = true,
	[1909] = true,
	[1901] = true,
	[1904] = true,
	[1905] = true,
	[1906] = true,
	[1903] = true,
	[1907] = true,
	[1908] = true,
    [2200] = true,
	[2201] = true,
	[2202] = true,
	[2203] = true,
	[2204] = true,
	[2205] = true,
	[2206] = true,
	[2207] = true,
	[2208] = true,
	[2209] = true,
	[2210] = true,
    [1500] = true,
	[1501] = true,
	[1502] = true,
	[1503] = true,
	[1516] = true,
	[1506] = true,
	[1504] = true,
	[1517] = true,
	[1508] = true,
	[1505] = true,
	[1507] = true,
	[1510] = true,
	[1509] = true,
	[1511] = true,
	[1512] = true,
	[1513] = true,
	[1514] = true,
	[1003] = true,
	[1002] = true,
	[1004] = true,
	[1008] = true,
	[1100] = true,
	[1005] = true,
	[1007] = true,
	[1012] = true,
	[1104] = true,
	[1013] = true,
	[1103] = true,
	[1102] = true,
	[1006] = true,
	[1101] = true,
	[1009] = true,
	[1010] = true,
}

-- The names are just for reference, they're not used for anything
local BossInfo = {
	[3566561083] = {name = "Lich", lootTier = 4},
	[186889532] = {name = "Wight", lootTier = 2},
	[2629601821] = {name = "Dullahan", lootTier = 5},
    [4200835371] = {name = "Cyclops (all)", lootTier = 1},
	[797468852] = {name = "Cyclops (with club)", lootTier = 1},
	[2314122076] = {name = "Cyclops (unarmed)", lootTier = 1},
	[597201144] = {name = "Cyclops (armored) ", lootTier = 2},
	[2487358235] = {name = "Cyclops (armored)", lootTier = 2},
	[2142776531] = {name = "Cyclops (armored)", lootTier = 2},
	[3906583030] = {name = "Cyclops (full armor)", lootTier = 3},
	[377282979] = {name = "Cyclops (full armor)", lootTier = 3},
	[884021677] = {name = "Cyclops (full armor)", lootTier = 3},
	[2138374751] = {name = "Ogre", lootTier = 2},
	[786298456] = {name = "Grim Ogre", lootTier = 3},
	[2288155078] = {name = "Golem (2 health bars)", lootTier = 2}, 
	[1156291195] = {name = "Golem (3 health bars)", lootTier = 3}, 
	[2224608577] = {name = "Golem (4 health bars)", lootTier = 4}, 
	[812385671] = {name = "Golem (5 health bars)", lootTier = 4}, 
	[3547788120] = {name = "Griffin", lootTier = 3},
	[3369196004] = {name = "Sphinx", lootTier = 6},
	[4243003424] = {name = "Vermund Purgener", lootTier = 6},
	[355142415] = {name = "Island Encampent Purgener", lootTier = 6},
	[3550884773] = {name = "Chimera", lootTier = 3},
	[3236853785] = {name = "Gorechimera", lootTier = 4},
	[4170025353] = {name = "Medusa", lootTier = 4},
	[2475491578] = {name = "Sacred Arbor Purgener", lootTier = 6},
	[3417537573] = {name = "Volcanic Island Purgener", lootTier = 6},
	[3061246416] = {name = "Minotaur", lootTier = 2},
	[1057828479] = {name = "Goreminotaur", lootTier = 3},
	[2133916449] = {name = "Drake", lootTier = 4},
	[3538966457] = {name = "Lesser Dragon", lootTier = 6},
	[2631267673] = {name = "Dragon", lootTier = 6},
    [169713426] = {name = "Garm", lootTier = 3},
	[247902159] = {name = "Warg", lootTier = 3},
}

local VanishingBosses = {
	[186889532] = true,
	[2629601821] = true,
	[3369196004] = true,
	[4243003424] = true,
	[355142415] = true,
	[2475491578] = true,
	[3417537573] = true,
}

local AreaInfo = {
	[1] = {name = "Vermund", chestTiers = {1,1,1,1,1,2,2,2}},
	[2] = {name = "Battalh", chestTiers = {2,2,3,3,3,3,3,3,3,4}},
	[3] = {name = "Volcanic Island", chestTiers = {3,3,3,4,4,4,4,4,4,4,5}},
	[4] = {name = "Vermund to Battalh 1", chestTiers = {1,2,2,2,2,2,3,3}},
	[5] = {name = "Vermund to Battalh 2", chestTiers = {1,2,2,2,2,2,3,3}},
	[6] = {name = "Misty Marshes", chestTiers = {2,2,2,2,2,2,2,3}},
	[7] = {name = "Unmoored World", chestTiers = {4,4,4,5,5,5,5,6}},
}

local bossMaxRank = 6

local gameTime = os.clock()
local lastTime = os.clock()
local lastFlush = os.clock()
local AlreadyLooted = {}

-- REF addresses may be reused for other objects later, so we need to flush them eventually
-- Also to avoid using too much memory
local function flush_looted()
	for address,time in pairs(AlreadyLooted) do
        if time then
		-- Let's assume a player won't loot a boss once, then wait 5 minutes to loot a second time
		    if gameTime - time > 3600.0 then
			    AlreadyLooted[address] = nil
		    end
        end
	end
end

local function get_area()
    return WeatherManager._NowArea
end

local function generate_boss_loot(lootTable, bossTier, TypeNumber)
    -- Pick a list of items among the lootTable, see Weapons for instance
    itemList = lootTable[TypeNumber]

    local available_items = {}

    -- Defines loot quality based on the boss rank and the items list length
    local rankScaler = bossMaxRank/#itemList
    local maxItemRankAllowed = math.floor(bossTier / rankScaler)
    local minItemRankAllowed = math.floor((bossTier - 1) / rankScaler) -- Ensures that strong bosses don't drop bad items

    if minItemRankAllowed < 1 then
        minItemRankAllowed = 1
    end

    if maxItemRankAllowed < 1 then
        maxItemRankAllowed = 1
    end

    bigListRandomizer = (math.random(10,12) / 10)
    maxItemRankAllowed = math.ceil(maxItemRankAllowed * bigListRandomizer)
    minItemRankAllowed = math.ceil(minItemRankAllowed * bigListRandomizer)

    --printlog("Boss tier: " .. bossTier .. " | Rank Scaler:" .. rankScaler .. " | maxItemRankAllowed:" .. maxItemRankAllowed .. " | minItemRankAllowed:" .. minItemRankAllowed .. " | bigListRandomizer: " .. bigListRandomizer)

    for index, item in ipairs(itemList) do
        local itemRank = index -- just so code is more clear but both are equal
        if itemRank <= maxItemRankAllowed then
            Debug("name: " .. item.item_name .. " rank: " .. itemRank)
            --printlog("name: " .. item.item_name .. " rank: " .. itemRank)
            table.insert(available_items, {name = item.item_name, id = item.id, item_index = index, level = itemRank}) -- whatever is done with those in other functions, left untouched
        end
    end

    -- Select a random item from the filtered list of available items
    if #available_items > 0 then
        local selectedIndex = math.random(minItemRankAllowed, #available_items)
        selectedItem = available_items[selectedIndex]
    else
        selectedIndex = 1
        selectedItem = available_items[selectedIndex]
    end

    if selectedItem then
        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
        newItem.ItemId = selectedItem.id
        newItem.ItemNum = 1
        local itemName = selectedItem.name
        txtColor = config.BossDropTextColor
        txtColor = config.BossDropBackgroundColor
        Log("Boss Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. "/" .. maxItemRankAllowed .. " )", txtColor, bgColor)
        AddItem(newItem)
    end
end

local function generate_chest_loot(lootTable)
    -- Pick a list of items among the lootTable, see Weapons for instance
    shuffleTable(lootTable)
    local randomIndex = math.random(1, #lootTable)
    local itemList = lootTable[randomIndex]
    if not itemList then
        shuffleTable(lootTable)
        local randomIndex = math.random(1, #lootTable)
        local itemList = lootTable[randomIndex]
    end

    local available_items = {}

    local area = get_area()
    --printlog("Openning a chest in : " .. area)
    local info = AreaInfo[area]
    local tierList = info.chestTiers
    local tierIndex = math.random(1,#tierList)
    local chestTier = tierList[tierIndex]

    -- Defines loot quality based on the boss rank and the items list length
    local rankScaler = bossMaxRank/#itemList
    local maxItemRankAllowed = math.ceil(chestTier / rankScaler)
    local minItemRankAllowed = math.floor((chestTier - 1) / rankScaler) -- Ensures that strong chests don't drop bad items

    if maxItemRankAllowed < 1 then
        maxItemRankAllowed = 1
    end

    bigListRandomizer = (math.random(9,11) / 10)
    maxItemRankAllowed = math.floor(maxItemRankAllowed * bigListRandomizer)
    minItemRankAllowed = math.floor(minItemRankAllowed * bigListRandomizer)

    --printlog("Chest tier: " .. chestTier .. " | Rank Scaler:" .. rankScaler .. " | maxItemRankAllowed:" .. maxItemRankAllowed .. " | minItemRankAllowed:" .. minItemRankAllowed .. " | bigListRandomizer: " .. bigListRandomizer)

    for index, item in ipairs(itemList) do
        local itemRank = index -- just so code is more clear but both are equal
        if itemRank <= maxItemRankAllowed then
            Debug("name: " .. item.item_name .. " rank: " .. itemRank)
            --printlog("name: " .. item.item_name .. " rank: " .. itemRank)
            table.insert(available_items, {name = item.item_name, id = item.id, item_index = index, level = itemRank}) -- whatever is done with those in other functions, left untouched
        end
    end

    -- Select a random item from the filtered list of available items
    if #available_items > 0 then
        local selectedIndex = math.random(minItemRankAllowed, #available_items)
        selectedItem = available_items[selectedIndex]
    else
        selectedIndex = 1
        selectedItem = available_items[selectedIndex]
    end

    if selectedItem then
        local newItem = sdk.create_instance("app.gm80_001.ItemParam")
        newItem.ItemId = selectedItem.id
        newItem.ItemNum = 1
        local itemName = selectedItem.name
        txtColor = config.GearTextColor
        txtColor = config.GearBackgroundColor
        Log("Chest Find!: Received " .. itemName .. " ( Rank " .. string.format("%d", math.floor(selectedItem.level)) .. "/" .. maxItemRankAllowed .. " )", txtColor, bgColor)
        AddItem(newItem)
    end
end

sdk.hook(
    sdk.find_type_definition("app.ItemManager"):get_method("getItem(System.Int32, System.Int32, app.Character, System.Boolean, System.Boolean, System.Boolean, app.ItemManager.GetItemEventType, System.Boolean, System.Boolean)"),
    function (args)
        if EnableStaticGear == false then
            ItemManager = sdk.to_managed_object(args[2])
            itemID = sdk.to_int64(args[3])
            itemNum = sdk.to_int64(args[4])
            itemEventType = sdk.to_int64(args[9])

            if itemID ~= nil and itemEventType ~= nil then
                --printlog("Loot to potentially ban: " .. itemID .. " | EventType: " .. itemEventType .. " | Ban it? " .. tostring(StaticLootToBan[itemID]))
                if itemEventType == 4 and StaticLootToBan[itemID] then
                    if EnableStaticGearRandomGear == true then
                        Vocation = pick_a_class()
                        ChestLootTable = VocationToLoot[Vocation]
                        generate_chest_loot(ChestLootTable)

                        randomItemID = math.random(1,12)
                        randomItemNum = 1
                        args[3] = sdk.to_ptr(randomItemID)
                        args[4] = sdk.to_ptr(randomItemNum)
                    else
                        randomItemID = UsefulItemsToReplaceBans[ math.random( #UsefulItemsToReplaceBans ) ]
                        randomItemNum = 1
                        args[3] = sdk.to_ptr(randomItemID)
                        args[4] = sdk.to_ptr(randomItemNum)
                    end
                end
            end
        end
    end, nil
)

sdk.hook(
    sdk.find_type_definition("app.gm80_001"):get_method("getItem"),
    function(args)
        --printlog("Assessing Chest Loot...")

        if math.random(0, 99) < ChestFind then
            Vocation = pick_a_class()
            ChestLootTable = VocationToLoot[Vocation]

            generate_chest_loot(ChestLootTable)
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
                AddItem(newItem)
            end
            DumpSaveData()
        else
            if ChestFind then
                ChestFind = ChestFind + ChestDropRate
            else
                ChestFind = ChestDropRate
            end
            DumpSaveData()
        end
    end, nil
)

sdk.hook(
    sdk.find_type_definition("app.SearchDeadBodyInteractController"):get_method("executeInteract(System.UInt32, app.Character)"),
    function(args)
        local this = sdk.to_managed_object(args[2])
		local chara = this.Chara
		local address = chara:get_address() -- Unique per enemy
		if AlreadyLooted[address] then return end
		local info = BossInfo[chara:get_CharaID()] -- Since this is the true CharaID of the enemy, Cyclops variants should work properly
		local isBoss = info ~= nil
		local bossLootTier = info and info.lootTier

        if this._CharaId == "4200835371" then
            local cyclopTier = math.random(1,10)
            if cyclopTier <= 7 then
                bossLootTier = 1
            else
                bossLootTier = 2
            end
        end

        if this._CharaId == "3550884773" then
            local chimeraTier = math.random(1,10)
            if chimeraTier <= 5 then
                bossLootTier = 3
            else
                bossLootTier = 4
            end
        end
        
        if this._CharaId == "3236853785" then
            local gorechimeraTier = math.random(1,10)
            if gorechimeraTier <= 5 then
                bossLootTier = 4
            else
                bossLootTier = 5
            end
        end   

        if this._CharaId == "2138374751" then
            local ogreTier = math.random(1,10)
            if ogreTier <= 7 then
                bossLootTier = 2
            else
                bossLootTier = 3
            end
        end

        if this._CharaId == "786298456" then
            local grimeogreTier = math.random(1,10)
            if grimeogreTier <= 7 then
                bossLootTier = 3
            else
                bossLootTier = 4
            end
        end

        if this._CharaId == "3061246416" then
            local minoTier = math.random(1,10)
            if minoTier <= 6 then
                bossLootTier = 2
            else
                bossLootTier = 3
            end
        end

        if this._CharaId == "1057828479" then
            local goreminoTier = math.random(1,10)
            if goreminoTier <= 5 then
                bossLootTier = 3
            else
                bossLootTier = 4
            end
        end

        if this._CharaId == "2133916449" then
            local drakeTier = math.random(1,10)
            if drakeTier <= 5 then
                bossLootTier = 4
            else
                bossLootTier = 5
            end
        end

        if this._CharaId == "2629601821" then
            local dullahanTier = math.random(1,10)
            if dullahanTier <= 5 then
                bossLootTier = 5
            else
                bossLootTier = 6
            end
        end

        if this._CharaId == "3547788120" then
            local griffinTier = math.random(1,10)
            if griffinTier <= 4 then
                bossLootTier = 3
            else
                bossLootTier = 4
            end
        end        

        if isBoss then
            local bossLootChance = GauranteedBossDrops
            local Hdrop = math.random(1,99)
            local Bdrop = math.random(1,99)
            local Ldrop = math.random(1,99)
            local Wdrop = math.random(1,99)
            --printlog(Hdrop)
            --printlog(Bdrop)
            --printlog(Ldrop)
            --printlog(Wdrop)
 
            if this._CharaId == "169713426" or this._CharaId == "247902159" then -- Garm and Wargs are "semi bosses" and can only drop 1 item
                Hdrop = 102
                Bdrop = 102
                Ldrop = 102
                Wdrop = 102
                bossLootTier = math.random(3,4)
            end

            if this._CharaId == "3538966457" or this._CharaId == "4243003424" or this._CharaId == "355142415" or this._CharaId == "2475491578" or this._CharaId == "3417537573" then  -- Lesser Dragon always drops 4 items
                Hdrop = 1
                Bdrop = 1
                Ldrop = 1
                Wdrop = 1
            end

            if Wdrop > bossLootChance and Hdrop > bossLootChance and Ldrop > bossLootChance and Bdrop > bossLootChance then -- Ensures atleast 1 loot per boss
                unluckyDrop = math.random(1,4)

                if unluckyDrop == 1 then
                    Hdrop = 1
                end

                if unluckyDrop == 2 then
                    Bdrop = 1
                end

                if unluckyDrop == 3 then
                    Ldrop = 1
                end

                if unluckyDrop == 4 then
                    Wdrop = 1
                end
            end

            Vocation = pick_a_class()
            BossLootTable = VocationToLoot[Vocation]

            if  Wdrop <= bossLootChance then
                generate_boss_loot(BossLootTable, bossLootTier, 4)
            end
            if  Ldrop <= bossLootChance then
                generate_boss_loot(BossLootTable, bossLootTier, 3)
            end
            if  Hdrop <= bossLootChance then
                generate_boss_loot(BossLootTable, bossLootTier, 2)
            end
            if  Bdrop <= bossLootChance then
                generate_boss_loot(BossLootTable, bossLootTier, 1)
            end
        end

		AlreadyLooted[address] = true
    end
)

local hitControllerGetCachedCharacter = sdk.find_type_definition("app.HitController"):get_method("get_CachedCharacter")
local characterGetCharaIdMethod = sdk.find_type_definition("app.Character"):get_method("get_CharaID")

sdk.hook(
	sdk.find_type_definition("app.Character"):get_method("onDieFromAttack(app.HitController.DamageInfo)"),
	function(args)
        --printlog("Enemy dying from attack")
        local this = sdk.to_managed_object(args[2])
        if not this then return end
        --printlog("This found")
        local id = this:get_CharaID()
        local address = this:get_address() -- Unique per enemy
        if AlreadyLooted[address] then return end
        --printlog("Found a chara being destroyed and not already looted with the following id: " .. id .. "| Address: " .. address)

        if VanishingBosses[id] then
            --printlog("Found a boss with vanishing body.")
            local info = BossInfo[id] -- Since this is the true CharaID of the enemy, Cyclops variants should work properly
            local isBoss = info ~= nil
            local bossLootTier = info and info.lootTier
            if isBoss then
                local bossLootChance = GauranteedBossDrops
                local Hdrop = math.random(1,99)
                local Bdrop = math.random(1,99)
                local Ldrop = math.random(1,99)
                local Wdrop = math.random(1,99)
                --printlog(Hdrop)
                --printlog(Bdrop)
                --printlog(Ldrop)
                --printlog(Wdrop)

                if Wdrop > bossLootChance and Hdrop > bossLootChance and Ldrop > bossLootChance and Bdrop > bossLootChance then -- Ensures atleast 1 loot per boss
                    unluckyDrop = math.random(1,4)

                    if unluckyDrop == 1 then
                        Hdrop = 1
                    end

                    if unluckyDrop == 2 then
                        Bdrop = 1
                    end

                    if unluckyDrop == 3 then
                        Ldrop = 1
                    end

                    if unluckyDrop == 4 then
                        Wdrop = 1
                    end
                end

                Vocation = pick_a_class()

                BossLootTable = VocationToLoot[Vocation]

                if  Wdrop <= bossLootChance then
                    generate_boss_loot(BossLootTable, bossLootTier, 4)
                end
                if  Ldrop <= bossLootChance then
                    generate_boss_loot(BossLootTable, bossLootTier, 3)
                end
                if  Hdrop <= bossLootChance then
                    generate_boss_loot(BossLootTable, bossLootTier, 2)
                end
                if  Bdrop <= bossLootChance then
                    generate_boss_loot(BossLootTable, bossLootTier, 1)
                end
            end
        end

--        AlreadyLooted[address] = true
	end
)


-- Pretty reliable at flushing addresses, no need to flush regularly
sdk.hook(
	sdk.find_type_definition("app.HitController"):get_method("onDestroy()"),
	function(args)
		local this = sdk.to_managed_object(args[2])
		local character = this["<CachedCharacter>k__BackingField"]
		if not character then return end
		local address = character:get_address()
		AlreadyLooted[address] = nil
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