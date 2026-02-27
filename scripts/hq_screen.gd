# res://scripts/hq_screen.gd
# Sede: panoramica azienda, gestione terminali, acquisto nuovi terminali
extends Control

func _ready():
	setup_ui()
	GameManager.delivery_completed.connect(func(_d): _rebuild())
	GameManager.ceo_level_up.connect(func(_l): _rebuild())
	GameManager.terminal_purchased.connect(func(_t): _rebuild())

func _rebuild():
	for c in get_children():
		c.queue_free()
	setup_ui()

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 14)
	scroll.add_child(vb)

	# ══════════ HEADER AZIENDA ══════════
	var hp = _panel()
	var hv = VBoxContainer.new()
	hv.add_theme_constant_override("separation", 4)
	hp.add_child(hv)
	var nm = Label.new()
	nm.text = GameManager.company_name
	nm.add_theme_font_size_override("font_size", 24)
	nm.add_theme_color_override("font_color", Color("#e6edf3"))
	hv.add_child(nm)
	var stars = int(GameManager.reputation / 20)
	var sl = Label.new()
	sl.text = "Reputazione: " + str(int(GameManager.reputation)) + "%"
	sl.add_theme_font_size_override("font_size", 14)
	sl.add_theme_color_override("font_color", Color("#f0c040"))
	hv.add_child(sl)
	vb.add_child(hp)

	# ══════════ CEO LEVEL ══════════
	var cp = _panel()
	var cv = VBoxContainer.new()
	cv.add_theme_constant_override("separation", 6)
	cp.add_child(cv)
	var cl = Label.new()
	cl.text = "CEO Livello " + str(GameManager.ceo_level)
	cl.add_theme_font_size_override("font_size", 18)
	cl.add_theme_color_override("font_color", Color("#e6edf3"))
	cv.add_child(cl)
	var xp_need = GameManager.xp_for_level(GameManager.ceo_level)
	var pb = ProgressBar.new()
	pb.min_value = 0
	pb.max_value = xp_need
	pb.value = GameManager.ceo_xp
	pb.custom_minimum_size.y = 14
	pb.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("#30363d")
	bg.set_corner_radius_all(7)
	pb.add_theme_stylebox_override("background", bg)
	var fl = StyleBoxFlat.new()
	fl.bg_color = Color("#2ea043")
	fl.set_corner_radius_all(7)
	pb.add_theme_stylebox_override("fill", fl)
	cv.add_child(pb)
	var xl = Label.new()
	xl.text = str(GameManager.ceo_xp) + " / " + str(xp_need) + " XP"
	xl.add_theme_font_size_override("font_size", 11)
	xl.add_theme_color_override("font_color", Color("#8b949e"))
	cv.add_child(xl)
	vb.add_child(cp)

	# ══════════ STATS ══════════
	var sp = _panel()
	var sv = VBoxContainer.new()
	sv.add_theme_constant_override("separation", 4)
	sp.add_child(sv)
	var st = Label.new()
	st.text = "Panoramica"
	st.add_theme_font_size_override("font_size", 18)
	st.add_theme_color_override("font_color", Color("#e6edf3"))
	sv.add_child(st)
	_stat_row(sv, "Terminali", str(GameManager.owned_terminals.size()), "#2ea043")
	_stat_row(sv, "Veicoli", str(GameManager.owned_vehicles.size()) + "/" + str(GameManager.max_vehicles), "#e6edf3")
	_stat_row(sv, "Consegne attive", str(GameManager.active_deliveries.size()), "#58a6ff")
	_stat_row(sv, "Trasferimenti", str(GameManager.active_transfers.size()), "#d29922")
	_stat_row(sv, "Disponibili", str(GameManager.get_available_vehicles().size()), "#2ea043")
	vb.add_child(sp)

	# ══════════ I MIEI TERMINALI ══════════
	vb.add_child(_sep())
	var mt = Label.new()
	mt.text = "I Miei Terminali (" + str(GameManager.owned_terminals.size()) + ")"
	mt.add_theme_font_size_override("font_size", 18)
	mt.add_theme_color_override("font_color", Color("#e6edf3"))
	vb.add_child(mt)

	for tid in GameManager.owned_terminals:
		vb.add_child(_terminal_card(tid, true))

	# ══════════ ACQUISTA TERMINALI ══════════
	vb.add_child(_sep())
	var bt = Label.new()
	bt.text = "Acquista Terminale"
	bt.add_theme_font_size_override("font_size", 18)
	bt.add_theme_color_override("font_color", Color("#e6edf3"))
	vb.add_child(bt)

	var hint = Label.new()
	hint.text = "I contratti si generano tra terminali posseduti entro 350 km"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#8b949e"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	vb.add_child(hint)

	var available = []
	for t in GameManager.terminal_catalog:
		if t.id not in GameManager.owned_terminals:
			available.append(t)
	for t in available:
		vb.add_child(_terminal_buy_card(t))

