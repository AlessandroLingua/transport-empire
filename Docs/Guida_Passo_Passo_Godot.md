# Transport Empire — Guida Passo-Passo per Iniziare con Godot 4

## PASSO 1: Scaricare e Installare Godot

1. Vai su **https://godotengine.org/download/**
2. Scarica **Godot Engine - Standard** per il tuo sistema operativo (Windows/macOS/Linux)
   - Su Windows: scarica la versione **64-bit**
   - È un file ZIP, NON richiede installazione
3. Estrai il file ZIP in una cartella a tua scelta (es. `C:\Godot` oppure `Desktop/Godot`)
4. Apri il file `Godot_v4.x-stable_win64.exe` (o equivalente per il tuo OS)
5. Si aprirà il **Project Manager** di Godot

> **NOTA**: Godot è un singolo eseguibile da ~60 MB. Non serve installare nulla!

---

## PASSO 2: Creare il Progetto

1. Nel Project Manager, clicca **"New Project"** (Nuovo Progetto)
2. Imposta:
   - **Project Name**: `TransportEmpire`
   - **Project Path**: scegli una cartella (es. `Documenti/TransportEmpire`)
   - **Renderer**: seleziona **"Compatibility"** (è il più leggero e va bene per un gioco 2D)
3. Clicca **"Create & Edit"**
4. Si aprirà l'editor di Godot

---

## PASSO 3: Capire l'Editor di Godot (5 minuti)

L'editor ha queste aree principali:

```
┌─────────────────────────────────────────────────────────────┐
│                      TOOLBAR (alto)                          │
├──────────┬──────────────────────────────┬───────────────────┤
│  SCENE   │                              │    INSPECTOR      │
│  TREE    │      VIEWPORT                │    (proprietà     │
│  (nodi)  │      (anteprima)             │     del nodo)     │
│          │                              │                   │
├──────────┤                              ├───────────────────┤
│FILESYSTEM│                              │      NODE         │
│(file)    │                              │    (segnali)      │
└──────────┴──────────────────────────────┴───────────────────┘
```

- **Scene Tree** (sinistra alto): i nodi che compongono la scena corrente
- **FileSystem** (sinistra basso): i file del tuo progetto
- **Viewport** (centro): anteprima visuale
- **Inspector** (destra): proprietà del nodo selezionato

---

## PASSO 4: Configurare il Progetto per Mobile

1. Vai su **Project → Project Settings** (menu in alto)
2. Nella tab **General**:
   - Cerca **"window"** nella barra di ricerca
   - **Display → Window → Size → Viewport Width**: `1920`
   - **Display → Window → Size → Viewport Height**: `1080`
   - **Display → Window → Stretch → Mode**: `canvas_items`
   - **Display → Window → Stretch → Aspect**: `expand`
3. Chiudi le impostazioni

---

## PASSO 5: Creare la Struttura Cartelle

Nel pannello **FileSystem** (basso sinistra), fai click destro su `res://` e crea queste cartelle:

```
res://
├── scenes/          ← le scene del gioco
│   ├── ui/          ← componenti UI riutilizzabili
│   └── screens/     ← schermate principali
├── scripts/         ← il codice GDScript
│   ├── data/        ← dati di gioco (veicoli, città, ecc.)
│   └── managers/    ← sistemi di gioco (economia, flotta)
├── assets/          ← immagini, suoni, font
│   ├── icons/       ← icone
│   ├── fonts/       ← font personalizzati
│   └── audio/       ← suoni e musica
└── themes/          ← temi grafici
```

Per creare una cartella: click destro → **Create New → Folder**

---

## PASSO 6: Creare il Tema Grafico (Dark Theme)

1. Click destro su `res://themes/` → **Create New → Resource**
2. Cerca **"Theme"** e selezionalo → salva come `game_theme.tres`
3. Doppio click sul file per aprirlo nell'Inspector
4. Per ora lo lasciamo base e lo personalizzeremo con il codice

In alternativa, creeremo il tema via codice — è più facile per iniziare.

---

## PASSO 7: Creare il Game Manager (Autoload)

Questo è il "cervello" del gioco — gestisce i dati globali come soldi, veicoli, ecc.

