extends Node2D

@onready var menu_tabs = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer
@onready var input_field = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/Story/InputPanel/InputMargin/InputVbox/Input
@onready var story_log = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/Story/StoryPanel/StoryMargin/Story
@onready var health = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/health
@onready var Exp = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/Exp
@onready var Energy = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/Exp2
@onready var item_hflow_ui = $root/rootMargin/rootVbox/HboxBot/ItemPanel/MarginContainer/VBoxContainer/ItemHflow
@onready var armor = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/armor
@onready var weapon = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/weapon
@onready var accessorys = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/accessory
@onready var dice_2d = $root/rootMargin/rootVbox/HboxBot/PanelContainer3/Dice2D
@onready var objective_label = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/objective
@onready var location_label = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/location
@onready var enemy_label = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/enemy
@onready var button_story = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/PanelContainer/HBoxContainer/Button
@onready var button_character = $root/rootMargin/rootVbox/TopHbox/MapPanel/MapMargin/VBoxContainer/PanelContainer/HBoxContainer/Button2
# ON CHARACTER
@onready var char_health_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/HealtLabelCont/HealthNumLabel
@onready var char_health_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/health
@onready var char_exp_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/ExpLabelCont/ExpNumLabel
@onready var char_exp_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/Exp
@onready var char_energy_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/EnergyLabelCont/EnergyNumLabel   # angka MANA
@onready var char_energy_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/Energy   # bar MANA

@onready var show_Strength = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/StrongCont/strengthNum
@onready var show_Dexterity = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/DextCont/DexterityNum
@onready var show_Endurance = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/EnduranceCont/EnduranceNum
@onready var show_Intelligence = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/IntCont/IntNum
@onready var show_Awareness = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/AwarenessCont/AwarenessNum
@onready var show_Charisma = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/CharismaCont/CharismaNum
@onready var show_Luck = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/LuckCont/LuckNum

@onready var char_weapon_name = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/weaponCont/WeaponName
@onready var char_weapon_desc = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/weaponCont/WeaponDesc
@onready var char_armor_name = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/ArmorCont/armorName
@onready var char_armor_desc = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/ArmorCont/armorDesc
@onready var char_accessory_name = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/AccessoryCont/accessoryName
@onready var char_accessory_desc = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/AccessoryCont/accessoryDesc
@onready var equipment_list = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/equipVbox/VScrollBar/VBoxContainer
@onready var level_label = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/LevelCont/level
@onready var skill_cont = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/skillVbox

const FONT_PATH := "res://assets/font/Merriweather-VariableFont_opsz,wdth,wght.ttf"
const BAL_PATH := "res://data/balance_data.json"
const WORLD_PATH := "res://data/world_data.json"
const FLAVOR_PATH := "res://data/flavor_data.json"   # prolog, narasi musuh muncul dan mati
const SHOW_ENEMY_DICE := true                         # tampilkan juga dadu damage serangan balik musuh
const DICE_TONES := ["damage", "fumble", "enemy"]
const DICE_LABELS := {"damage": "Damage dice", "fumble": "Fumble dice", "enemy": "Enemy damage dice"}
const DICE_COLORS := {"damage": "#8A4B08", "fumble": "#B3261E", "enemy": "#C2571A"}
const PROLOGUE_PAUSE := 1.6                           # detik antar paragraf prolog
const SERVER_HOST := "127.0.0.1"
const SERVER_PORT := 8080
const SERVER_WAIT_TRIES := 90
const MAX_INPUT_CHARS := 200

const C_PLAYER := "#8A4B08"
const C_SYSTEM := "#7A7167"
const C_RULE := "#CBBFAE"
const C_CRIT_WIN := "#9A6B00"
const C_WIN := "#2E7D32"
const C_FAIL := "#C2571A"
const C_CRIT_FAIL := "#B3261E"
const C_MANA := "#1565C0"
const C_EXP := "#7B1FA2"
const C_ITEM := "#00796B"
const C_EQUIP := "#AD1457"
const C_ENEMY := "#A1401A"
const C_NPC := "#4F5BB5"
const C_LOCATION := "#3D5A80"
const C_PANEL := "#E3D9C8"          # latar kartu (sedikit lebih gelap dari kertas)
const C_PANEL_EDGE := "#CBBFAE"
const C_INK := "#4A443F"
const C_MUTED := "#8C8378"
const C_TAN := "#B8AA8A"            # warna tombol aktif (sama dengan tombol Story Log)
const C_HEAD := "#B5AB9B"           # warna judul bagian (WEAPON, BAG, SKILLS)

const ENEMY_ALIASES := {
	"Goblin Ambusher": ["goblin", "goblins"], "Skeleton Warrior": ["skeleton", "skeletons"], "Orc Marauder": ["orc"],
	"Gelatinous Cube": ["cube"], "The Hollow Scribe": ["Scribe", "Hollow Scribe"]
}
const STAT_ORDER := ["STR", "DEX", "END", "INT", "AWR", "CHA", "LCK"]

var bal: Dictionary
var world: Dictionary
var flavor: Dictionary = {}
var _last_flavor: Dictionary = {}
var enemy_stats_label: Label
var engine: GameEngine
var ai: AIClient
var _font: Font = null
var highlight_terms: Dictionary = {}
var highlight_regex: RegEx

var awaiting_response := false
var _roll_pending := false
var _awaiting_dice_click := false
signal dice_clicked


