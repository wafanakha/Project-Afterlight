class_name GameEngine
extends RefCounted

const BOSS := "The Hollow Scribe"
const DEFAULT_ENDINGS := ["keep", "burn", "entrust"]

var bal: Dictionary
var world: Dictionary
var rng := RandomNumberGenerator.new()
var stat_full: Dictionary = {}   # "STR" -> "strength"
var abbr_of: Dictionary = {}     # "strength" -> "STR"

# ---- keadaan
var stats: Dictionary = {}
var level := 1
var exp_pts := 0
var total_exp := 0
var hp := 0
var mana := 0
var owned := {"weapon": [], "armor": [], "accessory": []}
var equipped := {"weapon": "", "armor": "", "accessory": ""}
var inv: Dictionary = {}
var usage: Dictionary = {}
var chapter := 1
var location := "oakhaven_village"
var enemy: Dictionary = {}          # kosong = tidak ada musuh
var npcs_present: Array = []        # id NPC
var queue: Array = []               # sisa pertemuan di bab ini
var turns_until_spawn := 0
var turn := 0
var down := false
var final_stage := false
var ending := ""
var history: Array = []             # ringkasan giliran (untuk [Recent])
var pending_chapter := 0
var village_safe := false           # Bab 1 selesai: tidak ada musuh yang muncul lagi di Oakhaven Village
var dice_log: Array = []            # dadu non-d20 yang dilempar di giliran ini: [{tag, sides, results}]
var last_defeated := ""             # nama musuh yang dikalahkan di giliran ini (dibaca UI untuk narasi)


func _init(bal_data: Dictionary, world_data: Dictionary, seed_value: int = -1) -> void:
	bal = bal_data
	world = world_data
	stat_full = world["stat_names"]
	for k in stat_full:
		abbr_of[stat_full[k]] = k
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	new_game()


# util
static var _slug_re: RegEx = RegEx.create_from_string("[^a-z0-9]+")
static var _dice_re: RegEx = RegEx.create_from_string("^(\\d+)d(\\d+)([+-]\\d+)?$")


static func slug(s: String) -> String:
	var out := _slug_re.sub(s.to_lower(), "_", true)
	while out.begins_with("_"):
		out = out.substr(1)
	while out.ends_with("_"):
		out = out.substr(0, out.length() - 1)
	return out


static func parse_dice(expr: String) -> Array:
	var m := _dice_re.search(expr)
	return [int(m.get_string(1)), int(m.get_string(2)), int(m.get_string(3)) if m.get_string(3) != "" else 0]


func roll_dice(n: int, sides: int, tag := "") -> int:
	## tag ("damage", "enemy", "fumble") membuat tiap dadu dicatat di dice_log supaya UI bisa menampilkannya.
	var t := 0
	var rolled: Array = []
	for i in n:
		var r := rng.randi_range(1, sides)
		rolled.append(r)
		t += r
	if tag != "" and n > 0:
		dice_log.append({"tag": tag, "sides": sides, "results": rolled})
	return t


func d20(adv := false) -> int:
	var r := rng.randi_range(1, 20)
	return maxi(r, rng.randi_range(1, 20)) if adv else r


func _pick(arr: Array):
	return arr[rng.randi_range(0, arr.size() - 1)]


func skill_name_by_id(id: String) -> String:
	for n in bal["skills"]:
		if slug(n) == id:
			return n
	return ""


func item_name_by_id(id: String) -> String:
	## nama item dari id slug
	for n in bal["consumables"]:
		if slug(n) == id:
			return n
	for cat in ["weapons", "armor", "accessories"]:
		for n in bal[cat]:
			if slug(n) == id:
				return n
	return ""


func slot_of(item: String) -> String:
	if bal["weapons"].has(item):
		return "weapon"
	if bal["armor"].has(item):
		return "armor"
	if bal["accessories"].has(item):
		return "accessory"
	return ""


# nilai turunan
func mod(abbr: String) -> int:
	return int(floor((stats[abbr] - 10) / 2.0))


func level_bonus() -> int:
	return 2 + (level - 1) / 3


func max_hp() -> int:
	var h: Dictionary = bal["hp"]
	var extra := int(bal["accessories"].get(equipped["accessory"], {}).get("hp", 0))
	return int(h["base"]) + int(h["per_level"]) * (level - 1) + mod("END") * level + extra


func max_mana() -> int:
	var m: Dictionary = bal["mana"]
	return int(m["base"]) + int(m["per_level"]) * (level - 1) + mod("INT") * level


func armor_ac(name: String) -> int:
	var a: Dictionary = bal["armor"][name]
	var dex := mod("DEX")
	if a["dex_cap"] != null:
		dex = mini(dex, int(a["dex_cap"]))
	return int(a["ac"]) + dex


func ac() -> int:
	return armor_ac(equipped["armor"]) + int(bal["accessories"].get(equipped["accessory"], {}).get("ac", 0))


func item_bonus(abbr: String) -> int:
	return int(bal["accessories"].get(equipped["accessory"], {}).get(abbr.to_lower(), 0))


func exp_needed() -> int:
	## EXP yang dibutuhkan untuk naik dari level sekarang
	if level >= int(bal["level_max"]):
		return 0
	return int(bal["exp_to_next"][level - 1])