1. Vai su `res://scripts/managers/`
2. Click destro → **Create New → Script**
3. Chiamalo `game_manager.gd`
4. Copia questo codice:

```gdscript
# res://scripts/managers/game_manager.gd
extends Node

# ══════════════════════════════════════
# DATI AZIENDA
# ══════════════════════════════════════
var company_name: String = "TransLogic"
var company_city: String = "Turin"
var company_country: String = "IT"
var cash: int = 500000
var ceo_level: int = 1
var ceo_xp: int = 0
var reputation: float = 50.0

# ══════════════════════════════════════
# FLOTTA
# ══════════════════════════════════════
var owned_vehicles: Array = []
var max_vehicles: int = 5

# ══════════════════════════════════════
# CATALOGO VEICOLI (dati di gioco)
# ══════════════════════════════════════
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

# ══════════════════════════════════════
# CITTÀ E DISTANZE
# ══════════════════════════════════════
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

# ══════════════════════════════════════
# CONTRATTI ATTIVI E CONSEGNE
# ══════════════════════════════════════
var available_contracts: Array = []
var active_deliveries: Array = []

# ══════════════════════════════════════
# SEGNALI (events)
# ══════════════════════════════════════
signal cash_changed(new_amount)
signal vehicle_purchased(vehicle)
signal delivery_completed(delivery)
signal ceo_level_up(new_level)
signal contract_accepted(contract)

# ══════════════════════════════════════
# FUNZIONI
# ══════════════════════════════════════

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

# ══════════════════════════════════════
# CONTRATTI
# ══════════════════════════════════════

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

# ══════════════════════════════════════
# PROGRESSIONE CEO
# ══════════════════════════════════════

func xp_for_level(level: int) -> int:
	return int(500 * pow(1.5, level - 1))

func add_ceo_xp(amount: int):
	ceo_xp += amount
	while ceo_xp >= xp_for_level(ceo_level):
		ceo_xp -= xp_for_level(ceo_level)
		ceo_level += 1
		max_vehicles = 5 + ceo_level * 2
		ceo_level_up.emit(ceo_level)

# ══════════════════════════════════════
# SALVATAGGIO (per dopo)
# ══════════════════════════════════════

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
```

5. **IMPORTANTE — Registra come Autoload:**
   - Vai su **Project → Project Settings → Autoload** (tab in alto)
   - Clicca l'icona cartella e seleziona `res://scripts/managers/game_manager.gd`
   - Il nome sarà automaticamente `GameManager`
   - Clicca **Add**
   - Ora `GameManager` è accessibile da qualsiasi script nel gioco!

---

## PASSO 8: Creare la Scena Principale (Main)

1. **Crea una nuova scena**: menu **Scene → New Scene**
2. Clicca **"User Interface"** (crea un nodo Control come root)
3. Rinomina il nodo root in `Main`
4. Salva la scena: **Ctrl+S** → `res://scenes/main.tscn`

### Struttura nodi di Main:

Crea questa gerarchia di nodi (click destro su un nodo → Add Child Node):

```
Main (Control)
├── ColorRect          ← sfondo
├── VBoxContainer      ← layout verticale che contiene tutto
│   ├── TopBar (PanelContainer)
│   │   └── HBoxContainer
│   │       ├── CashLabel (Label)
│   │       ├── Spacer (Control) 
│   │       ├── CompanyLabel (Label)
│   │       ├── Spacer2 (Control)
│   │       └── LevelLabel (Label)
│   ├── ScreenContainer (MarginContainer)
│   │   └── Content (Control)    ← qui appaiono le schermate
│   └── NavBar (PanelContainer)
│       └── HBoxContainer
│           ├── BtnHQ (Button)
│           ├── BtnGarage (Button)
│           └── BtnLogistics (Button)
```

5. Crea lo script per Main: seleziona il nodo `Main` → click icona script (📜) → Create
6. Salva come `res://scripts/main.gd`
7. Copia questo codice:

