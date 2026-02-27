# res://scripts/logistics_screen.gd
# Mappa OSM reale + contratti + consegne + trasferimenti
extends Control

var map_widget: Control
var deliveries_container: VBoxContainer
var contracts_container: VBoxContainer

func _ready():
	setup_ui()
	GameManager.delivery_completed.connect(func(_d): _update_contracts())
	GameManager.contract_accepted.connect(func(_c): _update_contracts())
	GameManager.transfer_completed.connect(func(_t): _update_contracts())

func setup_ui():
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)

	# ── MAPPA OSM ──
	var map_frame = PanelContainer.new()
	map_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fs = StyleBoxFlat.new()
	fs.bg_color = Color("#091525")
	fs.border_color = Color("#1f6feb44")
	fs.set_border_width_all(1)
	fs.set_corner_radius_all(12)
	map_frame.add_theme_stylebox_override("panel", fs)
	map_frame.custom_minimum_size = Vector2(0, 460)
	vbox.add_child(map_frame)
	var clip = Control.new()
	clip.set_anchors_preset(Control.PRESET_FULL_RECT)
	clip.clip_contents = true
	map_frame.add_child(clip)
	map_widget = OSMMap.new()
	map_widget.set_anchors_preset(Control.PRESET_FULL_RECT)
	clip.add_child(map_widget)

	# ── Zoom buttons ──
	var zh = HBoxContainer.new()
	zh.add_theme_constant_override("separation", 8)
	zh.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(zh)
	zh.add_child(_btn(" - ", func(): map_widget.change_zoom(-1)))
	zh.add_child(_btn(" Reset ", func(): map_widget.reset_view()))
	zh.add_child(_btn(" + ", func(): map_widget.change_zoom(1)))
	var ht = Label.new()
	ht.text = "Rotella=zoom | Trascina=sposta"
	ht.add_theme_font_size_override("font_size", 11)
	ht.add_theme_color_override("font_color", Color("#484f58"))
	zh.add_child(ht)

	# ── CONSEGNE ──
	vbox.add_child(_sep())
	deliveries_container = VBoxContainer.new()
	deliveries_container.add_theme_constant_override("separation", 6)
	vbox.add_child(deliveries_container)

	# ── CONTRATTI ──
	vbox.add_child(_sep())
	contracts_container = VBoxContainer.new()
	contracts_container.add_theme_constant_override("separation", 6)
	vbox.add_child(contracts_container)
	_update_contracts()

func _process(_d):
	_update_deliveries()
	if map_widget:
		map_widget.queue_redraw()

func _btn(text: String, cb: Callable) -> Button:
	var b = Button.new()
	b.text = text
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#21262d")
	s.border_color = Color("#30363d")
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_color_override("font_color", Color("#e6edf3"))
	b.add_theme_font_size_override("font_size", 14)
	b.pressed.connect(cb)
	return b

func _sep() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_color_override("separator", Color("#30363d"))
	return s

# ══════════ CONSEGNE + TRASFERIMENTI ══════════

func _update_deliveries():
	for c in deliveries_container.get_children():
		c.queue_free()
	var total = GameManager.active_deliveries.size() + GameManager.active_transfers.size()
	var t = Label.new()
	t.text = "In Corso (" + str(total) + ")"
	t.add_theme_font_size_override("font_size", 18)
	t.add_theme_color_override("font_color", Color("#e6edf3"))
	deliveries_container.add_child(t)
	if total == 0:
		var e = Label.new()
		e.text = "Nessuna consegna o trasferimento in corso"
		e.add_theme_font_size_override("font_size", 13)
		e.add_theme_color_override("font_color", Color("#8b949e"))
		deliveries_container.add_child(e)
		return
	for d in GameManager.active_deliveries:
		deliveries_container.add_child(_del_card(d, false))
	for tr in GameManager.active_transfers:
		deliveries_container.add_child(_del_card(tr, true))

