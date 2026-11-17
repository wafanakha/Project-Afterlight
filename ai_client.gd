class_name AIClient
extends Node
## Penghubung ke server model (server_app) untuk The Unwritten Tale.
##
## Alur satu giliran:
##   1. render_adjudicator_input(konteks, aksi)  ->  POST /adjudicate  ->  label (intent, target, risky, stat, dc, skill)
##   2. engine game menghitung angka (dadu, damage, EXP, ...) dari label
##   3. render_narrator_input(baris)             ->  POST /narrate_stream  ->  narasi yang muncul bertahap
##
## Teks prompt HARUS sama persis dengan format data latih (lihat render_* di bawah).

const INTENTS := ["attack", "physical", "equip", "social", "use_item", "search", "other", "travel", "magic",
		"decide", "talk", "observe", "flee", "skill", "stealth"]
const STATS := ["strength", "dexterity", "endurance", "intelligence", "awareness", "charisma", "luck"]
const DC_SCALE := [8, 12, 15, 18, 20]
const NO_ROLL_INTENTS := ["observe", "talk", "equip", "use_item", "decide"]
const DEFAULT_STAT := {"physical": "strength", "social": "charisma", "search": "awareness", "magic": "intelligence",
		"stealth": "dexterity", "travel": "endurance", "flee": "dexterity", "other": "luck", "skill": "endurance"}

var host := "127.0.0.1"
var port := 8080
var request_timeout_ms := 120000


# ===================================================================== keadaan -> kata (sama dengan generate_scenarios.py)
static func hp_state(hp: float, mx: float) -> String:
	var r := hp / mx
	return "healthy" if r > 0.7 else ("wounded" if r > 0.35 else "critical")


static func mana_state(m: float, mx: float) -> String:
	var r := (m / mx) if mx > 0.0 else 0.0
	return "full" if r >= 0.8 else ("ok" if r >= 0.4 else "low")


static func enemy_cond(h: float, mx: float) -> String:
	var r := h / mx
	return "healthy" if r > 0.66 else ("wounded" if r > 0.33 else "near death")


static func _signed(n: int) -> String:
	return ("+%d" % n) if n >= 0 else ("%d" % n)


static func _t(v) -> bool:
	## "truthy" ala Python
	if v == null:
		return false
	if v is bool:
		return v
	if v is int or v is float:
		return v != 0
	if v is String:
		return v != ""
	if v is Array or v is Dictionary:
		return v.size() > 0
	return true


static func _join(arr, sep := ", ") -> String:
	var p := PackedStringArray()
	for x in arr:
		p.append(str(x))
	return sep.join(p)


static func _norm_id(s: String) -> String:
	var re := RegEx.create_from_string("[^a-z0-9]")
	return re.sub(s.to_lower(), "", true)


static func _enemy_line(e) -> String:
	if _t(e):
		return "Enemy: %s (%s), %s" % [e["name"], e["condition"], "in combat" if e["engaged"] else "nearby, has not noticed you"]
	return "Enemy: none"


# ===================================================================== prompt Adjudicator
## c: {chapter:int, chapter_title, location_name, enemy:null|{name, condition, engaged:bool},
##     weapon:{name, type}, hp_state, mana:{current, max}, skills_unlocked:[nama skill], npcs_present:[nama NPC],
##     final_stage:bool (opsional)}
static func render_adjudicator_input(c: Dictionary, action: String) -> String:
	var L := PackedStringArray(["[Context]", "Chapter %d: %s" % [c["chapter"], c["chapter_title"]], "Location: %s" % c["location_name"]])
	L.append(_enemy_line(c.get("enemy")))
	L.append("Weapon: %s (%s)" % [c["weapon"]["name"], c["weapon"]["type"]])
	L.append("HP: %s" % c["hp_state"])
	L.append("Mana: %d/%d" % [c["mana"]["current"], c["mana"]["max"]])
	L.append("Skills unlocked: " + _join(c["skills_unlocked"]))
	L.append("NPCs present: " + (_join(c["npcs_present"]) if _t(c["npcs_present"]) else "none"))
	if c.get("final_stage", false):
		L.append("Story stage: the Hollow Scribe is defeated; the player must decide the fate of the Tome and the Inkwell")
	return "\n".join(L) + "\n\n[Action]\n" + action