```gdscript
# res://scripts/main.gd
extends Control

@onready var cash_label = $VBoxContainer/TopBar/HBoxContainer/CashLabel
@onready var company_label = $VBoxContainer/TopBar/HBoxContainer/CompanyLabel
@onready var level_label = $VBoxContainer/TopBar/HBoxContainer/LevelLabel
@onready var content = $VBoxContainer/ScreenContainer/Content
@onready var btn_hq = $VBoxContainer/NavBar/HBoxContainer/BtnHQ
@onready var btn_garage = $VBoxContainer/NavBar/HBoxContainer/BtnGarage
@onready var btn_logistics = $VBoxContainer/NavBar/HBoxContainer/BtnLogistics

# Scene da caricare per ogni schermata
var hq_scene = preload("res://scenes/screens/hq_screen.tscn")
var garage_scene = preload("res://scenes/screens/garage_screen.tscn")
var logistics_scene = preload("res://scenes/screens/logistics_screen.tscn")

var current_screen = null
var current_button = null

func _ready():
	# Colori e stile
	setup_theme()
	
	# Collega segnali bottoni
	btn_hq.pressed.connect(_on_btn_hq_pressed)
	btn_garage.pressed.connect(_on_btn_garage_pressed)
	btn_logistics.pressed.connect(_on_btn_logistics_pressed)
	
	# Collega segnali GameManager
	GameManager.cash_changed.connect(_on_cash_changed)
	GameManager.ceo_level_up.connect(_on_level_up)
	
	# Aggiorna UI iniziale
	update_top_bar()
	
	# Carica schermata iniziale
	switch_screen(hq_scene, btn_hq)

func setup_theme():
	# Sfondo scuro
	var bg = $ColorRect
	bg.color = Color("#0d1117")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Layout
	var vbox = $VBoxContainer
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Stile TopBar
	var top_bar = $VBoxContainer/TopBar
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color("#161b22")
	top_style.border_color = Color("#30363d")
	top_style.border_width_bottom = 1
	top_style.content_margin_left = 16
	top_style.content_margin_right = 16
	top_style.content_margin_top = 10
	top_style.content_margin_bottom = 10
	top_bar.add_theme_stylebox_override("panel", top_style)
	
	# Stile NavBar
	var nav_bar = $VBoxContainer/NavBar
	var nav_style = StyleBoxFlat.new()
	nav_style.bg_color = Color("#161b22")
	nav_style.border_color = Color("#30363d")
	nav_style.border_width_top = 1
	nav_style.content_margin_left = 8
	nav_style.content_margin_right = 8
	nav_style.content_margin_top = 8
	nav_style.content_margin_bottom = 8
	nav_bar.add_theme_stylebox_override("panel", nav_style)
	
	# Label styling
	cash_label.add_theme_color_override("font_color", Color("#2ea043"))
	cash_label.add_theme_font_size_override("font_size", 18)
	company_label.add_theme_color_override("font_color", Color("#e6edf3"))
	company_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color("#58a6ff"))
	level_label.add_theme_font_size_override("font_size", 14)
	
	# Spacer
	$VBoxContainer/TopBar/HBoxContainer/Spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$VBoxContainer/TopBar/HBoxContainer/Spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# ScreenContainer espandibile
	$VBoxContainer/ScreenContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Stile bottoni NavBar
	for btn in [btn_hq, btn_garage, btn_logistics]:
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 14)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#21262d")
		btn_style.border_color = Color("#30363d")
		btn_style.set_border_width_all(1)
		btn_style.set_corner_radius_all(8)
		btn_style.content_margin_top = 10
		btn_style.content_margin_bottom = 10
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color("#8b949e"))
	
	btn_hq.text = "🏢 Sede"
	btn_garage.text = "🚛 Garage"
	btn_logistics.text = "🗺️ Logistica"

func update_top_bar():
	cash_label.text = "💰 $" + format_number(GameManager.cash)
	company_label.text = GameManager.company_name
	level_label.text = "CEO Lv." + str(GameManager.ceo_level)

func format_number(n: int) -> String:
	var s = str(n)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result

func switch_screen(scene: PackedScene, button: Button):
	# Rimuovi schermata corrente
	if current_screen:
		current_screen.queue_free()
	
	# Resetta stile bottone precedente
	if current_button:
		current_button.add_theme_color_override("font_color", Color("#8b949e"))
		var old_style = StyleBoxFlat.new()
		old_style.bg_color = Color("#21262d")
		old_style.border_color = Color("#30363d")
		old_style.set_border_width_all(1)
		old_style.set_corner_radius_all(8)
		old_style.content_margin_top = 10
		old_style.content_margin_bottom = 10
		current_button.add_theme_stylebox_override("normal", old_style)
	
	# Carica nuova schermata
	current_screen = scene.instantiate()
	content.add_child(current_screen)
	
	# Evidenzia bottone attivo
	current_button = button
	button.add_theme_color_override("font_color", Color("#2ea043"))
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color("#2ea04322")
	active_style.border_color = Color("#2ea043")
	active_style.set_border_width_all(1)
	active_style.set_corner_radius_all(8)
	active_style.content_margin_top = 10
	active_style.content_margin_bottom = 10
	button.add_theme_stylebox_override("normal", active_style)

func _on_btn_hq_pressed():
	switch_screen(hq_scene, btn_hq)

func _on_btn_garage_pressed():
	switch_screen(garage_scene, btn_garage)

func _on_btn_logistics_pressed():
	switch_screen(logistics_scene, btn_logistics)

func _on_cash_changed(_amount):
	update_top_bar()

func _on_level_up(_level):
	update_top_bar()
```