func _del_card(d: Dictionary, is_transfer: bool) -> PanelContainer:
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#1c2333")
	s.border_color = Color("#1f6feb44") if not is_transfer else Color("#d2992244")
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", s)
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	var label_text = ""
	var from_city = ""
	var to_city = ""
	if is_transfer:
		from_city = GameManager.get_terminal(d.from_terminal).get("city", "?")
		to_city = GameManager.get_terminal(d.to_terminal).get("city", "?")
		label_text = "TRASF. " + d.vehicle.reg + ": " + from_city + " > " + to_city
	else:
		label_text = d.vehicle.reg + ": " + d.contract.origin + " > " + d.contract.destination
	var rl = Label.new()
	rl.text = label_text
	rl.add_theme_font_size_override("font_size", 13)
	rl.add_theme_color_override("font_color", Color("#d29922") if is_transfer else Color("#e6edf3"))
	vb.add_child(rl)
	var pb = ProgressBar.new()
	pb.min_value = 0
	pb.max_value = d.time_total
	pb.value = d.time_total - d.time_remaining
	pb.custom_minimum_size.y = 6
	pb.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("#30363d")
	bg.set_corner_radius_all(3)
	pb.add_theme_stylebox_override("background", bg)
	var fl = StyleBoxFlat.new()
	fl.bg_color = Color("#d29922") if is_transfer else Color("#1f6feb")
	fl.set_corner_radius_all(3)
	pb.add_theme_stylebox_override("fill", fl)
	vb.add_child(pb)
	var sec = int(d.time_remaining)
	var bl = Label.new()
	bl.text = str(sec / 60) + "m " + str(sec % 60) + "s"
	if not is_transfer:
		bl.text += "  |  $" + str(d.contract.payout)
	bl.add_theme_font_size_override("font_size", 11)
	bl.add_theme_color_override("font_color", Color("#8b949e"))
	vb.add_child(bl)
	return p

# ══════════ CONTRATTI ══════════

func _update_contracts():
	for c in contracts_container.get_children():
		c.queue_free()
	var t = Label.new()
	t.text = "Contratti (" + str(GameManager.available_contracts.size()) + ")"
	t.add_theme_font_size_override("font_size", 18)
	t.add_theme_color_override("font_color", Color("#e6edf3"))
	contracts_container.add_child(t)
	if GameManager.owned_vehicles.size() == 0:
		var h = Label.new()
		h.text = "Compra un veicolo nel Garage per iniziare"
		h.add_theme_font_size_override("font_size", 13)
		h.add_theme_color_override("font_color", Color("#d29922"))
		contracts_container.add_child(h)
	for i in range(GameManager.available_contracts.size()):
		contracts_container.add_child(_ctr_card(GameManager.available_contracts[i], i))

func _ctr_card(ct: Dictionary, idx: int) -> PanelContainer:
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#161b22")
	s.border_color = Color("#30363d")
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", s)
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	var rl = Label.new()
	rl.text = ct.origin + "  >  " + ct.destination
	rl.add_theme_font_size_override("font_size", 15)
	rl.add_theme_color_override("font_color", Color("#e6edf3"))
	vb.add_child(rl)
	var dl = Label.new()
	dl.text = str(ct.distance_km) + " km | " + str(ct.weight_kg) + " kg | " + ct.cargo_type
	dl.add_theme_font_size_override("font_size", 11)
	dl.add_theme_color_override("font_color", Color("#8b949e"))
	vb.add_child(dl)
	var bh = HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	vb.add_child(bh)
	var py = Label.new()
	py.text = "$" + str(ct.payout)
	py.add_theme_font_size_override("font_size", 16)
	py.add_theme_color_override("font_color", Color("#2ea043"))
	py.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bh.add_child(py)
	# Veicoli disponibili al terminale di partenza
	var avail = GameManager.vehicles_at(ct.origin_terminal)
	if avail.size() > 0:
		var btn = Button.new()
		btn.text = " Accetta "
		var bs = StyleBoxFlat.new()
		bs.bg_color = Color("#1f6feb")
		bs.set_corner_radius_all(6)
		bs.content_margin_left = 14
		bs.content_margin_right = 14
		bs.content_margin_top = 5
		bs.content_margin_bottom = 5
		btn.add_theme_stylebox_override("normal", bs)
		btn.add_theme_color_override("font_color", Color("#ffffff"))
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(func(): _accept(idx))
		bh.add_child(btn)
	else:
		var nl = Label.new()
		nl.text = "Nessun veicolo a " + ct.origin
		nl.add_theme_font_size_override("font_size", 11)
		nl.add_theme_color_override("font_color", Color("#f85149"))
		bh.add_child(nl)
	return p

