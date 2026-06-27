--[[
	VAULT HUB — Охотники за хранилищами: Открытый мир
	Автофарм: бид, продажа, рыбалка, зельки, мойка, оценка, ремонт, локсмит, покупка
	GUI: RU/EN, анимации, иконки, Right Shift, загрузочный экран, конфиг (save/import/export)
	Загрузка: loadstring(game:HttpGet("https://github.com/SqwaTik/Scripts/raw/refs/heads/main/VaultHub.lua"))()
]]

if shared.__VAULTHUB_LOADED then
	local cg = (gethui and gethui()) or game:GetService("CoreGui")
	local ex = cg:FindFirstChild("VaultHubGui")
	if ex then ex:Destroy() end
end
shared.__VAULTHUB_LOADED = true
local VH_SCRIPT_URL = "https://raw.githubusercontent.com/SqwaTik/Scripts/main/VaultHub.lua"

local _BUILD_OK, _BUILD_ERR = xpcall(function()

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local HttpService        = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- EXECUTOR COMPAT
---------------------------------------------------------------------
local httpGet     = (syn and syn.request) and nil or nil
local writefileF  = writefile
local readfileF   = readfile
local isfileF     = isfile
local isfolderF   = isfolder
local makefolderF = makefolder
local function hasFS() return (writefileF and readfileF and isfileF) ~= nil end

local CONFIG_FOLDER = "VaultHub"
local CONFIG_FILE   = CONFIG_FOLDER .. "/config.json"

---------------------------------------------------------------------
-- LOCALIZATION (RU / EN)
---------------------------------------------------------------------
local Locale = "ru"
local L = {
	ru = {
		title="VAULT HUB", subtitle="Охотники за хранилищами",
		loading="Загрузка...", ready="Готово",
		tab_home="Главная", tab_farm="Автофарм", tab_sell="Продажа", tab_process="Обработка",
		tab_tp="Телепорты", tab_shop="Магазин", tab_settings="Настройки",
		-- home
		networth="Состояние", coins="Монеты", players="Игроков", luck="Удача",
		quick="Быстрые действия", uptime="Аптайм",
		-- farm
		auto_bid="Авто-бид (аукцион)", min_bid="Скип, если ставка <",
		max_bid="Макс. ставка (стоп)", bid_area="Локация аукциона",
		auto_buyitems="Выкупать предметы в +", profit_min="Мин. профит",
		auto_fish="Авто-рыбалка", auto_collect="Авто-сбор всего",
		bid_speed="Скорость ставок",
		auto_stock="Авто-раскладка по полкам", auto_trade="Авто-торговля с клиентами",
		trade_min="Принимать оффер от %", return_full="Возврат на базу при фулл весе",
		-- sell
		auto_sell="Авто-продажа", sell_with_car="Подгонять тачку", keep_fav="Не продавать избранное",
		keep_trophy="Не продавать трофеи", sell_min="Мин. цена для продажи", sell_now="Продать сейчас",
		pawn_rate="Курс скупки", est_value="Оценка инвентаря",
		-- process
		auto_wash="Авто-мойка", auto_grade="Авто-оценка", auto_repair="Авто-ремонт",
		wash_min="Мыть от цены", grade_min="Оценивать от цены", source="Источник",
		src_inv="Инвентарь", src_car="Тачка",
		-- shop
		auto_buy_drink="Авто-покупка зелек", drink_tier="Уровень зелья",
		buy_now="Купить сейчас", restock="Ресток через",
		-- tp
		tp_areas="Локации", tp_shops="Магазины", tp_players="Магазины игроков",
		spawn_car="Заспавнить тачку",
		-- settings
		language="Язык", keybind="Клавиша открытия", save_cfg="Сохранить конфиг",
		load_cfg="Загрузить конфиг", export_cfg="Экспорт", import_cfg="Импорт",
		cfg_saved="Конфиг сохранён", cfg_loaded="Конфиг загружен",
		cfg_exported="Скопировано в буфер", cfg_imported="Конфиг импортирован",
		paste_here="Вставь конфиг сюда...", credits="by SqwaTik",
		on="ВКЛ", off="ВЫКЛ", none="нет",
		rmb_hint="ПКМ по функции — поднастройки", predictions="Эвенты",
		ev_soon="скоро", ev_active="идёт",
	},
	en = {
		title="VAULT HUB", subtitle="Vault Hunters Open World",
		loading="Loading...", ready="Ready",
		tab_home="Home", tab_farm="Auto Farm", tab_sell="Selling", tab_process="Processing",
		tab_tp="Teleports", tab_shop="Shop", tab_settings="Settings",
		networth="Net Worth", coins="Coins", players="Players", luck="Luck",
		quick="Quick Actions", uptime="Uptime",
		auto_bid="Auto Bid (auction)", min_bid="Skip if bid <",
		max_bid="Max bid (stop)", bid_area="Auction area",
		auto_buyitems="Buy profitable items", profit_min="Min profit",
		auto_fish="Auto Fishing", auto_collect="Auto Collect All",
		bid_speed="Bid Speed",
		auto_stock="Auto stock shelves", auto_trade="Auto trade with customers",
		trade_min="Accept offer from %", return_full="Return to base when full",
		auto_sell="Auto Sell", sell_with_car="Bring vehicle", keep_fav="Keep favorited",
		keep_trophy="Keep trophies", sell_min="Min price to sell", sell_now="Sell Now",
		pawn_rate="Pawn Rate", est_value="Inventory Value",
		auto_wash="Auto Wash", auto_grade="Auto Grade", auto_repair="Auto Repair",
		wash_min="Wash from price", grade_min="Grade from price", source="Source",
		src_inv="Inventory", src_car="Vehicle",
		auto_buy_drink="Auto Buy Drinks", drink_tier="Drink Tier",
		buy_now="Buy Now", restock="Restock in",
		tp_areas="Areas", tp_shops="Shops", tp_players="Player Shops",
		spawn_car="Spawn Vehicle",
		language="Language", keybind="Toggle Key", save_cfg="Save Config",
		load_cfg="Load Config", export_cfg="Export", import_cfg="Import",
		cfg_saved="Config saved", cfg_loaded="Config loaded",
		cfg_exported="Copied to clipboard", cfg_imported="Config imported",
		paste_here="Paste config here...", credits="by SqwaTik",
		on="ON", off="OFF", none="none",
		rmb_hint="Right-click a function for sub-settings", predictions="Events",
		ev_soon="soon", ev_active="active",
	},
}
local function T(key)
	return (L[Locale] and L[Locale][key]) or (L.en[key]) or key
end

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------
local Config = {
	language = "ru",
	keybind = "RightShift",
	-- farm
	autoBid = false, minBid = 0, maxBid = 25000, bidSpeed = 0.35,
	bidArea = "", autoBuyItems = false, profitMin = 20,
	autoFish = false, autoCollectAll = false,
	-- trade / shop management
	autoStock = false, autoTrade = false, tradeMinPercent = 80, returnWhenFull = true,
	-- sell
	autoSell = false, sellWithCar = true, keepFav = true, keepTrophy = false, sellMin = 0,
	-- process
	autoWash = false, autoGrade = false, autoRepair = false,
	washMin = 100, gradeMin = 100, procSource = "Inventory",
	-- shop
	autoBuyDrink = false, drinkTier = "1",
}

local function deepCopy(t)
	local r = {}
	for k,v in pairs(t) do r[k] = (type(v)=="table") and deepCopy(v) or v end
	return r
end

local function saveConfig()
	if not hasFS() then return false, "no filesystem" end
	pcall(function()
		if makefolderF and isfolderF and not isfolderF(CONFIG_FOLDER) then makefolderF(CONFIG_FOLDER) end
	end)
	local ok = pcall(function() writefileF(CONFIG_FILE, HttpService:JSONEncode(Config)) end)
	return ok
end

-- авто-действия, которые НЕ должны включаться сами при загрузке (иначе тепает/фармит сразу)
local AUTO_KEYS = {"autoBid","autoFish","autoSell","autoWash","autoGrade","autoRepair",
	"autoBuyDrink","autoStock","autoTrade","autoCollectAll","autoBuyItems","returnWhenFull"}

local function resetAutoFlags()
	for _, k in ipairs(AUTO_KEYS) do Config[k] = false end
end

local function loadConfig()
	if not hasFS() then resetAutoFlags(); return false end
	if not isfileF(CONFIG_FILE) then resetAutoFlags(); return false end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfileF(CONFIG_FILE)) end)
	if ok and type(data)=="table" then
		for k,v in pairs(data) do Config[k] = v end
		Locale = Config.language or "ru"
	end
	-- всегда стартуем с выключенными авто-функциями
	resetAutoFlags()
	return true
