local re = re
local sdk = sdk
local d2d = d2d
local imgui = imgui
local log = log
local json = json
local draw = draw

local modname="CampRaids"
local configfile=modname..".json"
log.info("["..modname.."]".."Start")

--settings
local _config={
    {name="raid_chance",type="float",default=35.0,min=0.0,max=100.0},
}

--merge config file to default config
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

config= recurse_def_settings(config, json.load_file(configfile) or {})


sdk.hook(sdk.find_type_definition("app.CampSetUserData.RaidSetting"):get_method("isRaidOccur(app.CampController)"),
function (args)
end, function(ret)
    raid_roll = math.random(1,99)
    raid_stat = config.raid_chance
    if raid_roll <= raid_stat then
        return sdk.to_ptr(true)
    else
        return sdk.to_ptr(false)
    end
end)

local function OnChanged()    
    raid_stat = config.raid_chance
end

local function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    return nil
end

local myapi = prequire("_XYZApi/_XYZApi")
if myapi~=nil then myapi.DrawIt(modname,configfile,_config,config, OnChanged) end

--sdk.hook(
--	sdk.find_type_definition("app.CampStateEndSleepTent"):get_method("onCampUpdate(app.CampController)"),
--	function(args)
--        local campController = sdk.to_managed_object(args[3])
--        local surpriseAttack = false
--        if surpriseAttack then
--            campController:call("set_IsSupriseAttacked", true)
--        end
--
--        local raid = true
--        if raid then
--            campController:call("set_IsRaided", true)
--        end
--    end
--)