func _accept(ci: int):
	if ci >= GameManager.available_contracts.size():
		return
	var ct = GameManager.available_contracts[ci]
	var avail = GameManager.vehicles_at(ct.origin_terminal)
	if avail.size() == 0:
		return
	var vi = GameManager.owned_vehicles.find(avail[0])
	if GameManager.accept_contract(ci, vi):
		_update_contracts()


# ══════════════════════════════════════════════════════════════
# OSM TILE MAP - Scarica tiles OpenStreetMap in tempo reale
# ══════════════════════════════════════════════════════════════
class OSMMap extends Control:
	# Usa CartoDB Dark Matter per tema scuro (gratis, no API key)
	const TILE_URL = "https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png"
	const TILE_SIZE = 256

	# Camera
	var center_lon: float = 9.0
	var center_lat: float = 45.5
	var zoom_level: int = 6
	var MIN_ZOOM: int = 4
	var MAX_ZOOM: int = 10

	# Pan
	var is_dragging: bool = false
	var drag_start: Vector2 = Vector2.ZERO
	var drag_lon: float = 0.0
	var drag_lat: float = 0.0

	# Tile cache e download
	var tile_cache: Dictionary = {}      # "z/x/y" -> ImageTexture
	var pending: Dictionary = {}         # "z/x/y" -> true
	var download_queue: Array = []
	var http_pool: Array = []
	var MAX_HTTP: int = 6

	# Animazione
	var pulse: float = 0.0

	func _ready():
		mouse_filter = Control.MOUSE_FILTER_STOP
		# Crea pool di HTTPRequest
		for i in MAX_HTTP:
			var http = HTTPRequest.new()
			http.use_threads = true
			add_child(http)
			http_pool.append({"node": http, "busy": false, "key": ""})

	func _process(delta):
		pulse += delta
		_process_queue()

	func change_zoom(delta_z: int):
		zoom_level = clampi(zoom_level + delta_z, MIN_ZOOM, MAX_ZOOM)
		queue_redraw()

	func reset_view():
		center_lon = 9.0
		center_lat = 45.5
		zoom_level = 6
		queue_redraw()

	# ── Input: zoom con rotella, pan con drag ──
	func _gui_input(event):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				zoom_level = clampi(zoom_level + 1, MIN_ZOOM, MAX_ZOOM)
				queue_redraw()
				accept_event()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				zoom_level = clampi(zoom_level - 1, MIN_ZOOM, MAX_ZOOM)
				queue_redraw()
				accept_event()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					is_dragging = true
					drag_start = event.position
					drag_lon = center_lon
					drag_lat = center_lat
				else:
					is_dragging = false
				accept_event()
		if event is InputEventMouseMotion and is_dragging:
			var dx = event.position.x - drag_start.x
			var dy = event.position.y - drag_start.y
			var n = pow(2, zoom_level)
			var lon_per_px = 360.0 / (n * TILE_SIZE)
			var lat_per_px = 170.0 / (n * TILE_SIZE)  # approssimazione
			center_lon = drag_lon - dx * lon_per_px
			center_lat = drag_lat + dy * lat_per_px
			center_lat = clampf(center_lat, -85, 85)
			queue_redraw()
			accept_event()

	# ── Coordinate geo <-> pixel ──
	func geo_to_world_px(lon: float, lat: float) -> Vector2:
		var n = pow(2, zoom_level)
		var x = (lon + 180.0) / 360.0 * n * TILE_SIZE
		var lat_r = deg_to_rad(lat)
		var y = (1.0 - log(tan(lat_r) + 1.0 / cos(lat_r)) / PI) / 2.0 * n * TILE_SIZE
		return Vector2(x, y)

	func geo_to_screen(lon: float, lat: float) -> Vector2:
		var wp = geo_to_world_px(lon, lat)
		var cp = geo_to_world_px(center_lon, center_lat)
		return wp - cp + size / 2.0

	# ── Download tiles ──
	func _request_tile(z: int, tx: int, ty: int):
		var key = str(z) + "/" + str(tx) + "/" + str(ty)
		if tile_cache.has(key) or pending.has(key):
			return
		pending[key] = true
		download_queue.append({"z": z, "x": tx, "y": ty, "key": key})

	func _process_queue():
		for h in http_pool:
			if not h.busy and download_queue.size() > 0:
				var item = download_queue.pop_front()
				h.busy = true
				h.key = item.key
				var url = TILE_URL.replace("{z}", str(item.z)).replace("{x}", str(item.x)).replace("{y}", str(item.y))
				var http_node: HTTPRequest = h.node
				# Disconnetti segnale precedente se presente
				if http_node.is_connected("request_completed", Callable()):
					pass  # Non serve, usiamo lambda con riferimento
				# Connessione one-shot
				var pool_entry = h
				var tile_key = item.key
				var cb = func(result, code, headers, body):
					_on_tile_done(result, code, body, tile_key, pool_entry)
				if http_node.is_connected("request_completed", cb):
					http_node.disconnect("request_completed", cb)
				# Pulisci connessioni vecchie
				for conn in http_node.get_signal_connection_list("request_completed"):
					http_node.disconnect("request_completed", conn.callable)
				http_node.connect("request_completed", cb, CONNECT_ONE_SHOT)
				http_node.request(url, ["User-Agent: TransportEmpire/1.0"])

	func _on_tile_done(result: int, code: int, body: PackedByteArray, key: String, pool_entry: Dictionary):
		pool_entry.busy = false
		pending.erase(key)
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var img = Image.new()
			if img.load_png_from_buffer(body) == OK:
				var tex = ImageTexture.create_from_image(img)
				tile_cache[key] = tex
				queue_redraw()

	# ── DRAW ──
	func _draw():
		var w = size.x
		var h = size.y

		# Sfondo
		draw_rect(Rect2(0, 0, w, h), Color("#091525"))

		var n_tiles = int(pow(2, zoom_level))
		var center_wp = geo_to_world_px(center_lon, center_lat)

		# Calcola range tiles visibili
		var top_left_wp = center_wp - size / 2.0
		var bottom_right_wp = center_wp + size / 2.0

		var tx_min = int(floor(top_left_wp.x / TILE_SIZE)) - 1
		var tx_max = int(floor(bottom_right_wp.x / TILE_SIZE)) + 1
		var ty_min = int(floor(top_left_wp.y / TILE_SIZE)) - 1
		var ty_max = int(floor(bottom_right_wp.y / TILE_SIZE)) + 1

		ty_min = clampi(ty_min, 0, n_tiles - 1)
		ty_max = clampi(ty_max, 0, n_tiles - 1)

		# Disegna tiles
		for tx in range(tx_min, tx_max + 1):
			var wrapped_tx = tx % n_tiles
			if wrapped_tx < 0:
				wrapped_tx += n_tiles
			for ty in range(ty_min, ty_max + 1):
				var key = str(zoom_level) + "/" + str(wrapped_tx) + "/" + str(ty)
				var screen_x = tx * TILE_SIZE - center_wp.x + w / 2.0
				var screen_y = ty * TILE_SIZE - center_wp.y + h / 2.0
				var tile_rect = Rect2(screen_x, screen_y, TILE_SIZE, TILE_SIZE)

				if tile_cache.has(key):
					draw_texture_rect(tile_cache[key], tile_rect, false)
				else:
					# Placeholder scuro mentre carica
					draw_rect(tile_rect, Color("#0d1a2d"))
					draw_rect(tile_rect, Color("#ffffff06"), false, 0.5)
					# Richiedi download
					_request_tile(zoom_level, wrapped_tx, ty)

		# ── ROTTE ATTIVE (consegne) ──
		for d in GameManager.active_deliveries:
			var orig_t = GameManager.get_terminal(d.contract.origin_terminal)
			var dest_t = GameManager.get_terminal(d.contract.dest_terminal)
			if orig_t.size() > 0 and dest_t.size() > 0:
				var p1 = geo_to_screen(orig_t.lon, orig_t.lat)
				var p2 = geo_to_screen(dest_t.lon, dest_t.lat)
				var prog = clampf(1.0 - d.time_remaining / d.time_total, 0.0, 1.0)
				var tp = p1.lerp(p2, prog)
				# Rotta
				draw_line(p1, p2, Color("#1f6feb44"), 2.0)
				draw_line(p1, tp, Color("#1f6feb"), 3.0)
				# Camion
				var gl = 8.0 + sin(pulse * 3.0) * 2.0
				draw_circle(tp, gl, Color("#1f6feb33"))
				draw_circle(tp, 5, Color("#1f6feb"))
				draw_circle(tp, 3, Color("#ffffff"))
				# Targa
				if zoom_level >= 7:
					draw_string(ThemeDB.fallback_font, tp + Vector2(8, -4), d.vehicle.reg, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#58a6ff"))

		# ── ROTTE TRASFERIMENTI ──
		for t in GameManager.active_transfers:
			var from_t = GameManager.get_terminal(t.from_terminal)
			var to_t = GameManager.get_terminal(t.to_terminal)
			if from_t.size() > 0 and to_t.size() > 0:
				var p1 = geo_to_screen(from_t.lon, from_t.lat)
				var p2 = geo_to_screen(to_t.lon, to_t.lat)
				var prog = clampf(1.0 - t.time_remaining / t.time_total, 0.0, 1.0)
				var tp = p1.lerp(p2, prog)
				_dash(p1, p2, Color("#d2992244"), 2.0, 6, 4)
				_dash(p1, tp, Color("#d29922"), 2.0, 6, 4)
				draw_circle(tp, 5, Color("#d29922"))
				draw_circle(tp, 3, Color("#ffffff"))
				if zoom_level >= 7:
					draw_string(ThemeDB.fallback_font, tp + Vector2(8, -4), "TRASF", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#d29922"))

		# ── CITTA (tutte dal catalogo) ──
		for t in GameManager.terminal_catalog:
			var pos = geo_to_screen(t.lon, t.lat)
			# Fuori schermo? Skip
			if pos.x < -50 or pos.x > w + 50 or pos.y < -50 or pos.y > h + 50:
				continue
			var owned = t.id in GameManager.owned_terminals
			var rad = 6.0 if owned else 3.0

			if owned:
				var gr = rad + 4.0 + sin(pulse * 2.0 + t.lon) * 2.0
				draw_circle(pos, gr, Color("#2ea04322"))
				draw_circle(pos, rad, Color("#2ea043"))
				draw_circle(pos, 2, Color("#ffffffbb"))
				# Conteggio veicoli
				var vc = GameManager.count_at(t.id)
				var cap = GameManager.capacity_of(t.id)
				if zoom_level >= 6:
					draw_string(ThemeDB.fallback_font, pos + Vector2(10, 4), t.city + " [" + str(vc) + "/" + str(cap) + "]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#e6edf3"))
				elif zoom_level >= 5:
					draw_string(ThemeDB.fallback_font, pos + Vector2(8, 4), t.city, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e6edf3"))
			else:
				draw_circle(pos, rad, Color("#30363d88"))
				if zoom_level >= 7:
					draw_string(ThemeDB.fallback_font, pos + Vector2(6, 4), t.city, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#8b949e55"))

		# ── Zoom label ──
		draw_string(ThemeDB.fallback_font, Vector2(w - 60, 14), "z" + str(zoom_level), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#484f58"))
		# Attribution
		draw_string(ThemeDB.fallback_font, Vector2(4, h - 4), "CartoDB | OSM", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#484f5844"))

	func _dash(from: Vector2, to: Vector2, col: Color, width: float, dash: float, gap: float):
		var dir = (to - from).normalized()
		var total = from.distance_to(to)
		var cur = 0.0
		while cur < total:
			var s = from + dir * cur
			var e = from + dir * minf(cur + dash, total)
			draw_line(s, e, col, width)
			cur += dash + gap
