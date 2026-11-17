extends Control
## Menu utama The Unwritten Tale. Seluruh UI dibangun lewat kode, jadi scene-nya hanya satu node Control.
## Pasang sebagai Main Scene: Project Settings > Application > Run > Main Scene.

const GAME_SCENE := "res://maincontrol.tscn"          # <- ubah ke path scene game kamu
const DICE_SCRIPT := "res://dice_2d.gd"        # <- ubah kalau skrip dadu ada di folder lain (opsional)
const FONT_PATH := "res://assets/font/Merriweather-VariableFont_opsz,wdth,wght.ttf"
const SERVER_HOST := "127.0.0.1"
const SERVER_PORT := 8080

# Palet yang sama dengan UI game
const C_BG := Color("#EAE2D3")
const C_TAN := Color("#B8AA8A")
const C_INK := Color("#4A443F")
const C_MUTED := Color("#8C8378")
const C_HEAD := Color("#B5AB9B")
const C_EDGE := Color("#CBBFAE")
const C_GOLD := Color("#C99700")
const C_OK := Color("#2E7D32")
const C_BAD := Color("#B3261E")

# huruf yang melayang di latar (campuran huruf judul dan alfabet biasa)
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabdefghklmnrstw"

const TEASES := [
	"Oakhaven is burning. Someone has to stand in the smoke.",
	"A blank book is waiting to write your name.",
	"Roll well. The Tome remembers.",
	"Not every hero walks in through the front gate.",
	"Somewhere beneath the crypt, a Scribe is holding the pen.",
	"Your story has not been written yet.",
]

var _font: Font
var _bold_font: Font
var _ai: AIClient
var _status: Label
var _tease: Label
var _die: Label
var _btn_new: Button
var _help_layer: Control
var _help_panel: PanelContainer
var _fade: ColorRect
var _starting := false
var _intro_nodes: Array = []
var _fx: Control


func _ready() -> void:
	_font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else null
	if _font != null:
		# Huruf tebal memakai sumbu weight dari font variabel (bukan bold sintetis), seperti di story log
		var ts := TextServerManager.get_primary_interface()
		var bold := FontVariation.new()
		bold.base_font = _font
		bold.variation_opentype = {ts.name_to_tag("weight"): 700}
		_bold_font = bold
	_build()
	_play_intro()
	_btn_new.grab_focus()
	_poll_server()
	_cycle_teases()
	_auto_roll()
	_letter_rain()


# ===================================================================== pembangunan UI
func _label(text: String, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if _font != null:
		l.add_theme_font_override("font", _font)
	return l


func _box(bg: Color, edge: Color, edge_w := 0, pad_h := 18, pad_v := 8) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.set_corner_radius_all(0)
	st.content_margin_left = pad_h
	st.content_margin_right = pad_h
	st.content_margin_top = pad_v
	st.content_margin_bottom = pad_v
	if edge_w > 0:
		st.border_color = edge
		st.set_border_width_all(edge_w)
	return st


func _button(text: String, primary: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 50)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 20)
	if _font != null:
		b.add_theme_font_override("font", _font)
	if primary:
		b.add_theme_stylebox_override("normal", _box(C_TAN, C_TAN, 1))
		b.add_theme_stylebox_override("hover", _box(C_TAN.darkened(0.1), C_TAN.darkened(0.1), 1))
		b.add_theme_stylebox_override("pressed", _box(C_TAN.darkened(0.22), C_TAN.darkened(0.22), 1))
		b.add_theme_color_override("font_color", Color("#F6F0E4"))
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_pressed_color", Color.WHITE)
		b.add_theme_color_override("font_focus_color", Color.WHITE)
	else:
		b.add_theme_stylebox_override("normal", _box(Color(0, 0, 0, 0), C_TAN, 1))
		b.add_theme_stylebox_override("hover", _box(Color(C_TAN, 0.25), C_TAN, 1))
		b.add_theme_stylebox_override("pressed", _box(Color(C_TAN, 0.45), C_TAN, 1))
		b.add_theme_color_override("font_color", C_MUTED)
		b.add_theme_color_override("font_hover_color", C_INK)
		b.add_theme_color_override("font_pressed_color", C_INK)
		b.add_theme_color_override("font_focus_color", C_INK)
	b.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), C_INK, 2))
	# efek membesar halus saat disorot mouse atau keyboard
	b.resized.connect(func(): b.pivot_offset = b.size * 0.5)
	b.mouse_entered.connect(_pop.bind(b, 1.05))
	b.mouse_exited.connect(_pop.bind(b, 1.0))
	b.focus_entered.connect(_pop.bind(b, 1.05))
	b.focus_exited.connect(_pop.bind(b, 1.0))
	return b


