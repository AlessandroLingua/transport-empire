# res://scripts/game_manager.gd
extends Node

# DATI AZIENDA
var company_name: String = "TransLogic"
var company_city: String = "Turin"
var company_country: String = "IT"
var cash: int = 500000
var ceo_level: int = 1
var ceo_xp: int = 0
var reputation: float = 50.0


# FLOTTA
var owned_vehicles: Array = []
var max_vehicles: int = 5


# CATALOGO VEICOLI (dati di gioco)
var vehicle_catalog: Array = [
	{
		"id": "van_basic",
		"name": "Porter 100",
		"type": "Furgone",
		"fuel": "Diesel",
		"price": 34000,
		"payload_kg": 1000,
		"capacity_m3": 8,
		"fuel_consumption": 12.0,
		"speed_kmh": 110,
		"icon": "🚐",
		"unlock_level": 1
	},
	{
		"id": "van_medium",
		"name": "Volaro 200",
		"type": "Furgone",
		"fuel": "Diesel",
		"price": 45000,
		"payload_kg": 1500,
		"capacity_m3": 12,
		"fuel_consumption": 14.0,
		"speed_kmh": 100,
		"icon": "🚐",
		"unlock_level": 2
	},
	{
		"id": "rigid_basic",
		"name": "Creator 350",
		"type": "Camion Rigido",
		"fuel": "Diesel",
		"price": 85000,
		"payload_kg": 5000,
		"capacity_m3": 30,
		"fuel_consumption": 22.0,
		"speed_kmh": 90,
		"icon": "🚚",
		"unlock_level": 4
	},
	{
		"id": "tractor_basic",
		"name": "T-Way 500",
		"type": "Trattore",
		"fuel": "Diesel",
		"price": 120000,
		"payload_kg": 15000,
		"capacity_m3": 80,
		"fuel_consumption": 32.0,
		"speed_kmh": 85,
		"icon": "🚛",
		"unlock_level": 6
	},
	{
		"id": "van_electric",
		"name": "ePorter 100",
		"type": "Furgone",
		"fuel": "Elettrico",
		"price": 48000,
		"payload_kg": 900,
		"capacity_m3": 7,
		"fuel_consumption": 25.0,
		"speed_kmh": 105,
		"icon": "⚡🚐",
		"unlock_level": 3
	},
]


# CITTÀ E DISTANZE
var cities: Array = [
	{"name": "Torino", "country": "IT", "x": 550, "y": 350},
	{"name": "Milano", "country": "IT", "x": 580, "y": 320},
	{"name": "Roma", "country": "IT", "x": 620, "y": 480},
	{"name": "Lione", "country": "FR", "x": 440, "y": 310},
	{"name": "Barcellona", "country": "ES", "x": 320, "y": 480},
	{"name": "Monaco", "country": "DE", "x": 620, "y": 230},
	{"name": "Vienna", "country": "AT", "x": 730, "y": 230},
	{"name": "Lubiana", "country": "SI", "x": 710, "y": 300},
	{"name": "Marsiglia", "country": "FR", "x": 430, "y": 410},
	{"name": "Zurigo", "country": "CH", "x": 530, "y": 260},
]


# CONTRATTI ATTIVI E CONSEGNE
var available_contracts: Array = []
var active_deliveries: Array = []


# SEGNALI (events)
signal cash_changed(new_amount)
signal vehicle_purchased(vehicle)
signal delivery_completed(delivery)
signal ceo_level_up(new_level)
signal contract_accepted(contract)


# FUNZIONI
func _ready():
	generate_contracts()

func add_cash(amount: int):
	cash += amount
	cash_changed.emit(cash)

func remove_cash(amount: int) -> bool:
	if cash >= amount:
		cash -= amount
		cash_changed.emit(cash)
		return true
	return false

func buy_vehicle(catalog_index: int) -> bool:
	var model = vehicle_catalog[catalog_index]
	if cash < model.price:
		return false
	if owned_vehicles.size() >= max_vehicles:
		return false
	if model.unlock_level > ceo_level:
		return false

	remove_cash(model.price)

	var vehicle = model.duplicate()
	vehicle["reg"] = generate_registration()
	vehicle["odometer_km"] = 0
	vehicle["wear"] = 0.0
	vehicle["status"] = "parked"  # parked, in_transit, maintenance
	vehicle["purchased_at"] = Time.get_datetime_string_from_system()

	owned_vehicles.append(vehicle)
	vehicle_purchased.emit(vehicle)
	add_ceo_xp(50)  # XP per acquisto
	return true

func generate_registration() -> String:
	var letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
	var reg = ""
	for i in range(3):
		reg += letters[randi() % letters.length()]
	reg += str(randi() % 10) + str(randi() % 10) + str(randi() % 10) + str(randi() % 10)
	return reg

