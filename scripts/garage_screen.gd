# res://scripts/garage_screen.gd
# Garage: compra veicoli (con assegnazione terminale), vedi flotta per terminale, trasferisci
extends Control

var content_box: VBoxContainer

func _ready():
	setup_ui()
	GameManager.vehicle_purchased.connect(func(_v): rebuild())
	GameManager.delivery_completed.connect(func(_d): rebuild())
	GameManager.transfer_completed.connect(func(_t): rebuild())

func rebuild():
	for c in get_children():
		c.queue_free()
	setup_ui()

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	content_box = VBoxContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 14)
	scroll.add_child(content_box)

	# ── FLOTTA PER TERMINALE ──
	var ft = Label.new()
	ft.text = "La Mia Flotta (" + str(GameManager.owned_vehicles.size()) + "/" + str(GameManager.max_vehicles) + ")"
	ft.add_theme_font_size_override("font_size", 20)
	ft.add_theme_color_override("font_color", Color("#e6edf3"))
	content_box.add_child(ft)

	for tid in GameManager.owned_terminals:
		_build_terminal_section(tid)

	# ── CATALOGO ──
	content_box.add_child(_sep())
	var ct = Label.new()
	ct.text = "Acquista Veicolo"
	ct.add_theme_font_size_override("font_size", 20)
	ct.add_theme_color_override("font_color", Color("#e6edf3"))
	content_box.add_child(ct)

	for i in range(GameManager.vehicle_catalog.size()):
		content_box.add_child(_catalog_card(GameManager.vehicle_catalog[i], i))

func _build_terminal_section(tid: String):
	var td = GameManager.get_terminal(tid)
	if td.size() == 0:
		return
	var vehs = GameManager.vehicles_at(tid)
	var total = GameManager.count_at(tid)
	var cap = GameManager.capacity_of(tid)

	# Header terminale
	var panel = _panel()
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	var header = Label.new()
	header.text = td.city + " (" + td.country + ")  —  " + str(total) + "/" + str(cap) + " veicoli"
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color("#2ea043"))
	vb.add_child(header)

	if vehs.size() == 0:
		var empty = Label.new()
		empty.text = "Nessun veicolo disponibile in questo terminale"
		empty.add_theme_font_size_override("font_size", 12)
		empty.add_theme_color_override("font_color", Color("#8b949e"))
		vb.add_child(empty)
	else:
		for v in vehs:
			vb.add_child(_vehicle_row(v, tid))

	# Veicoli in transito da/verso questo terminale
	for d in GameManager.active_deliveries:
		if d.vehicle.get("terminal_id", "") == tid or d.contract.get("dest_terminal", "") == tid:
			var tl = Label.new()
			tl.text = "  " + d.vehicle.reg + " in consegna > " + d.contract.destination
			tl.add_theme_font_size_override("font_size", 11)
			tl.add_theme_color_override("font_color", Color("#58a6ff"))
			vb.add_child(tl)

	for tr in GameManager.active_transfers:
		if tr.from_terminal == tid or tr.to_terminal == tid:
			var from_c = GameManager.get_terminal(tr.from_terminal).get("city", "?")
			var to_c = GameManager.get_terminal(tr.to_terminal).get("city", "?")
			var tl = Label.new()
			tl.text = "  " + tr.vehicle.reg + " trasferimento " + from_c + " > " + to_c
			tl.add_theme_font_size_override("font_size", 11)
			tl.add_theme_color_override("font_color", Color("#d29922"))
			vb.add_child(tl)

	content_box.add_child(panel)

func _vehicle_row(v: Dictionary, current_tid: String) -> HBoxContainer:
	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)

	# Info veicolo
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(info)

	var nl = Label.new()
	nl.text = v.name + "  [" + v.reg + "]"
	nl.add_theme_font_size_override("font_size", 14)
	nl.add_theme_color_override("font_color", Color("#e6edf3"))
	info.add_child(nl)

	var dl = Label.new()
	dl.text = v.type + " | " + v.fuel + " | " + str(v.payload_kg) + " kg | usura " + str(int(v.get("wear", 0))) + "%"
	dl.add_theme_font_size_override("font_size", 11)
	dl.add_theme_color_override("font_color", Color("#8b949e"))
	info.add_child(dl)

	# Bottone trasferisci
	var reachable = GameManager.reachable_terminals(current_tid)
	if reachable.size() > 0:
		var tr_btn = Button.new()
		tr_btn.text = "Trasferisci"
		var bs = StyleBoxFlat.new()
		bs.bg_color = Color("#d2992233")
		bs.border_color = Color("#d2992266")
		bs.set_border_width_all(1)
		bs.set_corner_radius_all(6)
		bs.content_margin_left = 10
		bs.content_margin_right = 10
		bs.content_margin_top = 4
		bs.content_margin_bottom = 4
		tr_btn.add_theme_stylebox_override("normal", bs)
		tr_btn.add_theme_color_override("font_color", Color("#d29922"))
		tr_btn.add_theme_font_size_override("font_size", 12)
		var veh_idx = GameManager.owned_vehicles.find(v)
		tr_btn.pressed.connect(func(): _show_transfer_options(veh_idx, current_tid))
		hb.add_child(tr_btn)

	return hb