# ===================================================================== prompt Narrator
## row: {context:{chapter, chapter_title, chapter_brief, chapter_flags:[...], location_name, enemy, npcs_present:[nama],
##                level, hp_state, mana:{current,max}, weapon:{name,type}, armor, accessory},
##       action:{text, intent, stat|null, skill|null}, verdict:{tier, roll:null|{d20, modifier, level_bonus, item_bonus,
##                skill_bonus, advantage, total, target, target_kind}}, results:{...lihat new_results()}, recent:[teks]}
static func new_results() -> Dictionary:
	return {"damage_dealt": 0, "enemy_condition_after": null, "enemy_defeated": false, "enemy_avoided": false,
			"enemy_counter": null, "player_damage_taken": 0, "hp_state_after": null, "mana_spent": 0, "healing": 0,
			"mana_restored": 0, "item_used": null, "items_found": [], "exp_gained": 0, "level_up": [],
			"story_beat": null, "location_change": null, "chapter_complete": null, "player_down": false,
			"fled": false, "encounter_triggered": null, "equipped": null}


static func render_narrator_input(row: Dictionary) -> String:
	var c: Dictionary = row["context"]
	var a: Dictionary = row["action"]
	var v: Dictionary = row["verdict"]
	var r: Dictionary = row["results"]
	var stat = a.get("stat")
	var skill = a.get("skill")
	var L := PackedStringArray(["[Story]", "Chapter %d: %s" % [c["chapter"], c["chapter_title"]], c["chapter_brief"],
			"Flags: " + _join(c["chapter_flags"]), "", "[Scene]", "Location: %s" % c["location_name"]])
	var e = c.get("enemy")
	L.append(_enemy_line(e))
	L.append("NPCs present: " + (_join(c["npcs_present"]) if _t(c["npcs_present"]) else "none"))
	L.append("")
	L.append("[Player]")
	L.append("Level %d. HP: %s. Mana: %s." % [c["level"], c["hp_state"], mana_state(c["mana"]["current"], c["mana"]["max"])])
	L.append("Equipped: %s (%s), %s, %s." % [c["weapon"]["name"], c["weapon"]["type"], c["armor"], c["accessory"]])
	L.append("")
	L.append("[Verdict]")
	L.append("Action: %s" % a["text"])
	L.append("Intent: %s | Stat: %s | Skill: %s" % [a["intent"], stat if _t(stat) else "none", skill if _t(skill) else "none"])
	var rl = v.get("roll")
	if _t(rl):
		var parts := PackedStringArray()
		parts.append("d20 %d" % rl["d20"] + (" (advantage)" if rl["advantage"] else ""))
		parts.append((_signed(rl["modifier"]) + " " + (str(stat) if _t(stat) else "")).strip_edges())
		parts.append(_signed(rl["level_bonus"]) + " level")
		if rl["item_bonus"] != 0:
			parts.append(_signed(rl["item_bonus"]) + " item")
		if rl["skill_bonus"] != 0:
			parts.append(_signed(rl["skill_bonus"]) + " skill")
		L.append("Roll: %s = %d vs %s %d" % [" ".join(parts), rl["total"], rl["target_kind"], rl["target"]])
	else:
		L.append("Roll: none (no dice needed)")
	L.append("Outcome: " + str(v["tier"]).replace("_", " "))
	L.append("")
	L.append("[Results]")
	if _t(r["damage_dealt"]):
		L.append("Damage dealt: %d" % r["damage_dealt"])
	if _t(r["enemy_condition_after"]) and _t(e):
		L.append("Enemy now: %s" % r["enemy_condition_after"])
	if r["enemy_defeated"]:
		L.append("Enemy defeated")
	if r["enemy_avoided"]:
		L.append("Enemy avoided (not fought)")
	var ec = r["enemy_counter"]
	if _t(ec):
		if ec["hit"]:
			L.append("Enemy counterattack: hit for %d" % ec["damage"] + (" (critical)" if ec["crit"] else ""))
		else:
			L.append("Enemy counterattack: missed")
	if _t(r["player_damage_taken"]):
		L.append("Damage taken: %d" % r["player_damage_taken"])
	L.append("Player HP now: %s" % r["hp_state_after"])
	if _t(r["mana_spent"]):
		L.append("Mana spent: %d" % r["mana_spent"])
	if _t(r["healing"]):
		L.append("Healed: %d" % r["healing"])
	if _t(r["mana_restored"]):
		L.append("Mana restored: %d" % r["mana_restored"])
	if _t(r["item_used"]):
		L.append("Item used: %s" % r["item_used"])
	if _t(r["items_found"]):
		L.append("Items found: " + _join(r["items_found"]))
	if _t(r["exp_gained"]):
		L.append("EXP gained: %d" % r["exp_gained"])
	for lu in r["level_up"]:
		var s := "Level up: now level %d" % lu["to"]
		if _t(lu.get("new_skills")):
			s += ", new skill " + _join(lu["new_skills"])
		if _t(lu.get("stat_up")):
			s += ", " + _join(lu["stat_up"]) + " +1"
		L.append(s)
	if r["fled"]:
		L.append("Player escaped the fight")
	if _t(r["encounter_triggered"]):
		L.append("Ambush: %s" % r["encounter_triggered"])
	if _t(r["location_change"]):
		L.append("Location changed to: %s" % r["location_change"])
	if _t(r["equipped"]):
		L.append("Equipped %s (%s)" % [r["equipped"]["item"], r["equipped"]["slot"]])
	if _t(r["story_beat"]):
		L.append("Story beat: %s" % r["story_beat"])
	if _t(r["chapter_complete"]):
		var cc: Dictionary = r["chapter_complete"]
		L.append("Chapter complete: %s. HP and Mana fully restored." % cc["title"] + (" Rewards: %s." % _join(cc["rewards"]) if _t(cc["rewards"]) else ""))
	if r["player_down"]:
		L.append("The player has fallen (game over)")
	L.append("")
	L.append("[Recent]")
	if _t(row.get("recent")):
		for s in row["recent"]:
			L.append("- " + str(s))
	else:
		L.append("- (start of the chapter)")
	return "\n".join(L)


