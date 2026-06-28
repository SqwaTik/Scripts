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
local VirtualInputManager = game:GetService("VirtualInputManager")

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
		tab_tp="Телепорты", tab_shop="Магазин", tab_quest="Квесты", tab_other="Прочее", tab_settings="Настройки",
		-- quest / other
		auto_quest="Авто-квесты", quest_npc="NPC квестов", quest_take_new="Брать новый после сдачи",
		anti_afk="Анти-АФК", keep_safes="Сейфы не продавать (в Locksmith)", keep_rods="Удочки не продавать",
		fish_broken_sell="Сломанные удочки в магазин",
		fly="Полёт (Fly)", fly_speed="Скорость полёта", walkspeed="Скорость ходьбы", jumppower="Сила прыжка",
		noclip="Без коллизий (NoClip)", inf_jump="Бесконечный прыжок",
		esp_players="ESP игроков", esp_containers="ESP контейнеров", esp_npc="ESP NPC",
		predict_enable="Показывать эвенты",
		-- home
		networth="Состояние", coins="Монеты", players="Игроков", luck="Удача",
		quick="Быстрые действия", uptime="Аптайм",
		-- farm
		auto_bid="Авто-бид (аукцион)", min_bid="Скип, если ставка <",
		max_bid="Макс. ставка (стоп)", bid_area="Локация аукциона",
		bid_new="Выкупать новые (коллекция)", kill_npc="Убирать NPC (Kick)",
		auto_buyitems="Выкупать предметы в +", profit_min="Мин. профит",
		auto_fish="Авто-рыбалка", auto_collect="Авто-сбор всего",
		auto_collect_lost="Авто-сбор спрятанного", lost_sell="Продавать собранное",
		bid_speed="Скорость ставок",
		auto_stock="Авто-раскладка по полкам", auto_trade="Авто-торговля с клиентами",
		trade_min="Принимать оффер от %", return_full="Возврат на базу при фулл весе",
		-- sell
		auto_sell="Авто-продажа", sell_with_car="Подгонять тачку", keep_fav="Не продавать избранное",
		keep_trophy="Не продавать трофеи", max_sell="Не продавать дороже", sell_now="Продать сейчас",
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
		tip_autoBid="Авто-аукцион: телепорт к контейнерам-гаражам, старт аукциона и авто-попадание по полосе ставок (без промахов). Скип дешёвых по мин.ставке, стоп по макс.",
		tip_autoFish="Авто-рыбалка: телепорт к озеру и автоматический заброс удочки.",
		tip_autoCollect="Авто-сбор: периодически собирает доступные награды/предметы.",
		tip_autoSell="Авто-продажа: телепорт в скупку, продаёт предметы начиная с самых дорогих (фильтры: избранное/трофеи/мин.цена).",
		tip_autoStock="Авто-магазин: возврат на базу при полном весе, выгрузка в инвентарь и торговля через помощника.",
		tip_autoWash="Авто-мойка: моет дорогие предметы (от заданной цены) по свободным слотам.",
		tip_autoGrade="Авто-оценка: оценивает дорогие предметы (от заданной цены) по слотам.",
		tip_autoRepair="Авто-ремонт: чинит предметы по свободным слотам.",
		tip_autoBuyDrink="Авто-покупка зелек удачи выбранного уровня, когда есть в наличии.",
	},
	en = {
		title="VAULT HUB", subtitle="Vault Hunters Open World",
		loading="Loading...", ready="Ready",
		tab_home="Home", tab_farm="Auto Farm", tab_sell="Selling", tab_process="Processing",
		tab_tp="Teleports", tab_shop="Shop", tab_quest="Quests", tab_other="Other", tab_settings="Settings",
		auto_quest="Auto Quests", quest_npc="Quest NPC", quest_take_new="Take new after turn-in",
		anti_afk="Anti-AFK", keep_safes="Keep safes (to Locksmith)", keep_rods="Keep fishing rods",
		fish_broken_sell="List broken rods in shop",
		fly="Fly", fly_speed="Fly speed", walkspeed="Walk speed", jumppower="Jump power",
		noclip="NoClip", inf_jump="Infinite jump",
		esp_players="ESP players", esp_containers="ESP containers", esp_npc="ESP NPC",
		predict_enable="Show events",
		networth="Net Worth", coins="Coins", players="Players", luck="Luck",
		quick="Quick Actions", uptime="Uptime",
		auto_bid="Auto Bid (auction)", min_bid="Skip if bid <",
		max_bid="Max bid (stop)", bid_area="Auction area",
		bid_new="Buy new (collection)", kill_npc="Kick NPC bidders",
		auto_buyitems="Buy profitable items", profit_min="Min profit",
		auto_fish="Auto Fishing", auto_collect="Auto Collect All",
		auto_collect_lost="Auto Collect Lost & Found", lost_sell="Sell collected",
		bid_speed="Bid Speed",
		auto_stock="Auto stock shelves", auto_trade="Auto trade with customers",
		trade_min="Accept offer from %", return_full="Return to base when full",
		auto_sell="Auto Sell", sell_with_car="Bring vehicle", keep_fav="Keep favorited",
		keep_trophy="Keep trophies", max_sell="Don't sell above", sell_now="Sell Now",
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
		tip_autoBid="Auto auction: teleports to garage containers, starts the auction and auto-hits the bid bar (no misses). Skips cheap lots by min bid, stops at max.",
		tip_autoFish="Auto fishing: teleports to the lake and casts automatically.",
		tip_autoCollect="Auto collect: periodically claims available rewards/items.",
		tip_autoSell="Auto sell: teleports to pawn shop, sells items most-expensive first (filters: favorited/trophies/min price).",
		tip_autoStock="Auto shop: returns to base when full, unloads to inventory and trades via assistant.",
		tip_autoWash="Auto wash: washes expensive items (above set price) into free slots.",
		tip_autoGrade="Auto grade: grades expensive items (above set price) into slots.",
		tip_autoRepair="Auto repair: repairs items into free slots.",
		tip_autoBuyDrink="Auto-buys luck drinks of the chosen tier when in stock.",
	},
	es = {
		title="VAULT HUB", subtitle="Vault Hunters Open World",
		loading="Cargando...", ready="Listo",
		tab_home="Inicio", tab_farm="Auto Farmeo", tab_sell="Venta", tab_process="Procesado",
		tab_tp="Teletransportes", tab_shop="Tienda", tab_quest="Misiones", tab_other="Otros", tab_settings="Ajustes",
		auto_quest="Auto Misiones", quest_npc="NPC de misión", quest_take_new="Tomar nueva tras entregar",
		anti_afk="Anti-AFK", keep_safes="Guardar cajas fuertes (a Cerrajero)", keep_rods="Guardar cañas",
		fish_broken_sell="Vender cañas rotas en tienda",
		fly="Volar (Fly)", fly_speed="Velocidad de vuelo", walkspeed="Velocidad de caminar", jumppower="Fuerza de salto",
		noclip="Sin colisiones (NoClip)", inf_jump="Salto infinito",
		esp_players="ESP jugadores", esp_containers="ESP contenedores", esp_npc="ESP NPC",
		predict_enable="Mostrar eventos",
		networth="Patrimonio", coins="Monedas", players="Jugadores", luck="Suerte",
		quick="Acciones rápidas", uptime="Tiempo activo",
		auto_bid="Auto Puja (subasta)", min_bid="Saltar si puja <",
		max_bid="Puja máx. (parar)", bid_area="Zona de subasta",
		bid_new="Comprar nuevos (colección)", kill_npc="Echar NPC (Kick)",
		auto_buyitems="Comprar objetos rentables", profit_min="Beneficio mín.",
		auto_fish="Auto Pesca", auto_collect="Auto Recoger Todo",
		auto_collect_lost="Auto Recoger Perdidos", lost_sell="Vender lo recogido",
		bid_speed="Velocidad de puja",
		auto_stock="Auto surtir estantes", auto_trade="Auto comerciar con clientes",
		trade_min="Aceptar oferta desde %", return_full="Volver a base si lleno",
		auto_sell="Auto Venta", sell_with_car="Traer vehículo", keep_fav="Guardar favoritos",
		keep_trophy="Guardar trofeos", max_sell="No vender por encima de", sell_now="Vender Ahora",
		pawn_rate="Tasa de empeño", est_value="Valor del inventario",
		auto_wash="Auto Lavado", auto_grade="Auto Tasación", auto_repair="Auto Reparación",
		wash_min="Lavar desde precio", grade_min="Tasar desde precio", source="Origen",
		src_inv="Inventario", src_car="Vehículo",
		auto_buy_drink="Auto Comprar Bebidas", drink_tier="Nivel de bebida",
		buy_now="Comprar Ahora", restock="Reposición en",
		tp_areas="Zonas", tp_shops="Tiendas", tp_players="Tiendas de jugadores",
		spawn_car="Aparecer Vehículo",
		language="Idioma", keybind="Tecla de apertura", save_cfg="Guardar Config",
		load_cfg="Cargar Config", export_cfg="Exportar", import_cfg="Importar",
		cfg_saved="Config guardada", cfg_loaded="Config cargada",
		cfg_exported="Copiado al portapapeles", cfg_imported="Config importada",
		paste_here="Pega la config aquí...", credits="by SqwaTik",
		on="SÍ", off="NO", none="ninguno",
		rmb_hint="Clic derecho en una función para sub-ajustes", predictions="Eventos",
		ev_soon="pronto", ev_active="activo",
		tip_autoBid="Auto subasta: teletransporta a los contenedores, inicia la subasta y acierta la barra de puja (sin fallos). Salta lotes baratos por puja mín., para en máx.",
		tip_autoFish="Auto pesca: teletransporta al lago y lanza automáticamente.",
		tip_autoCollect="Auto recoger: reclama recompensas/objetos disponibles periódicamente.",
		tip_autoSell="Auto venta: teletransporta a la casa de empeños, vende de lo más caro primero (filtros: favoritos/trofeos/precio mín.).",
		tip_autoStock="Auto tienda: vuelve a base si está lleno, descarga al inventario y comercia vía ayudante.",
		tip_autoWash="Auto lavado: lava objetos caros (sobre el precio fijado) en ranuras libres.",
		tip_autoGrade="Auto tasación: tasa objetos caros (sobre el precio fijado) en ranuras.",
		tip_autoRepair="Auto reparación: repara objetos en ranuras libres.",
		tip_autoBuyDrink="Compra automática de bebidas de suerte del nivel elegido cuando hay stock.",
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
	bidArea = "", autoBuyItems = false, profitMin = 20, bidNew = false, killNpc = false,
	autoFish = false, autoCollectAll = false,
	autoCollectLost = false, lostSell = false,
	-- trade / shop management
	autoStock = false, autoTrade = false, tradeMinPercent = 80, returnWhenFull = true,
	-- sell
	autoSell = false, sellWithCar = true, keepFav = true, keepTrophy = false, maxSell = 0,
	-- process
	autoWash = false, autoGrade = false, autoRepair = false,
	washMin = 100, gradeMin = 100, procSource = "Inventory",
	-- shop
	autoBuyDrink = false, drinkTier = "1",
	-- sell extra
	keepSafes = true, keepRods = true,
	-- quests
	autoQuest = false, questNpc = "Все", questTakeNew = true,
	-- fishing extra
	fishBrokenSell = true,
	-- predictions
	predictEnable = true,
	-- other / movement / esp
	fly = false, flySpeed = 60, walkSpeed = 16, jumpPower = 50,
	noclip = false, infJump = false, antiAfk = true,
	espPlayers = false, espContainers = false, espNpc = false,
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
	"autoBuyDrink","autoStock","autoTrade","autoCollectAll","autoBuyItems","returnWhenFull",
	"autoQuest","fly","noclip","infJump","espPlayers","espContainers","espNpc"}

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
	local g = guid or LocalPlayer:GetAttribute("EquippedVehicle")
	if not g then
		local v = API.getVehicles()
		g = v.equippedGuid
	end
	if not g then return false end
	pcall(function() f:FireServer(g) end)  -- у сервера кулдаун ~6с; не спамить
	return true