func unlocked_skills() -> Array:
	var out: Array = []
	for n in bal["skills"]:
		if int(bal["skills"][n]["unlock"]) <= level:
			out.append(n)
	return out


func skill_cost(name: String) -> int:
	return int(bal["skills"][name]["cost"])


func skill_usable(name: String) -> bool:
	return bal["skills"].has(name) and int(bal["skills"][name]["unlock"]) <= level and mana >= skill_cost(name)


func weapon_type() -> String:
	return str(bal["weapons"][equipped["weapon"]]["type"])


# attack option
func hit_chance(need: int) -> float:
	return maxf(0.05, minf(0.95, (21 - need) / 20.0))


func expected_damage(opt: Dictionary, target_ac: int) -> float:
	if int(opt["auto"]) > 0:
		return float(opt["auto"])
	var p := hit_chance(target_ac - int(opt["hit"]))
	if opt["adv"]:
		p = 1.0 - pow(1.0 - p, 2)
	var avg := 0.0
	for d in opt["dice"]:
		avg += d[0] * (d[1] + 1) / 2.0
	return p * (avg + float(opt["flat"])) + 0.05 * avg


func _option(name: String, stat: String, hit: int, dice: Array, flat: int, cost := 0, adv := false, auto := 0, skill_id := "") -> Dictionary:
	return {"name": name, "stat": stat, "hit": hit, "dice": dice, "flat": flat, "cost": cost, "adv": adv, "auto": auto, "skill_id": skill_id}


func weapon_option(w: String, want_stat := "") -> Dictionary:
	var info: Dictionary = bal["weapons"][w]
	var allowed: Array = {"melee": ["STR", "DEX"], "ranged": ["AWR", "DEX"], "arcane": ["INT"]}[info["type"]]
	var stat: String = allowed[0]
	if want_stat != "" and allowed.has(want_stat):
		stat = want_stat
	else:
		for s in allowed:
			if mod(s) > mod(stat):
				stat = s
	var d := parse_dice(info["dice"])
	return _option(w, stat, mod(stat) + level_bonus(), [[d[0], d[1]]], maxi(0, mod(stat)) + d[2])


func attack_options() -> Array:
	var base := weapon_option(equipped["weapon"])
	var opts: Array = [base]
	var wtype := weapon_type()
	var sk: Dictionary = bal["skills"]
	var extra := 1 if level < 5 else 2
	if skill_usable("Power Strike") and wtype == "melee":
		var smod := mod("STR")
		opts.append(_option("Power Strike", "STR", smod + level_bonus() + 3, base["dice"] + [[extra, 6]], maxi(0, smod), skill_cost("Power Strike"), false, 0, "power_strike"))
	if skill_usable("Keen Eye") and base["stat"] == "AWR":
		opts.append(_option("Keen Eye", base["stat"], int(base["hit"]) + 5, base["dice"], int(base["flat"]), skill_cost("Keen Eye"), false, 0, "keen_eye"))
	if skill_usable("Arcane Bolt"):
		var dn := 2 if level < 5 else 3
		opts.append(_option("Arcane Bolt", "INT", mod("INT") + level_bonus(), [[dn, 4]], maxi(0, mod("INT")), skill_cost("Arcane Bolt"), false, 0, "arcane_bolt"))
	if skill_usable("Lucky Break"):
		opts.append(_option("Lucky Break", base["stat"], int(base["hit"]), base["dice"], int(base["flat"]), skill_cost("Lucky Break"), true, 0, "lucky_break"))
	return opts


# permainan baru dan bab
func new_game() -> void:
	stats = bal["stats_start"].duplicate()
	level = 1
	exp_pts = 0
	total_exp = 0
	usage = {}
	var g: Dictionary = bal["start_gear"]
	owned = {"weapon": (g["weapons"] as Array).duplicate(), "armor": (g["armor"] as Array).duplicate(),
			"accessory": (g["accessories"] as Array).duplicate()}
	equipped = {"weapon": "", "armor": g["armor"][0], "accessory": g["accessories"][0]}
	var best := -1.0
	for w in owned["weapon"]:
		var d := parse_dice(bal["weapons"][w]["dice"])
		var avg: float = d[0] * (d[1] + 1) / 2.0
		if bal["weapons"][w]["type"] == "melee" and avg > best:
			best = avg
			equipped["weapon"] = w
	inv = (bal["start_inventory"] as Dictionary).duplicate()
	location = "oakhaven_village"
	enemy = {}
	npcs_present = []
	turn = 0
	down = false
	final_stage = false
	ending = ""
	history = []
	pending_chapter = 0
	village_safe = false
	last_defeated = ""
	hp = max_hp()
	mana = max_mana()
	begin_chapter(1)
	# Bab 1 opening
	npcs_present = ["mayor_bartholomew"]
	turns_until_spawn = rng.randi_range(2, 3)


func chapter_def() -> Dictionary:
	return bal["chapters"][chapter - 1]


func chapter_world() -> Dictionary:
	return world["chapters"][str(chapter)]


func main_location() -> String:
	return str(chapter_world()["main_location"])


func begin_chapter(cid: int) -> void:
	chapter = cid
	var ch := chapter_def()
	queue = []
	for i in int(ch["random_count"]):
		queue.append({"name": _pick(ch["random_pool"]), "scripted": false})
	for n in ch["scripted"]:
		queue.append({"name": n, "scripted": true})
	turns_until_spawn = rng.randi_range(1, 2)
	_refresh_npcs()