func _ready() -> void:
	bal = JSON.parse_string(FileAccess.get_file_as_string(BAL_PATH))
	world = JSON.parse_string(FileAccess.get_file_as_string(WORLD_PATH))
	var fl = JSON.parse_string(FileAccess.get_file_as_string(FLAVOR_PATH))
	flavor = fl if fl is Dictionary else {}
	engine = GameEngine.new(bal, world)
	_font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else null
	ai = AIClient.new()
	ai.host = SERVER_HOST
	ai.port = SERVER_PORT
	add_child(ai)
	_build_highlight_terms()

	# stat musuh ditulis di bawah nama musuh
	enemy_stats_label = Label.new()
	enemy_stats_label.add_theme_color_override("font_color", Color(C_MUTED))
	enemy_stats_label.add_theme_font_size_override("font_size", 14)
	if _font != null:
		enemy_stats_label.add_theme_font_override("font", _font)
	enemy_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	enemy_stats_label.visible = false
	var enemy_box := enemy_label.get_parent()
	enemy_box.add_child(enemy_stats_label)
	enemy_box.move_child(enemy_stats_label, enemy_label.get_index() + 1)

	input_field.text_submitted.connect(_on_input_submitted)
	_setup_fonts()
	story_log.bbcode_enabled = true
	story_log.scroll_following = true
	story_log.text = _bb("System: Waking up the Dungeon Master...", C_SYSTEM, false, true) + "\n"
	input_field.editable = false
	input_field.placeholder_text = "DM is preparing the story..."

	dice_2d.mouse_filter = Control.MOUSE_FILTER_STOP
	dice_2d.gui_input.connect(_on_dice_gui_input)

	_refresh_all_ui()
	_wait_for_server()


func _setup_fonts() -> void:
	var base_font: Font = _font
	if base_font == null:
		return
	var ts := TextServerManager.get_primary_interface()
	var bold_font := FontVariation.new()
	bold_font.base_font = base_font
	bold_font.variation_opentype = {ts.name_to_tag("weight"): 700}
	var italic_font := FontVariation.new()
	italic_font.base_font = base_font
	italic_font.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
	var bold_italic_font := FontVariation.new()
	bold_italic_font.base_font = base_font
	bold_italic_font.variation_opentype = {ts.name_to_tag("weight"): 700}
	bold_italic_font.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
	story_log.add_theme_font_override("normal_font", base_font)
	story_log.add_theme_font_override("bold_font", bold_font)
	story_log.add_theme_font_override("italics_font", italic_font)
	story_log.add_theme_font_override("bold_italics_font", bold_italic_font)


func _wait_for_server() -> void:
	for attempt in range(SERVER_WAIT_TRIES):
		if await ai.is_server_ready():
			_on_server_ready()
			return
		await get_tree().create_timer(2.0).timeout
	_log(_bb("System: The AI server did not respond. Start server_app and restart the game.", C_CRIT_FAIL, true))


func _on_server_ready() -> void:
	story_log.text = ""
	await _show_intro()   # _show_intro membuka kembali kolom input di akhir


# ===================================================================== teks dan format
func _bb(text: String, color: String, bold := false, italic := false) -> String:
	var s := "[color=%s]%s[/color]" % [color, text]
	if bold:
		s = "[b]" + s + "[/b]"
	if italic:
		s = "[i]" + s + "[/i]"
	return s


func _log(bbcode: String) -> void:
	story_log.text += bbcode + "\n"


func _esc(text: String) -> String:
	return text.replace("[", "[lb]")


func _remove_line(bbcode: String) -> void:
	var t: String = story_log.text
	var idx := t.rfind(bbcode + "\n")
	if idx != -1:
		story_log.text = t.substr(0, idx) + t.substr(idx + bbcode.length() + 1)


func _build_highlight_terms() -> void:
	var t := {}
	for n in bal["enemies"]:
		t[str(n).to_lower()] = C_ENEMY
		for a in ENEMY_ALIASES.get(n, []):
			t[str(a).to_lower()] = C_ENEMY
	for id in world["npcs"]:
		var nm: String = world["npcs"][id]["name"]
		t[nm.to_lower()] = C_NPC
		var words := nm.split(" ")
		var low := nm.to_lower()
		if low.begins_with("sir ") or low.begins_with("mayor ") or low.begins_with("archmage "):
			t[words[words.size() - 1].to_lower()] = C_NPC
		elif words.size() >= 2 and not low.begins_with("the "):
			t[words[0].to_lower()] = C_NPC
	for id in world["locations"]:
		t[str(world["locations"][id]["name"]).to_lower()] = C_LOCATION
	for n in bal["consumables"]:
		t[str(n).to_lower()] = C_ITEM
	for cat in ["weapons", "armor", "accessories"]:
		for n in bal[cat]:
			t[str(n).to_lower()] = C_EQUIP
	for n in bal["skills"]:
		t[str(n).to_lower()] = C_EXP
	highlight_terms = t
	var keys: Array = t.keys()
	keys.sort_custom(func(a, b): return a.length() > b.length())
	highlight_regex = RegEx.create_from_string("(?i)\\b(" + "|".join(PackedStringArray(keys)) + ")\\b")


