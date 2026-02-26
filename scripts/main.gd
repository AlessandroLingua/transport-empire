# res://scripts/main.gd
extends Control

# Riferimenti UI (creati da codice, non dalla scena)
var cash_label: Label
var company_label: Label
var level_label: Label
var content: Control
var btn_hq: Button
var btn_garage: Button
var btn_logistics: Button

# Scene schermate
var hq_scene = preload("res://scenes/screens/hq_screen.tscn")
var garage_scene = preload("res://scenes/screens/garage_screen.tscn")
var logistics_scene = preload("res://scenes/screens/logistics_screen.tscn")

var current_screen = null
var current_button = null

func _ready():
	build_ui()
	
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

func build_ui():
	# ── Sfondo scuro ──
	var bg = ColorRect.new()
	bg.color = Color("#0d1117")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# ── Layout verticale principale ──
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)
	
	# ══════════════════════════════
	# TOP BAR
	# ══════════════════════════════
	var top_bar = PanelContainer.new()
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color("#161b22")
	top_style.border_color = Color("#30363d")
	top_style.border_width_bottom = 1
	top_style.content_margin_left = 16
	top_style.content_margin_right = 16
	top_style.content_margin_top = 10
	top_style.content_margin_bottom = 10
	top_bar.add_theme_stylebox_override("panel", top_style)
	vbox.add_child(top_bar)
	
	var top_hbox = HBoxContainer.new()
	top_bar.add_child(top_hbox)
	
	# Cash
	cash_label = Label.new()
	cash_label.add_theme_color_override("font_color", Color("#2ea043"))
	cash_label.add_theme_font_size_override("font_size", 18)
	top_hbox.add_child(cash_label)
	
	# Spacer sinistro
	var spacer1 = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer1)
	
	# Nome azienda
	company_label = Label.new()
	company_label.add_theme_color_override("font_color", Color("#e6edf3"))
	company_label.add_theme_font_size_override("font_size", 16)
	top_hbox.add_child(company_label)
	
	# Spacer destro
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer2)
	
	# Livello CEO
	level_label = Label.new()
	level_label.add_theme_color_override("font_color", Color("#58a6ff"))
	level_label.add_theme_font_size_override("font_size", 14)
	top_hbox.add_child(level_label)
	
	# ══════════════════════════════
	# AREA CONTENUTO (schermate)
	# ══════════════════════════════
	var screen_container = MarginContainer.new()
	screen_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen_container.add_theme_constant_override("margin_left", 0)
	screen_container.add_theme_constant_override("margin_right", 0)
	screen_container.add_theme_constant_override("margin_top", 0)
	screen_container.add_theme_constant_override("margin_bottom", 0)
	vbox.add_child(screen_container)
	
	content = Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_container.add_child(content)
	
	# ══════════════════════════════
	# NAV BAR
	# ══════════════════════════════
	var nav_bar = PanelContainer.new()
	var nav_style = StyleBoxFlat.new()
	nav_style.bg_color = Color("#161b22")
	nav_style.border_color = Color("#30363d")
	nav_style.border_width_top = 1
	nav_style.content_margin_left = 8
	nav_style.content_margin_right = 8
	nav_style.content_margin_top = 8
	nav_style.content_margin_bottom = 8
	nav_bar.add_theme_stylebox_override("panel", nav_style)
	vbox.add_child(nav_bar)
	
	var nav_hbox = HBoxContainer.new()
	nav_hbox.add_theme_constant_override("separation", 8)
	nav_bar.add_child(nav_hbox)
	
	# Bottoni navigazione
	btn_hq = _create_nav_button("🏢 Sede")
	nav_hbox.add_child(btn_hq)
	
	btn_garage = _create_nav_button("🚛 Garage")
	nav_hbox.add_child(btn_garage)
	
	btn_logistics = _create_nav_button("🗺️ Logistica")
	nav_hbox.add_child(btn_logistics)

func _create_nav_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color("#8b949e"))
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#21262d")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", style)
	# Stile hover
	var hover = style.duplicate()
	hover.bg_color = Color("#30363d")
	btn.add_theme_stylebox_override("hover", hover)
	# Stile pressed
	var pressed = style.duplicate()
	pressed.bg_color = Color("#1c2333")
	btn.add_theme_stylebox_override("pressed", pressed)
	return btn

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
