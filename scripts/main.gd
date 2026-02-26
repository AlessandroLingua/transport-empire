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
