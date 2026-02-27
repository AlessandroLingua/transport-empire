# res://scripts/managers/game_manager.gd
extends Node

# ── AZIENDA ──
var company_name: String = "TransLogic"
var cash: int = 500000
var ceo_level: int = 1
var ceo_xp: int = 0
var reputation: float = 50.0

# ── FLOTTA ──
var owned_vehicles: Array = []
var max_vehicles: int = 5

# ── TERMINALI ──
var owned_terminals: Array = []
var MAX_DELIVERY_DISTANCE_KM: int = 350

# ── Catalogo terminali ──
var terminal_catalog: Array = [
	{"id": "torino",     "city": "Torino",      "country": "IT", "lon": 7.68,  "lat": 45.07, "price": 0,       "capacity": 5,  "unlock_level": 1},
	{"id": "milano",     "city": "Milano",      "country": "IT", "lon": 9.19,  "lat": 45.46, "price": 120000,  "capacity": 8,  "unlock_level": 2},
	{"id": "genova",     "city": "Genova",      "country": "IT", "lon": 8.93,  "lat": 44.41, "price": 110000,  "capacity": 6,  "unlock_level": 2},
	{"id": "lione",      "city": "Lione",       "country": "FR", "lon": 4.83,  "lat": 45.76, "price": 140000,  "capacity": 8,  "unlock_level": 3},
	{"id": "marsiglia",  "city": "Marsiglia",   "country": "FR", "lon": 5.37,  "lat": 43.30, "price": 130000,  "capacity": 8,  "unlock_level": 3},
	{"id": "firenze",    "city": "Firenze",     "country": "IT", "lon": 11.25, "lat": 43.77, "price": 125000,  "capacity": 6,  "unlock_level": 3},
	{"id": "venezia",    "city": "Venezia",     "country": "IT", "lon": 12.34, "lat": 45.44, "price": 115000,  "capacity": 6,  "unlock_level": 3},
	{"id": "bologna",    "city": "Bologna",     "country": "IT", "lon": 11.34, "lat": 44.49, "price": 115000,  "capacity": 6,  "unlock_level": 3},
	{"id": "nizza",      "city": "Nizza",       "country": "FR", "lon": 7.26,  "lat": 43.70, "price": 135000,  "capacity": 6,  "unlock_level": 4},
	{"id": "monaco_di_b","city": "Monaco",      "country": "DE", "lon": 11.58, "lat": 48.14, "price": 170000,  "capacity": 10, "unlock_level": 4},
	{"id": "lubiana",    "city": "Lubiana",     "country": "SI", "lon": 14.51, "lat": 46.06, "price": 100000,  "capacity": 6,  "unlock_level": 4},
	{"id": "innsbruck",  "city": "Innsbruck",   "country": "AT", "lon": 11.39, "lat": 47.26, "price": 120000,  "capacity": 6,  "unlock_level": 4},
	{"id": "zurigo",     "city": "Zurigo",      "country": "CH", "lon": 8.54,  "lat": 47.38, "price": 200000,  "capacity": 8,  "unlock_level": 5},
	{"id": "berna",      "city": "Berna",       "country": "CH", "lon": 7.45,  "lat": 46.95, "price": 180000,  "capacity": 6,  "unlock_level": 5},
	{"id": "stoccarda",  "city": "Stoccarda",   "country": "DE", "lon": 9.18,  "lat": 48.78, "price": 155000,  "capacity": 8,  "unlock_level": 5},
	{"id": "roma",       "city": "Roma",        "country": "IT", "lon": 12.50, "lat": 41.90, "price": 150000,  "capacity": 10, "unlock_level": 5},
	{"id": "barcellona", "city": "Barcellona",  "country": "ES", "lon": 2.17,  "lat": 41.39, "price": 160000,  "capacity": 8,  "unlock_level": 6},
	{"id": "napoli",     "city": "Napoli",      "country": "IT", "lon": 14.25, "lat": 40.85, "price": 120000,  "capacity": 8,  "unlock_level": 6},
	{"id": "vienna",     "city": "Vienna",      "country": "AT", "lon": 16.37, "lat": 48.21, "price": 180000,  "capacity": 10, "unlock_level": 7},
	{"id": "parigi",     "city": "Parigi",      "country": "FR", "lon": 2.35,  "lat": 48.86, "price": 250000,  "capacity": 12, "unlock_level": 8},
]