func _format_narrative(text: String) -> String:
	var s := _esc(text)
	var out := ""
	var last := 0
	for m in highlight_regex.search_all(s):
		out += s.substr(last, m.get_start() - last)
		var color: String = highlight_terms.get(m.get_string().to_lower(), "")
		out += _bb(m.get_string(), color, true) if color != "" else m.get_string()
		last = m.get_end()
	out += s.substr(last)
	return out


func _name_c(name: String, color: String) -> String:
	return _bb(_esc(name), color, true)


func _tier_color(tier: String) -> String:
	match tier:
		"critical_success": return C_CRIT_WIN
		"success": return C_WIN
		"failure": return C_FAIL
		_: return C_CRIT_FAIL


func _signed(n: int) -> String:
	return ("+%d" % n) if n >= 0 else ("%d" % n)


# ===================================================================== pembukaan dan bab
func _pick_flavor(key: String, arr: Array) -> String:
	## Pilih satu baris acak dari daftar, tanpa mengulang baris yang sama dua kali berturut-turut.
	if arr.is_empty():
		return ""
	var i := randi() % arr.size()
	if arr.size() > 1 and i == int(_last_flavor.get(key, -1)):
		i = (i + 1) % arr.size()
	_last_flavor[key] = i
	return str(arr[i])


func _show_intro() -> void:
	awaiting_response = true
	input_field.editable = false
	input_field.placeholder_text = "The Tome is writing..."
	_log("[center]" + _bb("~ THE UNWRITTEN TALE ~", C_CRIT_WIN, true) + "[/center]")
	_log("")
	_chapter_banner(false)
	for p in flavor.get("prologue", []):
		await get_tree().create_timer(PROLOGUE_PAUSE).timeout
		_log("")
		_log(_format_narrative(str(p)))
	var hook := str(flavor.get("prologue_hook", ""))
	if hook != "":
		await get_tree().create_timer(PROLOGUE_PAUSE).timeout
		_log("")
		_log(_bb(_esc(hook), C_CRIT_WIN, true, true))
	var calm := str(flavor.get("prologue_calm", ""))
	if calm != "":
		await get_tree().create_timer(PROLOGUE_PAUSE).timeout
		_log("")
		_log(_bb(_esc(calm), C_SYSTEM, false, true))
	if not engine.enemy.is_empty():
		_log("")
		_log_enemy_appears(str(engine.enemy["name"]), bool(engine.enemy["engaged"]), engine.queue.size())
	_log("")
	_log(_bb("Tip: describe what you do, e.g. \"I ask the Mayor what happened\", \"I look around the square\" or \"I swing my mace at the goblin\". "
			+ "Click a consumable or a skill to use it. Type /help for commands.", C_SYSTEM, false, true))
	_end_turn_ui()


func _chapter_banner(show_brief := true) -> void:
	var wch := engine.chapter_world()
	_log(_bb("Chapter %d: %s" % [engine.chapter, wch["title"]], C_LOCATION, true))
	if show_brief:
		_log(_bb(_esc(str(wch["brief"])), C_SYSTEM, false, true))
	if engine.location != engine.main_location():
		_log(_bb("Objective: head to %s." % world["locations"][engine.main_location()]["name"], C_CRIT_WIN, true))


func _spawn_line(name: String, engaged: bool, remaining: int) -> String:
	## Narasi kemunculan musuh. Bab 1: goblin pertama, kedua, dan ketiga punya kalimat sendiri.
	var id := GameEngine.slug(name)
	if engaged and engine.chapter == 1 and name == "Goblin Ambusher" and remaining >= 0:
		var waves: Array = flavor.get("ch1_goblin_waves", [])
		var idx: int = (bal["chapters"][0]["scripted"] as Array).size() - 1 - remaining
		if idx >= 0 and idx < waves.size():
			return str(waves[idx])
	var sp: Dictionary = flavor.get("enemy_spawn", {}).get(id, {})
	var kind := "engaged" if engaged else "lurking"
	var line := _pick_flavor("spawn_%s_%s" % [id, kind], sp.get(kind, []))
	if line != "":
		return line
	return ("%s lunges out of nowhere and attacks you!" if engaged else "%s lurks nearby, unaware of you.") % name


func _log_enemy_appears(name: String, engaged: bool, remaining := -1) -> void:
	_log(_format_narrative(_spawn_line(name, engaged, remaining)))
	_log(_bb(">>> %s attacks! <<<" % name if engaged else ">>> %s lurks nearby and has not noticed you. <<<" % name, C_ENEMY, true))


func _defeat_line(name: String) -> String:
	var id := GameEngine.slug(name)
	var line := _pick_flavor("defeat_" + id, flavor.get("enemy_defeat", {}).get(id, []))
	if line != "":
		return line
	return "The %s falls and does not rise again." % name


func _show_help() -> void:
	_log("")
	_log(_bb("How to play", C_CRIT_WIN, true))
	_log(_bb("Every risky action is a d20 roll: d20 + stat modifier + level bonus (+ item/skill) against a DC, or against the enemy's AC when you attack. "
			+ "A natural 1 always fails and a natural 20 always succeeds. Attacks that hit deal your weapon's dice plus your modifier.", C_SYSTEM, false, true))
	_log(_bb("Commands: /new (start over), /help.", C_SYSTEM, false, true))