---

## PASSO 9: Creare la Schermata Sede (HQ)

1. Crea una nuova scena: **Scene → New Scene → User Interface**
2. Rinomina il root in `HQScreen`
3. Salva come `res://scenes/screens/hq_screen.tscn`
4. Aggiungi lo script `res://scripts/hq_screen.gd`:

```gdscript
# res://scripts/hq_screen.gd
extends Control

func _ready():
	setup_ui()

func setup_ui():
	# ScrollContainer per contenuto scrollabile
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)
	
	# ── Intestazione Azienda ──
	var header = create_panel()
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	header.add_child(hbox)
	
	var icon_label = Label.new()
	icon_label.text = "🚛"
	icon_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(icon_label)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = GameManager.company_name
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color("#e6edf3"))
	info_vbox.add_child(name_label)
	
	var location_label = Label.new()
	location_label.text = "📍 " + GameManager.company_city + ", " + GameManager.company_country
	location_label.add_theme_font_size_override("font_size", 14)
	location_label.add_theme_color_override("font_color", Color("#8b949e"))
	info_vbox.add_child(location_label)
	
	vbox.add_child(header)
	
	# ── Livello CEO ──
	var ceo_panel = create_panel()
	var ceo_vbox = VBoxContainer.new()
	ceo_vbox.add_theme_constant_override("separation", 8)
	ceo_panel.add_child(ceo_vbox)
	
	var ceo_title = Label.new()
	ceo_title.text = "⭐ Livello CEO " + str(GameManager.ceo_level)
	ceo_title.add_theme_font_size_override("font_size", 18)
	ceo_title.add_theme_color_override("font_color", Color("#e6edf3"))
	ceo_vbox.add_child(ceo_title)
	
	var xp_needed = GameManager.xp_for_level(GameManager.ceo_level)
	var progress = ProgressBar.new()
	progress.min_value = 0
	progress.max_value = xp_needed
	progress.value = GameManager.ceo_xp
	progress.custom_minimum_size.y = 16
	progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Stile barra
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color("#30363d")
	bar_bg.set_corner_radius_all(8)
	progress.add_theme_stylebox_override("background", bar_bg)
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = Color("#2ea043")
	bar_fill.set_corner_radius_all(8)
	progress.add_theme_stylebox_override("fill", bar_fill)
	ceo_vbox.add_child(progress)
	
	var xp_label = Label.new()
	xp_label.text = str(GameManager.ceo_xp) + " / " + str(xp_needed) + " XP"
	xp_label.add_theme_font_size_override("font_size", 12)
	xp_label.add_theme_color_override("font_color", Color("#8b949e"))
	ceo_vbox.add_child(xp_label)
	
	vbox.add_child(ceo_panel)
	
	# ── Statistiche ──
	var stats_panel = create_panel()
	var stats_vbox = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 8)
	stats_panel.add_child(stats_vbox)
	
	var stats_title = Label.new()
	stats_title.text = "📊 Statistiche"
	stats_title.add_theme_font_size_override("font_size", 18)
	stats_title.add_theme_color_override("font_color", Color("#e6edf3"))
	stats_vbox.add_child(stats_title)
	
	var stats = [
		["Veicoli", str(GameManager.owned_vehicles.size()) + " / " + str(GameManager.max_vehicles)],
		["Consegne attive", str(GameManager.active_deliveries.size())],
		["Reputazione", str(int(GameManager.reputation)) + "%"],
		["Cash", "$" + str(GameManager.cash)],
	]
	
	for stat in stats:
		var row = HBoxContainer.new()
		var key = Label.new()
		key.text = stat[0]
		key.add_theme_font_size_override("font_size", 14)
		key.add_theme_color_override("font_color", Color("#8b949e"))
		key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(key)
		var val = Label.new()
		val.text = stat[1]
		val.add_theme_font_size_override("font_size", 14)
		val.add_theme_color_override("font_color", Color("#e6edf3"))
		row.add_child(val)
		stats_vbox.add_child(row)
	
	vbox.add_child(stats_panel)
	
	# ── Consegne Attive ──
	if GameManager.active_deliveries.size() > 0:
		var del_panel = create_panel()
		var del_vbox = VBoxContainer.new()
		del_vbox.add_theme_constant_override("separation", 8)
		del_panel.add_child(del_vbox)
		
		var del_title = Label.new()
		del_title.text = "🚚 Consegne in Corso"
		del_title.add_theme_font_size_override("font_size", 18)
		del_title.add_theme_color_override("font_color", Color("#e6edf3"))
		del_vbox.add_child(del_title)
		
		for d in GameManager.active_deliveries:
			var row = Label.new()
			var mins = int(d.time_remaining)
			row.text = d.vehicle.reg + " → " + d.contract.destination + " (" + str(mins) + "s)"
			row.add_theme_font_size_override("font_size", 13)
			row.add_theme_color_override("font_color", Color("#58a6ff"))
			del_vbox.add_child(row)
		
		vbox.add_child(del_panel)

func create_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel
```