func _refresh_npcs() -> void:
	npcs_present = []
	if not enemy.is_empty():
		return
	for n in chapter_world()["npcs"]:
		if world["npcs"][n]["location"] == location and rng.randf() < 0.6:
			npcs_present.append(n)


func spawn_next() -> Dictionary:
	if queue.is_empty():
		return {}
	var f: Dictionary = queue.pop_front()
	var e: Dictionary = bal["enemies"][f["name"]]
	enemy = {"name": f["name"], "id": slug(f["name"]), "hp": int(e["hp"]), "max_hp": int(e["hp"]),
			"engaged": f["scripted"] or rng.randf() >= 0.35, "scripted": f["scripted"], "boss": f["name"] == BOSS}
	npcs_present = []
	return enemy


func spawn_allowed() -> bool:
	if location != main_location():
		return false
	if village_safe and location == "oakhaven_village":
		return false
	return true


func enemy_condition() -> String:
	return AIClient.enemy_cond(enemy["hp"], enemy["max_hp"]) if not enemy.is_empty() else ""


# konteks untuk AIClient
func _enemy_ctx():
	if enemy.is_empty():
		return null
	return {"name": enemy["name"], "condition": AIClient.enemy_cond(enemy["hp"], enemy["max_hp"]), "engaged": enemy["engaged"]}


func _npc_names() -> Array:
	var out: Array = []
	for n in npcs_present:
		out.append(world["npcs"][n]["name"])
	return out


func adjudicator_context() -> Dictionary:
	var wch := chapter_world()
	return {"chapter": chapter, "chapter_title": wch["title"], "location_name": world["locations"][location]["name"],
			"enemy": _enemy_ctx(), "weapon": {"name": equipped["weapon"], "type": weapon_type()},
			"hp_state": AIClient.hp_state(maxi(hp, 0), max_hp()), "mana": {"current": mana, "max": max_mana()},
			"skills_unlocked": unlocked_skills(), "npcs_present": _npc_names(), "final_stage": final_stage}


func narrator_context() -> Dictionary:
	var wch := chapter_world()
	return {"chapter": chapter, "chapter_title": wch["title"], "chapter_brief": wch["brief"], "chapter_flags": wch["flags"],
			"location_name": world["locations"][location]["name"], "enemy": _enemy_ctx(), "npcs_present": _npc_names(),
			"level": level, "hp_state": AIClient.hp_state(maxi(hp, 0), max_hp()), "mana": {"current": mana, "max": max_mana()},
			"weapon": {"name": equipped["weapon"], "type": weapon_type()}, "armor": equipped["armor"], "accessory": equipped["accessory"]}


func known_ids() -> Dictionary:
	var items: Array = []
	for n in inv:
		if int(inv[n]) > 0:
			items.append(slug(n))
	for slot in owned:
		for n in owned[slot]:
			items.append(slug(n))
	var npcs: Array = []
	for n in world["npcs"]:
		npcs.append(n)
	var skills: Array = []
	for n in bal["skills"]:
		skills.append(slug(n))
	return {"enemy": enemy.get("id", ""), "npcs": npcs, "items": items, "locations": world["locations"].keys(), "skills": skills}


# roll a die
func check(abbr: String, dc: int, skill_id := "") -> Dictionary:
	var adv := skill_id == "lucky_break"
	var r1 := d20(false)
	var r2 := rng.randi_range(1, 20) if adv else 0
	var r := maxi(r1, r2) if adv else r1
	var m := mod(abbr)
	var lb := level_bonus()
	var ib := item_bonus(abbr)
	var sb := 5 if (skill_id == "keen_eye" or skill_id == "silver_tongue") else 0
	var total := r + m + lb + ib + sb
	var tier := "critical_failure" if r == 1 else ("critical_success" if r == 20 else ("success" if total >= dc else "failure"))
	return {"roll": {"d20": r, "dice": [r1, r2] if adv else [r1], "modifier": m, "level_bonus": lb, "item_bonus": ib, "skill_bonus": sb,
			"advantage": adv, "total": total, "target": dc, "target_kind": "DC"}, "tier": tier}


func attack_roll(opt: Dictionary, target_ac: int) -> Dictionary:
	mana -= int(opt["cost"])
	var r1 := d20(false)
	var r2 := rng.randi_range(1, 20) if opt["adv"] else 0
	var r := maxi(r1, r2) if opt["adv"] else r1
	var total := r + int(opt["hit"])
	var m := mod(opt["stat"])
	var lb := level_bonus()
	var roll := {"d20": r, "dice": [r1, r2] if opt["adv"] else [r1], "modifier": m, "level_bonus": lb, "item_bonus": 0,
			"skill_bonus": int(opt["hit"]) - m - lb, "advantage": opt["adv"], "total": total, "target": target_ac, "target_kind": "AC"}
	var dmg := 0
	var fumble := 0
	var tier := ""
	if r == 1:
		tier = "critical_failure"
		fumble = roll_dice(1, 4, "fumble")
	elif r == 20 or total >= target_ac:
		tier = "critical_success" if r == 20 else "success"
		var mult := 2 if r == 20 else 1
		for d in opt["dice"]:
			dmg += roll_dice(d[0] * mult, d[1], "damage")
		dmg += int(opt["flat"])
		usage[opt["stat"]] = int(usage.get(opt["stat"], 0)) + 1
	else:
		tier = "failure"
	return {"roll": roll, "tier": tier, "damage": dmg, "fumble": fumble}