# ===================================================================== input dan giliran
func _sanitize_input(raw: String) -> String:
	var t := raw.replace("\n", " ").replace("\r", " ").replace("\t", " ").replace("[", "").replace("]", "").replace("\"", "'")
	while t.contains("  "):
		t = t.replace("  ", " ")
	t = t.strip_edges()
	if t.length() > MAX_INPUT_CHARS:
		t = t.substr(0, MAX_INPUT_CHARS)
	return t


func _on_input_submitted(new_text: String) -> void:
	var text := new_text.strip_edges()
	if text == "" or awaiting_response or _roll_pending:
		return
	input_field.clear()
	if text.begins_with("/"):
		match text.to_lower():
			"/new": _restart()
			"/help": _show_help()
			_: _log(_bb("System: unknown command. Try /help.", C_SYSTEM, false, true))
		return
	_run_turn(text, {})


func _end_turn_ui() -> void:
	awaiting_response = false
	if engine.down:
		input_field.placeholder_text = "Game over. Type /new to start again."
		input_field.editable = true
	elif engine.ending != "":
		input_field.placeholder_text = "The end. Type /new to start again."
		input_field.editable = true
	else:
		input_field.editable = true
		input_field.placeholder_text = "What will you do?"
		input_field.grab_focus()


func _fail_turn(message: String) -> void:
	_log(_bb("System: " + message + " This turn was not applied.", C_CRIT_FAIL, true))
	_end_turn_ui()


func _run_turn(raw_text: String, forced_label: Dictionary) -> void:
	if awaiting_response or _roll_pending:
		return
	var action := _sanitize_input(raw_text)
	if action == "":
		return
	if engine.down or engine.ending != "":
		_log(_bb("System: the story is over. Type /new to start again.", C_SYSTEM, false, true))
		return

	awaiting_response = true
	input_field.editable = false
	_log("")
	_log(_bb("──────────  Turn %d  ──────────" % (engine.turn + 1), C_RULE))
	_log(_bb("> " + _esc(action), C_PLAYER, true))

	# 1. Adjudicator: ubah aksi menjadi label (tombol memakai label langsung)
	var label: Dictionary = forced_label
	if label.is_empty():
		var thinking := _bb("The DM is weighing your action...", C_SYSTEM, false, true)
		input_field.placeholder_text = "The DM is weighing your action..."
		_log(thinking)
		var r: Dictionary = await ai.adjudicate(AIClient.render_adjudicator_input(engine.adjudicator_context(), action))
		_remove_line(thinking)
		if not r["ok"]:
			_fail_turn("AI server: %s." % r["error"])
			return
		var san: Dictionary = {"ok": false, "issues": ["JSON tidak valid"]}
		if r["valid"]:
			san = AIClient.sanitize_label(r["label"], engine.known_ids())
		if san["ok"]:
			label = san["label"]
			if san["issues"].size() > 0:
				print("[AI] label disesuaikan: ", san["issues"], " mentah: ", r["raw"])
		else:
			label = engine.fallback_label(action)
			print("[AI] label tidak sah, memakai tebakan kata kunci: ", san["issues"], " mentah: ", r["raw"])

	# 2. Engine: aturan permainan
	var out: Dictionary = engine.resolve(label, action)
	if not out["ok"]:
		_log(_bb("System: " + str(out["message"]) + " (no turn used)", C_SYSTEM, false, true))
		_end_turn_ui()
		return
	var row: Dictionary = out["row"]

	# 3. Dadu
	if row["verdict"]["roll"] != null:
		await _show_roll(row["verdict"]["roll"], str(row["verdict"]["tier"]), row["action"]["stat"])
	await _show_extra_dice(out.get("dice", []))
	_refresh_all_ui()

	# 4. Narasi (streaming)
	await _narrate(row)

	# 5. Rincian mekanik dan peristiwa
	_log_results(row["results"])
	for ev in out["events"]:
		_log_event(ev)
	_refresh_all_ui()

	if engine.down:
		_log("")
		_log("[center]" + _bb("=== YOU HAVE FALLEN. THE TALE ENDS HERE. ===", C_CRIT_FAIL, true) + "[/center]")
	elif engine.ending != "":
		_log("")
		_log("[center]" + _bb("~ THE END ~", C_CRIT_WIN, true) + "[/center]")
		_log(_bb(_esc(engine.epilogue(engine.ending)), C_LOCATION, false, true))
	_end_turn_ui()


func _narrate(row: Dictionary) -> void:
	_log("")
	var base_text: String = story_log.text
	input_field.placeholder_text = "The DM is writing..."
	var cb := func(txt: String) -> void:
		story_log.text = base_text + _format_narrative(txt)
	var r: Dictionary = await ai.narrate_stream(AIClient.render_narrator_input(row), cb)
	var narrative: String
	if r["ok"]:
		narrative = str(r["text"])
	else:
		print("[AI] narasi gagal (", r["error"], "), memakai narasi cadangan.")
		narrative = engine.fallback_narration(row)
	story_log.text = base_text + _format_narrative(narrative) + "\n"