## Satu baris untuk daftar [Recent], format sama dengan summarize() di generate_scenarios.py
static func recent_line(action_text: String, intent: String, skill, tier: String, res: Dictionary) -> String:
	var s := "%s -> %s" % [action_text, intent]
	if _t(skill):
		s += " [%s]" % skill
	s += ": " + tier.replace("_", " ")
	var bits := PackedStringArray()
	if _t(res["damage_dealt"]) and not res["enemy_defeated"]:
		bits.append("enemy %s" % res["enemy_condition_after"])
	if res["enemy_defeated"]:
		bits.append("enemy defeated")
	if _t(res["enemy_counter"]) and res["enemy_counter"]["hit"]:
		bits.append("you were hit")
	if _t(res["healing"]):
		bits.append("you healed")
	if res["fled"]:
		bits.append("you escaped")
	if _t(res["items_found"]):
		bits.append("found " + _join(res["items_found"]))
	if _t(res["level_up"]):
		bits.append("level up")
	return s + (" (" + "; ".join(bits) + ")" if bits.size() > 0 else "")


# ===================================================================== pengaman label
## known: {"enemy": id|"", "npcs": [id], "items": [id], "locations": [id], "skills": [id]}
## Mengembalikan {"ok": bool, "label": Dictionary, "issues": [String]}. Engine tetap pemegang aturan: label hanya usulan.
static func sanitize_label(raw: Dictionary, known: Dictionary = {}) -> Dictionary:
	var issues: Array = []
	var label := {"intent": "observe", "target": null, "risky": false, "stat": null, "dc": null, "skill": null, "ending": null}
	var intent = raw.get("intent")
	if not (intent is String) or not INTENTS.has(intent):
		return {"ok": false, "label": label, "issues": ["intent tidak dikenal: %s" % str(intent)]}
	label["intent"] = intent
	label["risky"] = (raw.get("risky") == true)

	var stat = raw.get("stat")
	if _t(stat) and not STATS.has(stat):
		issues.append("stat tidak dikenal: %s" % str(stat))
		stat = null
	var dc = raw.get("dc")
	if dc is int or dc is float:
		var best: int = DC_SCALE[0]
		for d in DC_SCALE:
			if absf(d - float(dc)) < absf(best - float(dc)):
				best = d
		if best != int(dc):
			issues.append("dc %s dibulatkan ke %d" % [str(dc), best])
		dc = best
	else:
		dc = null

	if NO_ROLL_INTENTS.has(intent):
		label["risky"] = false  # aksi tanpa dadu: engine tidak boleh melempar
	if not label["risky"]:
		stat = null
		dc = null
	elif intent == "attack":
		dc = null  # serangan melawan AC musuh, bukan DC
		if stat == null:
			stat = "strength"
			issues.append("stat serangan kosong: dipakai strength")
	else:
		if stat == null:
			stat = DEFAULT_STAT.get(intent, "luck")
			issues.append("stat kosong untuk aksi berisiko: dipakai %s" % stat)
		if dc == null:
			dc = 12
			issues.append("dc kosong untuk aksi berisiko: dipakai 12")
	label["stat"] = stat
	label["dc"] = dc

	var skill = raw.get("skill")
	if _t(skill):
		if known.has("skills") and not (known["skills"] as Array).has(skill):
			issues.append("skill tidak dikenal/terbuka: %s" % str(skill))
			skill = null
	else:
		skill = null
	label["skill"] = skill

	var target = raw.get("target")
	if _t(target) and known.size() > 0:
		var pool: Array = []
		if _t(known.get("enemy", "")):
			pool.append(known["enemy"])
		for k in ["npcs", "items", "locations"]:
			pool.append_array(known.get(k, []))
		if not pool.has(target):
			var found = null
			var nt := _norm_id(str(target))
			for id in pool:
				var ni := _norm_id(str(id))
				if ni == nt or ni.contains(nt) or nt.contains(ni):
					found = id
					break
			if found == null:
				issues.append("target tidak dikenal: %s" % str(target))
			else:
				issues.append("target %s dipetakan ke %s" % [str(target), str(found)])
			target = found
	label["target"] = target if _t(target) else null
	if _t(raw.get("ending")) and ["keep", "burn", "entrust"].has(raw["ending"]):
		label["ending"] = raw["ending"]
	return {"ok": true, "label": label, "issues": issues}