end

-- найти заспавненную тачку игрока в мире (по владельцу/GUID)
function API.findMyVehicle()
	local myId = LocalPlayer.UserId
	local guid = LocalPlayer:GetAttribute("EquippedVehicle")
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("Model") and d:FindFirstChildWhichIsA("VehicleSeat") then
			if d:GetAttribute("OwnerUserId") == myId or (guid and d:GetAttribute("VehicleGUID") == guid) then
				return d
			end
		end
	end
	return nil
end

-- вес груза тачки: возвращает (текущий, лимит, заполнено?)
function API.vehicleCargo()
	local v = API.findMyVehicle()
	if not v then return 0, 0, false end
	local w = v:GetAttribute("CargoWeight") or 0
	local cap = v:GetAttribute("CargoWeightLimit") or 0
	return w, cap, (cap > 0 and w >= cap)
end

-- гарантировать наличие тачки рядом (спавн только если её нет; уважает кулдаун)
local _lastSpawnTry = 0
function API.ensureVehicle()
	local v = API.findMyVehicle()
	if v then return v end
	if os.clock() - _lastSpawnTry > 6 then  -- кулдаун спавна
		_lastSpawnTry = os.clock()
		API.spawnVehicle()
		task.wait(2)
		v = API.findMyVehicle()
	end
	return v
end

-- выгрузить тачку в инвентарь; при переполнении инвентаря и опции — продать у НПС
-- (объявлено здесь, до автобида, т.к. используется и им, и сборщиком)
local function unloadVehicleSmart(sellWhenFull)
	API.transferVehicleItems(); task.wait(1.2)
	local cnt = LocalPlayer:GetAttribute("InventoryCount") or 0
	local cap = LocalPlayer:GetAttribute("InventoryCap") or 999
	if sellWhenFull and cnt >= cap then
		if _G.__VH_sellNow then _G.__VH_sellNow() end; task.wait(2)
	end
end
-- подогнать тачку вплотную к точке (чтобы сработал промпт "Add to Vehicle")
local function nudgeVehicleTo(pos)
	local v = API.findMyVehicle()
	if v then pcall(function() v:PivotTo(CFrame.new(pos + Vector3.new(5, 3, 0))) end); return true end
	return false
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
	quest   = "",  -- векторный значок (рисуется), чтобы не было пустого квадрата
	other   = "",  -- векторный значок (рисуется)
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

local tabHolder = Instance.new("ScrollingFrame")
tabHolder.Size = UDim2.new(1, 0, 1, -64)
tabHolder.Position = UDim2.new(0, 0, 0, 64)
tabHolder.BackgroundTransparency = 1
tabHolder.BorderSizePixel = 0
tabHolder.ScrollBarThickness = 2
tabHolder.ScrollBarImageColor3 = Theme.Stroke
tabHolder.CanvasSize = UDim2.new(0,0,0,0)
tabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabHolder.ScrollingDirection = Enum.ScrollingDirection.Y
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
pageTitle.Size = UDim2.new(1, -260, 1, 0)
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

-- кнопка смены языка — значок глобуса, клик выдвигает выбор
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.fromOffset(30, 30)
langBtn.Position = UDim2.new(1, -78, 0.5, 0)
langBtn.AnchorPoint = Vector2.new(0, 0.5)
langBtn.BackgroundColor3 = Theme.Surface
langBtn.AutoButtonColor = false
langBtn.Text = "🌐"
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 15
langBtn.TextColor3 = Theme.Accent2
langBtn.Parent = topBar
corner(langBtn, 8)
langBtn.MouseEnter:Connect(function() tween(langBtn,0.15,{BackgroundColor3=Theme.SurfaceHl}) end)
langBtn.MouseLeave:Connect(function() tween(langBtn,0.15,{BackgroundColor3=Theme.Surface}) end)

local function switchLang(lang)
	if lang == Locale then return end
	Config.language = lang; Locale = lang; saveConfig()
	shared.__VAULTHUB_LOADED = nil
	ScreenGui:Destroy()
	task.spawn(function()
		local ok, body = pcall(function() return game:HttpGet(VH_SCRIPT_URL) end)
		if ok and body then local f = loadstring(body); if f then f() end end
	end)
end

