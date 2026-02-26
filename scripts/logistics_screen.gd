# res://scripts/logistics_screen.gd
# Schermata Logistica con MAPPA INTERATTIVA + contratti
extends Control

var map_widget: Control
var deliveries_container: VBoxContainer
var contracts_container: VBoxContainer

func _ready():
	setup_ui()
	GameManager.delivery_completed.connect(_on_delivery_completed)
	GameManager.contract_accepted.connect(_on_contract_accepted)

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)
	
	# ══════════════════════════════
	# MAPPA
	# ══════════════════════════════
	map_widget = MapWidget.new()
	map_widget.custom_minimum_size = Vector2(0, 420)
	vbox.add_child(map_widget)
	
	# ── Stato flotta sotto la mappa ──
	var status_hbox = HBoxContainer.new()
	status_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(status_hbox)
	
	var in_transit = GameManager.active_deliveries.size()
	var parked = GameManager.get_available_vehicles().size()
	var total = GameManager.owned_vehicles.size()
	
	status_hbox.add_child(_create_status_badge("🚚 In Transito: " + str(in_transit), "#1f6feb"))
	status_hbox.add_child(_create_status_badge("🅿️ Disponibili: " + str(parked), "#2ea043"))
	status_hbox.add_child(_create_status_badge("📊 Totale: " + str(total), "#8b949e"))
	
	# ── Separatore ──
	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", Color("#30363d"))
	vbox.add_child(sep)
	
	# ══════════════════════════════
	# CONSEGNE ATTIVE
	# ══════════════════════════════
	deliveries_container = VBoxContainer.new()
	deliveries_container.add_theme_constant_override("separation", 8)
	vbox.add_child(deliveries_container)
	
	var sep2 = HSeparator.new()
	sep2.add_theme_color_override("separator", Color("#30363d"))
	vbox.add_child(sep2)
	
	# ══════════════════════════════
	# CONTRATTI
	# ══════════════════════════════
	contracts_container = VBoxContainer.new()
	contracts_container.add_theme_constant_override("separation", 8)
	vbox.add_child(contracts_container)
	
	_update_contracts()

func _process(_delta):
	_update_deliveries()
	if map_widget:
		map_widget.queue_redraw()

func _create_status_badge(text: String, color: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color + "22")
	style.border_color = Color(color + "44")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(color))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel

# ══════════════════════════════════════
# CONSEGNE ATTIVE
# ══════════════════════════════════════

func _update_deliveries():
	for child in deliveries_container.get_children():
		child.queue_free()
	
	var title = Label.new()
	title.text = "🚚 Consegne in Corso (" + str(GameManager.active_deliveries.size()) + ")"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	deliveries_container.add_child(title)
	
	if GameManager.active_deliveries.size() == 0:
		var empty = Label.new()
		empty.text = "Nessuna consegna in corso. Accetta un contratto qui sotto!"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", Color("#8b949e"))
		deliveries_container.add_child(empty)
		return
	
	for d in GameManager.active_deliveries:
		deliveries_container.add_child(_create_delivery_card(d))