func get_available_vehicles() -> Array:
	var available = []
	for v in owned_vehicles:
		if v.status == "parked":
			available.append(v)
	return available


# CONTRATTI
func generate_contracts():
	available_contracts.clear()
	for i in range(5):
		var origin = cities[randi() % cities.size()]
		var destination = cities[randi() % cities.size()]
		while destination.name == origin.name:
			destination = cities[randi() % cities.size()]

		var distance = calculate_distance(origin, destination)
		var weight = (randi() % 3000) + 500
		var pay_per_km = randf_range(1.5, 3.0)
		var payout = int(distance * pay_per_km + weight * 0.5)

		var contract = {
			"id": "contract_" + str(i) + "_" + str(randi()),
			"origin": origin.name,
			"origin_country": origin.country,
			"destination": destination.name,
			"dest_country": destination.country,
			"distance_km": distance,
			"weight_kg": weight,
			"payout": payout,
			"cargo_type": ["Secco", "Secco", "Secco", "Refrigerato"][randi() % 4],
			"time_hours": distance / 70.0,  # ~70 km/h media
			"status": "available"
		}
		available_contracts.append(contract)

func calculate_distance(city_a: Dictionary, city_b: Dictionary) -> int:
	var dx = city_a.x - city_b.x
	var dy = city_a.y - city_b.y
	# Scala: 1 pixel ≈ 3 km (approssimativo per la mappa europea)
	return int(sqrt(dx * dx + dy * dy) * 3)

func accept_contract(contract_index: int, vehicle_index: int) -> bool:
	if contract_index >= available_contracts.size():
		return false
	if vehicle_index >= owned_vehicles.size():
		return false

	var contract = available_contracts[contract_index]
	var vehicle = owned_vehicles[vehicle_index]

	if vehicle.status != "parked":
		return false

	# Crea la consegna
	var delivery = {
		"contract": contract,
		"vehicle": vehicle,
		"time_total": contract.time_hours * 60.0,  # converti in secondi di gioco
		"time_remaining": contract.time_hours * 60.0,
		"fuel_cost": int(contract.distance_km * vehicle.fuel_consumption / 100.0 * 1.4),
		"started_at": Time.get_ticks_msec() / 1000.0
	}

	vehicle.status = "in_transit"
	contract.status = "in_progress"
	active_deliveries.append(delivery)
	available_contracts.remove_at(contract_index)
	contract_accepted.emit(contract)
	return true

func _process(delta):
	# Aggiorna consegne attive
	var completed = []
	for i in range(active_deliveries.size()):
		var d = active_deliveries[i]
		d.time_remaining -= delta
		if d.time_remaining <= 0:
			completed.append(i)

	# Completa le consegne (in ordine inverso per non sballare gli indici)
	completed.reverse()
	for i in completed:
		complete_delivery(i)

	# Rigenera contratti se ce ne sono pochi
	if available_contracts.size() < 3:
		generate_contracts()

func complete_delivery(index: int):
	var delivery = active_deliveries[index]
	var payout = delivery.contract.payout
	var fuel_cost = delivery.fuel_cost

	# Guadagno netto
	add_cash(payout - fuel_cost)

	# Aggiorna veicolo
	delivery.vehicle.status = "parked"
	delivery.vehicle.odometer_km += delivery.contract.distance_km
	delivery.vehicle.wear += randf_range(0.5, 2.0)

	# XP
	add_ceo_xp(int(payout / 100))

	delivery_completed.emit(delivery)
	active_deliveries.remove_at(index)


# PROGRESSIONE CEO
func xp_for_level(level: int) -> int:
	return int(500 * pow(1.5, level - 1))

func add_ceo_xp(amount: int):
	ceo_xp += amount
	while ceo_xp >= xp_for_level(ceo_level):
		ceo_xp -= xp_for_level(ceo_level)
		ceo_level += 1
		max_vehicles = 5 + ceo_level * 2
		ceo_level_up.emit(ceo_level)


# SALVATAGGIO (per dopo)
func save_game():
	var save_data = {
		"company_name": company_name,
		"cash": cash,
		"ceo_level": ceo_level,
		"ceo_xp": ceo_xp,
		"reputation": reputation,
		"owned_vehicles": owned_vehicles,
		"max_vehicles": max_vehicles,
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func load_game() -> bool:
	if not FileAccess.file_exists("user://savegame.json"):
		return false
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	var data = json.data
	company_name = data.get("company_name", "TransLogic")
	cash = data.get("cash", 500000)
	ceo_level = data.get("ceo_level", 1)
	ceo_xp = data.get("ceo_xp", 0)
	reputation = data.get("reputation", 50.0)
	owned_vehicles = data.get("owned_vehicles", [])
	max_vehicles = data.get("max_vehicles", 5)
	return true