-- меню языка поверх ВСЕГО (parent Main, максимальный ZIndex)
local langMenu = Instance.new("Frame")
langMenu.Size = UDim2.fromOffset(150, 0)
langMenu.AutomaticSize = Enum.AutomaticSize.Y
langMenu.Position = UDim2.new(1, -12, 0, 50)
langMenu.AnchorPoint = Vector2.new(1, 0)  -- правый край у границы окна, не вылезает вправо
langMenu.BackgroundColor3 = Theme.SurfaceHl
langMenu.Visible = false
langMenu.ZIndex = 5000
langMenu.Parent = Main
corner(langMenu, 8); stroke(langMenu, Theme.Stroke, 1, 0)
local lmp = Instance.new("UIPadding"); lmp.PaddingTop=UDim.new(0,4);lmp.PaddingBottom=UDim.new(0,4);lmp.PaddingLeft=UDim.new(0,4);lmp.PaddingRight=UDim.new(0,4); lmp.Parent=langMenu
local lml = Instance.new("UIListLayout"); lml.Padding=UDim.new(0,2); lml.Parent=langMenu
local LANG_NAME = { ru="Русский", en="English", es="Español" }
for _, lang in ipairs({"ru","en","es"}) do
	local o = Instance.new("TextButton")
	o.Size = UDim2.new(1,0,0,28); o.BackgroundColor3 = Theme.SurfaceHl; o.AutoButtonColor=false
	o.Font = Enum.Font.GothamBold; o.TextSize=12; o.TextColor3=Theme.Text
	o.Text = lang:upper().."  ·  "..(LANG_NAME[lang] or lang)  -- код + название, без emoji-флагов (tofu)
	o.TextXAlignment = Enum.TextXAlignment.Left
	local op = Instance.new("UIPadding"); op.PaddingLeft=UDim.new(0,10); op.Parent=o
	o.ZIndex = 5001; o.Parent = langMenu; corner(o,5)
	o.MouseEnter:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.Accent}) end)
	o.MouseLeave:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.SurfaceHl}) end)
	o.MouseButton1Click:Connect(function() langMenu.Visible=false; switchLang(lang) end)
end
langBtn.MouseButton1Click:Connect(function() langMenu.Visible = not langMenu.Visible end)

-- ГЛОБАЛЬНЫЙ ТУЛТИП (вверху по центру окна)
local tooltip = Instance.new("Frame")
tooltip.Name = "Tooltip"
tooltip.AnchorPoint = Vector2.new(0.5, 1)
tooltip.Position = UDim2.new(0.5, 0, 0, -8)
tooltip.Size = UDim2.fromOffset(440, 0)
tooltip.AutomaticSize = Enum.AutomaticSize.Y
tooltip.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
tooltip.BackgroundTransparency = 1
tooltip.Visible = false
tooltip.ZIndex = 5000
tooltip.Parent = Main
corner(tooltip, 8)
local ttStroke = stroke(tooltip, Theme.Accent, 1, 1)
local ttPad = Instance.new("UIPadding")
ttPad.PaddingTop=UDim.new(0,8); ttPad.PaddingBottom=UDim.new(0,8); ttPad.PaddingLeft=UDim.new(0,12); ttPad.PaddingRight=UDim.new(0,12); ttPad.Parent = tooltip
local ttText = Instance.new("TextLabel")
ttText.Size = UDim2.new(1, 0, 0, 0)
ttText.AutomaticSize = Enum.AutomaticSize.Y
ttText.BackgroundTransparency = 1
ttText.Font = Enum.Font.Gotham
ttText.TextSize = 12
ttText.TextColor3 = Theme.Text
ttText.TextWrapped = true
ttText.TextXAlignment = Enum.TextXAlignment.Left
ttText.TextTransparency = 1
ttText.ZIndex = 5001
ttText.Parent = tooltip

local function attachTip(obj, getText)
	obj.MouseEnter:Connect(function()
		local txt = getText()
		if not txt or txt == "" then return end
		ttText.Text = txt
		tooltip.Visible = true
		tween(tooltip, 0.15, {BackgroundTransparency = 0.05})
		tween(ttStroke, 0.15, {Transparency = 0.4})
		tween(ttText, 0.15, {TextTransparency = 0})
	end)
	obj.MouseLeave:Connect(function()
		tween(tooltip, 0.15, {BackgroundTransparency = 1})
		tween(ttStroke, 0.15, {Transparency = 1})
		tween(ttText, 0.15, {TextTransparency = 1})
		task.delay(0.16, function() if ttText.TextTransparency >= 1 then tooltip.Visible = false end end)
	end)
end

local pages = {}
local tabButtons = {}
local currentTab


local function selectTab(name)
	currentTab = name
	for n, t in pairs(tabButtons) do
		local active = (n == name)
		tween(t.btn, 0.2, {BackgroundColor3 = active and Theme.Surface or Theme.Panel})
		-- индикатор активной вкладки = её собственная полоска (скроллится вместе с кнопкой)
		if t.bar then tween(t.bar, 0.2, {BackgroundTransparency = active and 0 or 1}) end
		tween(t.ico, 0.2, {ImageColor3 = active and Theme.Accent or Theme.SubText})
		for _, g in ipairs(t.ico:GetChildren()) do  -- векторные значки (quest/other)
			if g.Name == "G" then tween(g, 0.2, {BackgroundColor3 = active and Theme.Accent or Theme.SubText}) end
		end
		tween(t.lbl, 0.2, {TextColor3 = active and Theme.Text or Theme.SubText})
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
	-- векторные значки для вкладок без картинки (quest/other) — без «квадратика»
	if ico.Image == "" then
		if iconKey == "other" then
			-- три точки (kebab "ещё")
			for i = 0, 2 do
				local dot = Instance.new("Frame")
				dot.Size = UDim2.fromOffset(4, 4)
				dot.AnchorPoint = Vector2.new(0.5, 0.5)
				dot.Position = UDim2.new(0.5, 0, 0.5, (i-1)*7)
				dot.BackgroundColor3 = Theme.SubText
				dot.BorderSizePixel = 0
				dot.Name = "G"
				dot.Parent = ico
				corner(dot, 2)
			end
		elseif iconKey == "quest" then
			-- восклицательный знак (квест/важное)
			local bar = Instance.new("Frame")
			bar.Size = UDim2.fromOffset(3, 11)
			bar.AnchorPoint = Vector2.new(0.5, 0)
			bar.Position = UDim2.new(0.5, 0, 0.5, -8)
			bar.BackgroundColor3 = Theme.SubText
			bar.BorderSizePixel = 0
			bar.Name = "G"
			bar.Parent = ico
			corner(bar, 1)
			local dot = Instance.new("Frame")
			dot.Size = UDim2.fromOffset(3, 3)
			dot.AnchorPoint = Vector2.new(0.5, 1)
			dot.Position = UDim2.new(0.5, 0, 0.5, 8)
			dot.BackgroundColor3 = Theme.SubText
			dot.BorderSizePixel = 0
			dot.Name = "G"
			dot.Parent = ico
			corner(dot, 1)
		end
	end

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
	-- анимация наведения
	sw.MouseEnter:Connect(function() tween(knob, 0.12, {Size = UDim2.fromOffset(20,20)}) end)
	sw.MouseLeave:Connect(function() tween(knob, 0.12, {Size = UDim2.fromOffset(18,18)}) end)
	return { set = set, label = lbl }
end

function Comp.slider(parent, text, key, min, max, step, suffix, callback)
	local r = rowBase(parent, 48)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -84, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Theme.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	-- значение = TextBox (клик -> ввод любого числа), но визуально как обычная подпись
	local valBox = Instance.new("TextBox")
	valBox.Size = UDim2.new(0, 80, 0, 20)
	valBox.Position = UDim2.new(1, -80, 0, 0)
	valBox.BackgroundTransparency = 1
	valBox.Font = Enum.Font.GothamBold
	valBox.TextSize = 13
	valBox.TextColor3 = Theme.Accent2
	valBox.TextXAlignment = Enum.TextXAlignment.Right
	valBox.ClearTextOnFocus = false
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
		v = math.floor(v/step + 0.5)*step
		Config[key] = v
		local a = (max>min) and (v - min)/(max - min) or 0
		tween(fill, 0.1, {Size = UDim2.new(a, 0, 1, 0)})
		if not valBox:IsFocused() then valBox.Text = fmt(v) end
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

	-- ручной ввод числа по клику на значение
	valBox.Focused:Connect(function() valBox.Text = tostring(Config[key] or min) end)
	valBox.FocusLost:Connect(function()
		local n = tonumber((valBox.Text:gsub("[^%d%.%-]", "")))
		if n then set(n, true); saveConfig() else valBox.Text = fmt(Config[key] or min) end
	end)

	set(Config[key] or min, false)
	track.MouseEnter:Connect(function() tween(track,0.12,{Size=UDim2.new(1,0,0,9)}); tween(valBox,0.12,{TextColor3=Theme.Accent}) end)
	track.MouseLeave:Connect(function() tween(track,0.12,{Size=UDim2.new(1,0,0,6)}); tween(valBox,0.12,{TextColor3=Theme.Accent2}) end)
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
		-- press-эффект без :Wait() (раньше кнопка залипала сжатой), размер всегда восстанавливается
		tween(b, 0.07, {Size = UDim2.new(1, -8, 0, 33)})
		task.delay(0.08, function() tween(b, 0.12, {Size = UDim2.new(1, 0, 0, 36)}) end)
		if callback then task.spawn(callback) end
	end)
	return b