end

local function exportConfig()
	local raw = HttpService:JSONEncode(Config)
	local b64
	pcall(function()
		local enc = (syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.encode)
			or (crypt and crypt.base64encode) or (crypt and crypt.base64 and crypt.base64.encode)
			or (base64 and base64.encode)
		if enc then b64 = enc(raw) end
	end)
	b64 = b64 or raw
	pcall(function() (setclipboard or toclipboard or writeclipboard)(b64) end)
	return b64
end

local function importConfig(str)
	if not str or #str == 0 then return false end
	local raw = str
	pcall(function()
		local dec = (syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode)
			or (crypt and crypt.base64decode) or (crypt and crypt.base64 and crypt.base64.decode)
			or (base64 and base64.decode)
		if dec then
			local ok, res = pcall(dec, str)
			if ok and res and res:find("{") then raw = res end
		end
	end)
	local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok and type(data)=="table" then
		for k,v in pairs(data) do Config[k] = v end
		Locale = Config.language or Locale
		resetAutoFlags()
		saveConfig()
		return true
	end
	return false
end

-- загружаем конфиг СРАЗУ (до построения GUI), чтобы слайдеры/язык отразили сохранённое
loadConfig()
Locale = Config.language or "ru"

---------------------------------------------------------------------
-- GAME API (реверс-обёртки)
---------------------------------------------------------------------
local Events = ReplicatedStorage:WaitForChild("Events")
local function ev(path)
	local node = Events
	for _,p in ipairs(string.split(path,".")) do
		node = node and node:FindFirstChild(p)
	end
	return node
end

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Items, MutatorModule, GradingMod
pcall(function() Items = require(Modules.Items) end)
pcall(function() MutatorModule = require(Modules.MutatorModule) end)
pcall(function() GradingMod = require(Modules.Grading) end)

local API = {}

function API.itemPrice(entry)
	if not Items or not entry or not entry.ItemId then return 0 end
	local def = Items[tostring(entry.ItemId)]
	if not def then return 0 end
	local price = def.BasePrice or 0
	if MutatorModule and MutatorModule.CalculatePriceForEntry then
		local ok, p = pcall(function() return MutatorModule:CalculatePriceForEntry(def.BasePrice or 0, entry) end)
		if ok and type(p)=="number" then price = p end
	end
	if entry.Grade and GradingMod and GradingMod.GradeMultipliers and GradingMod.GradeMultipliers[entry.Grade] then
		price = price * GradingMod.GradeMultipliers[entry.Grade]
	end
	return price
end

function API.getPOIs()
	local f = ev("GPS.GetPOIs")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	if ok and res and res.pois then return res.pois end
	return {}
end

function API.getInventory()
	local f = ev("Inventory.GetPlayerInventory")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and type(res)=="table") and res or {}
end

function API.getSellable()
	local f = ev("Pawn.GetSellableItems")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and type(res)=="table") and res or {}
end

function API.pawnState()
	local f = ev("Pawn.GetPawnState")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and res) or {}
end

function API.sell(guids)
	local f = ev("Pawn.SellItems")
	if not f or #guids == 0 then return false end
	local ok, res = pcall(function() return f:InvokeServer(guids) end)
	return ok, res
end

function API.energyCatalog()
	local f = ev("EnergyShop.GetCatalog")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and res) or {}
end

function API.buyDrink(drinkId)
	local f = ev("EnergyShop.BuyDrink")
	if not f then return false end
	-- сигнатура: BuyDrink(EnergyDrinkId)
	local ok, res = pcall(function() return f:InvokeServer(drinkId) end)
	return ok, res
end

function API.getVehicles()
	local f = ev("Vehicles.GetOwnedVehicles")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and res) or {}
end

function API.spawnVehicle(guid)
	local f = ev("Vehicles.RequestSpawn")
	if not f then return false end
	local g = guid
	if not g then
		local v = API.getVehicles()
		g = v.equippedGuid
	end
	if not g then return false end
	pcall(function() f:FireServer(g) end)
	return true
end

-- универсальные обёртки обработки (Wash/Grading/Repair/Locksmith)
local PROC = {
	Wash    = {get="Wash.GetWashableItems",    start="Wash.StartWash",       slot="Wash.GetSlotState",     claim="Wash.ClaimWashedItem",   collect="Wash.CollectWash"},
	Grade   = {get="Grading.GetGradableItems", start="Grading.StartGrading", slot="Grading.GetSlotState",  claim="Grading.ClaimGradedItem",collect="Grading.CollectGrade"},
	Repair  = {get="Repair.GetRepairableItems",start="Repair.StartRepair",   slot="Repair.GetSlotState",   claim="Repair.ClaimRepairedItem",collect="Repair.CollectRepair"},
}

function API.procItems(kind)
	local p = PROC[kind]; if not p then return {} end
	local f = ev(p.get); if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and type(res)=="table") and res or {}
end

function API.procSlots(kind)
	local p = PROC[kind]; if not p then return {} end
	local f = ev(p.slot); if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and res) or {unlockedCount=0, slots={}}
end

function API.procStart(kind, slotIdx, guid, source, vehicleGUID)
	local p = PROC[kind]; if not p then return false end
	local f = ev(p.start); if not f then return false end
	local ok, res = pcall(function() return f:InvokeServer(slotIdx, guid, source, vehicleGUID) end)
	return ok, res
end

function API.procClaim(kind, slotIdx, guid)
	local p = PROC[kind]; if not p then return false end
	local f = ev(p.claim); if not f then return false end
	local ok, res = pcall(function() return f:InvokeServer(slotIdx, guid) end)
	if not ok then
		local cf = ev(p.collect)
		if cf then pcall(function() cf:InvokeServer(slotIdx) end) end
	end
	return ok, res
end

-- auction
function API.bid()
	local f = ev("Auction.Bid")
	if f then pcall(function() f:FireServer() end) end
end
function API.leaveAuction()
	local f = ev("Auction.LeaveAuction")
	if f then pcall(function() f:InvokeServer() end) end
end

-- vehicle weight & transfer
function API.vehicleWeight()
	-- VehicleWeightUpdate приходит событием; пробуем атрибуты персонажа/тачки
	local w = LocalPlayer:GetAttribute("VehicleWeight") or LocalPlayer:GetAttribute("CarryWeight")
	local mx = LocalPlayer:GetAttribute("VehicleMaxWeight") or LocalPlayer:GetAttribute("MaxWeight")
	return w, mx
end
function API.transferVehicleItems()
	local f = ev("Vehicles.TransferVehicleItemsToInventory")
	if not f then return false end
	local g = API.getVehicles().equippedGuid
	pcall(function() f:FireServer(g) end)
	return true
end

-- staff (авто-торговля через наёмного помощника)
function API.getStaff()
	local f = ev("Staff.GetStaffData")
	if not f then return {} end
	local ok, res = pcall(function() return f:InvokeServer() end)
	return (ok and res) or {}
end
function API.hireStaff(staffType)
	local f = ev("Staff.HireStaff")
	if not f then return false end
	local ok, res = pcall(function() return f:InvokeServer(staffType) end)
	return ok, res
end
function API.setStaffOffer(staffId, percent)
	local f = ev("Staff.UpdateStaffConfig")
	if f then pcall(function() f:FireServer(staffId, {MinOfferPercent = percent}) end) end
end

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function getHRP()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function parseVec(str)
	if typeof(str) == "Vector3" then return str end
	local x,y,z = tostring(str):match("(-?%d+%.?%d*),%s*(-?%d+%.?%d*),%s*(-?%d+%.?%d*)")
	if x then return Vector3.new(tonumber(x), tonumber(y), tonumber(z)) end
	return nil
end

local function teleport(pos)
	local hrp = getHRP()
	local v = parseVec(pos)
	if hrp and v then
		hrp.CFrame = CFrame.new(v + Vector3.new(0, 4, 0))
		return true
	end
	return false
end

local function notify(text, color)
	local f = ev("UI.Notify")
	if f then pcall(function() f:FireServer(text) end) end
end

local function commas(n)
	n = math.floor(tonumber(n) or 0)
	local s = tostring(n)
	local out = s:reverse():gsub("(%d%d%d)", "%1 "):reverse()
	return (out:gsub("^%s+",""))
end

local function getNetWorth()
	local cash = LocalPlayer:GetAttribute("Cash") or 0
	local nw = LocalPlayer:GetAttribute("NetWorth") or LocalPlayer:GetAttribute("MaxNetWorth") or 0
	-- точный нетворт, если доступен
	local f = ev("UI.GetNetWorthBreakdown")
	if f then
		local ok, res = pcall(function() return f:InvokeServer() end)
		if ok and type(res)=="table" then
			nw = res.total or res.netWorth or res.NetWorth or nw
		end
	end
	return nw, cash