func _create_delivery_card(delivery: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1c2333")
	style.border_color = Color("#1f6feb44")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	
	var route_hbox = HBoxContainer.new()
	route_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(route_hbox)
	
	var icon = Label.new()
	icon.text = delivery.vehicle.get("icon", "🚛")
	icon.add_theme_font_size_override("font_size", 18)
	route_hbox.add_child(icon)
	
	var route = Label.new()
	route.text = delivery.vehicle.reg + ":  " + delivery.contract.origin + " → " + delivery.contract.destination
	route.add_theme_font_size_override("font_size", 14)
	route.add_theme_color_override("font_color", Color("#e6edf3"))
	route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_hbox.add_child(route)
	
	# Barra progresso
	var progress = ProgressBar.new()
	progress.min_value = 0
	progress.max_value = delivery.time_total
	progress.value = delivery.time_total - delivery.time_remaining
	progress.custom_minimum_size.y = 8
	progress.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("#30363d")
	bg.set_corner_radius_all(4)
	progress.add_theme_stylebox_override("background", bg)
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color("#1f6feb")
	fill.set_corner_radius_all(4)
	progress.add_theme_stylebox_override("fill", fill)
	vbox.add_child(progress)
	
	var bottom = HBoxContainer.new()
	vbox.add_child(bottom)
	var secs = int(delivery.time_remaining)
	var time_l = Label.new()
	time_l.text = "⏱ " + str(secs / 60) + "m " + str(secs % 60) + "s"
	time_l.add_theme_font_size_override("font_size", 12)
	time_l.add_theme_color_override("font_color", Color("#58a6ff"))
	time_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(time_l)
	var pay_l = Label.new()
	pay_l.text = "💰 $" + str(delivery.contract.payout)
	pay_l.add_theme_font_size_override("font_size", 12)
	pay_l.add_theme_color_override("font_color", Color("#2ea043"))
	bottom.add_child(pay_l)
	
	return panel

# ══════════════════════════════════════
# CONTRATTI
# ══════════════════════════════════════

func _update_contracts():
	for child in contracts_container.get_children():
		child.queue_free()
	
	var available = GameManager.get_available_vehicles()
	
	var title = Label.new()
	title.text = "📋 Contratti Disponibili (" + str(GameManager.available_contracts.size()) + ")"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#e6edf3"))
	contracts_container.add_child(title)
	
	if available.size() == 0 and GameManager.owned_vehicles.size() == 0:
		var hint = Label.new()
		hint.text = "⚠ Devi prima comprare un veicolo nel Garage!"
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", Color("#d29922"))
		contracts_container.add_child(hint)
	elif available.size() == 0:
		var hint = Label.new()
		hint.text = "⏳ Tutti i veicoli sono in transito. Aspetta che tornino!"
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", Color("#d29922"))
		contracts_container.add_child(hint)
	
	for i in range(GameManager.available_contracts.size()):
		contracts_container.add_child(_create_contract_card(GameManager.available_contracts[i], i, available))

func _create_contract_card(contract: Dictionary, index: int, available_vehicles: Array) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	
	var route = Label.new()
	route.text = "📦  " + contract.origin + "  →  " + contract.destination
	route.add_theme_font_size_override("font_size", 16)
	route.add_theme_color_override("font_color", Color("#e6edf3"))
	vbox.add_child(route)
	
	var details = Label.new()
	details.text = str(contract.distance_km) + " km  •  " + str(contract.weight_kg) + " kg  •  " + contract.cargo_type
	details.add_theme_font_size_override("font_size", 12)
	details.add_theme_color_override("font_color", Color("#8b949e"))
	vbox.add_child(details)
	
	var bottom = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom)
	
	var pay = Label.new()
	pay.text = "💰 $" + str(contract.payout)
	pay.add_theme_font_size_override("font_size", 18)
	pay.add_theme_color_override("font_color", Color("#2ea043"))
	pay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(pay)
	
	if available_vehicles.size() > 0:
		var btn = Button.new()
		btn.text = "  Accetta ▶  "
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#1f6feb")
		btn_style.set_corner_radius_all(8)
		btn_style.content_margin_left = 16
		btn_style.content_margin_right = 16
		btn_style.content_margin_top = 8
		btn_style.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", btn_style)
		var btn_hover = btn_style.duplicate()
		btn_hover.bg_color = Color("#388bfd")
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_color_override("font_color", Color("#ffffff"))
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(_on_accept.bind(index))
		bottom.add_child(btn)
	
	return panel

func _on_accept(contract_index: int):
	var available = GameManager.get_available_vehicles()
	if available.size() == 0:
		return
	var vehicle_index = GameManager.owned_vehicles.find(available[0])
	if GameManager.accept_contract(contract_index, vehicle_index):
		_update_contracts()

func _on_delivery_completed(_delivery):
	_update_contracts()

func _on_contract_accepted(_contract):
	_update_contracts()