end

function Comp.dropdown(parent, text, key, options, callback)
	-- раздвижной вниз (в потоке), раздвигает список — не улетает и не закрывает другое
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, 34)
	wrap.BackgroundTransparency = 1
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.Parent = parent
	local wl = Instance.new("UIListLayout"); wl.SortOrder = Enum.SortOrder.LayoutOrder; wl.Parent = wrap

	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, 0, 0, 34)
	r.BackgroundTransparency = 1
	r.LayoutOrder = 0
	r.Parent = wrap

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
	local arr = Instance.new("TextLabel")
	arr.Size = UDim2.fromOffset(16,28); arr.Position = UDim2.new(1,-18,0.5,0); arr.AnchorPoint=Vector2.new(0,0.5)
	arr.BackgroundTransparency=1; arr.Text="▾"; arr.Font=Enum.Font.GothamBold; arr.TextSize=11; arr.TextColor3=Theme.SubText; arr.Parent=box

	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Size = UDim2.new(1, 0, 0, 0)
	menu.AutomaticSize = Enum.AutomaticSize.Y
	menu.BackgroundTransparency = 1
	menu.LayoutOrder = 1
	menu.Visible = false
	menu.Parent = wrap
	local mp = Instance.new("UIPadding"); mp.PaddingLeft=UDim.new(0.5,4); mp.PaddingBottom=UDim.new(0,4); mp.Parent=menu
	local ml = Instance.new("UIListLayout"); ml.Padding=UDim.new(0,2); ml.SortOrder = Enum.SortOrder.LayoutOrder; ml.Parent = menu

	local open = false
	local function choose(v)
		Config[key] = v; box.Text = tostring(v)
		if callback then task.spawn(callback, v) end
		saveConfig()
	end
	for i, opt in ipairs(options) do
		local o = Instance.new("TextButton")
		o.Size = UDim2.new(1, -8, 0, 26)
		o.BackgroundColor3 = Theme.SurfaceHl
		o.AutoButtonColor = false
		o.Font = Enum.Font.Gotham
		o.TextSize = 12
		o.TextColor3 = Theme.Text
		o.Text = tostring(opt)
		o.LayoutOrder = i
		o.Parent = menu
		corner(o, 5)
		o.MouseEnter:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.Accent}) end)
		o.MouseLeave:Connect(function() tween(o,0.1,{BackgroundColor3=Theme.SurfaceHl}) end)
		o.MouseButton1Click:Connect(function()
			choose(opt); open=false; menu.Visible=false; tween(arr,0.15,{Rotation=0})
		end)
	end
	box.MouseButton1Click:Connect(function()
		open = not open
		menu.Visible = open
		tween(arr, 0.18, {Rotation = open and 180 or 0})
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
	wrap.Parent = parent
	corner(wrap, 8); stroke(wrap, Theme.Stroke, 1, 0.5)
	local wl = Instance.new("UIListLayout"); wl.SortOrder = Enum.SortOrder.LayoutOrder; wl.Parent = wrap

	-- шапка (кликабельна -> раскрывает поднастройки)
	local head = Instance.new("TextButton")
	head.Size = UDim2.new(1, 0, 0, 36)
	head.BackgroundTransparency = 1
	head.AutoButtonColor = false
	head.Text = ""
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

	-- подпанель (плавная анимация высоты)
	local panel = Instance.new("Frame")
	panel.Name = "Sub"
	panel.Size = UDim2.new(1, 0, 0, 0)
	panel.BackgroundTransparency = 1
	panel.LayoutOrder = 1
	panel.Visible = false
	panel.ClipsDescendants = true
	panel.Parent = wrap
	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, 0, 0, 0)
	inner.AutomaticSize = Enum.AutomaticSize.Y
	inner.BackgroundTransparency = 1
	inner.Parent = panel
	local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,4); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = inner
	local pp = Instance.new("UIPadding"); pp.PaddingLeft=UDim.new(0,12); pp.PaddingRight=UDim.new(0,12); pp.PaddingBottom=UDim.new(0,10); pp.PaddingTop=UDim.new(0,2); pp.Parent = inner
	if subBuild then subBuild(inner) end

	local hasSub = subBuild ~= nil
	if not hasSub then arrow.Text = "" end  -- нет поднастроек -> нет стрелки
	local expanded = false
	local function togglePanel()
		if not hasSub then return end
		expanded = not expanded
		tween(arrow, 0.2, {Rotation = expanded and 90 or 0})
		tween(arrow, 0.2, {TextColor3 = expanded and Theme.Accent or Theme.SubText})
		tween(wrap, 0.12, {BackgroundColor3 = Theme.Surface})  -- развёрнутый/свёрнутый — без подсветки наведения
		if expanded then
			panel.Visible = true
			panel.AutomaticSize = Enum.AutomaticSize.None
			panel.ClipsDescendants = true
			local h = inner.AbsoluteSize.Y
			if h < 4 then h = 0 end
			tween(panel, 0.22, {Size = UDim2.new(1, 0, 0, h)}, Enum.EasingStyle.Quad)
			-- после анимации отдаём высоту авто-размеру: вложенные dropdown'ы раскрываются без обрезки
			task.delay(0.24, function()
				if expanded then panel.ClipsDescendants = false; panel.AutomaticSize = Enum.AutomaticSize.Y end
			end)
		else
			panel.AutomaticSize = Enum.AutomaticSize.None
			panel.ClipsDescendants = true
			panel.Size = UDim2.new(1, 0, 0, inner.AbsoluteSize.Y)  -- зафиксировать текущую высоту перед схлопыванием
			tween(panel, 0.18, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quad)
			task.delay(0.18, function() if not expanded then panel.Visible = false end end)
		end
	end
	-- клик по шапке (ЛКМ и ПКМ) раскрывает; свитч справа тоглит сам
	head.MouseButton1Click:Connect(togglePanel)
	head.MouseButton2Click:Connect(togglePanel)
	head.MouseEnter:Connect(function() if hasSub and not expanded then tween(wrap,0.12,{BackgroundColor3=Theme.SurfaceHl}) end end)
	head.MouseLeave:Connect(function() if not expanded then tween(wrap,0.12,{BackgroundColor3=Theme.Surface}) end end)
	-- тултип-описание (если есть перевод tip_<key>)
	attachTip(head, function()
		local tk = "tip_"..key
		local t = T(tk)
		return (t ~= tk) and t or ""
	end)
	return { set = setSw }
end

---------------------------------------------------------------------
-- BUILD TABS
---------------------------------------------------------------------
local homePage     = addTab("home", "home")
local farmPage     = addTab("farm", "farm")
local sellPage     = addTab("sell", "sell")
local processPage  = addTab("process", "process")
local questPage    = addTab("quest", "quest")
local tpPage       = addTab("tp", "tp")
local shopPage     = addTab("shop", "shop")
local otherPage    = addTab("other", "other")
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
	Comp.slider(p, T("min_bid"), "minBid", 0, 50000, 50, "$")
	Comp.slider(p, T("max_bid"), "maxBid", 0, 100000, 50, "$")
	Comp.slider(p, T("bid_speed"), "bidSpeed", 0.1, 1.5, 0.05, "s")
	Comp.toggle(p, T("bid_new"), "bidNew")
	Comp.toggle(p, T("kill_npc"), "killNpc")
	Comp.toggle(p, T("auto_buyitems"), "autoBuyItems")
	Comp.slider(p, T("profit_min"), "profitMin", 0, 100, 5, "%")
	Comp.toggle(p, T("keep_safes"), "keepSafes")
end)
Comp.module(farmSec, T("auto_fish"), "autoFish", function(p)
	Comp.toggle(p, T("fish_broken_sell"), "fishBrokenSell")
end)
Comp.module(farmSec, T("auto_collect_lost"), "autoCollectLost", function(p)
	Comp.toggle(p, T("lost_sell"), "lostSell")
end)