end

---------------------------------------------------------------------
-- THEME
---------------------------------------------------------------------
local Theme = {
	Bg        = Color3.fromRGB(15, 16, 22),
	Panel     = Color3.fromRGB(22, 24, 32),
	Surface   = Color3.fromRGB(30, 33, 44),
	SurfaceHl = Color3.fromRGB(40, 44, 58),
	Stroke    = Color3.fromRGB(48, 52, 68),
	Accent    = Color3.fromRGB(120, 110, 255),
	Accent2   = Color3.fromRGB(90, 200, 255),
	Success   = Color3.fromRGB(70, 220, 140),
	Danger    = Color3.fromRGB(255, 90, 110),
	Text      = Color3.fromRGB(235, 238, 250),
	SubText   = Color3.fromRGB(140, 146, 168),
}

local ICON = {
	home    = "rbxassetid://10723407389",
	farm    = "rbxassetid://120291053901182",  -- Lake (game)
	sell    = "rbxassetid://116204155184116",  -- Pawn (game)
	process = "rbxassetid://127877743329826",  -- Repair (game)
	tp      = "rbxassetid://120644819082905",  -- Area (game)
	shop    = "rbxassetid://15133445964",       -- Energy (game)
	settings= "rbxassetid://10734950309",
	close   = "rbxassetid://7733658504",
	logo    = "rbxassetid://116204155184116",
}
local POI_ICON = {
	["Area"]="rbxassetid://120644819082905", ["Shop"]="rbxassetid://18136118615",
	["Player Shop"]="rbxassetid://124620632231839",
	["Grading Store"]="rbxassetid://138880939782808", ["Car Customisation"]="rbxassetid://128071570341302",
	["Locksmith"]="rbxassetid://117308097936020", ["Shopping Mall"]="rbxassetid://18136118615",
	["Car Shop"]="rbxassetid://101646918234834", ["Repair Shop"]="rbxassetid://127877743329826",
	["Item Cleaning Services"]="rbxassetid://73439729673986", ["Lake"]="rbxassetid://120291053901182",
	["Trailer Store"]="rbxassetid://74579694256080", ["Pawn Shop"]="rbxassetid://116204155184116",
	["Energy Drink Shop"]="rbxassetid://15133445964",
}

local function tween(obj, t, props, style, dir)
	local ti = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, ti, props)
	tw:Play()
	return tw
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end
local function stroke(parent, color, th, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = th or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end
local function pad(parent, all)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, all); p.PaddingBottom = UDim.new(0, all)
	p.PaddingLeft = UDim.new(0, all); p.PaddingRight = UDim.new(0, all)
	p.Parent = parent
	return p
end