func _show_extra_dice(dice: Array) -> void:
	## Dadu damage (senjata/skill), luka gagal kritis, dan serangan balik musuh: otomatis dilempar tanpa klik.
	if dice.is_empty():
		return
	_roll_pending = true
	for tone in DICE_TONES:
		if tone == "enemy" and not SHOW_ENEMY_DICE:
			continue
		var parts := PackedStringArray()
		for e in dice:
			if str(e["tag"]) != tone:
				continue
			await dice_2d.roll_many(int(e["sides"]), e["results"], tone)
			for r in e["results"]:
				parts.append("%d (d%d)" % [int(r), int(e["sides"])])
		if parts.size() > 0:
			_log(_bb("%s: " % DICE_LABELS[tone], C_SYSTEM, false, true) + _bb(" + ".join(parts), DICE_COLORS[tone], true))
			await get_tree().create_timer(0.2).timeout
	_roll_pending = false


func _on_dice_gui_input(event: InputEvent) -> void:
	if _awaiting_dice_click and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dice_clicked.emit()


func _roll_prompt_bb(roll: Dictionary) -> String:
	var need := "AC" if roll["target_kind"] == "AC" else "DC"
	return _bb("Click the dice to roll! (%s %d)" % [need, int(roll["target"])], C_SYSTEM, false, true)