func _terminal_card(tid: String, owned: bool) -> PanelContainer:
	var td = GameManager.get_terminal(tid)
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#161b22")
	s.border_color = Color("#2ea04366")
	s.set_border_width_all(1)
	s.set_corner_radius_all(10)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", s)

	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	p.add_child(hb)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	hb.add_child(info)

	var nl = Label.new()
	nl.text = td.city + " (" + td.country + ")"
	nl.add_theme_font_size_override("font_size", 16)
	nl.add_theme_color_override("font_color", Color("#2ea043"))
	info.add_child(nl)

	var cnt = GameManager.count_at(tid)
	var cap = GameManager.capacity_of(tid)
	var dl = Label.new()
	dl.text = "Veicoli: " + str(cnt) + "/" + str(cap)
	dl.add_theme_font_size_override("font_size", 12)
	dl.add_theme_color_override("font_color", Color("#8b949e"))
	info.add_child(dl)

	# Terminali raggiungibili
	var reach = GameManager.reachable_terminals(tid)
	if reach.size() > 0:
		var names = []
		for r in reach:
			var rd = GameManager.get_terminal(r.id)
			names.append(rd.city + " (" + str(r.distance_km) + "km)")
		var rl = Label.new()
		rl.text = "Collegato a: " + ", ".join(names)
		rl.add_theme_font_size_override("font_size", 11)
		rl.add_theme_color_override("font_color", Color("#58a6ff"))
		rl.autowrap_mode = TextServer.AUTOWRAP_WORD
		info.add_child(rl)
	else:
		var rl = Label.new()
		rl.text = "Nessun terminale raggiungibile (< 350 km)"
		rl.add_theme_font_size_override("font_size", 11)
		rl.add_theme_color_override("font_color", Color("#d29922"))
		info.add_child(rl)

	return p

func _terminal_buy_card(t: Dictionary) -> PanelContainer:
	var unlocked = t.unlock_level <= GameManager.ceo_level
	var afford = GameManager.cash >= t.price

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

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	p.add_child(vbox)

	var nl = Label.new()
	nl.text = t.city + " (" + t.country + ")"
	nl.add_theme_font_size_override("font_size", 16)
	nl.add_theme_color_override("font_color", Color("#e6edf3") if unlocked else Color("#484f58"))
	vbox.add_child(nl)

	var dl = Label.new()
	dl.text = "Capacita: " + str(t.capacity) + " veicoli"
	dl.add_theme_font_size_override("font_size", 12)
	dl.add_theme_color_override("font_color", Color("#8b949e"))
	vbox.add_child(dl)

	# Distanze dai terminali posseduti
	var dists = []
	for owned_tid in GameManager.owned_terminals:
		var od = GameManager.get_terminal(owned_tid)
		var d = GameManager.dist_between(t.id, owned_tid)
		var mark = " <350" if d <= 350 else ""
		dists.append(od.city + ": " + str(d) + "km" + mark)
	if dists.size() > 0:
		var dist_l = Label.new()
		dist_l.text = "Distanze: " + ", ".join(dists)
		dist_l.add_theme_font_size_override("font_size", 11)
		dist_l.add_theme_color_override("font_color", Color("#8b949e"))
		dist_l.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(dist_l)

	var bh = HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	vbox.add_child(bh)

	var pl = Label.new()
	pl.text = "$" + _fmt(t.price)
	pl.add_theme_font_size_override("font_size", 16)
	pl.add_theme_color_override("font_color", Color("#e6edf3") if afford else Color("#f85149"))
	pl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bh.add_child(pl)

	if not unlocked:
		var ll = Label.new()
		ll.text = "CEO Lv." + str(t.unlock_level)
		ll.add_theme_font_size_override("font_size", 12)
		ll.add_theme_color_override("font_color", Color("#d29922"))
		bh.add_child(ll)
	elif afford:
		var btn = Button.new()
		btn.text = " Acquista Terminale "
		var bs = StyleBoxFlat.new()
		bs.bg_color = Color("#2ea043")
		bs.set_corner_radius_all(6)
		bs.content_margin_left = 14
		bs.content_margin_right = 14
		bs.content_margin_top = 5
		bs.content_margin_bottom = 5
		btn.add_theme_stylebox_override("normal", bs)
		btn.add_theme_color_override("font_color", Color("#ffffff"))
		btn.add_theme_font_size_override("font_size", 13)
		var tid = t.id
		btn.pressed.connect(func():
			GameManager.buy_terminal(tid)
			_rebuild()
		)
		bh.add_child(btn)

	return p

func _stat_row(parent: VBoxContainer, key: String, val: String, color: String):
	var hb = HBoxContainer.new()
	parent.add_child(hb)
	var kl = Label.new()
	kl.text = key
	kl.add_theme_font_size_override("font_size", 14)
	kl.add_theme_color_override("font_color", Color("#8b949e"))
	kl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(kl)
	var vl = Label.new()
	vl.text = val
	vl.add_theme_font_size_override("font_size", 14)
	vl.add_theme_color_override("font_color", Color(color))
	hb.add_child(vl)

func _panel() -> PanelContainer:
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#161b22")
	s.border_color = Color("#30363d")
	s.set_border_width_all(1)
	s.set_corner_radius_all(12)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
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