# EXP, level, item
func gain(amount: int) -> Array:
	var lv0 := level
	var st0 := stats.duplicate()
	exp_pts += amount
	total_exp += amount
	while level < int(bal["level_max"]) and exp_pts >= int(bal["exp_to_next"][level - 1]):
		exp_pts -= int(bal["exp_to_next"][level - 1])
		level += 1
		if not usage.is_empty():
			var top := ""
			var best := -1
			for k in usage:
				if int(usage[k]) > best:
					best = int(usage[k])
					top = k
			stats[top] = mini(20, int(stats[top]) + 1)
		usage.clear()
		hp = max_hp()
		mana = max_mana()
	if level == lv0:
		return []
	var new_skills: Array = []
	for n in bal["skills"]:
		var u := int(bal["skills"][n]["unlock"])
		if lv0 < u and u <= level:
			new_skills.append(n)
	var up: Array = []
	for k in stats:
		if int(stats[k]) > int(st0[k]):
			up.append(stat_full[k])
	return [{"from": lv0, "to": level, "new_skills": new_skills, "stat_up": up}]


func find_item() -> String:
	var cands: Array = []
	for slot in ["weapon", "armor", "accessory"]:
		for item in world["drop_pool"][slot]:
			if chapter >= int(world["drop_pool"][slot][item]) and not owned[slot].has(item):
				cands.append([slot, item])
	for item in world["drop_pool"]["consumable"]:
		if chapter >= int(world["drop_pool"]["consumable"][item]):
			cands.append(["consumable", item])
	if cands.is_empty():
		return ""
	var c: Array = _pick(cands)
	if c[0] == "consumable":
		inv[c[1]] = int(inv.get(c[1], 0)) + 1
	else:
		owned[c[0]].append(c[1])
	return c[1]


static func new_results() -> Dictionary:
	return AIClient.new_results()


func _new_turn(label: Dictionary, text: String) -> Dictionary:
	return {"label": label, "text": text, "ctx": narrator_context(), "res": new_results(), "roll": null, "tier": "no_roll",
			"mana_before": mana, "skill_id": null, "stat": null, "enemy_acts": true, "ended": false, "events": [],
			"risky": bool(label.get("risky", false)), "target": label.get("target"), "intent": str(label.get("intent", "observe"))}


func resolve(label: Dictionary, action_text: String) -> Dictionary:
	if down:
		return {"ok": false, "message": "You have fallen. Type /new to start again."}
	if ending != "":
		return {"ok": false, "message": "The story is over. Type /new to start again."}
	last_defeated = ""
	dice_log = []
	var t := _new_turn(label, action_text)
	var err := ""
	match t["intent"]:
		"attack": err = _do_attack(t)
		"use_item": err = _do_use_item(t)
		"skill": err = _do_skill(t)
		"flee": err = _do_flee(t)
		"equip": err = _do_equip(t)
		"travel": err = _do_travel(t)
		"decide": err = _do_decide(t)
		_: err = _do_generic(t)
	if err != "":
		return {"ok": false, "message": err}
	return _finish_turn(t)


func _finish_turn(t: Dictionary) -> Dictionary:
	var res: Dictionary = t["res"]
	# serangan balik musuh, bila musuh masih hidup dan menyerang di giliran ini
	if not enemy.is_empty() and enemy["engaged"] and t["enemy_acts"] and hp > 0 and not t["ended"]:
		_enemy_counter(res)
	if hp <= 0:
		res["player_down"] = true
		down = true
	turn += 1
	res["mana_spent"] = maxi(0, int(t["mana_before"]) - mana)
	res["hp_state_after"] = AIClient.hp_state(maxi(hp, 0), max_hp())
	var recent: Array = []
	for i in range(maxi(0, history.size() - 2), history.size()):
		recent.append(history[i])
	var row := {"context": t["ctx"], "action": {"text": t["text"], "intent": t["intent"], "target": t["target"], "risky": t["risky"],
			"stat": t["stat"], "skill": t["skill_id"]}, "verdict": {"roll": t["roll"], "tier": t["tier"]}, "results": res, "recent": recent}
	history.append(AIClient.recent_line(t["text"], t["intent"], t["skill_id"], t["tier"], res))
	# keadaan sesudah giliran
	var events: Array = t["events"]
	if not down and not t["ended"]:
		mana = mini(max_mana(), mana + int(bal["mana"]["regen_per_turn"]))
	if pending_chapter != 0:
		var nxt := pending_chapter
		pending_chapter = 0
		begin_chapter(nxt)
		events.append({"type": "chapter_begin", "chapter": nxt})
	elif not down and enemy.is_empty() and not queue.is_empty() and not final_stage:
		if spawn_allowed():
			turns_until_spawn -= 1
			if turns_until_spawn <= 0:
				var e := spawn_next()
				events.append({"type": "enemy_appears", "name": e["name"], "engaged": e["engaged"], "remaining": queue.size()})
	return {"ok": true, "message": "", "row": row, "events": events, "dice": dice_log.duplicate(true)}