---------------------------------------------------------------------
-- ROOT GUI
---------------------------------------------------------------------
local old = PlayerGui:FindFirstChild("VaultHubGui")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VaultHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
pcall(function() ScreenGui.Parent = (gethui and gethui()) or PlayerGui end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

---------------------------------------------------------------------
-- LOADING SCREEN
---------------------------------------------------------------------
local function showLoader(onDone)
	local lf = Instance.new("Frame")
	lf.Name = "Loader"
	lf.Size = UDim2.fromScale(1,1)
	lf.BackgroundColor3 = Theme.Bg
	lf.BackgroundTransparency = 0
	lf.Parent = ScreenGui

	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(360, 150)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.BackgroundTransparency = 1
	box.Parent = lf

	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.fromOffset(64, 64)
	logo.Position = UDim2.new(0.5, 0, 0, 0)
	logo.AnchorPoint = Vector2.new(0.5, 0)
	logo.BackgroundTransparency = 1
	logo.Image = ICON.logo
	logo.ImageColor3 = Theme.Accent
	logo.Parent = box

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 72)
	title.BackgroundTransparency = 1
	title.Text = "VAULT HUB"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextColor3 = Theme.Text
	title.Parent = box

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, 0, 0, 6)
	barBg.Position = UDim2.new(0, 0, 0, 112)
	barBg.BackgroundColor3 = Theme.Surface
	barBg.BorderSizePixel = 0
	barBg.Parent = box
	corner(barBg, 3)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.BackgroundColor3 = Theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = barBg
	corner(bar, 3)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
	grad.Parent = bar

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, 0, 0, 20)
	status.Position = UDim2.new(0, 0, 0, 124)
	status.BackgroundTransparency = 1
	status.Text = T("loading")
	status.Font = Enum.Font.Gotham
	status.TextSize = 12
	status.TextColor3 = Theme.SubText
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = box

	task.spawn(function()
		local steps = {"init", "remotes", "items", "ui", "done"}
		for i, _ in ipairs(steps) do
			tween(bar, 0.25, {Size = UDim2.new(i/#steps, 0, 1, 0)})
			task.wait(0.18)
		end
		status.Text = T("ready")
		task.wait(0.25)
		tween(lf, 0.4, {BackgroundTransparency = 1})
		for _,d in ipairs(box:GetDescendants()) do
			if d:IsA("TextLabel") then tween(d, 0.3, {TextTransparency=1}) end
			if d:IsA("ImageLabel") then tween(d, 0.3, {ImageTransparency=1}) end
			if d:IsA("Frame") then tween(d, 0.3, {BackgroundTransparency=1}) end
		end
		task.wait(0.4)
		lf:Destroy()
		if onDone then onDone() end
	end)
end

---------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(640, 440)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = ScreenGui
corner(Main, 14)
stroke(Main, Theme.Stroke, 1, 0.2)

-- drag
do
	local dragging, dragStart, startPos
	local TitleDragArea
	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - Main.AbsolutePosition.Y < 56 then
			dragging = true; dragStart = input.Position; startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- SIDEBAR
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 170, 1, 0)
Side.BackgroundColor3 = Theme.Panel
Side.BorderSizePixel = 0
Side.Parent = Main

local sideHeader = Instance.new("Frame")
sideHeader.Size = UDim2.new(1, 0, 0, 64)
sideHeader.BackgroundTransparency = 1
sideHeader.Parent = Side

local logoImg = Instance.new("ImageLabel")
logoImg.Size = UDim2.fromOffset(34, 34)
logoImg.Position = UDim2.new(0, 16, 0.5, 0)
logoImg.AnchorPoint = Vector2.new(0, 0.5)
logoImg.BackgroundTransparency = 1
logoImg.Image = ICON.logo
logoImg.ImageColor3 = Theme.Accent
logoImg.Parent = sideHeader

local logoTitle = Instance.new("TextLabel")
logoTitle.Size = UDim2.new(1, -60, 0, 20)
logoTitle.Position = UDim2.new(0, 58, 0, 14)
logoTitle.BackgroundTransparency = 1
logoTitle.Text = "VAULT HUB"
logoTitle.Font = Enum.Font.GothamBold
logoTitle.TextSize = 16
logoTitle.TextColor3 = Theme.Text
logoTitle.TextXAlignment = Enum.TextXAlignment.Left
logoTitle.Parent = sideHeader

local logoSub = Instance.new("TextLabel")
logoSub.Name = "Sub"
logoSub.Size = UDim2.new(1, -60, 0, 14)
logoSub.Position = UDim2.new(0, 58, 0, 34)
logoSub.BackgroundTransparency = 1
logoSub.Text = T("credits")
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 11
logoSub.TextColor3 = Theme.SubText
logoSub.TextXAlignment = Enum.TextXAlignment.Left
logoSub.Parent = sideHeader

local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, 0, 1, -64)
tabHolder.Position = UDim2.new(0, 0, 0, 64)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = Side
local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabHolder
local _tabOrder = 0
pad(tabHolder, 10); tabHolder.UIPadding.PaddingTop = UDim.new(0,4)

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -170, 1, 0)
Content.Position = UDim2.new(0, 170, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundTransparency = 1
topBar.Parent = Content

local pageTitle = Instance.new("TextLabel")
pageTitle.Size = UDim2.new(1, -110, 1, 0)
pageTitle.Position = UDim2.new(0, 20, 0, 0)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = T("tab_home")
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 20
pageTitle.TextColor3 = Theme.Text
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = topBar

-- крестик закрытия (две диагональные линии — не зависит от шрифта)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -42, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(0, 0.5)
closeBtn.BackgroundColor3 = Theme.Surface
closeBtn.AutoButtonColor = false
closeBtn.Text = ""
closeBtn.Parent = topBar
corner(closeBtn, 8)
do
	local l1 = Instance.new("Frame")
	l1.Size = UDim2.fromOffset(15, 2); l1.Position = UDim2.fromScale(0.5,0.5); l1.AnchorPoint = Vector2.new(0.5,0.5)
	l1.BackgroundColor3 = Theme.SubText; l1.BorderSizePixel = 0; l1.Rotation = 45; l1.Name="X1"; l1.Parent = closeBtn
	corner(l1, 1)
	local l2 = Instance.new("Frame")
	l2.Size = UDim2.fromOffset(15, 2); l2.Position = UDim2.fromScale(0.5,0.5); l2.AnchorPoint = Vector2.new(0.5,0.5)
	l2.BackgroundColor3 = Theme.SubText; l2.BorderSizePixel = 0; l2.Rotation = -45; l2.Name="X2"; l2.Parent = closeBtn
	corner(l2, 1)
end

-- кнопка смены языка (рядом с крестиком)
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.fromOffset(34, 30)
langBtn.Position = UDim2.new(1, -82, 0.5, 0)
langBtn.AnchorPoint = Vector2.new(0, 0.5)
langBtn.BackgroundColor3 = Theme.Surface
langBtn.AutoButtonColor = false
langBtn.Text = "🌐 "..tostring(Locale):upper()
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 11
langBtn.TextColor3 = Theme.Accent2
langBtn.Parent = topBar
corner(langBtn, 8)
langBtn.MouseEnter:Connect(function() tween(langBtn,0.15,{BackgroundColor3=Theme.SurfaceHl}) end)
langBtn.MouseLeave:Connect(function() tween(langBtn,0.15,{BackgroundColor3=Theme.Surface}) end)
langBtn.MouseButton1Click:Connect(function()
	Config.language = (Locale == "ru") and "en" or "ru"
	Locale = Config.language
	saveConfig()
	-- мгновенный перезапуск интерфейса с новым языком
	shared.__VAULTHUB_LOADED = nil
	ScreenGui:Destroy()
	task.spawn(function()
		local ok, body = pcall(function() return game:HttpGet(VH_SCRIPT_URL) end)
		if ok and body then local f = loadstring(body); if f then f() end end
	end)
end)

local pages = {}
local tabButtons = {}
local currentTab

-- общий индикатор активной вкладки (плавно съезжает)
local tabIndicator = Instance.new("Frame")
tabIndicator.Name = "TabIndicator"
tabIndicator.Size = UDim2.fromOffset(3, 22)
tabIndicator.Position = UDim2.new(0, 0, 0, 76)
tabIndicator.BackgroundColor3 = Theme.Accent
tabIndicator.BorderSizePixel = 0
tabIndicator.ZIndex = 6
tabIndicator.Parent = Side
corner(tabIndicator, 2)
local tig = Instance.new("UIGradient"); tig.Color = ColorSequence.new(Theme.Accent, Theme.Accent2); tig.Rotation = 90; tig.Parent = tabIndicator

local function selectTab(name)
	currentTab = name
	for n, t in pairs(tabButtons) do
		local active = (n == name)
		tween(t.btn, 0.2, {BackgroundColor3 = active and Theme.Surface or Theme.Panel})
		if t.bar then t.bar.BackgroundTransparency = 1 end
		tween(t.ico, 0.2, {ImageColor3 = active and Theme.Accent or Theme.SubText})
		tween(t.lbl, 0.2, {TextColor3 = active and Theme.Text or Theme.SubText})
	end
	local t = tabButtons[name]
	if t then
		local y = 64 + 4 + (t.btn.LayoutOrder - 1) * 44 + 9
		tween(tabIndicator, 0.3, {Position = UDim2.new(0, 0, 0, y)}, Enum.EasingStyle.Back)
	end
	for n, pg in pairs(pages) do pg.Visible = (n == name) end
	pageTitle.Text = T("tab_"..name)
end

local function addTab(name, iconKey)
	_tabOrder = _tabOrder + 1
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.LayoutOrder = _tabOrder
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Theme.Panel
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = tabHolder
	corner(btn, 8)

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Size = UDim2.new(0, 3, 0.6, 0)
	bar.Position = UDim2.new(0, 0, 0.2, 0)
	bar.BackgroundColor3 = Theme.Accent
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.Parent = btn
	corner(bar, 2)

	local ico = Instance.new("ImageLabel")
	ico.Name = "Ico"
	ico.Size = UDim2.fromOffset(20, 20)
	ico.Position = UDim2.new(0, 14, 0.5, 0)
	ico.AnchorPoint = Vector2.new(0, 0.5)
	ico.BackgroundTransparency = 1
	ico.Image = ICON[iconKey] or ""
	ico.ImageColor3 = Theme.SubText
	ico.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Lbl"
	lbl.Size = UDim2.new(1, -46, 1, 0)
	lbl.Position = UDim2.new(0, 44, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = T("tab_"..name)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 14
	lbl.TextColor3 = Theme.SubText
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	btn.MouseEnter:Connect(function() if currentTab ~= name then tween(btn,0.15,{BackgroundColor3=Theme.Surface}) end end)
	btn.MouseLeave:Connect(function() if currentTab ~= name then tween(btn,0.15,{BackgroundColor3=Theme.Panel}) end end)
	btn.MouseButton1Click:Connect(function() selectTab(name) end)
	tabButtons[name] = { btn = btn, bar = bar, ico = ico, lbl = lbl }

	-- page
	local pg = Instance.new("ScrollingFrame")
	pg.Name = name
	pg.Size = UDim2.new(1, 0, 1, -52)
	pg.Position = UDim2.new(0, 0, 0, 52)
	pg.BackgroundTransparency = 1
	pg.BorderSizePixel = 0
	pg.ScrollBarThickness = 3
	pg.ScrollBarImageColor3 = Theme.Stroke
	pg.CanvasSize = UDim2.new(0,0,0,0)
	pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pg.Visible = false
	pg.Parent = Content
	local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0,10); lay.Parent = pg
	local pp = Instance.new("UIPadding"); pp.PaddingLeft=UDim.new(0,20);pp.PaddingRight=UDim.new(0,20);pp.PaddingTop=UDim.new(0,4);pp.PaddingBottom=UDim.new(0,16); pp.Parent=pg
	pages[name] = pg
	return pg
end

---------------------------------------------------------------------
-- COMPONENT FACTORY
---------------------------------------------------------------------
local Comp = {}

function Comp.section(parent, titleText)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 36)
	f.BackgroundColor3 = Theme.Panel
	f.BorderSizePixel = 0
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.Parent = parent
	corner(f, 10); stroke(f, Theme.Stroke, 1, 0.4)
	local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0,6); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Parent = f
	pad(f, 12)
	if titleText then
		local t = Instance.new("TextLabel")
		t.Name = "Header"
		t.Size = UDim2.new(1, 0, 0, 20)
		t.BackgroundTransparency = 1
		t.Text = titleText
		t.Font = Enum.Font.GothamBold
		t.TextSize = 14
		t.TextColor3 = Theme.Text
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = f
		t.LayoutOrder = -1
	end
	return f
end

local function rowBase(parent, h)
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, 0, 0, h or 34)
	r.BackgroundTransparency = 1
	r.Parent = parent
	return r
end

function Comp.label(parent, text, sub)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, sub and 16 or 20)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = sub and Enum.Font.Gotham or Enum.Font.GothamMedium
	l.TextSize = sub and 12 or 13
	l.TextColor3 = sub and Theme.SubText or Theme.Text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