-- =========== SELL ===========
local sellSec = Comp.section(sellPage, nil)
Comp.module(sellSec, T("auto_sell"), "autoSell", function(p)
	Comp.toggle(p, T("sell_with_car"), "sellWithCar")
	Comp.toggle(p, T("keep_fav"), "keepFav")
	Comp.toggle(p, T("keep_trophy"), "keepTrophy")
	Comp.toggle(p, T("keep_safes"), "keepSafes")
	Comp.toggle(p, T("keep_rods"), "keepRods")
	Comp.slider(p, T("max_sell"), "maxSell", 0, 100000, 50, "$")  -- не продавать дороже X (0 = без лимита)
end)
Comp.module(sellSec, T("auto_stock"), "autoStock", function(p)
	Comp.toggle(p, T("return_full"), "returnWhenFull")
	Comp.toggle(p, T("auto_trade"), "autoTrade")
	Comp.toggle(p, T("keep_trophy"), "keepTrophy")
	Comp.toggle(p, T("keep_rods"), "keepRods")
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
-- «Источник» убран: обработка всегда берёт из инвентаря

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

-- =========== QUEST ===========
local questNpcNames = {"Все"}
do
	local seen = {["Все"]=true}
	local function addNpc(n) if n and not seen[n] then seen[n]=true; table.insert(questNpcNames, n) end end
	local qfolder = Workspace:FindFirstChild("Mall - Shop NPCs")
	qfolder = qfolder and qfolder:FindFirstChild("Quest NPC")
	if qfolder then for _, n in ipairs(qfolder:GetChildren()) do addNpc(n.Name) end end
	for _, npc in ipairs({"Billy","Sal","Ted","Steve"}) do addNpc(npc) end
end
if Locale == "en" then questNpcNames[1] = "All" elseif Locale == "es" then questNpcNames[1] = "Todos" end
if not Config.questNpc or Config.questNpc == "" then Config.questNpc = questNpcNames[1] end

local questSec = Comp.section(questPage, nil)
Comp.module(questSec, T("auto_quest"), "autoQuest", function(p)
	Comp.dropdown(p, T("quest_npc"), "questNpc", questNpcNames)
	Comp.toggle(p, T("quest_take_new"), "questTakeNew")
end)

-- =========== OTHER ===========
local moveSec = Comp.section(otherPage, T("tab_other"))
Comp.module(moveSec, T("fly"), "fly", function(p)
	Comp.slider(p, T("fly_speed"), "flySpeed", 16, 250, 2)
end, function(v) _G.__VH_setFly(v) end)
Comp.slider(moveSec, T("walkspeed"), "walkSpeed", 16, 200, 2, "", function(v) _G.__VH_setWalk(v) end)
Comp.slider(moveSec, T("jumppower"), "jumpPower", 50, 350, 5, "", function(v) _G.__VH_setJump(v) end)
Comp.toggle(moveSec, T("noclip"), "noclip", function(v) _G.__VH_setNoclip(v) end)
Comp.toggle(moveSec, T("inf_jump"), "infJump")
Comp.toggle(moveSec, T("anti_afk"), "antiAfk")

local espSec = Comp.section(otherPage, "ESP")
local function espRefresh() if _G.__VH_refreshEsp then _G.__VH_refreshEsp() end end
Comp.toggle(espSec, T("esp_players"), "espPlayers", espRefresh)
Comp.toggle(espSec, T("esp_containers"), "espContainers", espRefresh)
Comp.toggle(espSec, T("esp_npc"), "espNpc", espRefresh)

local miscSec = Comp.section(otherPage, T("predictions"))
Comp.toggle(miscSec, T("predict_enable"), "predictEnable", function(v) if _G.__VH_setPred then _G.__VH_setPred(v) end end)

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
		local def = Items and Items[tostring(e.ItemId)]
		local isSafe = (def and (def.SafeId ~= nil or (def.Category=="Safe") or ((def.Name or ""):lower():find("safe")))) or false
		local isRod = (def and ((def.Category=="Tool") or ((def.Name or ""):lower():find("rod")))) or false
		local skip = false
		if Config.keepFav and e.Favorited then skip = true end
		if Config.keepTrophy and e.IsTrophy then skip = true end
		if Config.keepSafes and isSafe then skip = true end
		if Config.keepRods and isRod then skip = true end
		if (Config.maxSell or 0) > 0 and price > Config.maxSell then skip = true end  -- не продавать дороже X
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
				-- не покупаем, если зелье этого уровня уже активно (ActiveLuckDrinkExpireAt_<tier> в будущем)
				local expireAt = LocalPlayer:GetAttribute("ActiveLuckDrinkExpireAt_"..tostring(Config.drinkTier)) or 0
				if expireAt <= os.time() then
					local cat = API.energyCatalog()
					if cat.Drinks then
						for _, d in ipairs(cat.Drinks) do
							if d.EnergyDrinkId == Config.drinkTier and (d.StockRemaining or 0) > 0 then
								API.buyDrink(Config.drinkTier)
							end
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
local areaActive = false   -- ToggleAuctionArea: аукцион реально идёт (приходит ~0.1с после старта)
local currentBid = 0
local autoHitEnabled = false  -- бьём по бар-полосе ТОЛЬКО на одобренном аукционе (не на дешёвых/чужих)
do
	local toggleArea = ev("Auction.ToggleAuctionArea")
	local toggleUI = ev("Auction.ToggleBiddingUI")
	local updBid = ev("Auction.UpdateCurrentWinningBid")
	if toggleArea then toggleArea.OnClientEvent:Connect(function(state) areaActive = (state == true) end) end
	if toggleUI then toggleUI.OnClientEvent:Connect(function(state) biddingActive = (state ~= false and state ~= nil) end) end
	if updBid then updBid.OnClientEvent:Connect(function(v)
		if type(v)=="number" then currentBid = v
		elseif type(v)=="table" and v.amount then currentBid = v.amount end
	end) end
	-- NB: AuctionPickupItem — HUD-уведомление о прибыли, НЕ команда. Раньше зря перефаирили его на сервер.
end

-- кикнуть NPC-участников аукциона (они дети гаража: Model+Humanoid, кроме Auctioneer)
local function kickAuctionNPCs(garageModel)
	if not garageModel then return end
	local kickF = ev("Auction.UseKickNPC")
	if not kickF then return end
	for _, npc in ipairs(garageModel:GetChildren()) do
		if not (Config.killNpc and Config.autoBid) then break end
		if npc:IsA("Model") and npc.Name ~= "Auctioneer" and npc:FindFirstChildOfClass("Humanoid") then
			local ok, res = pcall(function() return kickF:InvokeServer(npc.Name) end)
			if ok and res == "limit" then break end  -- лимит киков на этот аукцион исчерпан
			task.wait(0.2)
		end
	end
end

-- забрать выигранные предметы из гаража (промпт "Add to Vehicle"/"Collect")
local function collectWonItems(garageModel)
	if not garageModel then return end
	for _, m in ipairs(garageModel:GetDescendants()) do
		if m:IsA("ProximityPrompt") and (m.ActionText == "Add to Vehicle" or m.ActionText == "Collect" or m.ActionText == "Pick Up") then
			pcall(function() fireproximityprompt(m) end)
			task.wait(0.2)
		end
	end
end

-- АВТО-ПОПАДАНИЕ по бид-бару: читаем реальные позиции курсора и зоны,
-- бид строго когда курсор внутри зоны (любой редкости/скорости) -> промахов нет -> нет кд
local lastHit = 0
RunService.Heartbeat:Connect(function()
	if not (Config.autoBid and autoHitEnabled) then return end  -- бьём только на одобренном лоте
	local ui = PlayerGui:FindFirstChild("UIControllerGui")
	local cont = ui and ui:FindFirstChild("AuctionBiddingContainer")
	if not (cont and cont.Visible) then return end
	if Config.maxBid > 0 and currentBid >= Config.maxBid then return end
	if Config.minBid > 0 and currentBid > 0 and currentBid < Config.minBid then return end  -- дешёвый лот — не бьём
	-- умно: не бидим выше своих наличных (капитал не позволяет)
	local cash = LocalPlayer:GetAttribute("Cash") or 0
	if currentBid > 0 and currentBid >= cash then return end
	-- путь: AuctionBiddingContainer.BidBarRow.Track.{BidZone,Cursor}
	local row = cont:FindFirstChild("BidBarRow")
	local track = row and row:FindFirstChild("Track")
	local zone = track and track:FindFirstChild("BidZone")
	local cur = track and track:FindFirstChild("Cursor")
	if not (zone and cur) or zone.AbsoluteSize.X <= 0 then return end
	-- считаем в пикселях (надёжно при любых якорях/единицах)
	local zs = zone.AbsolutePosition.X
	local ze = zs + zone.AbsoluteSize.X
	local cx = cur.AbsolutePosition.X + cur.AbsoluteSize.X * 0.5
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

-- конфиг гаражей (MinNetWorth / EntryCost / MinAuctionValue) для умного скипа по капиталу
local GarageCfg
pcall(function() GarageCfg = require(Modules.Garages) end)
-- кэш проверки "открыт ли предмет" (Collections.HasDiscoveredItem), чтобы не дёргать сервер повторно
local discoveredCache = {}
local function isItemNew(itemId)
	if not itemId then return false end
	local key = tostring(itemId)
	if discoveredCache[key] ~= nil then return discoveredCache[key] == false end
	local discovered = true
	local cf = ev("Collections.HasDiscoveredItem")
	if cf then
		local done = false
		task.spawn(function()
			local ok, res = pcall(function() return cf:InvokeServer(key) end)
			if ok and type(res) == "boolean" then discovered = res end
			done = true
		end)
		local t = 0
		repeat task.wait(0.1); t = t + 0.1 until done or t > 3
	end
	discoveredCache[key] = discovered
	return discovered == false
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

	-- скип по капиталу: если MinNetWorth гаража выше, чем у игрока — пропускаем
	local garageCfg = GarageCfg and GarageCfg[g.name]
	if garageCfg and garageCfg.MinNetWorth then
		local myNetWorth = LocalPlayer:GetAttribute("MaxNetWorth") or LocalPlayer:GetAttribute("NetWorth") or 0
		if myNetWorth < garageCfg.MinNetWorth then return end  -- допуск по капиталу не пройден
	end

	autoHitEnabled = false  -- пока лот не одобрен — НЕ бьём по бару
	hrp.CFrame = CFrame.new(g.part.Position + Vector3.new(0, 3, 0))
	task.wait(0.35)
	biddingActive = false
	areaActive = false
	currentBid = 0
	pcall(function() fireproximityprompt(g.prompt) end)

	-- ждём вход в зону (ToggleAuctionArea приходит ~0.1с)
	local t0 = os.clock()
	repeat task.wait(0.08) until areaActive or (os.clock()-t0) > 2 or not Config.autoBid
	if not areaActive then task.wait(0.2); return end

	-- ждём старт торгов И появление реальной ставки (>0), чтобы решение по minBid было верным
	t0 = os.clock()
	repeat task.wait(0.12) until (biddingActive and currentBid > 0) or (os.clock()-t0) > 12 or (not areaActive) or not Config.autoBid
	if not biddingActive then autoHitEnabled = false; API.leaveAuction(); task.wait(0.4); return end

	-- решаем: дешёвый лот (ниже minBid)?
	local skipCheap = (Config.minBid > 0 and currentBid > 0 and currentBid < Config.minBid)
	if skipCheap and Config.bidNew then
		-- "выкупать новые": если предмет не открыт в коллекции — не скипать даже дешёвый
		local itemId
		for _, m in ipairs(g.model:GetDescendants()) do itemId = m:GetAttribute("ItemId"); if itemId then break end end
		if itemId and isItemNew(itemId) then skipCheap = false end
	end
	local cash = LocalPlayer:GetAttribute("Cash") or 0
	local tooExpensive = (currentBid > 0 and currentBid >= cash)
	if skipCheap or tooExpensive then
		autoHitEnabled = false
		API.leaveAuction(); task.wait(0.5)  -- ВЫХОДИМ из лота полностью, не играем
		return
	end

	-- лот одобрен -> включаем авто-хит и (если надо) кикаем 1 NPC
	autoHitEnabled = true
	if Config.killNpc then task.spawn(function() kickAuctionNPCs(g.model) end) end

	-- стоим на гараже до конца торгов; во время — следим за лимитами
	local bt = os.clock()
	repeat
		if hrp and (hrp.Position - (g.part.Position + Vector3.new(0,3,0))).Magnitude > 6 then
			hrp.CFrame = CFrame.new(g.part.Position + Vector3.new(0, 3, 0))
		end
		-- если ставка превысила макс/наличные — прекращаем бить (но лот доигрываем)
		if (Config.maxBid > 0 and currentBid >= Config.maxBid) or (currentBid >= (LocalPlayer:GetAttribute("Cash") or 0)) then
			autoHitEnabled = false
		end
		task.wait(0.2)
	until (not areaActive) or (not Config.autoBid) or (os.clock()-bt) > 40
	autoHitEnabled = false
	task.wait(0.6)
	-- забрать выигранное; если тачки нет рядом — подогнать (спавн с учётом кулдауна)
	API.ensureVehicle()
	collectWonItems(g.model)
	-- если тачка переполнилась — отвезти/продать (выигранное часто валится в ящик забытых вещей)
	local _, _, full = API.vehicleCargo()
	if full then unloadVehicleSmart(true) end
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

-- ========== АВТО-РЫБАЛКА (reel: держим маркер в зоне рыбы) ==========
local function mousePress()
	if mouse1press then pcall(mouse1press)
	else pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0) end) end