func _enemy_counter(res: Dictionary) -> void:
	var e: Dictionary = bal["enemies"][enemy["name"]]
	var d := parse_dice(e["dmg"])
	var r := rng.randi_range(1, 20)
	var hit := r != 1 and (r == 20 or r + int(e["atk"]) >= ac())
	var dmg: int = (roll_dice(d[0] * (2 if r == 20 else 1), d[1], "enemy") + d[2]) if hit else 0
	hp -= dmg
	res["player_damage_taken"] = int(res["player_damage_taken"]) + dmg
	res["enemy_counter"] = {"hit": hit, "crit": r == 20, "damage": dmg}


func _remove_enemy_after_kill(t: Dictionary) -> void:
	var res: Dictionary = t["res"]
	res["enemy_defeated"] = true
	var e: Dictionary = bal["enemies"][enemy["name"]]
	if int(e["exp"]) > 0:
		res["exp_gained"] = int(res["exp_gained"]) + int(e["exp"])
		res["level_up"] += gain(int(e["exp"]))
	if not enemy["boss"] and rng.randf() < 0.35:
		var it := find_item()
		if it != "":
			(res["items_found"] as Array).append(it)
	t["ended"] = true
	last_defeated = str(enemy["name"])
	enemy = {}
	if queue.is_empty():
		_complete_chapter(t)
	else:
		turns_until_spawn = rng.randi_range(1, 3)
		_refresh_npcs()


func _complete_chapter(t: Dictionary) -> void:
	var res: Dictionary = t["res"]
	var ch := chapter_def()
	var wch := chapter_world()
	if chapter == 1:
		village_safe = true   # semua goblin Oakhaven sudah tumbang
	if int(ch["exp_bonus"]) > 0:
		res["exp_gained"] = int(res["exp_gained"]) + int(ch["exp_bonus"])
		res["level_up"] += gain(int(ch["exp_bonus"]))
	hp = max_hp()
	mana = max_mana()
	var rewards: Array = []
	var r: Dictionary = ch["reward"]
	for pair in [["weapon", "weapons"], ["armor", "armor"], ["accessory", "accessories"]]:
		for it in r.get(pair[1], []):
			if not owned[pair[0]].has(it):
				owned[pair[0]].append(it)
			rewards.append(it)
	for it in r.get("items", {}):
		inv[it] = int(inv.get(it, 0)) + int(r["items"][it])
		rewards.append(it)
	res["story_beat"] = wch["beat"]
	res["chapter_complete"] = {"chapter": chapter, "title": wch["title"], "rewards": rewards}
	if chapter < bal["chapters"].size():
		pending_chapter = chapter + 1
	else:
		final_stage = true
		t["events"].append({"type": "final_stage"})


# action
func _skill_from_label(t: Dictionary, allowed: Array) -> String:
	## Mengembalikan nama skill bila disebut, diizinkan, terbuka, dan mananya cukup. Mana langsung dipotong oleh pemanggil.
	var sid = t["label"].get("skill")
	if sid == null or str(sid) == "":
		return ""
	var name := skill_name_by_id(str(sid))
	if name == "" or not allowed.has(name) or not skill_usable(name):
		return ""
	return name


func _do_attack(t: Dictionary) -> String:
	if enemy.is_empty():
		return "There is nothing to attack here."
	var label: Dictionary = t["label"]
	var want_abbr: String = abbr_of.get(str(label.get("stat", "")), "")
	var opt := weapon_option(equipped["weapon"], want_abbr)
	var sname := _skill_from_label(t, ["Power Strike", "Keen Eye", "Arcane Bolt", "Lucky Break"])
	if sname != "":
		for o in attack_options():
			if o["name"] == sname:
				opt = o
				break
		# stat dasar opsi skill mengikuti permintaan model bila sah
		if opt["skill_id"] == "lucky_break" and want_abbr != "":
			var base := weapon_option(equipped["weapon"], want_abbr)
			opt = _option("Lucky Break", base["stat"], base["hit"], base["dice"], base["flat"], skill_cost("Lucky Break"), true, 0, "lucky_break")
	enemy["engaged"] = true
	t["stat"] = stat_full[opt["stat"]]
	t["skill_id"] = opt["skill_id"] if opt["skill_id"] != "" else null
	t["risky"] = true
	t["target"] = enemy["id"]
	var e: Dictionary = bal["enemies"][enemy["name"]]
	var rec := attack_roll(opt, int(e["ac"]))
	t["roll"] = rec["roll"]
	t["tier"] = rec["tier"]
	var res: Dictionary = t["res"]
	enemy["hp"] = int(enemy["hp"]) - int(rec["damage"])
	res["damage_dealt"] = rec["damage"]
	if int(rec["fumble"]) > 0:
		hp -= int(rec["fumble"])
		res["player_damage_taken"] = int(res["player_damage_taken"]) + int(rec["fumble"])
	res["enemy_condition_after"] = AIClient.enemy_cond(maxi(enemy["hp"], 0), enemy["max_hp"]) if enemy["hp"] > 0 else "defeated"
	if enemy["hp"] <= 0:
		_remove_enemy_after_kill(t)
	return ""