---

## PASSO 10: Creare la Schermata Garage

1. Nuova scena → **User Interface** → rinomina `GarageScreen`
2. Salva come `res://scenes/screens/garage_screen.tscn`
3. Script `res://scripts/garage_screen.gd`:

```gdscript
# res://scripts/garage_screen.gd
extends Control

var vehicle_list_container: VBoxContainer
var catalog_container: VBoxContainer

func _ready():
	setup_ui()
	GameManager.vehicle_purchased.connect(_on_vehicle_purchased)

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)
	
	# ── I Miei Veicoli ──
	var my_panel = create_panel()
	vehicle_list_container = VBoxContainer.new()
	vehicle_list_container.add_theme_constant_override("separation", 8)
	my_panel.add_child(vehicle_list_container)
	vbox.add_child(my_panel)
	update_vehicle_list()
	
	# ── Catalogo Acquisti ──
	var title = Label.new()
	title.text = "🛒 Acquista Veicolo"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	vbox.add_child(title)
	
	catalog_container = VBoxContainer.new()
	catalog_container.add_theme_constant_override("separation", 8)
	vbox.add_child(catalog_container)
	update_catalog()

func update_vehicle_list():
	# Pulisci lista
	for child in vehicle_list_container.get_children():
		child.queue_free()
	
	var title = Label.new()
	title.text = "🚛 La Mia Flotta (" + str(GameManager.owned_vehicles.size()) + "/" + str(GameManager.max_vehicles) + ")"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	vehicle_list_container.add_child(title)
	
	if GameManager.owned_vehicles.size() == 0:
		var empty = Label.new()
		empty.text = "Nessun veicolo. Acquista il tuo primo camion!"
		empty.add_theme_font_size_override("font_size", 14)
		empty.add_theme_color_override("font_color", Color("#8b949e"))
		vehicle_list_container.add_child(empty)
		return
	
	for v in GameManager.owned_vehicles:
		var card = create_vehicle_card(v)
		vehicle_list_container.add_child(card)

func create_vehicle_card(vehicle: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1c2333")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	var icon = Label.new()
	icon.text = vehicle.get("icon", "🚛")
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)
	
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)
	
	var name_label = Label.new()
	name_label.text = vehicle.name + " [" + vehicle.reg + "]"
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color("#e6edf3"))
	info.add_child(name_label)
	
	var detail = Label.new()
	var status_color = "#2ea043" if vehicle.status == "parked" else "#58a6ff"
	var status_text = "Parcheggiato" if vehicle.status == "parked" else "In Transito"
	detail.text = vehicle.type + " | " + vehicle.fuel + " | " + status_text
	detail.add_theme_font_size_override("font_size", 12)
	detail.add_theme_color_override("font_color", Color(status_color))
	info.add_child(detail)
	
	return panel

func update_catalog():
	for child in catalog_container.get_children():
		child.queue_free()
	
	for i in range(GameManager.vehicle_catalog.size()):
		var model = GameManager.vehicle_catalog[i]
		var card = create_catalog_card(model, i)
		catalog_container.add_child(card)

func create_catalog_card(model: Dictionary, index: int) -> PanelContainer:
	var panel = PanelContainer.new()
	var can_buy = GameManager.cash >= model.price and GameManager.owned_vehicles.size() < GameManager.max_vehicles and model.unlock_level <= GameManager.ceo_level
	var border_color = "#2ea043" if can_buy else "#30363d"
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color(border_color)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)
	
	# Nome e tipo
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var icon = Label.new()
	icon.text = model.get("icon", "🚛")
	icon.add_theme_font_size_override("font_size", 24)
	header.add_child(icon)
	
	var name_vbox = VBoxContainer.new()
	name_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_vbox)
	
	var name_l = Label.new()
	name_l.text = model.name
	name_l.add_theme_font_size_override("font_size", 16)
	name_l.add_theme_color_override("font_color", Color("#e6edf3"))
	name_vbox.add_child(name_l)
	
	var type_l = Label.new()
	type_l.text = model.type + " | " + model.fuel + " | " + str(model.payload_kg) + " kg"
	type_l.add_theme_font_size_override("font_size", 12)
	type_l.add_theme_color_override("font_color", Color("#8b949e"))
	name_vbox.add_child(type_l)
	
	# Prezzo e bottone
	var bottom = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom)
	
	var price_l = Label.new()
	price_l.text = "$" + str(model.price)
	price_l.add_theme_font_size_override("font_size", 18)
	price_l.add_theme_color_override("font_color", Color("#e6edf3") if can_buy else Color("#f85149"))
	price_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(price_l)
	
	if model.unlock_level > GameManager.ceo_level:
		var lock = Label.new()
		lock.text = "🔒 CEO Lv." + str(model.unlock_level)
		lock.add_theme_font_size_override("font_size", 14)
		lock.add_theme_color_override("font_color", Color("#8b949e"))
		bottom.add_child(lock)
	else:
		var buy_btn = Button.new()
		buy_btn.text = "Compra"
		buy_btn.disabled = not can_buy
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#2ea043") if can_buy else Color("#21262d")
		btn_style.set_corner_radius_all(8)
		btn_style.content_margin_left = 20
		btn_style.content_margin_right = 20
		btn_style.content_margin_top = 6
		btn_style.content_margin_bottom = 6
		buy_btn.add_theme_stylebox_override("normal", btn_style)
		buy_btn.add_theme_color_override("font_color", Color("#ffffff"))
		buy_btn.pressed.connect(_on_buy_pressed.bind(index))
		bottom.add_child(buy_btn)
	
	return panel

func _on_buy_pressed(index: int):
	if GameManager.buy_vehicle(index):
		update_vehicle_list()
		update_catalog()

func _on_vehicle_purchased(_vehicle):
	update_vehicle_list()
	update_catalog()

func create_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel
```