function Comp.toggle(parent, text, key, callback)
	local r = rowBase(parent, 34)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -56, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Theme.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.fromOffset(44, 24)
	sw.Position = UDim2.new(1, -44, 0.5, 0)
	sw.AnchorPoint = Vector2.new(0, 0.5)
	sw.AutoButtonColor = false
	sw.Text = ""
	sw.BackgroundColor3 = Theme.Surface
	sw.Parent = r
	corner(sw, 12); stroke(sw, Theme.Stroke, 1, 0.3)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = UDim2.new(0, 3, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Theme.SubText
	knob.BorderSizePixel = 0
	knob.Parent = sw
	corner(knob, 9)

	local function set(v, fire)
		Config[key] = v
		tween(sw, 0.2, {BackgroundColor3 = v and Theme.Accent or Theme.Surface})
		tween(knob, 0.2, {Position = v and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = v and Color3.new(1,1,1) or Theme.SubText})
		if fire and callback then task.spawn(callback, v) end
	end
	sw.MouseButton1Click:Connect(function() set(not Config[key], true); saveConfig() end)
	set(Config[key], false)
	return { set = set, label = lbl }
end

function Comp.slider(parent, text, key, min, max, step, suffix, callback)
	local r = rowBase(parent, 48)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -70, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Theme.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	local valBox = Instance.new("TextLabel")
	valBox.Size = UDim2.new(0, 70, 0, 20)
	valBox.Position = UDim2.new(1, -70, 0, 0)
	valBox.BackgroundTransparency = 1
	valBox.Font = Enum.Font.GothamBold
	valBox.TextSize = 13
	valBox.TextColor3 = Theme.Accent2
	valBox.TextXAlignment = Enum.TextXAlignment.Right
	valBox.Parent = r

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 6)
	track.Position = UDim2.new(0, 0, 0, 32)
	track.BackgroundColor3 = Theme.Surface
	track.BorderSizePixel = 0
	track.Parent = r
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 3)
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(Theme.Accent, Theme.Accent2); g.Parent = fill

	local function fmt(v)
		if step < 1 then return string.format("%.2f%s", v, suffix or "") end
		return commas(v)..(suffix or "")
	end
	local function set(v, fire)
		v = math.clamp(v, min, max)
		if step >= 1 then v = math.floor(v/step + 0.5)*step end
		Config[key] = v
		local a = (v - min)/(max - min)
		tween(fill, 0.1, {Size = UDim2.new(a, 0, 1, 0)})
		valBox.Text = fmt(v)
		if fire and callback then task.spawn(callback, v) end
	end

	local dragging = false
	local function upd(inp)
		local a = math.clamp((inp.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
		set(min + a*(max-min), true)
	end
	track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; upd(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then if dragging then dragging=false; saveConfig() end end end)
	UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
	set(Config[key] or min, false)
	return { set = set, label = lbl }
end

function Comp.button(parent, text, color, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 36)
	b.BackgroundColor3 = color or Theme.Accent
	b.AutoButtonColor = false
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.Parent = parent
	corner(b, 8)
	b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=(color or Theme.Accent):Lerp(Color3.new(1,1,1),0.12)}) end)
	b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=color or Theme.Accent}) end)
	b.MouseButton1Click:Connect(function()
		tween(b,0.08,{Size=UDim2.new(1,-6,0,34)}):Wait()
		tween(b,0.08,{Size=UDim2.new(1,0,0,36)})
		if callback then task.spawn(callback) end
	end)
	return b
end