func _do_use_item(t: Dictionary) -> String:
	var label: Dictionary = t["label"]
	var name := item_name_by_id(str(label.get("target", "")))
	if name == "" or not bal["consumables"].has(name):
		return "Which item? You do not have that."
	if int(inv.get(name, 0)) <= 0:
		return "You have no %s." % name
	var cons: Dictionary = bal["consumables"][name]
	var res: Dictionary = t["res"]
	t["risky"] = false
	t["target"] = slug(name)
	if name == "Scroll of Magic Missile":
		if enemy.is_empty():
			return "There is nothing to aim the scroll at."
		enemy["engaged"] = true
		inv[name] -= 1
		enemy["hp"] = int(enemy["hp"]) - int(cons["damage"])
		res["damage_dealt"] = int(cons["damage"])
		res["item_used"] = name
		res["enemy_condition_after"] = AIClient.enemy_cond(maxi(enemy["hp"], 0), enemy["max_hp"]) if enemy["hp"] > 0 else "defeated"
		if enemy["hp"] <= 0:
			_remove_enemy_after_kill(t)
		return ""
	if name == "Smoke Bomb":
		if enemy.is_empty() or not enemy["engaged"]:
			return "There is nobody to escape from."
		if enemy["scripted"] or enemy["boss"]:
			return "You cannot escape this fight."
		inv[name] -= 1
		res["item_used"] = name
		res["fled"] = true
		t["enemy_acts"] = false
		t["ended"] = true
		enemy = {}
		turns_until_spawn = rng.randi_range(1, 3)
		_refresh_npcs()
		return ""
	inv[name] -= 1
	res["item_used"] = name
	if cons.has("heal"):
		var healed := mini(int(cons["heal"]), max_hp() - hp)
		hp += healed
		res["healing"] = healed
	if cons.has("mana"):
		var restored := mini(int(cons["mana"]), max_mana() - mana)
		mana += restored
		res["mana_restored"] = restored
	return ""


func _do_skill(t: Dictionary) -> String:
	var sname := _skill_from_label(t, ["Second Wind", "Evasive Step"])
	if sname == "":
		var sid = t["label"].get("skill")
		var n := skill_name_by_id(str(sid)) if sid != null else ""
		if n == "" or not ["Second Wind", "Evasive Step"].has(n):
			return _do_generic(t)
		if int(bal["skills"][n]["unlock"]) > level:
			return "%s unlocks at level %d." % [n, int(bal["skills"][n]["unlock"])]
		return "Not enough mana for %s." % n
	var res: Dictionary = t["res"]
	t["risky"] = false
	t["stat"] = null
	t["skill_id"] = slug(sname)
	t["target"] = null
	if sname == "Second Wind":
		mana -= skill_cost(sname)
		var healed := mini(5 + 3 * level, max_hp() - hp)
		hp += healed
		res["healing"] = healed
	else:
		if enemy.is_empty() or not enemy["engaged"]:
			return "There is nothing to evade."
		mana -= skill_cost(sname)
		t["enemy_acts"] = false
		res["enemy_counter"] = {"hit": false, "crit": false, "damage": 0}
	return ""


func _do_flee(t: Dictionary) -> String:
	if enemy.is_empty() or not enemy["engaged"]:
		return "There is nothing to flee from."
	if enemy["scripted"] or enemy["boss"]:
		return "You cannot escape this fight."
	var dc := int(t["label"].get("dc", 12)) if t["label"].get("dc") != null else 12
	var rec := check("DEX", dc)
	t["roll"] = rec["roll"]
	t["tier"] = rec["tier"]
	t["risky"] = true
	t["stat"] = "dexterity"
	t["target"] = enemy["id"]
	var res: Dictionary = t["res"]
	if rec["tier"] == "critical_failure":
		var dmg := roll_dice(1, 4, "fumble")
		hp -= dmg
		res["player_damage_taken"] = int(res["player_damage_taken"]) + dmg
	if rec["tier"] == "success" or rec["tier"] == "critical_success":
		res["fled"] = true
		t["enemy_acts"] = false
		t["ended"] = true
		enemy = {}
		turns_until_spawn = rng.randi_range(1, 3)
		_refresh_npcs()
	return ""


func _do_equip(t: Dictionary) -> String:
	var name := item_name_by_id(str(t["label"].get("target", "")))
	var slot := slot_of(name)
	if name == "" or slot == "" or not owned[slot].has(name):
		return "You do not own that."
	if equipped[slot] == name:
		return "You already have the %s equipped." % name
	equipped[slot] = name
	t["risky"] = false
	t["target"] = slug(name)
	t["res"]["equipped"] = {"slot": slot, "item": name}
	hp = mini(hp, max_hp())
	return ""


func equip_free(name: String) -> String:
	## Ganti perlengkapan tanpa giliran (dipakai tombol Equip saat tidak ada musuh yang sedang bertarung).
	var slot := slot_of(name)
	if slot == "" or not owned[slot].has(name):
		return "You do not own that."
	equipped[slot] = name
	hp = mini(hp, max_hp())
	return ""