func _show_roll(roll: Dictionary, tier: String, stat) -> void:
	_roll_pending = true
	var prompt := _roll_prompt_bb(roll)
	_log(prompt)
	_awaiting_dice_click = true
	dice_2d.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var pulse := create_tween().set_loops()
	pulse.tween_property(dice_2d, "scale", Vector2.ONE * 1.08, 0.5).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(dice_2d, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	await dice_clicked
	_awaiting_dice_click = false
	pulse.kill()
	dice_2d.scale = Vector2.ONE
	dice_2d.mouse_default_cursor_shape = Control.CURSOR_ARROW
	_remove_line(prompt)

	dice_2d.roll_dice(int(roll["d20"]))
	await dice_2d.roll_finished

	var col := _tier_color(tier)
	var parts := PackedStringArray()
	var d20_txt := "d20 %d" % int(roll["d20"])
	if roll["advantage"]:
		d20_txt = "d20 %d (advantage: %s)" % [int(roll["d20"]), " & ".join(PackedStringArray((roll["dice"] as Array).map(func(x): return str(int(x)))))]
	parts.append(d20_txt)
	parts.append("%s%s" % [_signed(int(roll["modifier"])), (" " + str(engine.abbr_of.get(str(stat), str(stat).substr(0, 3).to_upper()))) if stat != null else ""])
	parts.append("%s level" % _signed(int(roll["level_bonus"])))
	if int(roll["item_bonus"]) != 0:
		parts.append("%s item" % _signed(int(roll["item_bonus"])))
	if int(roll["skill_bonus"]) != 0:
		parts.append("%s skill" % _signed(int(roll["skill_bonus"])))
	_log(_bb("Roll: ", C_SYSTEM, false, true) + _bb(" ".join(parts), C_SYSTEM) + _bb("  =  %d vs %s %d" % [int(roll["total"]), roll["target_kind"], int(roll["target"])], col, true)
			+ "   " + _bb(tier.replace("_", " ").to_upper(), col, true))
	_roll_pending = false


# ===================================================================== rincian hasil dan peristiwa (di story log)
func _log_results(res: Dictionary) -> void:
	var chips := PackedStringArray()
	if int(res["damage_dealt"]) > 0:
		chips.append(_bb("Enemy takes %d damage" % int(res["damage_dealt"]), C_ENEMY, true))
	if int(res["player_damage_taken"]) > 0:
		chips.append(_bb("HP -%d" % int(res["player_damage_taken"]), C_CRIT_FAIL, true))
	if int(res["healing"]) > 0:
		chips.append(_bb("HP +%d" % int(res["healing"]), C_WIN, true))
	if int(res["mana_spent"]) > 0:
		chips.append(_bb("Mana -%d" % int(res["mana_spent"]), C_MANA, true))
	if int(res["mana_restored"]) > 0:
		chips.append(_bb("Mana +%d" % int(res["mana_restored"]), C_MANA, true))
	if int(res["exp_gained"]) > 0:
		chips.append(_bb("EXP +%d" % int(res["exp_gained"]), C_EXP, true))
	if chips.size() > 0:
		_log("   " + "   ".join(chips))
	if res["enemy_counter"] != null:
		var ec: Dictionary = res["enemy_counter"]
		if ec["hit"]:
			_log("   " + _bb("The enemy strikes back%s." % (" with a critical hit" if ec["crit"] else ""), C_FAIL, false, true))
		else:
			_log("   " + _bb("The enemy's counterattack misses.", C_SYSTEM, false, true))
	if res["item_used"] != null:
		_log("   " + _bb("You used: ", C_SYSTEM, false, true) + _name_c(str(res["item_used"]), C_ITEM))
	for it in res["items_found"]:
		_log(_bb(">>> You found: %s <<<" % _esc(str(it)), C_ITEM, true))
	if res["equipped"] != null:
		_log(_bb(">>> You equipped: %s <<<" % _esc(str(res["equipped"]["item"])), C_EQUIP, true))
	if res["fled"]:
		_log("   " + _bb("You got away.", C_WIN, false, true))
	if res["enemy_avoided"]:
		_log("   " + _bb("You slipped past the enemy unseen.", C_WIN, false, true))
	if res["encounter_triggered"] != null:
		_log("")
		_log_enemy_appears(str(res["encounter_triggered"]), true)
	if res["location_change"] != null:
		_log(_bb(">>> MOVED TO: %s <<<" % res["location_change"], C_LOCATION, true))
	if res["enemy_defeated"]:
		var dn := engine.last_defeated
		_log("")
		_log("[i]" + _format_narrative(_defeat_line(dn)) + "[/i]")
		_log("[center]" + _bb(">>> %s defeated! <<<" % _esc(dn) if dn != "" else ">>> The enemy is defeated! <<<", C_CRIT_WIN, true) + "[/center]")
	for lu in res["level_up"]:
		_log("")
		_log("[center]" + _bb("*** LEVEL UP! You are now Level %d! ***" % int(lu["to"]), C_CRIT_WIN, true) + "[/center]")
		_log(_bb("HP and Mana fully restored.", C_WIN, false, true))
		if (lu["new_skills"] as Array).size() > 0:
			_log(_bb("New skill: %s" % ", ".join(PackedStringArray(lu["new_skills"])), C_EXP, true))
		if (lu["stat_up"] as Array).size() > 0:
			_log(_bb("%s +1" % ", ".join(PackedStringArray(lu["stat_up"])), C_EXP, true))
	if res["story_beat"] != null:
		_log("")
		_log(_bb(_esc(str(res["story_beat"])), C_LOCATION, false, true))
	if res["chapter_complete"] != null:
		var cc: Dictionary = res["chapter_complete"]
		_log("")
		_log("[center]" + _bb("*** CHAPTER COMPLETE: %s ***" % cc["title"], C_CRIT_WIN, true) + "[/center]")
		_log(_bb("HP and Mana fully restored.", C_WIN, false, true))
		if (cc["rewards"] as Array).size() > 0:
			_log(_bb("Rewards: %s" % ", ".join(PackedStringArray(cc["rewards"])), C_ITEM, true))


func _log_event(ev: Dictionary) -> void:
	match ev["type"]:
		"enemy_appears":
			_log("")
			_log_enemy_appears(str(ev["name"]), bool(ev["engaged"]), int(ev.get("remaining", -1)))
		"chapter_begin":
			_log("")
			_chapter_banner()
		"final_stage":
			_log("")
			_log(_bb("The Hollow Scribe is defeated. The Unwritten Tome and the Inkwell of Dawn lie before you.", C_CRIT_WIN, true))
			_log(_bb("Decide their fate: keep the Tome, burn both relics, or entrust them to Elara. Type your choice.", C_CRIT_WIN, false, true))


func _restart() -> void:
	engine.new_game()
	story_log.text = ""
	_refresh_all_ui()
	await _show_intro()   # _show_intro membuka kembali kolom input di akhir


# ===================================================================== UI: bar, label, daftar
func _refresh_all_ui() -> void:
	var mh := engine.max_hp()
	health.max_value = mh
	health.value = clampf(engine.hp, 0, mh)
	char_health_bar.max_value = mh
	char_health_bar.value = health.value
	char_health_num.text = "%d/%d" % [maxi(engine.hp, 0), mh]

	var mm := engine.max_mana()
	Energy.max_value = maxi(mm, 1)
	Energy.value = clampf(engine.mana, 0, mm)
	char_energy_bar.max_value = Energy.max_value
	char_energy_bar.value = Energy.value
	char_energy_num.text = "%d/%d" % [maxi(engine.mana, 0), mm]

	var need := engine.exp_needed()
	Exp.max_value = maxi(need, 1)
	Exp.value = engine.exp_pts if need > 0 else 1
	char_exp_bar.max_value = Exp.max_value
	char_exp_bar.value = Exp.value
	char_exp_num.text = ("%d/%d" % [engine.exp_pts, need]) if need > 0 else "MAX"
	level_label.text = "Level %d" % engine.level

	_refresh_stats_ui()
	_refresh_equipment_labels()
	_update_status_panel()
	update_equipment_inventory_ui()
	update_items_inventory_ui()
	update_skills_ui()


func _update_status_panel() -> void:
	var wch := engine.chapter_world()
	objective_label.text = "Ch. %d: %s" % [engine.chapter, wch["title"]]
	location_label.text = str(world["locations"][engine.location]["name"])
	if engine.enemy.is_empty():
		enemy_label.text = "None"
		enemy_stats_label.visible = false
	else:
		var e := engine.enemy
		var ac: int = int(bal["enemies"][e["name"]]["ac"])
		enemy_label.text = str(e["name"])
		enemy_stats_label.text = "HP %d/%d  ·  AC %d\n%s%s" % [maxi(e["hp"], 0), e["max_hp"], ac, str(engine.enemy_condition()).capitalize(),
				"" if e["engaged"] else "  ·  unaware of you"]
		enemy_stats_label.visible = true


func _refresh_stats_ui() -> void:
	var labels := {"STR": show_Strength, "DEX": show_Dexterity, "END": show_Endurance, "INT": show_Intelligence,
			"AWR": show_Awareness, "CHA": show_Charisma, "LCK": show_Luck}
	for k in labels:
		labels[k].text = "%d (%s)" % [int(engine.stats[k]), _signed(engine.mod(k))]


func _weapon_desc(name: String) -> String:
	var w: Dictionary = bal["weapons"][name]
	var stat_txt: String = {"melee": "STR or DEX", "ranged": "AWR or DEX", "arcane": "INT"}[w["type"]]
	return "Damage %s, %s weapon (uses %s). Attack bonus %s." % [w["dice"], w["type"], stat_txt,
			_signed(engine.weapon_option(name)["hit"])]


func _armor_desc(name: String) -> String:
	var a: Dictionary = bal["armor"][name]
	var cap := "no DEX limit" if a["dex_cap"] == null else "DEX bonus up to %s" % _signed(int(a["dex_cap"]))
	return "AC %d with your DEX (base %d, %s). Total AC %d." % [engine.armor_ac(name), int(a["ac"]), cap, engine.ac()]


func _accessory_desc(name: String) -> String:
	var a: Dictionary = bal["accessories"][name]
	var bits := PackedStringArray()
	if int(a.get("ac", 0)) != 0:
		bits.append("%s AC" % _signed(int(a["ac"])))
	if a.has("hp"):
		bits.append("%s max HP" % _signed(int(a["hp"])))
	for k in ["cha", "lck"]:
		if a.has(k):
			bits.append("%s to %s checks" % [_signed(int(a[k])), k.to_upper()])
	return ", ".join(bits) if bits.size() > 0 else "No effect."


func _refresh_equipment_labels() -> void:
	var w: String = engine.equipped["weapon"]
	var a: String = engine.equipped["armor"]
	var c: String = engine.equipped["accessory"]
	weapon.text = w
	armor.text = a
	accessorys.text = c
	char_weapon_name.text = w
	char_armor_name.text = a
	char_accessory_name.text = c
	char_weapon_desc.text = _weapon_desc(w)
	char_armor_desc.text = _armor_desc(a)
	char_accessory_desc.text = _accessory_desc(c)


func _flat(bg: Color, edge := "") -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.set_corner_radius_all(0)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	if edge != "":
		st.border_color = Color(edge)
		st.set_border_width_all(1)
	return st


func _styled_button(text: String, bg := C_TAN) -> Button:
	## Tombol datar bersudut tegas, selaras dengan tombol Story Log / Character Sheet.
	var b := Button.new()
	b.text = text
	if _font != null:
		b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 15)
	var base := Color(bg)
	b.add_theme_stylebox_override("normal", _flat(base))
	b.add_theme_stylebox_override("hover", _flat(base.darkened(0.1)))
	b.add_theme_stylebox_override("pressed", _flat(base.darkened(0.22)))
	b.add_theme_stylebox_override("disabled", _flat(Color(0, 0, 0, 0), C_PANEL_EDGE))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", Color("#F6F0E4"))
	b.add_theme_color_override("font_hover_color", Color("#FFFFFF"))
	b.add_theme_color_override("font_pressed_color", Color("#FFFFFF"))
	b.add_theme_color_override("font_disabled_color", Color(C_HEAD))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b


