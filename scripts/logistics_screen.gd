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