func _pop(b: Control, s: float) -> void:
	create_tween().tween_property(b, "scale", Vector2.ONE * s, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _ornament() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 8)
	var l := ColorRect.new()
	l.color = C_TAN
	l.custom_minimum_size = Vector2(90, 2)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var r := ColorRect.new()
	r.color = C_TAN
	r.custom_minimum_size = Vector2(90, 2)
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(18, 18)
	var dia := ColorRect.new()
	dia.color = C_GOLD
	dia.size = Vector2(9, 9)
	dia.position = Vector2(4.5, 4.5)
	dia.pivot_offset = Vector2(4.5, 4.5)
	dia.rotation_degrees = 45.0
	holder.add_child(dia)
	h.add_child(l)
	h.add_child(holder)
	h.add_child(r)
	# berdenyut pelan
	var tw := create_tween().set_loops()
	tw.tween_property(dia, "scale", Vector2.ONE * 1.4, 1.1).set_trans(Tween.TRANS_SINE)
	tw.tween_property(dia, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_SINE)
	return h


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# latar: kertas dengan cahaya lembut di tengah
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var glow_grad := Gradient.new()
	glow_grad.colors = PackedColorArray([Color("#F6F0E2"), Color("#E3D9C6")])
	var glow := GradientTexture2D.new()
	glow.gradient = glow_grad
	glow.fill = GradientTexture2D.FILL_RADIAL
	glow.fill_from = Vector2(0.5, 0.45)
	glow.fill_to = Vector2(1.0, 1.0)
	glow.width = 256
	glow.height = 256
	var vignette := TextureRect.new()
	vignette.texture = glow
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# huruf yang melayang naik di belakang menu
	_fx = Control.new()
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fx)
	_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# bingkai ganda
	var frame := Panel.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0), C_TAN, 6))
	add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inner := Panel.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0), C_EDGE, 1))
	add_child(inner)
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(col)

	# dadu d20 yang berguling sendiri (klik untuk melempar)
	if ResourceLoader.exists(DICE_SCRIPT):
		_die = Label.new()
		_die.set_script(load(DICE_SCRIPT))
		_die.set("die_size", 96.0)
		_die.set("number_font_size", 36)
		_die.text = "20"
		_die.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_die.mouse_filter = Control.MOUSE_FILTER_STOP
		_die.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_die.tooltip_text = "Roll the die"
		_die.gui_input.connect(_on_die_input)
		col.add_child(_die)

	var title := _label("THE UNWRITTEN TALE", 60, C_INK)
	title.add_theme_color_override("font_shadow_color", Color(C_TAN, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 0)
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.visible_ratio = 0.0   # judul "menulis dirinya sendiri"
	var ornament := _ornament()
	var sub := _label("Every action is a roll. Every roll writes the story.", 18, C_MUTED)
	_tease = _label("", 15, C_HEAD)
	_tease.custom_minimum_size = Vector2(0, 24)
	_tease.modulate.a = 0.0
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 18)
	_btn_new = _button("New Game", true)
	var btn_help := _button("How to Play", false)
	var btn_quit := _button("Quit", false)
	if OS.has_feature("web"):
		btn_quit.visible = false
	_status = _label("AI server: checking...", 14, C_MUTED)

	for n in [title, ornament, sub, _tease, gap, _btn_new, btn_help, btn_quit, _status]:
		col.add_child(n)

	_btn_new.pressed.connect(_start_game)
	btn_help.pressed.connect(_toggle_help.bind(true))
	btn_quit.pressed.connect(func(): get_tree().quit())

	_build_help()

	# lapisan fade untuk transisi ke game
	_fade = ColorRect.new()
	_fade.color = Color(C_BG, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# judul ditulis huruf demi huruf, sisanya muncul bergantian sesudahnya
	_title_node = title
	_intro_nodes = [ornament, sub, _btn_new, btn_help, btn_quit, _status]
	if _die != null:
		_intro_nodes.push_front(_die)


var _title_node: Label


func _build_help() -> void:
	_help_layer = Control.new()
	_help_layer.visible = false
	add_child(_help_layer)
	_help_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(C_INK, 0.45)
	_help_layer.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_toggle_help(false))

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_layer.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_help_panel = PanelContainer.new()
	_help_panel.custom_minimum_size = Vector2(600, 0)
	_help_panel.add_theme_stylebox_override("panel", _box(C_BG, C_TAN, 2, 30, 24))
	center.add_child(_help_panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_help_panel.add_child(col)

	col.add_child(_label("HOW TO PLAY", 24, C_HEAD, HORIZONTAL_ALIGNMENT_LEFT))
	var rule := ColorRect.new()
	rule.color = C_EDGE
	rule.custom_minimum_size = Vector2(0, 1)
	col.add_child(rule)

	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("default_color", C_INK)
	body.add_theme_font_size_override("normal_font_size", 16)
	body.add_theme_font_size_override("bold_font_size", 16)
	if _font != null:
		body.add_theme_font_override("normal_font", _font)
		body.add_theme_font_override("bold_font", _bold_font)
	body.text = "\n".join([
		"[b]Say what you do.[/b] Type your action in your own words: talk, explore, fight, sneak. The Tome turns it into a game action and narrates the result.",
		"",
		"[b]Risky actions are a d20 roll.[/b] d20 + stat modifier + level bonus (+ item or skill) against a DC, or against the enemy's AC when you attack. A natural 20 always succeeds and a natural 1 always fails.",
		"",
		"[b]Hits roll damage dice.[/b] Your weapon's dice plus your modifier. The dice are thrown on screen.",
		"",
		"[b]Items and skills.[/b] Click a consumable or press Use on a skill. Skills cost mana, which regenerates a little every turn.",
		"",
		"[b]Commands.[/b] /help, /new (start over), /menu (back to this screen).",
	])
	col.add_child(body)

	var close := _button("Close", true)
	close.custom_minimum_size = Vector2(160, 42)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.pressed.connect(_toggle_help.bind(false))
	col.add_child(close)


# ===================================================================== perilaku
func _spawn_letter(preseed := false) -> void:
	## Satu huruf muncul pudar, melayang naik sambil sedikit miring, lalu hilang.
	var area := get_viewport_rect().size
	var depth := randf()                                   # 0 = jauh (kecil, pelan), 1 = dekat (besar)
	var fsize := int(lerpf(18.0, 56.0, depth))
	var l := Label.new()
	l.text = LETTERS[randi() % LETTERS.length()]
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", C_GOLD if randf() < 0.35 else C_TAN)
	if _font != null:
		l.add_theme_font_override("font", _font)
	var x := randf_range(10.0, maxf(area.x - fsize - 10.0, 11.0))
	var start_y := randf_range(0.0, area.y) if preseed else area.y + 20.0
	var travel := randf_range(260.0, 520.0)
	var dur := randf_range(8.0, 13.0) * lerpf(1.2, 0.8, depth)
	var peak := randf_range(0.30, 0.60)
	var tilt := randf_range(-18.0, 18.0)
	l.modulate.a = 0.0
	l.position = Vector2(x, start_y)
	l.rotation_degrees = tilt
	_fx.add_child(l)
	var move := l.create_tween().set_parallel(true)
	move.tween_property(l, "position:y", start_y - travel, dur)
	move.tween_property(l, "position:x", x + randf_range(-40.0, 40.0), dur).set_trans(Tween.TRANS_SINE)
	move.tween_property(l, "rotation_degrees", tilt + randf_range(-25.0, 25.0), dur)
	var fade := l.create_tween()
	fade.tween_property(l, "modulate:a", peak, dur * 0.25).set_trans(Tween.TRANS_SINE)
	fade.tween_property(l, "modulate:a", 0.0, dur * 0.75).set_trans(Tween.TRANS_SINE)
	fade.finished.connect(l.queue_free)


func _letter_rain() -> void:
	for i in 14:
		_spawn_letter(true)
	while is_inside_tree() and not _starting:
		_spawn_letter()
		await get_tree().create_timer(randf_range(0.35, 0.8)).timeout


func _play_intro() -> void:
	modulate = Color.WHITE
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_title_node, "visible_ratio", 1.0, 1.5).set_delay(0.25).set_trans(Tween.TRANS_SINE)
	for i in _intro_nodes.size():
		var n: Control = _intro_nodes[i]
		n.modulate.a = 0.0
		tw.tween_property(n, "modulate:a", 1.0, 0.7).set_delay(0.9 + 0.12 * i).set_trans(Tween.TRANS_SINE)