---

## PASSO 11: Creare la Schermata Logistica (Contratti)

1. Nuova scena → **User Interface** → rinomina `LogisticsScreen`
2. Salva come `res://scenes/screens/logistics_screen.tscn`
3. Script `res://scripts/logistics_screen.gd`:

```gdscript
# res://scripts/logistics_screen.gd
extends Control

var contracts_container: VBoxContainer
var deliveries_container: VBoxContainer

func _ready():
	setup_ui()
	GameManager.delivery_completed.connect(_on_delivery_completed)
	GameManager.contract_accepted.connect(_on_contract_accepted)

func _process(_delta):
	# Aggiorna timer consegne ogni frame
	update_deliveries_display()

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)
	
	# ── Consegne Attive ──
	var del_panel = create_panel()
	deliveries_container = VBoxContainer.new()
	deliveries_container.add_theme_constant_override("separation", 8)
	del_panel.add_child(deliveries_container)
	vbox.add_child(del_panel)
	
	# ── Contratti Disponibili ──
	var title = Label.new()
	title.text = "📋 Contratti Disponibili"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	vbox.add_child(title)
	
	contracts_container = VBoxContainer.new()
	contracts_container.add_theme_constant_override("separation", 8)
	vbox.add_child(contracts_container)
	
	update_contracts_display()

func update_deliveries_display():
	for child in deliveries_container.get_children():
		child.queue_free()
	
	var title = Label.new()
	title.text = "🚚 Consegne in Corso (" + str(GameManager.active_deliveries.size()) + ")"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	deliveries_container.add_child(title)
	
	if GameManager.active_deliveries.size() == 0:
		var empty = Label.new()
		empty.text = "Nessuna consegna attiva. Accetta un contratto!"
		empty.add_theme_font_size_override("font_size", 14)
		empty.add_theme_color_override("font_color", Color("#8b949e"))
		deliveries_container.add_child(empty)
		return
	
	for d in GameManager.active_deliveries:
		var card = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1c2333")
		style.border_color = Color("#1f6feb44")
		style.set_border_width_all(1)
		style.set_corner_radius_all(8)
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		card.add_theme_stylebox_override("panel", style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card.add_child(hbox)
		
		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info)
		
		var route = Label.new()
		route.text = d.vehicle.reg + ": " + d.contract.origin + " → " + d.contract.destination
		route.add_theme_font_size_override("font_size", 14)
		route.add_theme_color_override("font_color", Color("#e6edf3"))
		info.add_child(route)
		
		# Barra progresso
		var progress = ProgressBar.new()
		progress.min_value = 0
		progress.max_value = d.time_total
		progress.value = d.time_total - d.time_remaining
		progress.custom_minimum_size.y = 8
		var bg = StyleBoxFlat.new()
		bg.bg_color = Color("#30363d")
		bg.set_corner_radius_all(4)
		progress.add_theme_stylebox_override("background", bg)
		var fill = StyleBoxFlat.new()
		fill.bg_color = Color("#1f6feb")
		fill.set_corner_radius_all(4)
		progress.add_theme_stylebox_override("fill", fill)
		info.add_child(progress)
		
		var time_label = Label.new()
		var secs = int(d.time_remaining)
		var mins = secs / 60
		secs = secs % 60
		time_label.text = str(mins) + "m " + str(secs) + "s | $" + str(d.contract.payout)
		time_label.add_theme_font_size_override("font_size", 12)
		time_label.add_theme_color_override("font_color", Color("#58a6ff"))
		info.add_child(time_label)
		
		deliveries_container.add_child(card)

func update_contracts_display():
	for child in contracts_container.get_children():
		child.queue_free()
	
	var available_vehicles = GameManager.get_available_vehicles()
	
	for i in range(GameManager.available_contracts.size()):
		var c = GameManager.available_contracts[i]
		var card = create_contract_card(c, i, available_vehicles)
		contracts_container.add_child(card)

func create_contract_card(contract: Dictionary, index: int, available_vehicles: Array) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)
	
	# Rotta
	var route = Label.new()
	route.text = "📦 " + contract.origin + " → " + contract.destination
	route.add_theme_font_size_override("font_size", 16)
	route.add_theme_color_override("font_color", Color("#e6edf3"))
	vbox.add_child(route)
	
	# Dettagli
	var details = Label.new()
	details.text = str(contract.distance_km) + " km | " + str(contract.weight_kg) + " kg | " + contract.cargo_type
	details.add_theme_font_size_override("font_size", 12)
	details.add_theme_color_override("font_color", Color("#8b949e"))
	vbox.add_child(details)
	
	# Payout e bottone
	var bottom = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom)
	
	var payout = Label.new()
	payout.text = "💰 $" + str(contract.payout)
	payout.add_theme_font_size_override("font_size", 18)
	payout.add_theme_color_override("font_color", Color("#2ea043"))
	payout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(payout)
	
	if available_vehicles.size() > 0:
		var accept_btn = Button.new()
		accept_btn.text = "Accetta ▶"
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#1f6feb")
		btn_style.set_corner_radius_all(8)
		btn_style.content_margin_left = 16
		btn_style.content_margin_right = 16
		btn_style.content_margin_top = 6
		btn_style.content_margin_bottom = 6
		accept_btn.add_theme_stylebox_override("normal", btn_style)
		accept_btn.add_theme_color_override("font_color", Color("#ffffff"))
		accept_btn.pressed.connect(_on_accept_pressed.bind(index))
		bottom.add_child(accept_btn)
	else:
		var no_vehicle = Label.new()
		no_vehicle.text = "⚠ Nessun veicolo disponibile"
		no_vehicle.add_theme_font_size_override("font_size", 12)
		no_vehicle.add_theme_color_override("font_color", Color("#f85149"))
		bottom.add_child(no_vehicle)
	
	return panel

func _on_accept_pressed(contract_index: int):
	# Prendi il primo veicolo disponibile
	var available = GameManager.get_available_vehicles()
	if available.size() == 0:
		return
	
	var vehicle_index = GameManager.owned_vehicles.find(available[0])
	if GameManager.accept_contract(contract_index, vehicle_index):
		update_contracts_display()

func _on_delivery_completed(_delivery):
	update_contracts_display()

func _on_contract_accepted(_contract):
	update_contracts_display()

func create_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel
```