end
local function mouseRelease()
	if mouse1release then pcall(mouse1release)
	else pcall(function() VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0) end) end
end

local function getRodTool()
	local char = LocalPlayer.Character
	local bp = LocalPlayer:FindFirstChild("Backpack")
	local function isRod(t) return t:IsA("Tool") and (t.Name:lower():find("rod") or t.Name:lower():find("fish")) end
	if char then for _, t in ipairs(char:GetChildren()) do if isRod(t) then return t, true end end end
	if bp then for _, t in ipairs(bp:GetChildren()) do if isRod(t) then return t, false end end end
	return nil
end
local function equipRod()
	-- уже в руках?
	local tool, inHand = getRodTool()
	if tool and inHand then return true end
	if tool and not inHand then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:EquipTool(tool); return true end
	end
	-- удочка в игровом инвентаре -> экипировать через Hotbar.EquipTool(guid)
	local inv = API.getInventory()
	local equipF = ev("Hotbar.EquipTool")
	for guid, e in pairs(inv) do
		local def = Items and Items[tostring(e.ItemId)]
		local nm = (def and def.Name or ""):lower()
		if (def and def.Category == "Tool" and (nm:find("rod") or nm:find("fish"))) or nm:find("rod") then
			if equipF then pcall(function() equipF:FireServer(guid) end) end
			task.wait(0.8)
			local t2 = getRodTool()
			if t2 then return true end
		end
	end
	return false
end
-- точка на воде перед игроком + сама вода (для FishingCast:FireServer(water, pos))
local function getCastTarget()
	local hrp = getHRP(); if not hrp then return nil end
	local water
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "Water" then water = d; break end
	end
	if not water then return nil end
	local top = water.Position.Y + water.Size.Y/2
	local fwd = hrp.CFrame.LookVector; fwd = Vector3.new(fwd.X, 0, fwd.Z)
	if fwd.Magnitude < 0.1 then fwd = Vector3.new(0,0,-1) end
	fwd = fwd.Unit
	local point = Vector3.new(hrp.Position.X, top, hrp.Position.Z) + fwd * 18
	return water, point
end
-- телепорт к рыбаку (а не в центр озера)
local function tpToFisherman()
	local fm
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("Model") and d.Name == "Fisherman" then fm = d; break end
	end
	if fm then
		local pp = fm:FindFirstChild("HumanoidRootPart") or fm.PrimaryPart or fm:FindFirstChildWhichIsA("BasePart")
		local hrp = getHRP()
		if pp and hrp then
			if (hrp.Position - pp.Position).Magnitude > 12 then  -- не телепортим если уже рядом
				hrp.CFrame = CFrame.new(pp.Position + Vector3.new(0, 3, 5))
			end
			return true
		end
	end
	-- запасной вариант: POI Lake
	for _, poi in ipairs(API.getPOIs()) do
		if poi.name == "Lake" then teleport(poi.position); return true end
	end
	return false
end