func _show_transfer_options(veh_idx: int, from_tid: String):
	# Mostra popup con terminali raggiungibili
	var reachable = GameManager.reachable_terminals(from_tid)
	if reachable.size() == 0:
		return

	# Rimuovi popup precedente se esiste
	var old = get_node_or_null("TransferPopup")
	if old:
		old.queue_free()

	var popup_panel = PanelContainer.new()
	popup_panel.name = "TransferPopup"
	popup_panel.set_anchors_preset(Control.PRESET_CENTER)
	popup_panel.custom_minimum_size = Vector2(350, 0)
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color("#161b22ee")
	ps.border_color = Color("#d29922")
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(12)
	ps.content_margin_left = 16
	ps.content_margin_right = 16
	ps.content_margin_top = 14
	ps.content_margin_bottom = 14
	popup_panel.add_theme_stylebox_override("panel", ps)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	popup_panel.add_child(vb)

	var title = Label.new()
	title.text = "Trasferisci a:"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("#d29922"))
	vb.add_child(title)

	for r in reachable:
		var td = GameManager.get_terminal(r.id)
		var cap = GameManager.capacity_of(r.id)
		var cnt = GameManager.count_at(r.id)
		var can = cnt < cap

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vb.add_child(row)

		var lbl = Label.new()
		lbl.text = td.city + " (" + str(r.distance_km) + " km) [" + str(cnt) + "/" + str(cap) + "]"
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color("#e6edf3") if can else Color("#f85149"))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		if can:
			var btn = Button.new()
			btn.text = "Invia"
			var bs2 = StyleBoxFlat.new()
			bs2.bg_color = Color("#d29922")
			bs2.set_corner_radius_all(6)
			bs2.content_margin_left = 12
			bs2.content_margin_right = 12
			bs2.content_margin_top = 3
			bs2.content_margin_bottom = 3
			btn.add_theme_stylebox_override("normal", bs2)
			btn.add_theme_color_override("font_color", Color("#000000"))
			btn.add_theme_font_size_override("font_size", 12)
			var dest_id = r.id
			btn.pressed.connect(func():
				GameManager.start_transfer(veh_idx, dest_id)
				popup_panel.queue_free()
				rebuild()
			)
			row.add_child(btn)

	# Bottone chiudi
	var close_btn = Button.new()
	close_btn.text = "Annulla"
	var cs = StyleBoxFlat.new()
	cs.bg_color = Color("#21262d")
	cs.set_corner_radius_all(6)
	cs.content_margin_top = 4
	cs.content_margin_bottom = 4
	close_btn.add_theme_stylebox_override("normal", cs)
	close_btn.add_theme_color_override("font_color", Color("#8b949e"))
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(func(): popup_panel.queue_free())
	vb.add_child(close_btn)

	add_child(popup_panel)

# ══════════ CATALOGO ══════════

func _catalog_card(model: Dictionary, idx: int) -> PanelContainer:
	var unlocked = model.unlock_level <= GameManager.ceo_level
	var afford = GameManager.cash >= model.price
	var space = GameManager.owned_vehicles.size() < GameManager.max_vehicles

	var p = _panel()
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	p.add_child(vb)

	# Nome e tipo
	var nl = Label.new()
	nl.text = model.name
	nl.add_theme_font_size_override("font_size", 16)
	nl.add_theme_color_override("font_color", Color("#e6edf3") if unlocked else Color("#484f58"))
	vb.add_child(nl)

	var dl = Label.new()
	dl.text = model.type + " | " + model.fuel + " | " + str(model.payload_kg) + " kg | " + str(model.capacity_m3) + " m3"
	dl.add_theme_font_size_override("font_size", 12)
	dl.add_theme_color_override("font_color", Color("#8b949e"))
	vb.add_child(dl)

	var bh = HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	vb.add_child(bh)

	var pl = Label.new()
	pl.text = "$" + _fmt(model.price)
	pl.add_theme_font_size_override("font_size", 16)
	pl.add_theme_color_override("font_color", Color("#e6edf3") if afford else Color("#f85149"))
	pl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bh.add_child(pl)

	if not unlocked:
		var ll = Label.new()
		ll.text = "CEO Lv." + str(model.unlock_level)
		ll.add_theme_font_size_override("font_size", 12)
		ll.add_theme_color_override("font_color", Color("#d29922"))
		bh.add_child(ll)
	elif not space:
		var sl = Label.new()
		sl.text = "Flotta piena"
		sl.add_theme_font_size_override("font_size", 12)
		sl.add_theme_color_override("font_color", Color("#f85149"))
		bh.add_child(sl)
	elif afford:
		# Dropdown terminale + bottone compra
		for tid in GameManager.owned_terminals:
			var td = GameManager.get_terminal(tid)
			var cnt = GameManager.count_at(tid)
			var cap = GameManager.capacity_of(tid)
			if cnt < cap:
				var btn = Button.new()
				btn.text = " Compra > " + td.city + " [" + str(cnt) + "/" + str(cap) + "] "
				var bs = StyleBoxFlat.new()
				bs.bg_color = Color("#2ea043")
				bs.set_corner_radius_all(6)
				bs.content_margin_left = 10
				bs.content_margin_right = 10
				bs.content_margin_top = 4
				bs.content_margin_bottom = 4
				btn.add_theme_stylebox_override("normal", bs)
				btn.add_theme_color_override("font_color", Color("#ffffff"))
				btn.add_theme_font_size_override("font_size", 12)
				var terminal_id = tid
				btn.pressed.connect(func():
					GameManager.buy_vehicle(idx, terminal_id)
					rebuild()
				)
				bh.add_child(btn)

	return p

func _panel() -> PanelContainer:
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#161b22")
	s.border_color = Color("#30363d")
	s.set_border_width_all(1)
	s.set_corner_radius_all(10)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", s)
	return p

func _sep() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_color_override("separator", Color("#30363d"))
	return s

func _fmt(n: int) -> String:
	var s = str(n)
	var r = ""
	var c = 0
	for i in range(s.length() - 1, -1, -1):
		if c > 0 and c % 3 == 0:
			r = "," + r
		r = s[i] + r
		c += 1
	return r