func _hairline() -> HSeparator:
	var s := HSeparator.new()
	var line := StyleBoxLine.new()
	line.color = Color(C_PANEL_EDGE)
	line.thickness = 1
	s.add_theme_stylebox_override("separator", line)
	s.add_theme_constant_override("separation", 6)
	return s


func _list_row(content: Control, trailing: Control = null) -> VBoxContainer:
	## Baris daftar tanpa kotak: isi di kiri, tombol di kanan, garis tipis di bawah (gaya yang sama dengan blok Weapon/Armor).
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 0)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(content)
	if trailing != null:
		trailing.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(trailing)
	box.add_child(row)
	box.add_child(_hairline())
	return box


func _text(text: String, color: String, size := 0, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", Color(color))
	if _font != null:
		l.add_theme_font_override("font", _font)
	if size > 0:
		l.add_theme_font_size_override("font_size", size)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _label(text: String, color: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", Color(color))
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func _item_short_desc(slot: String, item: String) -> String:
	match slot:
		"weapon":
			var w: Dictionary = bal["weapons"][item]
			return "Weapon  ·  %s %s" % [w["dice"], w["type"]]
		"armor":
			return "Armor  ·  AC %d" % engine.armor_ac(item)
	return "Accessory  ·  " + _accessory_desc(item)


func _equip_card(slot: String, item: String) -> VBoxContainer:
	## Baris item di tas (item yang dipakai sudah tampil di bagian atas halaman).
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.add_child(_text(item, C_EQUIP))
	col.add_child(_text(_item_short_desc(slot, item), C_MUTED, 12, true))
	var btn := _styled_button("Equip")
	btn.pressed.connect(func(): _on_equip_pressed(item))
	return _list_row(col, btn)


func update_equipment_inventory_ui() -> void:
	if not equipment_list:
		return
	for child in equipment_list.get_children():
		child.queue_free()
	var sc := equipment_list.get_parent()
	if sc is ScrollContainer:
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equipment_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_list.add_theme_constant_override("separation", 2)
	equipment_list.add_child(_text("BAG", C_HEAD, 14))
	var any := false
	for slot in ["weapon", "armor", "accessory"]:
		for item in engine.owned[slot]:
			if item == engine.equipped[slot]:
				continue
			any = true
			equipment_list.add_child(_equip_card(slot, str(item)))
	if not any:
		var empty := _text("- Bag is empty -", C_MUTED, 12)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		equipment_list.add_child(empty)


func _on_equip_pressed(item: String) -> void:
	if awaiting_response or _roll_pending:
		_log(_bb("System: Wait for the DM to finish the current turn.", C_SYSTEM, false, true))
		return
	var in_combat: bool = (not engine.enemy.is_empty()) and bool(engine.enemy["engaged"])
	if in_combat:
		_run_turn("I equip the %s." % item, {"intent": "equip", "target": GameEngine.slug(item), "risky": false, "stat": null, "dc": null, "skill": null, "ending": null})
		return
	var err := engine.equip_free(item)
	if err != "":
		_log(_bb("System: " + err, C_SYSTEM, false, true))
		return
	_log(_bb(">>> You equipped: %s <<<" % _esc(item), C_EQUIP, true))
	_refresh_all_ui()


func _consumable_desc(name: String) -> String:
	var c: Dictionary = bal["consumables"][name]
	if c.has("heal"):
		return "Restores %d HP." % int(c["heal"])
	if c.has("mana"):
		return "Restores %d mana." % int(c["mana"])
	if c.has("damage"):
		return "Hurls force at an enemy for %d damage." % int(c["damage"])
	return "Lets you escape a random fight."


func update_items_inventory_ui() -> void:
	if not item_hflow_ui:
		return
	for child in item_hflow_ui.get_children():
		child.queue_free()
	var f = _font
	for name in engine.inv:
		var n := int(engine.inv[name])
		if n <= 0:
			continue
		var b := Button.new()
		b.text = "%s x%d" % [name, n] if n > 1 else str(name)
		if f != null:
			b.add_theme_font_override("font", f)
		b.tooltip_text = _consumable_desc(name)
		b.add_theme_color_override("font_color", Color(C_ITEM))
		b.add_theme_color_override("font_hover_color", Color(C_CRIT_FAIL))
		b.add_theme_color_override("font_pressed_color", Color(C_CRIT_FAIL))
		for sname in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(sname, StyleBoxEmpty.new())
		b.pressed.connect(func(): _on_inventory_item_selected(str(name)))
		item_hflow_ui.add_child(b)


func _on_inventory_item_selected(item: String) -> void:
	if awaiting_response or _roll_pending:
		_log(_bb("System: Wait for the DM to finish the current turn.", C_SYSTEM, false, true))
		return
	_run_turn("I use the %s." % item, engine.item_label(item))


func _skill_desc(name: String) -> String:
	var lv: int = engine.level
	match name:
		"Power Strike":
			return "Melee only. +3 to hit and an extra %dd6 damage." % (1 if lv < 5 else 2)
		"Second Wind":
			return "Catch your breath and heal %d HP." % (5 + 3 * lv)
		"Evasive Step":
			return "Slip away: the enemy's counterattack misses this turn."
		"Arcane Bolt":
			return "A bolt of magic: %dd4 + INT damage, no weapon needed." % (2 if lv < 5 else 3)
		"Keen Eye":
			return "Ranged weapons only. +5 to hit."
		"Silver Tongue":
			return "+5 to a Charisma check when you talk to someone."
		"Lucky Break":
			return "Attack with advantage: roll twice, keep the higher."
	return ""


func update_skills_ui() -> void:
	if not skill_cont:
		return
	for child in skill_cont.get_children():
		if child.has_meta("dyn"):
			child.queue_free()
	skill_cont.add_theme_constant_override("separation", 2)
	var head := _text("SKILLS", C_HEAD, 22)
	head.set_meta("dyn", true)
	skill_cont.add_child(head)
	for sname in bal["skills"]:
		var info: Dictionary = bal["skills"][sname]
		var st := engine.skill_button(sname)
		var unlocked: bool = int(info["unlock"]) <= engine.level
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		var title := HBoxContainer.new()
		title.add_theme_constant_override("separation", 8)
		title.add_child(_text(sname, C_INK if unlocked else C_MUTED))
		var meta := _text(("%d mana" % int(info["cost"])) if unlocked else ("Lv %d" % int(info["unlock"])), C_MANA if unlocked else C_MUTED, 12)
		meta.size_flags_horizontal = Control.SIZE_SHRINK_END
		meta.size_flags_vertical = Control.SIZE_SHRINK_END
		title.add_child(meta)
		col.add_child(title)
		col.add_child(_text(_skill_desc(sname) if unlocked else "Unlocks at level %d." % int(info["unlock"]), C_MUTED, 12, true))
		var btn: Button = null
		if unlocked:
			btn = _styled_button("Use")
			btn.disabled = not st["enabled"]
			btn.tooltip_text = st["text"] if st["enabled"] else str(st["reason"])
			var skill_name: String = sname
			btn.pressed.connect(func(): _on_skill_pressed(skill_name))
		var row := _list_row(col, btn)
		row.set_meta("dyn", true)
		if not unlocked:
			row.modulate = Color(1, 1, 1, 0.6)
		skill_cont.add_child(row)


func _on_skill_pressed(skill_name: String) -> void:
	if awaiting_response or _roll_pending:
		_log(_bb("System: Wait for the DM to finish the current turn.", C_SYSTEM, false, true))
		return
	var st := engine.skill_button(skill_name)
	if not st["enabled"]:
		_log(_bb("System: %s." % st["reason"], C_SYSTEM, false, true))
		return
	_run_turn(str(st["text"]), st["label"])


func _set_tab(index: int) -> void:
	menu_tabs.current_tab = index
	match index:
		1: button_story.button_pressed = true
		2: button_character.button_pressed = true


func _on_button_story_pressed() -> void:
	menu_tabs.current_tab = 1
	_set_tab(1)


func _on_button_character_pressed() -> void:
	menu_tabs.current_tab = 2
	_set_tab(2)