-- авто-reel: ведём управляемую игроком зону Zone на цель-рыбу Fish.
-- Механика игры (FishingRodClient.runReelMinigame): зажал ЛКМ -> Zone ускоряется
-- вправо (+3.0), отпустил -> влево (-1.4), с демпфированием. Fish блуждает сама.
-- Поимка: центр Fish внутри Zone (|fish-zone| <= ширина Zone/2). Прогресс = MeterFill.
do
	local holding = false
	local prevZ, prevT = nil, nil
	-- центр элемента в пикселях (Zone/Fish имеют AnchorPoint 0.5 -> это их позиция)
	local function cx(el) return el.AbsolutePosition.X + el.AbsoluteSize.X * 0.5 end
	local function findReel()
		local gui = PlayerGui:FindFirstChild("FishingReelGui")
		if not gui then return nil end
		local cb = gui:FindFirstChild("CatchBar", true)
		if not cb then return nil end
		local zone = cb:FindFirstChild("Zone")   -- управляемая игроком (двигаем мы)
		local fish = cb:FindFirstChild("Fish")   -- цель (двигается сама)
		if zone and fish and zone.AbsoluteSize.X > 0 and fish.AbsoluteSize.X > 0 then
			return zone, fish
		end
		return nil
	end
	RunService.Heartbeat:Connect(function()
		if not Config.autoFish then
			if holding then mouseRelease(); holding=false end
			prevZ = nil; return
		end
		local zone, fish = findReel()
		if not (zone and fish) then
			if holding then mouseRelease(); holding=false end
			prevZ = nil; return
		end
		local zC   = cx(zone)
		local fC   = cx(fish)
		local now  = os.clock()
		-- оценка скорости зоны (px/с) для упреждения и гашения инерции
		local vel = 0
		if prevZ and prevT and now > prevT then vel = (zC - prevZ) / (now - prevT) end
		prevZ, prevT = zC, now
		-- упреждение: куда зона придёт через LEAD сек при текущей скорости
		local LEAD = 0.09
		local future = zC + vel * LEAD
		-- bang-bang по упреждённой позиции: левее цели -> зажать (вправо), иначе отпустить
		if future < fC then
			if not holding then mousePress(); holding=true end
		else
			if holding then mouseRelease(); holding=false end
		end
	end)
end

task.spawn(function()
	while ScreenGui.Parent do
		if Config.autoFish then
			-- сломанные удочки -> выставить в магазин (не чинятся)
			if Config.fishBrokenSell then
				local inv = API.getSellable()
				local broken = {}
				for guid, e in pairs(inv) do
					local def = Items and Items[tostring(e.ItemId)]
					if def and (def.Category=="Tool" or (def.Name or ""):lower():find("rod")) and (e.Condition or 100) <= 1 then
						table.insert(broken, guid)
					end
				end
				if #broken > 0 then API.sell(broken) end
			end
			if not equipRod() then task.wait(2)
			else
				tpToFisherman()  -- к рыбаку, не в центр озера; не спамит если уже рядом
				task.wait(0.5)
				-- уже идёт миниигра? тогда не забрасываем повторно
				local reeling = PlayerGui:FindFirstChild("FishingReelGui") ~= nil
				if not reeling then
					local water, point = getCastTarget()
					local cast = ev("Misc.FishingCast")
					if cast and water and point then
						pcall(function() cast:FireServer(water, point) end)  -- сигнатура: (вода, точка)
					end
				end
				task.wait(3)
			end
		else
			task.wait(1)
		end
	end
end)

-- ========== АВТО-СБОР LOST & FOUND (умный: тачка рядом, вес/выгрузка/продажа) ==========
-- (unloadVehicleSmart и nudgeVehicleTo объявлены выше, рядом с API-хелперами тачки)
do
	local failCount = {}  -- [item]=неудачные попытки

	task.spawn(function()
		while ScreenGui.Parent do
			if not Config.autoCollectLost then task.wait(1.5); continue end
			local hrp = getHRP()
			local folder = Workspace:FindFirstChild("_LostItems", true)
			if not (hrp and folder) then task.wait(3); continue end
			-- только НАШИ предметы (Owner == наш UserId), у которых ещё не исчерпан лимит попыток
			local mine = {}
			for _, item in ipairs(folder:GetChildren()) do
				if item:IsA("Model")
					and (item:GetAttribute("Owner") == LocalPlayer.UserId or item:GetAttribute("LostOwnerId") == LocalPlayer.UserId)
					and (failCount[item] or 0) < 3 then
					mine[#mine+1] = item
				end
			end
			if #mine == 0 then task.wait(4); continue end
			API.ensureVehicle()  -- спавним тачку ОДИН раз (с учётом кулдауна), не спамим
			local consecFails = 0
			for _, item in ipairs(mine) do
				if not Config.autoCollectLost then break end
				if item.Parent then
					-- переполнение тачки/инвентаря ИЛИ подряд неудачи -> выгрузить/продать
					local _, _, full = API.vehicleCargo()
					if full or consecFails >= 3 then
						unloadVehicleSmart(Config.lostSell); consecFails = 0
						API.ensureVehicle()
					end
					local prompt
					for _, d in ipairs(item:GetDescendants()) do
						if d:IsA("ProximityPrompt") and d.ActionText == "Add to Vehicle" then prompt = d; break end
					end
					local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
					if prompt and part then
						hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
						task.wait(0.35)
						nudgeVehicleTo(part.Position)  -- подгоняем тачку вплотную
						task.wait(0.45)
						pcall(function() fireproximityprompt(prompt) end)
						task.wait(0.55)
						if item.Parent then
							failCount[item] = (failCount[item] or 0) + 1
							consecFails = consecFails + 1
						else
							consecFails = 0
						end
					else
						failCount[item] = (failCount[item] or 0) + 1
					end
				end
			end
			task.wait(1.5)
		end
	end)
end

-- ========== ДВИЖЕНИЕ: Fly / WalkSpeed / Jump / NoClip / InfJump ==========
local flyConn, flyBV, flyBG
function _G.__VH_setFly(on)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if flyConn then flyConn:Disconnect(); flyConn=nil end
	if flyBV then flyBV:Destroy(); flyBV=nil end
	if flyBG then flyBG:Destroy(); flyBG=nil end
	if not (on and hrp and hum) then return end
	flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1,1,1)*9e9; flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
	flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1,1,1)*9e9; flyBG.P = 9e4; flyBG.Parent = hrp
	flyConn = RunService.RenderStepped:Connect(function()
		if not Config.fly then return end
		local cam = Workspace.CurrentCamera
		local dir = Vector3.zero
		local sp = Config.flySpeed or 60
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
		flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * sp or Vector3.zero)
		flyBG.CFrame = cam.CFrame
	end)
end
function _G.__VH_setWalk(v)
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = v end
end
function _G.__VH_setJump(v)
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.JumpPower = v; hum.UseJumpPower = true end
end
function _G.__VH_setNoclip() end -- noclip обрабатывается циклом ниже

RunService.Stepped:Connect(function()
	if Config.noclip then
		local char = LocalPlayer.Character
		if char then for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
		end end
	end
end)
UserInputService.JumpRequest:Connect(function()
	if Config.infJump then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)
-- применять скорость/прыжок при респавне
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	_G.__VH_setWalk(Config.walkSpeed); _G.__VH_setJump(Config.jumpPower)
	if Config.fly then _G.__VH_setFly(true) end
end)

