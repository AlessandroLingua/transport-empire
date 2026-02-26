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