func _do_travel(t: Dictionary) -> String:
	var dest := str(t["label"].get("target", ""))
	if not world["locations"].has(dest):
		return "Where do you want to go?"
	if dest == location:
		return "You are already there."
	if int(world["locations"][dest]["unlock_chapter"]) > chapter:
		return "The way to %s is not open yet." % world["locations"][dest]["name"]
	if not enemy.is_empty() and enemy["engaged"]:
		return "You cannot leave in the middle of a fight."
	var res: Dictionary = t["res"]
	t["target"] = dest
	var safe: bool = world["locations"][dest]["safe"]
	if t["risky"] and not safe:
		var abbr: String = abbr_of.get(str(t["label"].get("stat", "")), "END")
		var dc := int(t["label"]["dc"]) if t["label"].get("dc") != null else 12
		var rec := check(abbr, dc)
		t["roll"] = rec["roll"]
		t["tier"] = rec["tier"]
		t["stat"] = stat_full[abbr]
		if rec["tier"] == "critical_failure":
			var dmg := roll_dice(1, 4, "fumble")
			hp -= dmg
			res["player_damage_taken"] = int(res["player_damage_taken"]) + dmg
		elif rec["tier"] == "success" or rec["tier"] == "critical_success":
			usage[abbr] = int(usage.get(abbr, 0)) + 1
			var xp := (dc / 2) * (2 if rec["tier"] == "critical_success" else 1)
			res["exp_gained"] = int(res["exp_gained"]) + xp
			res["level_up"] += gain(xp)
	else:
		t["risky"] = false
	enemy = {}   # musuh yang belum menyadari kehadiran pemain tertinggal di tempat lama
	location = dest
	res["location_change"] = world["locations"][dest]["name"]
	_refresh_npcs()
	# gagal di wilayah liar: disergap musuh bab ini
	if t["tier"] in ["failure", "critical_failure"] and not safe and not queue.is_empty() and dest == main_location():
		var idx := -1
		for i in queue.size():
			if not queue[i]["scripted"]:
				idx = i
				break
		if idx >= 0:
			var f: Dictionary = queue[idx]
			queue.remove_at(idx)
			queue.push_front(f)
			var e := spawn_next()
			e["engaged"] = true
			res["encounter_triggered"] = e["name"]
	elif dest == main_location() and enemy.is_empty() and not queue.is_empty() and not (village_safe and dest == "oakhaven_village"):
		turns_until_spawn = rng.randi_range(1, 2)
	return ""


func _do_decide(t: Dictionary) -> String:
	if not final_stage:
		return "There is no decision to make yet."
	var e = t["label"].get("ending")
	if e == null or not DEFAULT_ENDINGS.has(str(e)):
		return "Decide: keep the Tome, burn both relics, or entrust them to Elara?"
	ending = str(e)
	t["risky"] = false
	t["tier"] = "no_roll"
	return ""


func _do_generic(t: Dictionary) -> String:
	## physical, social, search, magic, stealth, other, talk, observe, dan travel/skill yang jatuh kemari
	var label: Dictionary = t["label"]
	var res: Dictionary = t["res"]
	var intent: String = t["intent"]
	var risky: bool = bool(label.get("risky", false)) and not ["talk", "observe"].has(intent)
	t["risky"] = risky
	if not risky:
		t["stat"] = null
		return ""
	var abbr: String = abbr_of.get(str(label.get("stat", "")), "")
	if abbr == "":
		abbr = "LCK"
	var dc := int(label["dc"]) if label.get("dc") != null else 12
	var sname := _skill_from_label(t, ["Silver Tongue", "Keen Eye", "Lucky Break"])
	var sid := ""
	if sname != "":
		sid = slug(sname)
		mana -= skill_cost(sname)
		t["skill_id"] = sid
	var rec := check(abbr, dc, sid)
	t["roll"] = rec["roll"]
	t["tier"] = rec["tier"]
	t["stat"] = stat_full[abbr]
	var tier: String = rec["tier"]
	if tier == "critical_failure":
		var dmg := roll_dice(1, 4, "fumble")
		hp -= dmg
		res["player_damage_taken"] = int(res["player_damage_taken"]) + dmg
	elif tier == "success" or tier == "critical_success":
		usage[abbr] = int(usage.get(abbr, 0)) + 1
		var xp := (dc / 2) * (2 if tier == "critical_success" else 1)
		res["exp_gained"] = int(res["exp_gained"]) + xp
		res["level_up"] += gain(xp)
		if intent == "search" and rng.randf() < 0.35:
			var it := find_item()
			if it != "":
				(res["items_found"] as Array).append(it)
	# musuh yang belum menyadari pemain (stealth)
	if not enemy.is_empty() and not enemy["engaged"]:
		if intent == "stealth":
			if tier == "success" or tier == "critical_success":
				res["enemy_avoided"] = true
				t["ended"] = true
				enemy = {}
				turns_until_spawn = rng.randi_range(1, 3)
				_refresh_npcs()
			else:
				enemy["engaged"] = true
				t["enemy_acts"] = false
		else:
			t["enemy_acts"] = false
	return ""


# ===================================================================== tombol (label langsung, tanpa Adjudicator)
func item_label(item_name: String) -> Dictionary:
	return {"intent": "use_item", "target": slug(item_name), "risky": false, "stat": null, "dc": null, "skill": null, "ending": null}