# ===================================================================== jaringan
func is_server_ready() -> bool:
	var http := HTTPRequest.new()
	http.timeout = 3.0
	add_child(http)
	if http.request("http://%s:%d/health" % [host, port]) != OK:
		http.queue_free()
		return false
	var res: Array = await http.request_completed
	http.queue_free()
	return int(res[1]) == 200


## Tahap 1. Mengembalikan {"ok", "valid", "label", "raw", "stats", "error"}
func adjudicate(input_text: String) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = request_timeout_ms / 1000.0
	add_child(http)
	var err := http.request("http://%s:%d/adjudicate" % [host, port], ["Content-Type: application/json"],
			HTTPClient.METHOD_POST, JSON.stringify({"input": input_text}))
	if err != OK:
		http.queue_free()
		return {"ok": false, "valid": false, "label": {}, "raw": "", "stats": {}, "error": "tidak bisa mengirim permintaan (%d)" % err}
	var res: Array = await http.request_completed
	http.queue_free()
	if int(res[0]) != HTTPRequest.RESULT_SUCCESS or int(res[1]) != 200:
		return {"ok": false, "valid": false, "label": {}, "raw": "", "stats": {}, "error": "server (result %d, HTTP %d)" % [int(res[0]), int(res[1])]}
	var data = JSON.parse_string((res[3] as PackedByteArray).get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY or not data.has("label"):
		return {"ok": false, "valid": false, "label": {}, "raw": "", "stats": {}, "error": "respons tidak valid"}
	return {"ok": true, "valid": bool(data.get("valid", false)), "label": data["label"], "raw": str(data.get("raw", "")),
			"stats": data.get("stats", {}), "error": ""}


## Tahap 2, streaming. on_text dipanggil dengan SELURUH teks sejauh ini tiap ada potongan baru.
## Mengembalikan {"ok", "text", "error"}.
func narrate_stream(input_text: String, on_text: Callable = Callable()) -> Dictionary:
	var client := HTTPClient.new()
	var t0 := Time.get_ticks_msec()
	if client.connect_to_host(host, port) != OK:
		return {"ok": false, "text": "", "error": "tidak bisa terhubung ke server"}
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		await get_tree().process_frame
		if Time.get_ticks_msec() - t0 > 5000:
			return {"ok": false, "text": "", "error": "koneksi ke server habis waktu"}
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		return {"ok": false, "text": "", "error": "koneksi gagal (status %d)" % client.get_status()}
	if client.request(HTTPClient.METHOD_POST, "/narrate_stream", ["Content-Type: application/json"],
			JSON.stringify({"input": input_text})) != OK:
		return {"ok": false, "text": "", "error": "tidak bisa mengirim permintaan"}
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		await get_tree().process_frame
	if not client.has_response():
		return {"ok": false, "text": "", "error": "tidak ada respons"}
	var code := client.get_response_code()
	var buf := PackedByteArray()
	while client.get_status() == HTTPClient.STATUS_BODY:
		client.poll()
		var chunk := client.read_response_body_chunk()
		if chunk.size() > 0:
			buf.append_array(chunk)
			if on_text.is_valid():
				on_text.call(buf.get_string_from_utf8())
		else:
			await get_tree().process_frame
		if Time.get_ticks_msec() - t0 > request_timeout_ms:
			client.close()
			return {"ok": false, "text": buf.get_string_from_utf8(), "error": "narasi habis waktu"}
	client.close()
	var text := buf.get_string_from_utf8().strip_edges()
	return {"ok": code == 200 and text != "", "text": text, "error": "" if code == 200 else "HTTP %d" % code}