# ── Catalogo veicoli ──
var vehicle_catalog: Array = [
	{"id": "van_basic",    "name": "Porter 100",  "type": "Furgone",       "fuel": "Diesel",    "price": 34000,  "payload_kg": 1000,  "capacity_m3": 8,  "fuel_consumption": 12.0, "speed_kmh": 110, "unlock_level": 1},
	{"id": "van_medium",   "name": "Volaro 200",  "type": "Furgone",       "fuel": "Diesel",    "price": 45000,  "payload_kg": 1500,  "capacity_m3": 12, "fuel_consumption": 14.0, "speed_kmh": 100, "unlock_level": 2},
	{"id": "van_electric", "name": "ePorter 100", "type": "Furgone",       "fuel": "Elettrico", "price": 48000,  "payload_kg": 900,   "capacity_m3": 7,  "fuel_consumption": 25.0, "speed_kmh": 105, "unlock_level": 3},
	{"id": "rigid_basic",  "name": "Creator 350", "type": "Camion Rigido", "fuel": "Diesel",    "price": 85000,  "payload_kg": 5000,  "capacity_m3": 30, "fuel_consumption": 22.0, "speed_kmh": 90,  "unlock_level": 4},
	{"id": "rigid_large",  "name": "Creator 500", "type": "Camion Rigido", "fuel": "Diesel",    "price": 110000, "payload_kg": 8000,  "capacity_m3": 45, "fuel_consumption": 26.0, "speed_kmh": 85,  "unlock_level": 5},
	{"id": "tractor_basic","name": "T-Way 500",   "type": "Trattore",      "fuel": "Diesel",    "price": 120000, "payload_kg": 15000, "capacity_m3": 80, "fuel_consumption": 32.0, "speed_kmh": 85,  "unlock_level": 6},
]

# ── Contratti e consegne ──
var available_contracts: Array = []
var active_deliveries: Array = []
var active_transfers: Array = []

# ── Segnali ──
signal cash_changed(new_amount)
signal vehicle_purchased(vehicle)
signal delivery_completed(delivery)
signal transfer_completed(transfer)
signal ceo_level_up(new_level)
signal contract_accepted(contract)
signal terminal_purchased(terminal)

func _ready():
	if owned_terminals.size() == 0:
		owned_terminals.append("torino")
	if not load_game():
		generate_contracts()

# ══════════ CASH ══════════

func add_cash(amount: int):
	cash += amount
	cash_changed.emit(cash)

func remove_cash(amount: int) -> bool:
	if cash >= amount:
		cash -= amount
		cash_changed.emit(cash)
		return true
	return false

# ══════════ TERMINALI ══════════

func get_terminal(tid: String) -> Dictionary:
	for t in terminal_catalog:
		if t.id == tid:
			return t
	return {}

func get_owned_terminal_list() -> Array:
	var r = []
	for tid in owned_terminals:
		var d = get_terminal(tid)
		if d.size() > 0:
			r.append(d)
	return r

func vehicles_at(tid: String) -> Array:
	var r = []
	for v in owned_vehicles:
		if v.get("terminal_id", "") == tid and v.status == "parked":
			r.append(v)
	return r

func count_at(tid: String) -> int:
	var c = 0
	for v in owned_vehicles:
		if v.get("terminal_id", "") == tid:
			c += 1
	return c

func capacity_of(tid: String) -> int:
	return get_terminal(tid).get("capacity", 0)

func buy_terminal(tid: String) -> bool:
	if tid in owned_terminals:
		return false
	var d = get_terminal(tid)
	if d.size() == 0 or d.unlock_level > ceo_level or cash < d.price:
		return false
	remove_cash(d.price)
	owned_terminals.append(tid)
	terminal_purchased.emit(d)
	add_ceo_xp(100)
	generate_contracts()
	return true

# ══════════ DISTANZE ══════════

func dist_between(tid_a: String, tid_b: String) -> int:
	var a = get_terminal(tid_a)
	var b = get_terminal(tid_b)
	if a.size() == 0 or b.size() == 0:
		return 99999
	return haversine(a.lat, a.lon, b.lat, b.lon)

func haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> int:
	var R = 6371.0
	var dlat = deg_to_rad(lat2 - lat1)
	var dlon = deg_to_rad(lon2 - lon1)
	var a = sin(dlat / 2) * sin(dlat / 2) + cos(deg_to_rad(lat1)) * cos(deg_to_rad(lat2)) * sin(dlon / 2) * sin(dlon / 2)
	var c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
	return int(R * c * 1.3)

func reachable_terminals(tid: String) -> Array:
	var r = []
	for other in owned_terminals:
		if other == tid:
			continue
		var d = dist_between(tid, other)
		if d <= MAX_DELIVERY_DISTANCE_KM:
			r.append({"id": other, "distance_km": d})
	return r

# ══════════ VEICOLI ══════════

func buy_vehicle(cat_idx: int, tid: String) -> bool:
	var m = vehicle_catalog[cat_idx]
	if cash < m.price or owned_vehicles.size() >= max_vehicles:
		return false
	if m.unlock_level > ceo_level or tid not in owned_terminals:
		return false
	if count_at(tid) >= capacity_of(tid):
		return false
	remove_cash(m.price)
	var v = m.duplicate()
	v["reg"] = _reg()
	v["odometer_km"] = 0
	v["wear"] = 0.0
	v["status"] = "parked"
	v["terminal_id"] = tid
	owned_vehicles.append(v)
	vehicle_purchased.emit(v)
	add_ceo_xp(50)
	return true

func _reg() -> String:
	var L = "ABCDEFGHJKLMNPRSTUVWXYZ"
	var r = ""
	for i in 3:
		r += L[randi() % L.length()]
	for i in 4:
		r += str(randi() % 10)
	return r

func get_available_vehicles() -> Array:
	var r = []
	for v in owned_vehicles:
		if v.status == "parked":
			r.append(v)
	return r

# ══════════ TRASFERIMENTI ══════════

func start_transfer(veh_idx: int, dest_tid: String) -> bool:
	if veh_idx >= owned_vehicles.size():
		return false
	var v = owned_vehicles[veh_idx]
	if v.status != "parked" or dest_tid not in owned_terminals or v.terminal_id == dest_tid:
		return false
	var d = dist_between(v.terminal_id, dest_tid)
	var secs = d / 70.0 * 60.0
	var tr = {
		"vehicle": v,
		"from_terminal": v.terminal_id,
		"to_terminal": dest_tid,
		"distance_km": d,
		"time_total": secs,
		"time_remaining": secs,
	}
	v.status = "in_transit"
	active_transfers.append(tr)
	return true

# ══════════ CONTRATTI ══════════

func generate_contracts():
	available_contracts.clear()
	var pairs = []
	for i in range(owned_terminals.size()):
		for j in range(i + 1, owned_terminals.size()):
			var d = dist_between(owned_terminals[i], owned_terminals[j])
			if d <= MAX_DELIVERY_DISTANCE_KM:
				pairs.append([owned_terminals[i], owned_terminals[j], d])
	if pairs.size() == 0:
		for i in 3:
			var tid = owned_terminals[randi() % owned_terminals.size()]
			var td = get_terminal(tid)
			available_contracts.append({
				"id": "loc_" + str(randi()),
				"origin_terminal": tid, "origin": td.city,
				"dest_terminal": tid, "destination": td.city + " (locale)",
				"distance_km": (randi() % 50) + 20,
				"weight_kg": (randi() % 2000) + 500,
				"payout": (randi() % 3000) + 1500,
				"cargo_type": ["Secco", "Refrigerato"][randi() % 2],
				"time_hours": 0.5 + randf() * 1.0,
			})
		return
	var n = mini(pairs.size() * 2 + 2, 8)
	for i in range(n):
		var p = pairs[randi() % pairs.size()]
		var from_id = p[0] if randi() % 2 == 0 else p[1]
		var to_id = p[1] if from_id == p[0] else p[0]
		var fd = get_terminal(from_id)
		var td = get_terminal(to_id)
		var w = (randi() % 4000) + 500
		var pay = int(p[2] * randf_range(1.8, 3.5) + w * 0.3)
		available_contracts.append({
			"id": "c_" + str(i) + "_" + str(randi()),
			"origin_terminal": from_id, "origin": fd.city,
			"dest_terminal": to_id, "destination": td.city,
			"distance_km": p[2], "weight_kg": w, "payout": pay,
			"cargo_type": ["Secco", "Secco", "Refrigerato"][randi() % 3],
			"time_hours": p[2] / 70.0,
		})

