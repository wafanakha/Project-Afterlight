extends Label


signal roll_finished(result: int, severity: String)

@export var die_size: float = 80.0
@export var number_font_size: int = 30
@export var flight_time: float = 1.0
@export var quick_factor: float = 0.55        # dadu damage terbang lebih singkat
@export var spins: float = 2.5
@export var peak_scale: float = 1.45
@export var sfx_tick: AudioStream
@export var sfx_land: AudioStream
@export var sfx_crit: AudioStream

const INK := Color("#4A443F")
const FACE := Color("#FBF6EA")
const ANTICIPATION := 0.12

const COL_CRIT_WIN := Color("#C99700")
const COL_WIN := Color("#2E7D32")
const COL_FAIL := Color("#C2571A")
const COL_CRIT_FAIL := Color("#B3261E")
const COL_DAMAGE := Color("#8A4B08")
const COL_ENEMY := Color("#A1401A")

const FONT_PATH := "res://assets/font/Merriweather-VariableFont_opsz,wdth,wght.ttf"

var is_rolling := false
var final_result := 1
var current_sides := 20
var current_tone := ""

var _flying := false
var _ft := 1.0                      # lama terbang dadu yang sedang dilempar

var _run_id := 0
var _face: DieFace
var _particles: CPUParticles2D
var _audio: AudioStreamPlayer
var _tweens: Array[Tween] = []


class DieFace extends Control:
	var sides: int = 20:
		set(v):
			sides = v
			queue_redraw()
	var accent: Color = Color("#4A443F"):
		set(v):
			accent = v
			queue_redraw()
	var face_color: Color = Color("#FBF6EA"):
		set(v):
			face_color = v
			queue_redraw()
	var glow: float = 0.0:
		set(v):
			glow = v
			queue_redraw()
	var ring: float = 1.0:
		set(v):
			ring = v
			queue_redraw()
	var flash: float = 0.0:
		set(v):
			flash = v
			queue_redraw()
	var cracked: bool = false:
		set(v):
			cracked = v
			queue_redraw()

	func _shape(c: Vector2, r: float) -> PackedVector2Array:
		var n := 6
		var start := -90.0
		var rr := r
		match sides:
			4:
				n = 3
			6:
				n = 4
				start = -45.0
				rr = r * 0.92
			8:
				n = 4
			10:
				n = 5
			12:
				n = 10
		var pts := PackedVector2Array()
		for i in n:
			pts.append(c + Vector2.from_angle(deg_to_rad(start + 360.0 / n * i)) * rr)
		return pts

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.44
		var hex := _shape(c, r)

		if glow > 0.01:
			for i in 3:
				var gc := accent
				gc.a = glow * (0.20 - i * 0.055)
				draw_colored_polygon(_shape(c, r * (1.16 + i * 0.12)), gc)

		if ring < 1.0:
			var rc := accent
			rc.a = (1.0 - ring) * 0.85
			draw_arc(c, r * (1.0 + ring * 0.85), 0.0, TAU, 56, rc, 3.0, true)

		draw_colored_polygon(hex, face_color)

		var line_col := accent
		line_col.a = 0.42
		if sides == 20:
			var tri: Array[Vector2] = []
			for k in 3:
				tri.append(c + Vector2.from_angle(deg_to_rad(-90.0 + 120.0 * k)) * r * 0.64)
			for k in 3:
				draw_line(tri[k], tri[(k + 1) % 3], line_col, 1.6, true)
				var base_angle := -90.0 + 120.0 * k
				for off in [-60.0, 0.0, 60.0]:
					draw_line(tri[k], c + Vector2.from_angle(deg_to_rad(base_angle + off)) * r, line_col, 1.4, true)
		else:
			for p in hex:
				draw_line(c + (p - c).normalized() * r * 0.47, p, line_col, 1.4, true)

		if cracked:
			var crack := PackedVector2Array([
				c + Vector2(0.06, -0.98) * r, c + Vector2(-0.14, -0.58) * r, c + Vector2(0.10, -0.22) * r,
				c + Vector2(-0.10, 0.18) * r, c + Vector2(0.15, 0.56) * r, c + Vector2(0.0, 0.96) * r])
			draw_polyline(crack, accent, 2.6, true)

		draw_circle(c, r * 0.47, face_color)
		draw_arc(c, r * 0.47, 0.0, TAU, 40, line_col, 1.4, true)

		var outline := hex.duplicate()
		outline.append(hex[0])
		draw_polyline(outline, accent, 3.2, true)

		if flash > 0.01:
			draw_colored_polygon(hex, Color(1, 1, 1, flash * 0.75))