-- ========== ANTI-AFK ==========
do
	local vu = game:GetService("VirtualUser")
	LocalPlayer.Idled:Connect(function()
		if Config.antiAfk then
			pcall(function()
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
	end)
end

-- ========== ESP ==========
local espCache = {}
local function makeEsp(inst, color, label)
	if not inst or espCache[inst] then return end
	local part = inst:IsA("Model") and (inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")) or (inst:IsA("BasePart") and inst)
	if not part then return end
	local hl = Instance.new("Highlight")
	hl.FillColor = color; hl.OutlineColor = Color3.new(1,1,1); hl.FillTransparency = 0.6; hl.OutlineTransparency = 0
	hl.Adornee = inst; hl.Parent = inst
	espCache[inst] = hl
end
local function clearEsp(pred)
	for inst, hl in pairs(espCache) do
		if (not inst.Parent) or pred(inst) then hl:Destroy(); espCache[inst] = nil end
	end
end
-- один проход ESP (вызывается циклом и мгновенно из тогглов)
local function espPass()
	-- игроки
	if Config.espPlayers then
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LocalPlayer and pl.Character then makeEsp(pl.Character, Color3.fromRGB(90,160,255)) end
		end
	else clearEsp(function(i) return i:IsA("Model") and Players:GetPlayerFromCharacter(i) ~= nil end) end
	-- контейнеры (гаражи)
	if Config.espContainers then
		local gf = Workspace:FindFirstChild("_Debris"); gf = gf and gf:FindFirstChild("Garages")
		if gf then for _, g in ipairs(gf:GetChildren()) do makeEsp(g, Color3.fromRGB(120,255,140)) end end
	else clearEsp(function(i) return i.Parent and i.Parent.Name=="Garages" end) end
	-- NPC
	if Config.espNpc then
		local nf = Workspace:FindFirstChild("Mall - Shop NPCs")
		if nf then for _, n in ipairs(nf:GetDescendants()) do if n:IsA("Model") and n:FindFirstChildOfClass("Humanoid") then makeEsp(n, Color3.fromRGB(255,200,80)) end end end
	else clearEsp(function(i) return i:IsA("Model") and i:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(i) and i.Parent and i.Parent.Name=="Mall - Shop NPCs" end) end
end
-- мгновенное применение при переключении тоггла ESP
function _G.__VH_refreshEsp()
	pcall(espPass)
end
task.spawn(function()
	while ScreenGui.Parent do
		pcall(espPass)
		task.wait(1)
	end
end)

-- ========== AUTO-QUEST ==========
task.spawn(function()
	local questEv = Events:FindFirstChild("Quest")
	while ScreenGui.Parent do
		if Config.autoQuest then
			-- ищем NPC с восклицательным знаком (доступен квест) и общаемся
			local target = Config.questNpc
			local function npcMatches(name) return (target=="Все" or target=="All" or target=="Todos") or name==target end
			local function tryNpc(npcModel)
				if not npcModel then return end
				local hrp = getHRP()
				local pp = npcModel:FindFirstChild("HumanoidRootPart") or npcModel.PrimaryPart
				if hrp and pp then
					hrp.CFrame = CFrame.new(pp.Position + Vector3.new(2,0,0))
					task.wait(0.4)
					for _, d in ipairs(npcModel:GetDescendants()) do
						if d:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(d) end); break end
					end
					task.wait(0.6)
					-- подтвердить диалог квеста (принять/сдать)
					local sq = ev("UI.SendQuestDialogResult")
					if sq then pcall(function() sq:FireServer(true) end) end
				end
			end
			-- собрать NPC
			local nf = Workspace:FindFirstChild("Mall - Shop NPCs")
			local qf = nf and nf:FindFirstChild("Quest NPC")
			if qf then for _, n in ipairs(qf:GetChildren()) do
				if Config.autoQuest and npcMatches(n.Name) then tryNpc(n) end
			end end
			for _, area in ipairs({"Junk Yard","Back Alley","Farmyard","Shipyard"}) do
				local a = Workspace.Areas and Workspace.Areas:FindFirstChild(area)
				if a then for _, npc in ipairs({"Billy","Sal","Ted","Steve"}) do
					local n = a:FindFirstChild(npc)
					if n and Config.autoQuest and npcMatches(npc) then tryNpc(n) end
				end end
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
-- ПОИСК ФУНКЦИЙ (рядом с языком в topBar)
---------------------------------------------------------------------
do
	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.fromOffset(150, 30)
	searchBox.Position = UDim2.new(1, -236, 0.5, 0)
	searchBox.AnchorPoint = Vector2.new(0, 0.5)
	searchBox.BackgroundColor3 = Theme.Surface
	searchBox.Text = ""
	searchBox.PlaceholderText = (Locale=="ru" and "Поиск" or (Locale=="es" and "Buscar" or "Search"))
	searchBox.PlaceholderColor3 = Theme.SubText
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 12
	searchBox.TextColor3 = Theme.Text
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = topBar
	corner(searchBox, 8); stroke(searchBox, Theme.Stroke, 1, 0.3)
	local sbp = Instance.new("UIPadding"); sbp.PaddingLeft=UDim.new(0,26); sbp.PaddingRight=UDim.new(0,8); sbp.Parent=searchBox
		-- ВЕКТОРНАЯ ЛУПА в topBar (НЕ внутри searchBox, иначе UIPadding её сдвигает на текст)
		local lens = Instance.new("Frame")
		lens.Size = UDim2.fromOffset(10, 10)
		lens.Position = UDim2.new(1, -236 + 9, 0.5, -1)  -- у левого края поля
		lens.AnchorPoint = Vector2.new(0, 0.5)
		lens.BackgroundTransparency = 1
		lens.ZIndex = 3
		lens.Parent = topBar
		stroke(lens, Theme.SubText, 1.5, 0); corner(lens, 5)
		local handle = Instance.new("Frame")
		handle.Size = UDim2.fromOffset(4, 1.5)
		handle.AnchorPoint = Vector2.new(0, 0.5)
		handle.Position = UDim2.new(1, 0, 1, 0)
		handle.Rotation = 45
		handle.BackgroundColor3 = Theme.SubText
		handle.BorderSizePixel = 0
		handle.ZIndex = 3
		handle.Parent = lens

	-- текст искомого элемента: кнопка -> её текст; иначе первый осмысленный TextLabel (слева)
	local function nodeText(node)
		if node:IsA("TextButton") and node.Text ~= "" then return node.Text end
		for _, d in ipairs(node:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text ~= "" and d.Name ~= "Header" and d.TextXAlignment == Enum.TextXAlignment.Left then
				return d.Text
			end
		end
		return nil
	end
	-- индекс модулей/тогглов/кнопок + хэйстек из всех языков (умный поиск независимо от текущего языка)
	local searchIndex = {}
	for tabName, pg in pairs(pages) do
		for _, sec in ipairs(pg:GetChildren()) do
			if sec:IsA("Frame") then
				for _, child in ipairs(sec:GetChildren()) do
					if child:IsA("Frame") or child:IsA("TextButton") then
						local txt = nodeText(child)
						if txt then
							-- хэйстек: видимый текст + перевод вкладки во всех языках
							local hay = txt:lower().." "
							for _, lng in ipairs({"ru","en","es"}) do
								local tl = L[lng]
								if tl then hay = hay..(tl["tab_"..tabName] or "").." " end
							end
							searchIndex[#searchIndex+1] = {tab=tabName, node=child, sec=sec, hay=hay:lower()}
						end
					end
				end
			end
		end
	end

	-- совпадение: каждое слово запроса должно встретиться где-то в хэйстеке (порядок не важен)
	local function matches(hay, words)
		for _, w in ipairs(words) do
			if not hay:find(w, 1, true) then return false end
		end
		return true
	end

	local function doSearch(q)
		q = (q or ""):lower():gsub("^%s+",""):gsub("%s+$","")
		if q == "" then
			for _, e in ipairs(searchIndex) do e.node.Visible = true; e.sec.Visible = true end
			return
		end
		-- разбиваем запрос на слова
		local words = {}
		for w in q:gmatch("%S+") do words[#words+1] = w end
		local secHas, tabHas, firstTab = {}, {}, nil
		for _, e in ipairs(searchIndex) do
			local m = matches(e.hay, words)
			e.node.Visible = m
			if m then
				secHas[e.sec] = true
				tabHas[e.tab] = true
				if not firstTab then firstTab = e.tab end
			end
		end
		for _, e in ipairs(searchIndex) do e.sec.Visible = (secHas[e.sec] == true) end
		-- прыгаем на вкладку с совпадением только если на текущей ничего не нашлось
		if firstTab and not tabHas[currentTab] then selectTab(firstTab) end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(function() doSearch(searchBox.Text) end)
end

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

	-- мгновенное скрытие/показ панели при переключении тоггла
	function _G.__VH_setPred(v) pred.Visible = (v ~= false) end

	task.spawn(function()
		while ScreenGui.Parent do
			pred.Visible = (Config.predictEnable ~= false)
			if pred.Visible then
				local anyShown = false
				ptitle.Text = T("predictions")
				for _, name in ipairs(eventNames) do
					local row = rows[name]
					local startTs
					pcall(function() if SEM then startTs = SEM:GetNextEventStart(name) end end)
					if row then
						local n = startTs and tonumber(startTs)
						if n and (n - os.time()) > -5 and (n - os.time()) < 86400 then
							-- показываем только то, что реально предсказуемо
							local left = math.floor(n - os.time())
							row.Visible = true; anyShown = true
							if left <= 0 then
								row.Text = "● "..name..": "..T("ev_active"); row.TextColor3 = Theme.Success
							else
								row.Text = string.format("%s: %d:%02d", name, math.floor(left/60), left%60); row.TextColor3 = Theme.SubText
							end
						else
							row.Visible = false  -- непредсказуемый эвент скрываем
						end
					end
				end
				if not anyShown then ptitle.Text = T("predictions").." —" end
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