function Comp.dropdown(parent, text, key, options, callback)
	local r = rowBase(parent, 34)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Theme.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	local box = Instance.new("TextButton")
	box.Size = UDim2.new(0.5, -4, 0, 28)
	box.Position = UDim2.new(0.5, 4, 0.5, 0)
	box.AnchorPoint = Vector2.new(0, 0.5)
	box.BackgroundColor3 = Theme.Surface
	box.AutoButtonColor = false
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 12
	box.TextColor3 = Theme.Text
	box.Text = tostring(Config[key])
	box.Parent = r
	corner(box, 6); stroke(box, Theme.Stroke, 1, 0.3)

	-- меню рендерим в ОВЕРЛЕЕ поверх всего GUI (иначе слоится под слайдерами)
	local open = false
	local menu = Instance.new("Frame")
	menu.Name = "DropdownOverlay"
	menu.Size = UDim2.fromOffset(10, 0)
	menu.BackgroundColor3 = Theme.SurfaceHl
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ZIndex = 500
	menu.ClipsDescendants = true
	menu.Parent = ScreenGui
	corner(menu, 6); stroke(menu, Theme.Stroke, 1, 0)
	local ml = Instance.new("UIListLayout"); ml.Parent = menu

	local function setZ(obj, z)
		for _,d in ipairs(obj:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex = z end end
	end

	local function choose(v)
		Config[key] = v; box.Text = tostring(v)
		if callback then task.spawn(callback, v) end
		saveConfig()
	end
	for _, opt in ipairs(options) do
		local o = Instance.new("TextButton")
		o.Size = UDim2.new(1, 0, 0, 26)
		o.BackgroundColor3 = Theme.SurfaceHl
		o.AutoButtonColor = false
		o.Font = Enum.Font.Gotham
		o.TextSize = 12
		o.TextColor3 = Theme.Text
		o.Text = tostring(opt)
		o.ZIndex = 501
		o.Parent = menu
		o.MouseEnter:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.Accent}) end)
		o.MouseLeave:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.SurfaceHl}) end)
		o.MouseButton1Click:Connect(function()
			choose(opt); open=false
			tween(menu,0.12,{Size=UDim2.fromOffset(box.AbsoluteSize.X,0)})
			task.delay(0.12, function() if not open then menu.Visible=false end end)
		end)
	end
	box.MouseButton1Click:Connect(function()
		open = not open
		if open then
			local p = box.AbsolutePosition
			menu.Position = UDim2.fromOffset(p.X, p.Y + box.AbsoluteSize.Y + 2)
			menu.Size = UDim2.fromOffset(box.AbsoluteSize.X, 0)
			menu.Visible = true
			tween(menu, 0.18, {Size = UDim2.fromOffset(box.AbsoluteSize.X, #options*26)})
		else
			tween(menu, 0.15, {Size = UDim2.fromOffset(box.AbsoluteSize.X, 0)})
			task.delay(0.15, function() if not open then menu.Visible=false end end)
		end
	end)
	return { set = function(v) choose(v) end }
end

function Comp.textbox(parent, placeholder, callback)
	local b = Instance.new("TextBox")
	b.Size = UDim2.new(1, 0, 0, 60)
	b.BackgroundColor3 = Theme.Surface
	b.Text = ""
	b.PlaceholderText = placeholder
	b.PlaceholderColor3 = Theme.SubText
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.TextColor3 = Theme.Text
	b.TextWrapped = true
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.TextYAlignment = Enum.TextYAlignment.Top
	b.ClearTextOnFocus = false
	b.MultiLine = true
	b.Parent = parent
	corner(b, 8); stroke(b, Theme.Stroke, 1, 0.3); pad(b, 10)
	if callback then b.FocusLost:Connect(function() callback(b.Text) end) end
	return b
end

-- модуль: строка-тоггл + ПКМ раскрывает поднастройки (subBuild(panel))
function Comp.module(parent, text, key, subBuild, callback)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, 36)
	wrap.BackgroundColor3 = Theme.Surface
	wrap.BorderSizePixel = 0
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.ClipsDescendants = true
	wrap.Parent = parent
	corner(wrap, 8); stroke(wrap, Theme.Stroke, 1, 0.5)
	local wl = Instance.new("UIListLayout"); wl.SortOrder = Enum.SortOrder.LayoutOrder; wl.Parent = wrap

	-- шапка
	local head = Instance.new("Frame")
	head.Size = UDim2.new(1, 0, 0, 36)
	head.BackgroundTransparency = 1
	head.LayoutOrder = 0
	head.Parent = wrap

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(20, 36)
	arrow.Position = UDim2.new(0, 6, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "›"
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 16
	arrow.TextColor3 = Theme.SubText
	arrow.Parent = head

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -90, 1, 0)
	lbl.Position = UDim2.new(0, 30, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Theme.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = head

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.fromOffset(44, 24)
	sw.Position = UDim2.new(1, -52, 0.5, 0)
	sw.AnchorPoint = Vector2.new(0, 0.5)
	sw.AutoButtonColor = false
	sw.Text = ""
	sw.BackgroundColor3 = Theme.Panel
	sw.Parent = head
	corner(sw, 12); stroke(sw, Theme.Stroke, 1, 0.3)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = UDim2.new(0, 3, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Theme.SubText
	knob.BorderSizePixel = 0
	knob.Parent = sw
	corner(knob, 9)

	local function setSw(v, fire)
		Config[key] = v
		tween(sw, 0.2, {BackgroundColor3 = v and Theme.Accent or Theme.Panel})
		tween(knob, 0.2, {Position = v and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0), BackgroundColor3 = v and Color3.new(1,1,1) or Theme.SubText})
		if fire and callback then task.spawn(callback, v) end
	end
	sw.MouseButton1Click:Connect(function() setSw(not Config[key], true); saveConfig() end)
	setSw(Config[key], false)

	-- подпанель
	local panel = Instance.new("Frame")
	panel.Name = "Sub"
	panel.Size = UDim2.new(1, 0, 0, 0)
	panel.BackgroundTransparency = 1
	panel.LayoutOrder = 1
	panel.Visible = false
	panel.Parent = wrap
	local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,4); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = panel
	local pp = Instance.new("UIPadding"); pp.PaddingLeft=UDim.new(0,12); pp.PaddingRight=UDim.new(0,12); pp.PaddingBottom=UDim.new(0,10); pp.PaddingTop=UDim.new(0,2); pp.Parent = panel
	if subBuild then subBuild(panel) end

	local expanded = false
	local function togglePanel()
		expanded = not expanded
		panel.Visible = true
		tween(arrow, 0.2, {Rotation = expanded and 90 or 0})
		if not expanded then task.delay(0.05, function() if not expanded then panel.Visible=false end end) end
	end
	-- ПКМ по шапке -> раскрыть поднастройки
	for _, el in ipairs({head, arrow, lbl}) do
		el.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then togglePanel() end
		end)
	end
	return { set = setSw }
end

---------------------------------------------------------------------
-- BUILD TABS
---------------------------------------------------------------------
local homePage     = addTab("home", "home")
local farmPage     = addTab("farm", "farm")
local sellPage     = addTab("sell", "sell")
local processPage  = addTab("process", "process")
local tpPage       = addTab("tp", "tp")
local shopPage     = addTab("shop", "shop")
local settingsPage = addTab("settings", "settings")

-- =========== HOME ===========
local homeStats = Comp.section(homePage, nil)
local statNet  = Comp.label(homeStats, T("networth")..": ...")
local statCoin = Comp.label(homeStats, T("coins")..": ...")
local statPl   = Comp.label(homeStats, T("players")..": ...")
local statUp   = Comp.label(homeStats, T("uptime")..": 00:00")

local homeQuick = Comp.section(homePage, T("quick"))
Comp.button(homeQuick, T("sell_now"), Theme.Accent, function() _G.__VH_sellNow() end)
Comp.button(homeQuick, T("spawn_car"), Theme.Surface, function() API.spawnVehicle() end)

local startTime = os.clock()
task.spawn(function()
	while ScreenGui.Parent do
		local nw, coins = getNetWorth()
		statNet.Text  = T("networth")..": $"..commas(nw)
		statCoin.Text = T("coins")..": $"..commas(coins)
		statPl.Text   = T("players")..": "..#Players:GetPlayers()
		local el = os.clock() - startTime
		statUp.Text   = string.format("%s: %02d:%02d", T("uptime"), math.floor(el/60), math.floor(el%60))
		task.wait(2)
	end
end)

-- =========== FARM ===========
local areaNames = {}
do
	for _, poi in ipairs(API.getPOIs()) do
		if poi.category == "Area" then table.insert(areaNames, poi.name) end
	end
	if #areaNames == 0 then areaNames = {"Junk Yard","Back Alley","Farmyard","Shipyard"} end
end
if not Config.bidArea or Config.bidArea == "" then Config.bidArea = areaNames[1] end

local farmSec = Comp.section(farmPage, nil)
-- автобид (свёрнут, ПКМ -> поднастройки)
Comp.module(farmSec, T("auto_bid"), "autoBid", function(p)
	Comp.dropdown(p, T("bid_area"), "bidArea", areaNames)
	Comp.slider(p, T("min_bid"), "minBid", 0, 50000, 25, "$")
	Comp.slider(p, T("max_bid"), "maxBid", 0, 100000, 50, "$")
	Comp.slider(p, T("bid_speed"), "bidSpeed", 0.1, 1.5, 0.05, "s")
	Comp.toggle(p, T("auto_buyitems"), "autoBuyItems")
	Comp.slider(p, T("profit_min"), "profitMin", 0, 100, 5, "%")
end)
Comp.module(farmSec, T("auto_fish"), "autoFish", nil)
Comp.module(farmSec, T("auto_collect"), "autoCollectAll", nil)

-- =========== SELL ===========
local sellSec = Comp.section(sellPage, nil)
Comp.module(sellSec, T("auto_sell"), "autoSell", function(p)
	Comp.toggle(p, T("sell_with_car"), "sellWithCar")
	Comp.toggle(p, T("keep_fav"), "keepFav")
	Comp.toggle(p, T("keep_trophy"), "keepTrophy")
	Comp.slider(p, T("sell_min"), "sellMin", 0, 50000, 25, "$")
end)
Comp.module(sellSec, T("auto_stock"), "autoStock", function(p)
	Comp.toggle(p, T("return_full"), "returnWhenFull")
	Comp.toggle(p, T("auto_trade"), "autoTrade")
	Comp.slider(p, T("trade_min"), "tradeMinPercent", 0, 100, 5, "%")
end)
Comp.button(sellSec, T("sell_now"), Theme.Success, function() _G.__VH_sellNow() end)

local sellInfo = Comp.section(sellPage, nil)
local rateLbl = Comp.label(sellInfo, T("pawn_rate")..": ...")
local estLbl  = Comp.label(sellInfo, T("est_value")..": ...")
task.spawn(function()
	while ScreenGui.Parent do
		local st = API.pawnState()
		if st.rate then rateLbl.Text = string.format("%s: %d%%", T("pawn_rate"), math.floor((st.rate or 0)*100)) end
		local total = 0
		for _, e in pairs(API.getSellable()) do total = total + API.itemPrice(e) end
		estLbl.Text = T("est_value")..": $"..commas(total)
		task.wait(5)
	end
end)

-- =========== PROCESS ===========
local procSec = Comp.section(processPage, nil)
Comp.module(procSec, T("auto_wash"), "autoWash", function(p)
	Comp.slider(p, T("wash_min"), "washMin", 0, 50000, 25, "$")
end)
Comp.module(procSec, T("auto_grade"), "autoGrade", function(p)
	Comp.slider(p, T("grade_min"), "gradeMin", 0, 50000, 25, "$")
end)
Comp.module(procSec, T("auto_repair"), "autoRepair", nil)
local srcSec = Comp.section(processPage, T("source"))
Comp.dropdown(srcSec, T("source"), "procSource", {"Inventory", "Vehicle"})

-- =========== SHOP ===========
local drinkSec = Comp.section(shopPage, nil)
Comp.module(drinkSec, T("auto_buy_drink"), "autoBuyDrink", function(p)
	Comp.dropdown(p, T("drink_tier"), "drinkTier", {"1","2","3"})
	Comp.button(p, T("buy_now"), Theme.Accent, function() API.buyDrink(Config.drinkTier) end)
end)
local restockLbl = Comp.label(Comp.section(shopPage, nil), T("restock")..": ...")
task.spawn(function()
	local secs = 0
	local lastFetch = 0
	while ScreenGui.Parent do
		-- запрашиваем каталог раз в 10с, но обратный отсчёт тикает каждую секунду
		if os.clock() - lastFetch > 10 then
			local c = API.energyCatalog()
			if c.RestockSeconds then secs = c.RestockSeconds end
			lastFetch = os.clock()
		end
		if secs > 0 then secs = secs - 1 end
		restockLbl.Text = string.format("%s: %ds", T("restock"), math.max(0, secs))
		task.wait(1)
	end
end)

-- =========== TELEPORTS ===========
local tpAreas   = Comp.section(tpPage, T("tp_areas"))
local tpShops   = Comp.section(tpPage, T("tp_shops"))
local tpPlayers = Comp.section(tpPage, T("tp_players"))
Comp.button(tpAreas, T("spawn_car"), Theme.Surface, function() API.spawnVehicle() end)

local function buildTeleports()
	for _, sec in ipairs({tpAreas, tpShops, tpPlayers}) do
		for _, c in ipairs(sec:GetChildren()) do
			if c:IsA("TextButton") and c.Name ~= "spawnbtn" then c:Destroy() end
		end
	end
	for _, poi in ipairs(API.getPOIs()) do
		local target = (poi.category == "Area") and tpAreas
			or (poi.category == "Player Shop") and tpPlayers or tpShops
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 30)
		b.BackgroundColor3 = Theme.Surface
		b.AutoButtonColor = false
		b.Text = ""
		b.Parent = target
		corner(b, 6)
		local ic = Instance.new("ImageLabel")
		ic.Size = UDim2.fromOffset(16,16); ic.Position = UDim2.new(0,8,0.5,0); ic.AnchorPoint=Vector2.new(0,0.5)
		ic.BackgroundTransparency = 1
		ic.Image = POI_ICON[poi.name] or POI_ICON[poi.category] or ""
		ic.ImageColor3 = Theme.Accent2
		ic.Parent = b
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1,-34,1,0); t.Position=UDim2.new(0,32,0,0); t.BackgroundTransparency=1
		t.Text = poi.name; t.Font=Enum.Font.GothamMedium; t.TextSize=12; t.TextColor3=Theme.Text
		t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = b
		b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=Theme.SurfaceHl}) end)
		b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundColor3=Theme.Surface}) end)
		b.MouseButton1Click:Connect(function() teleport(poi.position) end)
	end
end

-- =========== SETTINGS ===========
local setSec = Comp.section(settingsPage, T("keybind"))

local cfgSec = Comp.section(settingsPage, T("save_cfg"))
Comp.button(cfgSec, T("save_cfg"), Theme.Success, function()
	if saveConfig() then notify(T("cfg_saved")) end
end)
Comp.button(cfgSec, T("export_cfg"), Theme.Accent, function()
	exportConfig(); notify(T("cfg_exported"))
end)
local importBox = Comp.textbox(cfgSec, T("paste_here"))
Comp.button(cfgSec, T("import_cfg"), Theme.Surface, function()
	if importConfig(importBox.Text) then notify(T("cfg_imported")) end
end)