func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	custom_minimum_size = custom_minimum_size.max(Vector2(die_size, die_size))
	add_theme_color_override("font_color", INK)
	if ResourceLoader.exists(FONT_PATH):
		var base: Font = load(FONT_PATH)
		var ts := TextServerManager.get_primary_interface()
		var bold := FontVariation.new()
		bold.base_font = base
		bold.variation_opentype = {ts.name_to_tag("weight"): 700}   # angka tebal, terbaca jelas di atas wajah dadu
		add_theme_font_override("font", bold)
	add_theme_font_size_override("font_size", number_font_size)
	modulate = Color.WHITE
	if text.strip_edges() == "":
		text = "20"

	_face = DieFace.new()
	_face.show_behind_parent = true
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_face)
	_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_particles = _make_particles()
	add_child(_particles)
	_audio = AudioStreamPlayer.new()
	add_child(_audio)

	resized.connect(_on_resized)
	_on_resized()


func _on_resized() -> void:
	pivot_offset = size * 0.5
	if _particles:
		_particles.position = size * 0.5


func _make_particles() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = 28
	p.lifetime = 0.9
	p.explosiveness = 1.0
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.initial_velocity_min = 110.0
	p.initial_velocity_max = 240.0
	p.gravity = Vector2(0, 280)
	p.scale_amount_min = 2.5
	p.scale_amount_max = 5.0
	var g := Gradient.new()
	g.colors = PackedColorArray([Color("#FFE27A"), Color("#E0A800"), Color(0.88, 0.66, 0.0, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	p.color_ramp = g
	return p


func roll_dice(result: int, sides: int = 20, tone: String = "") -> void:
	if is_rolling:
		return
	_run(result, sides, tone)


## Lempar beberapa dadu sejenis satu per satu. Pemakaian: await dice_2d.roll_many(6, [3, 5], "damage")
func roll_many(sides: int, results: Array, tone: String = "") -> void:
	for i in results.size():
		roll_dice(int(results[i]), sides, tone)
		await roll_finished
		if i < results.size() - 1:
			await get_tree().create_timer(0.1).timeout


func skip() -> void:
	if not is_rolling:
		return
	_run_id += 1
	_kill_tweens()
	_finish_now()


func _is_d20() -> bool:
	return current_sides == 20 and current_tone == ""


func _is_max_damage() -> bool:
	return not _is_d20() and final_result == current_sides and (current_tone == "" or current_tone == "damage")


func _style_for(result: int) -> Dictionary:
	if _is_d20():
		if result == 20:
			return {"color": COL_CRIT_WIN, "face": Color("#FFF4C9"), "sev": "CRITICAL SUCCESS"}
		if result == 1:
			return {"color": COL_CRIT_FAIL, "face": Color("#F9DAD6"), "sev": "CRITICAL FAILURE"}
		if result >= 10:
			return {"color": COL_WIN, "face": Color("#EAF5E6"), "sev": "SUCCESS"}
		return {"color": COL_FAIL, "face": Color("#FBE9D8"), "sev": "FAILURE"}
	match current_tone:
		"enemy":
			return {"color": COL_ENEMY, "face": Color("#F6E1D8"), "sev": "ENEMY DAMAGE"}
		"fumble":
			return {"color": COL_CRIT_FAIL, "face": Color("#F9DAD6"), "sev": "FUMBLE"}
	if _is_max_damage():
		return {"color": COL_CRIT_WIN, "face": Color("#FFF4C9"), "sev": "MAX DAMAGE"}
	return {"color": COL_DAMAGE, "face": Color("#FBF0E0"), "sev": "DAMAGE"}


func _new_tween() -> Tween:
	var t := create_tween()
	_tweens.append(t)
	return t


func _kill_tweens() -> void:
	for t in _tweens:
		if t and t.is_valid():
			t.kill()
	_tweens.clear()


func _play(stream: AudioStream) -> void:
	if stream == null or _audio == null:
		return
	_audio.stream = stream
	_audio.play()


func _run(result: int, sides: int, tone: String) -> void:
	_run_id += 1
	var my_id := _run_id
	current_sides = maxi(sides, 2)
	current_tone = tone
	final_result = clampi(result, 1, current_sides)
	_ft = flight_time if _is_d20() else flight_time * quick_factor
	is_rolling = true
	_flying = true
	_kill_tweens()

	# reset
	_face.sides = current_sides
	_face.accent = INK
	_face.face_color = FACE
	_face.cracked = false
	_face.flash = 0.0
	_face.ring = 1.0
	var fade := _new_tween()
	fade.tween_property(_face, "glow", 0.0, 0.15)
	rotation_degrees = 0.0
	scale = Vector2.ONE

	_cycle_numbers(my_id)

	var tw := _new_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE * 0.80, ANTICIPATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation_degrees", -14.0, ANTICIPATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(self, "rotation_degrees", spins * 360.0, _ft).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE * peak_scale, _ft * 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE * 1.10, _ft * 0.58).set_delay(_ft * 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw.finished
	if my_id != _run_id:
		return
	_land(my_id)


func _cycle_numbers(my_id: int) -> void:
	var interval := 0.04
	var elapsed := 0.0
	var last := -1
	var total := ANTICIPATION + _ft - 0.05
	while _flying and elapsed < total and my_id == _run_id:
		var n := randi_range(1, current_sides)
		if current_sides >= 3:
			while n == last or n == final_result:
				n = randi_range(1, current_sides)
		last = n
		text = str(n)
		_play(sfx_tick)
		await get_tree().create_timer(interval).timeout
		elapsed += interval
		interval = minf(interval * 1.15, 0.18)


func _land(my_id: int) -> void:
	_flying = false
	var st := _style_for(final_result)
	var col: Color = st["color"]
	text = str(final_result)
	rotation_degrees = 0.0
	_play(sfx_land)

	_face.accent = col
	_face.face_color = st["face"]
	_face.flash = 1.0
	_face.ring = 0.0
	var fx := _new_tween()
	fx.set_parallel(true)
	fx.tween_property(_face, "flash", 0.0, 0.35)
	fx.tween_property(_face, "ring", 1.0, 0.65).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	if _is_d20() and final_result == 20:
		_play(sfx_crit)
		_face.glow = 1.0
		fx.tween_property(_face, "glow", 0.45, 1.2).set_delay(0.25)
		_particles.restart()
		_particles.emitting = true
	elif _is_d20() and final_result == 1:
		_play(sfx_crit)
		_face.cracked = true
		var shake := _new_tween()
		for i in 7:
			var amp := 8.0 * (1.0 - float(i) / 7.0)
			shake.tween_property(self, "rotation_degrees", amp if i % 2 == 0 else -amp, 0.045)
		shake.tween_property(self, "rotation_degrees", 0.0, 0.05)
	elif _is_max_damage():
		_face.glow = 1.0
		fx.tween_property(_face, "glow", 0.35, 0.8).set_delay(0.2)

	# hentakan lalu pantulan elastis
	var tw := _new_tween()
	tw.tween_property(self, "scale", Vector2.ONE * 0.84, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2.ONE, 0.5 if _is_d20() else 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await tw.finished
	if my_id != _run_id:
		return
	is_rolling = false
	roll_finished.emit(final_result, st["sev"])


func _finish_now() -> void:
	_flying = false
	var st := _style_for(final_result)
	text = str(final_result)
	rotation_degrees = 0.0
	scale = Vector2.ONE
	_face.sides = current_sides
	_face.accent = st["color"]
	_face.face_color = st["face"]
	_face.flash = 0.0
	_face.ring = 1.0
	_face.cracked = _is_d20() and final_result == 1
	_face.glow = 0.45 if (_is_d20() and final_result == 20) else (0.35 if _is_max_damage() else 0.0)
	is_rolling = false
	roll_finished.emit(final_result, st["sev"])