---

## PASSO 12: Impostare la Scena Principale

1. Vai su **Project → Project Settings → General**
2. Cerca **"run"** nella barra di ricerca
3. **Application → Run → Main Scene**: seleziona `res://scenes/main.tscn`
4. Chiudi le impostazioni

---

## PASSO 13: Provare il Gioco!

1. Premi **F5** (o il pulsante ▶ in alto a destra)
2. Dovresti vedere:
   - La **TopBar** con cash, nome azienda e livello
   - La **schermata Sede** con le statistiche
   - La **NavBar** in basso con 3 bottoni
3. Clicca su **Garage** → vedrai il catalogo veicoli → compra il tuo primo camion!
4. Clicca su **Logistica** → vedrai i contratti → accettane uno!
5. Guarda il timer scorrere → la consegna si completa → i soldi arrivano!

---

## PROBLEMI COMUNI E SOLUZIONI

| Problema | Soluzione |
|----------|-----------|
| "Errore: file non trovato" | Controlla che i percorsi dei file .tscn siano corretti in main.gd |
| "Schermata nera" | Verifica che Main Scene sia impostata nelle Project Settings |
| "Nodo non trovato" con @onready | I nomi dei nodi nell'albero devono corrispondere ESATTAMENTE ai path nello script |
| "Il bottone non funziona" | Verifica che il segnale `pressed` sia collegato alla funzione corretta |
| Lo scroll non funziona | Assicurati che il VBoxContainer dentro ScrollContainer abbia size_flags_horizontal = EXPAND_FILL |

---

## PROSSIMI PASSI (dopo che funziona)

1. **Personalizza i colori** — sperimenta con i codici colore nel codice
2. **Aggiungi più veicoli** al catalogo in game_manager.gd
3. **Aggiungi più città** all'array cities
4. **Migliora i tempi** — attualmente le consegne sono in secondi, puoi moltiplicare per renderle più lunghe
5. **Aggiungi il salvataggio** — la funzione save_game() è già pronta, basta chiamarla!

Ogni volta che sei bloccato, copiami l'errore di Godot e ti aiuto a risolverlo!