---------------------------------------------------------------------
-- FARM LOGIC
---------------------------------------------------------------------
function _G.__VH_sellNow()
	if Config.sellWithCar then API.spawnVehicle() end
	-- найти Pawn / Quick Sell POI
	for _, poi in ipairs(API.getPOIs()) do
		if poi.name == "Quck Sell Shop" or poi.name == "Quick Sell Shop" or poi.name:find("Sell") or poi.name:find("Pawn") then
			teleport(poi.position); break
		end
	end
	task.wait(0.3)
	local items = API.getSellable()
	local list = {}
	for guid, e in pairs(items) do
		local price = API.itemPrice(e)
		local skip = false
		if Config.keepFav and e.Favorited then skip = true end
		if Config.keepTrophy and e.IsTrophy then skip = true end
		if price < (Config.sellMin or 0) then skip = true end
		if not skip then table.insert(list, {guid=guid, price=price}) end
	end
	table.sort(list, function(a,b) return a.price > b.price end) -- дорогие первыми
	local guids = {}
	for _, it in ipairs(list) do table.insert(guids, it.guid) end
	if #guids > 0 then
		API.sell(guids)
		notify(string.format("Sold %d items", #guids))
	end
end

-- авто-обработка (wash/grade/repair)
local function autoProcess(kind, minPrice)
	local slotState = API.procSlots(kind)
	local unlocked = slotState.unlockedCount or 1
	local slots = slotState.slots or {}
	-- забрать готовые
	for idx, s in pairs(slots) do
		if type(s)=="table" and (s.done or s.ready or s.completed or (s.finishTime and s.finishTime <= 0)) then
			API.procClaim(kind, idx, s.guid)
		end
	end
	-- запустить новые в свободные слоты
	local items = API.procItems(kind)
	local sorted = {}
	for guid, e in pairs(items) do
		local price = API.itemPrice(e)
		if price >= (minPrice or 0) then table.insert(sorted, {guid=guid, e=e, price=price}) end
	end
	table.sort(sorted, function(a,b) return a.price > b.price end)
	local si = 1
	for idx = 1, unlocked do
		if not slots[idx] and sorted[si] then
			local it = sorted[si]
			local src = Config.procSource or "Inventory"
			local vguid = (src == "Vehicle") and (API.getVehicles().equippedGuid) or nil
			API.procStart(kind, idx, it.guid, src, vguid)
			si = si + 1
		end
	end
end

-- вес тачки (через событие)
local vehWeight, vehMaxWeight = 0, 0
do
	local wu = ev("UI.VehicleWeightUpdate")
	if wu then wu.OnClientEvent:Connect(function(a, b)
		if type(a)=="number" then vehWeight = a end
		if type(b)=="number" then vehMaxWeight = b end
		if type(a)=="table" then vehWeight = a.weight or a.current or vehWeight; vehMaxWeight = a.max or a.maxWeight or vehMaxWeight end
	end) end
end

local function tpToBase()
	-- свой магазин/плот игрока
	local myId = LocalPlayer.UserId
	for _, poi in ipairs(API.getPOIs()) do
		if poi.category == "Player Shop" and poi.ownerUserId == myId then
			teleport(poi.position); return true
		end
	end
	-- запасной: телепорт к плоту через событие
	local tpPlot = ev("Plot.TeleportToPlot")
	if tpPlot then pcall(function() tpPlot:FireServer() end); return true end
	return false
end

-- авто-торговля: нанять помощника и выставить процент оффера
local function ensureTradeStaff()
	local data = API.getStaff()
	local staffList = (type(data)=="table" and (data.staff or data.Staff or data)) or {}
	local found
	for id, s in pairs(staffList) do
		if type(s)=="table" then found = (s.id or id); break end
	end
	if not found then
		local ok, res = API.hireStaff("ShopAssistant")
		if ok and type(res)=="table" then found = res.id or res.staffId end
	end
	if found then API.setStaffOffer(found, Config.tradeMinPercent or 80) end
end

-- мастер-цикл
task.spawn(function()
	while ScreenGui.Parent do
		local ok, err = pcall(function()
			-- возврат на базу при полном весе + выгрузка в инвентарь
			if Config.returnWhenFull and vehMaxWeight > 0 and vehWeight >= vehMaxWeight * 0.97 then
				tpToBase(); task.wait(1)
				API.transferVehicleItems(); task.wait(1)
			end
			if Config.autoSell then _G.__VH_sellNow() end
			if Config.autoWash then autoProcess("Wash", Config.washMin) end
			if Config.autoGrade then autoProcess("Grade", Config.gradeMin) end
			if Config.autoRepair then autoProcess("Repair", 0) end
			if Config.autoTrade then ensureTradeStaff() end
			if Config.autoBuyDrink then
				local cat = API.energyCatalog()
				if cat.Drinks then
					for _, d in ipairs(cat.Drinks) do
						if d.EnergyDrinkId == Config.drinkTier and (d.StockRemaining or 0) > 0 then
							API.buyDrink(Config.drinkTier)
						end
					end
				end
			end
		end)
		task.wait(8)
	end
end)

-- авто-бид (timing-миниигра: исход решает сервер -> шлём Bid в ритме)
local biddingActive = false
local currentBid = 0
do
	local toggleUI = ev("Auction.ToggleBiddingUI")
	local updBid = ev("Auction.UpdateCurrentWinningBid")
	if toggleUI then toggleUI.OnClientEvent:Connect(function(state) biddingActive = (state ~= false and state ~= nil) end) end
	if updBid then updBid.OnClientEvent:Connect(function(v)
		if type(v)=="number" then currentBid = v
		elseif type(v)=="table" and v.amount then currentBid = v.amount end
	end) end
	-- авто-забор выигранных предметов
	local pickItem = ev("Auction.AuctionPickupItem")
	if pickItem then pickItem.OnClientEvent:Connect(function(...)
		local args = {...}
		pcall(function() pickItem:FireServer(table.unpack(args)) end)
	end) end
end

-- АВТО-ПОПАДАНИЕ по бид-бару: читаем реальные позиции курсора и зоны,
-- бид строго когда курсор внутри зоны (любой редкости/скорости) -> промахов нет -> нет кд
local lastHit = 0
RunService.Heartbeat:Connect(function()
	if not Config.autoBid then return end
	local ui = PlayerGui:FindFirstChild("UIControllerGui")
	local cont = ui and ui:FindFirstChild("AuctionBiddingContainer")
	if not (cont and cont.Visible) then return end
	if Config.maxBid > 0 and currentBid >= Config.maxBid then return end
	local row = cont:FindFirstChild("BidBarRow")
	local zone = row and row:FindFirstChild("BidZone")
	local cur = row and row:FindFirstChild("Cursor")
	if not (zone and cur) then return end
	local zs = zone.Position.X.Scale - zone.AnchorPoint.X * zone.Size.X.Scale
	local ze = zs + zone.Size.X.Scale
	local cx = cur.Position.X.Scale
	-- небольшой внутренний отступ -> бьём ближе к центру (perfect), не по краю
	local pad = (ze - zs) * 0.12
	if cx >= (zs + pad) and cx <= (ze - pad) and (os.clock() - lastHit) > 0.1 then
		lastHit = os.clock()
		API.bid()
	end
end)

-- КОНТЕЙНЕРЫ = гаражи в Workspace._Debris.Garages (промпт "Start Auction")
-- центры зон для фильтра по выбранной локации
local AREA_CENTER = {}
do
	for _, poi in ipairs(API.getPOIs()) do
		if poi.category == "Area" then AREA_CENTER[poi.name] = parseVec(poi.position) end
	end
end

local function getGarages()
	local out = {}
	local gf = Workspace:FindFirstChild("_Debris")
	gf = gf and gf:FindFirstChild("Garages")
	if not gf then return out end
	for _, g in ipairs(gf:GetChildren()) do
		local entry = g:FindFirstChild("EntrySquare")
		local prompt
		if entry then
			for _, d in ipairs(entry:GetDescendants()) do
				if d:IsA("ProximityPrompt") and d.ActionText == "Start Auction" then prompt = d; break end
			end
		end
		local part = prompt and (prompt.Parent:IsA("BasePart") and prompt.Parent or (entry:IsA("BasePart") and entry or entry:FindFirstChildWhichIsA("BasePart")))
		if prompt and part then
			table.insert(out, {model=g, part=part, prompt=prompt, name=g.Name, pos=part.Position})
		end
	end
	return out
end

-- один цикл аукциона на конкретном гараже (стоим на месте пока идёт торг!)
local function doGarageAuction(g)
	local hrp = getHRP()
	if not hrp or not g.part then return end
	hrp.CFrame = CFrame.new(g.part.Position + Vector3.new(0, 3, 0))
	task.wait(0.35)
	biddingActive = false
	currentBid = 0
	pcall(function() fireproximityprompt(g.prompt) end)
	-- ждём старт торгов (max 4с)
	local t0 = os.clock()
	repeat task.wait(0.1) until biddingActive or (os.clock()-t0) > 4 or not Config.autoBid
	if not biddingActive then return end
	task.wait(0.35)
	-- скип дешёвого лота по начальной ставке
	if Config.minBid > 0 and currentBid > 0 and currentBid < Config.minBid then
		API.leaveAuction(); task.wait(0.3); return
	end
	-- СТОИМ на гараже и ждём конца торгов; авто-хит (Heartbeat) сам бидит в зоне
	local bt = os.clock()
	repeat
		-- держим персонажа на месте, чтобы не выпасть из зоны (скилл-чек не пропал)
		if hrp and (hrp.Position - (g.part.Position + Vector3.new(0,3,0))).Magnitude > 6 then
			hrp.CFrame = CFrame.new(g.part.Position + Vector3.new(0, 3, 0))
		end
		task.wait(0.2)
	until (not biddingActive) or (not Config.autoBid) or (os.clock()-bt) > 30
	task.wait(0.6) -- дать забрать предметы (auto-pickup на событии)
end

task.spawn(function()
	while ScreenGui.Parent do
		if Config.autoBid then
			local garages = getGarages()
			local center = AREA_CENTER[Config.bidArea]
			-- сортируем по близости к выбранной зоне
			if center then
				table.sort(garages, function(a,b) return (a.pos-center).Magnitude < (b.pos-center).Magnitude end)
			end
			for _, g in ipairs(garages) do
				if not Config.autoBid then break end
				-- только гаражи выбранной зоны (в радиусе) если зона задана
				if (not center) or (g.pos - center).Magnitude < 350 then
					pcall(doGarageAuction, g)
				end
			end
			task.wait(1)
		else
			task.wait(1)
		end
	end
end)

-- авто-рыбалка
task.spawn(function()
	local Misc = ev("Misc.FishingCast") and Events:FindFirstChild("Misc")
	while ScreenGui.Parent do
		if Config.autoFish then
			-- телепорт к озеру
			for _, poi in ipairs(API.getPOIs()) do
				if poi.name == "Lake" then teleport(poi.position); break end
			end
			-- заброс + авто-реал
			local cast = ev("Misc.FishingCast")
			if cast then
				pcall(function() cast:FireServer() end)
			end
			task.wait(3)
		else
			task.wait(1)
		end
	end
end)

---------------------------------------------------------------------
-- TOGGLE / KEYBIND
---------------------------------------------------------------------
local _anim = false
local function setVisible(v)
	if _anim then return end
	if v then
		Main.Visible = true
		Main.Size = UDim2.fromOffset(560, 400)
		tween(Main, 0.26, {Size = UDim2.fromOffset(640, 440)}, Enum.EasingStyle.Back)
	else
		_anim = true
		local tw = tween(Main, 0.18, {Size = UDim2.fromOffset(560, 400)})
		tw.Completed:Once(function() Main.Visible = false; _anim = false end)
	end
end

-- toggle опирается на РЕАЛЬНОЕ состояние окна, чтобы не было рассинхрона
local function toggleGui()
	setVisible(not Main.Visible)
end

closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
closeBtn.MouseEnter:Connect(function()
	tween(closeBtn,0.15,{BackgroundColor3=Theme.Danger})
	tween(closeBtn.X1,0.15,{BackgroundColor3=Color3.new(1,1,1)}); tween(closeBtn.X2,0.15,{BackgroundColor3=Color3.new(1,1,1)})
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn,0.15,{BackgroundColor3=Theme.Surface})
	tween(closeBtn.X1,0.15,{BackgroundColor3=Theme.SubText}); tween(closeBtn.X2,0.15,{BackgroundColor3=Theme.SubText})
end)

local function keyFromName(name)
	for _, e in ipairs(Enum.KeyCode:GetEnumItems()) do
		if e.Name == name then return e end
	end
	return Enum.KeyCode.RightShift
end
local toggleKey = keyFromName(Config.keybind or "RightShift")
local bindingKey = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if bindingKey then return end
	if input.KeyCode == toggleKey then
		-- не реагируем, только если игрок печатает в текстбоксе
		if gpe and UserInputService:GetFocusedTextBox() then return end
		toggleGui()
	end
end)