func skill_button(skill_name: String) -> Dictionary:
	## {"enabled": bool, "reason": String, "text": String, "label": Dictionary}
	var out := {"enabled": false, "reason": "", "text": "", "label": {}}
	var info: Dictionary = bal["skills"][skill_name]
	if int(info["unlock"]) > level:
		out["reason"] = "Unlocks at level %d" % int(info["unlock"])
		return out
	if mana < int(info["cost"]):
		out["reason"] = "Not enough mana (%d needed)" % int(info["cost"])
		return out
	var sid := slug(skill_name)
	var en: String = enemy.get("name", "")
	var engaged: bool = (not enemy.is_empty()) and bool(enemy["engaged"])
	var lab := {"intent": "attack", "target": enemy.get("id"), "risky": true, "stat": null, "dc": null, "skill": sid, "ending": null}
	match skill_name:
		"Power Strike":
			if enemy.is_empty() or weapon_type() != "melee":
				out["reason"] = "Needs an enemy and a melee weapon"
				return out
			lab["stat"] = "strength"
			out["text"] = "I use Power Strike on the %s." % en
		"Keen Eye":
			if enemy.is_empty() or weapon_type() != "ranged":
				out["reason"] = "Needs an enemy and a ranged weapon"
				return out
			lab["stat"] = "awareness"
			out["text"] = "I use Keen Eye and take careful aim at the %s." % en
		"Arcane Bolt":
			if enemy.is_empty():
				out["reason"] = "Needs an enemy"
				return out
			lab["stat"] = "intelligence"
			out["text"] = "I cast Arcane Bolt at the %s." % en
		"Lucky Break":
			if enemy.is_empty():
				out["reason"] = "Needs an enemy"
				return out
			lab["stat"] = stat_full[weapon_option(equipped["weapon"])["stat"]]
			out["text"] = "I use Lucky Break and strike the %s." % en
		"Second Wind":
			lab = {"intent": "skill", "target": null, "risky": false, "stat": null, "dc": null, "skill": sid, "ending": null}
			out["text"] = "I use Second Wind to catch my breath."
		"Evasive Step":
			if not engaged:
				out["reason"] = "Needs an enemy in combat"
				return out
			lab = {"intent": "skill", "target": null, "risky": false, "stat": null, "dc": null, "skill": sid, "ending": null}
			out["text"] = "I use Evasive Step to slip out of the %s's reach." % en
		"Silver Tongue":
			if npcs_present.is_empty():
				out["reason"] = "Needs someone to talk to"
				return out
			var nm: String = world["npcs"][npcs_present[0]]["name"]
			lab = {"intent": "social", "target": npcs_present[0], "risky": true, "stat": "charisma", "dc": 12, "skill": sid, "ending": null}
			out["text"] = "I use Silver Tongue on %s." % nm
		_:
			out["reason"] = "Unavailable"
			return out
	out["enabled"] = true
	out["label"] = lab
	return out


func fallback_label(action: String) -> Dictionary:
	## Dipakai bila server tidak memberi label yang sah: tebakan sederhana dari kata kunci.
	var low := action.to_lower()
	var lab := {"intent": "observe", "target": null, "risky": false, "stat": null, "dc": null, "skill": null, "ending": null}
	var attack_words := ["attack", "strike", "hit", "slash", "stab", "shoot", "swing", "smash", "fire", "fight", "bash"]
	for w in attack_words:
		if low.contains(w) and not enemy.is_empty():
			lab = {"intent": "attack", "target": enemy["id"], "risky": true, "stat": stat_full[weapon_option(equipped["weapon"])["stat"]], "dc": null, "skill": null, "ending": null}
			return lab
	for id in world["locations"]:
		var nm: String = str(world["locations"][id]["name"]).to_lower()
		if low.contains(nm) or low.contains(nm.split(" ")[0]):
			lab = {"intent": "travel", "target": id, "risky": not world["locations"][id]["safe"], "stat": "endurance" if not world["locations"][id]["safe"] else null,
					"dc": 12 if not world["locations"][id]["safe"] else null, "skill": null, "ending": null}
			return lab
	return lab


# ===================================================================== narasi cadangan (bila model tidak menjawab)
func fallback_narration(row: Dictionary) -> String:
	var r: Dictionary = row["results"]
	var tier: String = str(row["verdict"]["tier"]).replace("_", " ")
	var s := PackedStringArray()
	s.append("You act, and the result is a %s." % tier if tier != "no roll" else "You act.")
	if int(r["damage_dealt"]) > 0:
		s.append("Your blow lands for %d damage." % int(r["damage_dealt"]))
	if r["enemy_defeated"]:
		s.append("The enemy falls.")
	if r["enemy_counter"] != null:
		s.append("The enemy strikes back for %d." % int(r["enemy_counter"]["damage"]) if r["enemy_counter"]["hit"] else "The enemy's counterattack misses.")
	if int(r["healing"]) > 0:
		s.append("You recover %d health." % int(r["healing"]))
	if r["fled"]:
		s.append("You get away.")
	return " ".join(s)


func epilogue(kind: String) -> String:
	## Teks epilog sementara (Narrator tidak dilatih untuk epilog). Ganti sesuai naskah akhir.
	match kind:
		"keep":
			return "You keep the Unwritten Tome and take up the pen yourself. From now on, the tale is yours to write."
		"burn":
			return "You cast the Tome and the Inkwell of Dawn into the fire. The pages curl and the ink runs dry. No one will rewrite the world again."
		"entrust":
			return "You place both relics in Archmage Elara's hands. She seals them away, and the realm sleeps safely."
	return ""