# ══════════════════════════════════════════════════════════════
# CLASSE MAPPA - Disegna la mappa europea con camion animati
# ══════════════════════════════════════════════════════════════
class MapWidget extends Control:
	
	# Coordinate città normalizzate (0-1) sulla mappa
	# Basate su posizioni geografiche reali semplificate
	var city_positions: Dictionary = {
		"Torino":     Vector2(0.42, 0.52),
		"Milano":     Vector2(0.45, 0.46),
		"Roma":       Vector2(0.50, 0.72),
		"Lione":      Vector2(0.32, 0.48),
		"Barcellona": Vector2(0.18, 0.72),
		"Monaco":     Vector2(0.50, 0.30),
		"Vienna":     Vector2(0.62, 0.30),
		"Lubiana":    Vector2(0.58, 0.42),
		"Marsiglia":  Vector2(0.30, 0.62),
		"Zurigo":     Vector2(0.40, 0.35),
	}
	
	# Connessioni tra città (rotte principali)
	var connections: Array = [
		["Torino", "Milano"],
		["Torino", "Lione"],
		["Torino", "Marsiglia"],
		["Milano", "Zurigo"],
		["Milano", "Lubiana"],
		["Milano", "Roma"],
		["Lione", "Zurigo"],
		["Lione", "Marsiglia"],
		["Lione", "Barcellona"],
		["Marsiglia", "Barcellona"],
		["Zurigo", "Monaco"],
		["Monaco", "Vienna"],
		["Monaco", "Lubiana"],
		["Vienna", "Lubiana"],
		["Lubiana", "Roma"],
	]
	
	var pulse_time: float = 0.0
	
	func _process(delta):
		pulse_time += delta
	
	func _draw():
		var rect = get_rect()
		var w = rect.size.x
		var h = rect.size.y
		var margin = 40.0
		
		# ── Sfondo mappa ──
		var bg_style = StyleBoxFlat.new()
		draw_rect(Rect2(0, 0, w, h), Color("#0d1a2d"))
		# Bordo
		draw_rect(Rect2(0, 0, w, h), Color("#1f6feb33"), false, 1.0)
		# Titolo
		draw_string(ThemeDB.fallback_font, Vector2(12, 22), "🗺️ MAPPA EUROPA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8b949e"))
		
		# ── Griglia sottile ──
		for i in range(10):
			var x_line = margin + (w - 2 * margin) * i / 9.0
			var y_line = margin + (h - 2 * margin) * i / 9.0
			draw_line(Vector2(x_line, margin), Vector2(x_line, h - margin), Color("#ffffff08"), 1.0)
			draw_line(Vector2(margin, y_line), Vector2(w - margin, y_line), Color("#ffffff08"), 1.0)
		
		# ── Disegna connessioni (rotte) ──
		for conn in connections:
			if city_positions.has(conn[0]) and city_positions.has(conn[1]):
				var p1 = _map_pos(city_positions[conn[0]], w, h, margin)
				var p2 = _map_pos(city_positions[conn[1]], w, h, margin)
				# Linea tratteggiata
				_draw_dashed_line(p1, p2, Color("#ffffff15"), 1.0, 8.0, 4.0)
		
		# ── Disegna rotte attive (consegne in corso) ──
		for delivery in GameManager.active_deliveries:
			var origin_name = delivery.contract.origin
			var dest_name = delivery.contract.destination
			if city_positions.has(origin_name) and city_positions.has(dest_name):
				var p1 = _map_pos(city_positions[origin_name], w, h, margin)
				var p2 = _map_pos(city_positions[dest_name], w, h, margin)
				
				# Linea rotta attiva (luminosa)
				draw_line(p1, p2, Color("#1f6feb66"), 2.5)
				
				# Progresso consegna (0 a 1)
				var progress = 1.0 - (delivery.time_remaining / delivery.time_total)
				progress = clampf(progress, 0.0, 1.0)
				
				# Posizione camion lungo la rotta
				var truck_pos = p1.lerp(p2, progress)
				
				# Scia del camion (linea percorsa)
				draw_line(p1, truck_pos, Color("#1f6feb"), 3.0)
				
				# Glow attorno al camion
				var glow_size = 14.0 + sin(pulse_time * 3.0) * 3.0
				draw_circle(truck_pos, glow_size, Color("#1f6feb33"))
				draw_circle(truck_pos, glow_size * 0.6, Color("#1f6feb55"))
				
				# Icona camion
				var truck_icon = delivery.vehicle.get("icon", "🚛")
				draw_string(ThemeDB.fallback_font, truck_pos + Vector2(-8, 6), truck_icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
		
		# ── Disegna città ──
		for city_name in city_positions.keys():
			var pos = _map_pos(city_positions[city_name], w, h, margin)
			var is_active = _is_city_active(city_name)
			
			# Cerchio esterno (glow per città attive)
			if is_active:
				var glow = 10.0 + sin(pulse_time * 2.0 + city_positions[city_name].x * 10.0) * 2.0
				draw_circle(pos, glow, Color("#2ea04333"))
			
			# Cerchio città
			var city_color = Color("#2ea043") if is_active else Color("#30363d")
			var city_radius = 7.0 if is_active else 5.0
			draw_circle(pos, city_radius + 1, Color("#0d1a2d"))  # bordo scuro
			draw_circle(pos, city_radius, city_color)
			
			# Puntino interno
			draw_circle(pos, 2.0, Color("#ffffff88"))
			
			# Nome città
			var label_color = Color("#e6edf3") if is_active else Color("#8b949e88")
			var label_size = 13 if is_active else 11
			var label_offset = Vector2(-city_name.length() * 3.0, -city_radius - 6)
			draw_string(ThemeDB.fallback_font, pos + label_offset, city_name, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, label_color)
		
		# ── Legenda in basso ──
		var legend_y = h - 18
		draw_circle(Vector2(margin, legend_y), 4, Color("#2ea043"))
		draw_string(ThemeDB.fallback_font, Vector2(margin + 10, legend_y + 4), "Terminale", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#8b949e"))
		draw_circle(Vector2(margin + 110, legend_y), 4, Color("#1f6feb"))
		draw_string(ThemeDB.fallback_font, Vector2(margin + 120, legend_y + 4), "Rotta attiva", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#8b949e"))
		draw_string(ThemeDB.fallback_font, Vector2(margin + 220, legend_y + 4), "🚛 Veicolo in transito", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#8b949e"))
	
	func _map_pos(normalized: Vector2, w: float, h: float, margin: float) -> Vector2:
		return Vector2(
			margin + normalized.x * (w - 2 * margin),
			margin + normalized.y * (h - 2 * margin)
		)
	
	func _is_city_active(city_name: String) -> bool:
		# Una città è "attiva" se è origine o destinazione di una consegna
		for d in GameManager.active_deliveries:
			if d.contract.origin == city_name or d.contract.destination == city_name:
				return true
		# Oppure se il giocatore ha almeno 1 veicolo (la prima città è sempre attiva)
		if city_name == GameManager.company_city and GameManager.owned_vehicles.size() > 0:
			return true
		return false
	
	func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float, dash: float, gap: float):
		var direction = (to - from).normalized()
		var total_length = from.distance_to(to)
		var current = 0.0
		while current < total_length:
			var start = from + direction * current
			var end_dist = minf(current + dash, total_length)
			var end = from + direction * end_dist
			draw_line(start, end, color, width)
			current += dash + gap
