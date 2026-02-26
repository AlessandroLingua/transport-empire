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