-- keybind setter
local keybindBtn
keybindBtn = Comp.button(setSec, T("keybind").." ["..(Config.keybind or "RightShift").."]", Theme.Surface, function()
	keybindBtn.Text = T("keybind").." [ ... ]"
	bindingKey = true
	local conn
	conn = UserInputService.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			Config.keybind = inp.KeyCode.Name
			toggleKey = inp.KeyCode
			saveConfig()
			keybindBtn.Text = T("keybind").." ["..inp.KeyCode.Name.."]"
			notify("Key: "..inp.KeyCode.Name)
			conn:Disconnect()
			task.wait(0.1)
			bindingKey = false
		end
	end)
end)

---------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------
buildTeleports()
selectTab("home")
LocalPlayer.CharacterAdded:Connect(function() task.wait(2); buildTeleports() end)

-- ============ PREDICTIONS (снизу справа) ============
do
	local SEM, SEC
	pcall(function() SEM = require(Modules.SpecialEventManager) end)
	pcall(function() SEC = require(Modules.SpecialEventConfig) end)
	local eventNames = {}
	if SEC and SEC.Events then for _, e in ipairs(SEC.Events) do table.insert(eventNames, e.Name or e.Id) end end
	if #eventNames == 0 then eventNames = {"Moonlit","Lucky Lots","Rain"} end

	local pred = Instance.new("Frame")
	pred.Name = "Predictions"
	pred.Size = UDim2.fromOffset(210, 0)
	pred.AutomaticSize = Enum.AutomaticSize.Y
	pred.AnchorPoint = Vector2.new(1, 1)
	pred.Position = UDim2.new(1, -14, 1, -14)
	pred.BackgroundColor3 = Theme.Panel
	pred.BackgroundTransparency = 0.1
	pred.BorderSizePixel = 0
	pred.Parent = ScreenGui
	corner(pred, 10); stroke(pred, Theme.Stroke, 1, 0.3)
	local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 5); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = pred
	local pp2 = Instance.new("UIPadding"); pp2.PaddingTop=UDim.new(0,10);pp2.PaddingBottom=UDim.new(0,10);pp2.PaddingLeft=UDim.new(0,12);pp2.PaddingRight=UDim.new(0,12); pp2.Parent = pred

	local ptitle = Instance.new("TextLabel")
	ptitle.Size = UDim2.new(1, 0, 0, 18)
	ptitle.BackgroundTransparency = 1
	ptitle.Font = Enum.Font.GothamBold
	ptitle.TextSize = 13
	ptitle.TextColor3 = Theme.Accent2
	ptitle.TextXAlignment = Enum.TextXAlignment.Left
	ptitle.LayoutOrder = 0
	ptitle.Parent = pred

	local rows = {}
	for i, name in ipairs(eventNames) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, 0, 0, 16)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.GothamMedium
		row.TextSize = 12
		row.TextColor3 = Theme.SubText
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.LayoutOrder = i
		row.Text = name..": ..."
		row.Parent = pred
		rows[name] = row
	end

	task.spawn(function()
		while ScreenGui.Parent do
			ptitle.Text = "⏳ "..T("predictions")
			for _, name in ipairs(eventNames) do
				local row = rows[name]
				local startTs
				pcall(function() if SEM then startTs = SEM:GetNextEventStart(name) end end)
				if row then
					if startTs and tonumber(startTs) then
						local left = math.floor(tonumber(startTs) - os.time())
						if left <= 0 then
							row.Text = "🟢 "..name..": "..T("ev_active")
							row.TextColor3 = Theme.Success
						else
							row.Text = string.format("%s: %d:%02d", name, math.floor(left/60), left%60)
							row.TextColor3 = Theme.SubText
						end
					else
						row.Text = name..": "..T("none")
					end
				end
			end
			task.wait(1)
		end
	end)
end

showLoader(function()
	setVisible(true)
end)

notify("Vault Hub loaded — "..(Config.keybind or "RightShift").." to toggle")
print("[VaultHub] Loaded successfully.")
end, debug.traceback)
if not _BUILD_OK then warn("[VaultHub BUILD ERROR] "..tostring(_BUILD_ERR)) end