func _cycle_teases() -> void:
	await get_tree().create_timer(2.0).timeout
	var i := randi() % TEASES.size()
	while is_inside_tree() and not _starting:
		_tease.text = TEASES[i]
		var tw := create_tween()
		tw.tween_property(_tease, "modulate:a", 1.0, 0.8)
		tw.tween_interval(3.6)
		tw.tween_property(_tease, "modulate:a", 0.0, 0.8)
		await tw.finished
		i = (i + 1) % TEASES.size()


func _on_die_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		_die.call("roll_dice", randi_range(1, 20))


func _auto_roll() -> void:
	if _die == null:
		return
	await get_tree().create_timer(2.2).timeout
	while is_inside_tree() and not _starting:
		if not bool(_die.get("is_rolling")):
			_die.call("roll_dice", randi_range(1, 20))
		await get_tree().create_timer(randf_range(4.5, 7.0)).timeout


func _toggle_help(open: bool) -> void:
	if open:
		_help_layer.visible = true
		_help_panel.modulate.a = 0.0
		await get_tree().process_frame
		_help_panel.pivot_offset = _help_panel.size * 0.5
		_help_panel.scale = Vector2.ONE * 0.94
		var tw := create_tween().set_parallel(true)
		tw.tween_property(_help_panel, "modulate:a", 1.0, 0.2)
		tw.tween_property(_help_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_help_layer.visible = false
		_btn_new.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _help_layer.visible:
		_toggle_help(false)
		get_viewport().set_input_as_handled()


func _start_game() -> void:
	if _starting:
		return
	if not ResourceLoader.exists(GAME_SCENE):
		_status.text = "Game scene not found: %s (set GAME_SCENE in main_menu.gd)" % GAME_SCENE
		_status.add_theme_color_override("font_color", C_BAD)
		return
	_starting = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.45)
	await tw.finished
	get_tree().change_scene_to_file(GAME_SCENE)


## Menampilkan status server AI (server_app) supaya pemain tahu sebelum masuk game.
func _poll_server() -> void:
	_ai = AIClient.new()
	_ai.host = SERVER_HOST
	_ai.port = SERVER_PORT
	add_child(_ai)
	while is_inside_tree() and not _starting:
		var ok: bool = await _ai.is_server_ready()
		if not is_inside_tree():
			return
		if ok:
			_status.text = "AI server: ready"
			_status.add_theme_color_override("font_color", C_OK)
		else:
			_status.text = "AI server: not found. Start server_app before playing."
			_status.add_theme_color_override("font_color", C_BAD)
		await get_tree().create_timer(3.0).timeout