func accept_contract(ci: int, vi: int) -> bool:
	if ci >= available_contracts.size() or vi >= owned_vehicles.size():
		return false
	var c = available_contracts[ci]
	var v = owned_vehicles[vi]
	if v.status != "parked" or v.terminal_id != c.origin_terminal:
		return false
	var fc = int(c.distance_km * v.fuel_consumption / 100.0 * 1.4)
	var dl = {
		"contract": c, "vehicle": v,
		"time_total": c.time_hours * 60.0,
		"time_remaining": c.time_hours * 60.0,
		"fuel_cost": fc,
	}
	v.status = "in_transit"
	active_deliveries.append(dl)
	available_contracts.remove_at(ci)
	contract_accepted.emit(c)
	return true

# ══════════ PROCESS ══════════

func _process(delta):
	var done_d = []
	for i in range(active_deliveries.size()):
		active_deliveries[i].time_remaining -= delta
		if active_deliveries[i].time_remaining <= 0:
			done_d.append(i)
	done_d.reverse()
	for i in done_d:
		_finish_delivery(i)
	var done_t = []
	for i in range(active_transfers.size()):
		active_transfers[i].time_remaining -= delta
		if active_transfers[i].time_remaining <= 0:
			done_t.append(i)
	done_t.reverse()
	for i in done_t:
		_finish_transfer(i)
	if available_contracts.size() < 3:
		generate_contracts()

func _finish_delivery(i: int):
	var d = active_deliveries[i]
	add_cash(d.contract.payout - d.fuel_cost)
	d.vehicle.status = "parked"
	d.vehicle.terminal_id = d.contract.dest_terminal
	d.vehicle.odometer_km += d.contract.distance_km
	d.vehicle.wear += randf_range(0.5, 2.0)
	add_ceo_xp(int(d.contract.payout / 100))
	delivery_completed.emit(d)
	active_deliveries.remove_at(i)

func _finish_transfer(i: int):
	var t = active_transfers[i]
	t.vehicle.status = "parked"
	t.vehicle.terminal_id = t.to_terminal
	t.vehicle.odometer_km += t.distance_km
	t.vehicle.wear += randf_range(0.2, 0.8)
	transfer_completed.emit(t)
	active_transfers.remove_at(i)

# ══════════ CEO XP ══════════

func xp_for_level(lv: int) -> int:
	return int(500 * pow(1.5, lv - 1))

func add_ceo_xp(amount: int):
	ceo_xp += amount
	while ceo_xp >= xp_for_level(ceo_level):
		ceo_xp -= xp_for_level(ceo_level)
		ceo_level += 1
		max_vehicles = 5 + ceo_level * 2
		ceo_level_up.emit(ceo_level)

# ══════════ SAVE/LOAD ══════════

func save_game():
	var d = {"company_name": company_name, "cash": cash, "ceo_level": ceo_level,
		"ceo_xp": ceo_xp, "reputation": reputation, "owned_vehicles": owned_vehicles,
		"max_vehicles": max_vehicles, "owned_terminals": owned_terminals}
	var f = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(d))

func load_game() -> bool:
	if not FileAccess.file_exists("user://savegame.json"):
		return false
	var f = FileAccess.open("user://savegame.json", FileAccess.READ)
	var j = JSON.new()
	if j.parse(f.get_as_text()) != OK:
		return false
	var d = j.data
	company_name = d.get("company_name", "TransLogic")
	cash = d.get("cash", 500000)
	ceo_level = d.get("ceo_level", 1)
	ceo_xp = d.get("ceo_xp", 0)
	reputation = d.get("reputation", 50.0)
	owned_vehicles = d.get("owned_vehicles", [])
	max_vehicles = d.get("max_vehicles", 5)
	owned_terminals = d.get("owned_terminals", ["torino"])
	generate_contracts()
	return true
