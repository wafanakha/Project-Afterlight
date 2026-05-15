extends Node2D
@onready var input_field = $root/rootMargin/rootVbox/TopHbox/Textmargin/TextHbox/InputPanel/InputMargin/InputVbox/Input
@onready var story_log = $root/rootMargin/rootVbox/TopHbox/Textmargin/TextHbox/StoryPanel/StoryMargin/Story
@onready var http_request = $HTTPRequest
@onready var health = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/HealthCont/health
@onready var Exp = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/ExpCont/Exp
@onready var Energy = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/ExpCont2/Exp
@onready var item_hflow_ui = $root/rootMargin/rootVbox/HboxBot/ItemPanel/MarginContainer/VBoxContainer/ItemHflow

const SERVER_URL = "http://127.0.0.1:8080/generate"


# Called when the node enters the scene tree for the first time.
var world_database = {
	"locations": {
		"sunflower_village": "A peaceful and brightly lit village, illuminated by giant glowing sunflowers. The residents are friendly and always ready to offer tea.",
		"giggle_thicket": "A lush forest with simple round leaves. The trees here often whisper corny jokes to anyone passing by.",
		"bouncy_caverns": "An underground cave where the floor is covered in super squishy pink mushrooms. It's very hard to walk without bouncing into the air."
	},
"bestiary": {
		"sir_beetle": {
			"desc": "A very serious rhinoceros beetle, wearing armor made from a used tin can. Fights with a stale baguette sword.",
			"type": "serious"
		},
		"grumpy_fluff": {
			"desc": "A heavily furred, round creature that is always grumbling. Rolls at high speed.",
			"type": "serious"
		},
		"sir_quackers": {
			"desc": "A mallard duck knight who takes his duty way too seriously. Armed with a sharp celery stalk and wearing a pot on his head.",
			"type": "serious"
		},
		"clumsy_mantis": {
			"desc": "A tall, awkward mantis that keeps tripping over its own scythes.",
			"type": "silly"
		},
		"opera_grub": {
			"desc": "A chubby grub that sings opera at the top of its lungs.",
			"type": "silly"
		},
		"jelly_cube_intern": {
			"desc": "A gelatinous cube wearing a tiny necktie. Constantly drops its paperwork and accidentally absorbs items it tries to pick up.",
			"type": "silly"
		}
	},
	"npcs": {
		"mayor_bloom": {
			"desc": "A giant, sentient sunflower wearing a tiny top hat. He is the mayor of Sunflower Village but often forgets where he put his leaves.",
			"personality": "Forgetful, jolly, and overly optimistic."
		},
		"chuckles_the_tree": {
			"desc": "An ancient oak tree in Giggle Thicket with a face carved into his bark. He won't let anyone pass until they hear his 'pun of the day'.",
			"personality": "Pun-obsessed, stubborn, and dad-joke expert."
		},
		"pogo_the_rabbit": {
			"desc": "A hyperactive rabbit in Bouncy Caverns wearing mechanical spring-boots. He speaks incredibly fast and loves jumping.",
			"personality": "Energetic, helpful, and constantly vibrating with excitement."
		},
		"madame_whiskers": {
			"desc": "A sophisticated aristocratic cat who runs a local tea shop. She wears a monocle and judges everyone's table manners.",
			"personality": "Snobby, elegant, but secretly loves being pet."
		},
		"barney_the_boulder": {
			"desc": "A literal large rock with googly eyes glued on. For some reason, everyone in town treats him like a wise therapist.",
			"personality": "Silent, stoic, and an excellent listener (because he is a rock)."
		},
		"greg_the_goblin": {
			"desc": "A former dungeon monster who reformed and now works as an over-enthusiastic insurance salesman.",
			"personality": "Pushy, corporate-minded, but very friendly."
		},
		"chef_sizzle": {
			"desc": "A small fire elemental who runs a bakery. He loves baking but constantly burns the pastries because his body is too hot.",
			"personality": "Passionate, easily frustrated, and dramatic."
		}
	},
	"equipment": {
		"weapons": {
			"squeaky_nail": "A toy sword that is somehow quite sharp. Every time it hits an enemy, it makes a loud rubber squeaky toy sound. (Boosts Strength)",
			"stale_baguette": "A loaf of bread so hard it can be used as a blunt weapon or eaten in an emergency for a tiny health boost. (Boosts Strength)"
		},
		"armor": {
			"cozy_moth_cloak": "A super soft cloak woven by kind-hearted moths. It makes the wearer feel extremely cozy and light on their feet. (Boosts Dexterity)",
			"heavy_tin_can_armor": "Upcycled armor made from soup cans. It provides great defense but makes you waddle loudly when you walk. (Boosts Endurance, lowers Dexterity)",
			"cardboard_shield": "A shield drawn with magic markers on a piece of cardboard. Surprisingly effective against pollen bombs."
		},
		"accessories": {
			"glasses_of_hindsight": "A pair of silly glasses with eyes painted on the back. It makes it impossible for enemies to sneak up on you. (Boosts Awareness)",
			"clown_nose": "A bright red squeaky nose. It makes every NPC take you less seriously but love you much more. (Boosts Charisma)",
			"lucky_clover_pin": "A somewhat crumpled four-leaf clover pinned to your shirt. It makes you feel like today is your lucky day. (Boosts Luck)"
		}
	},
	"items": {
		"sugar_rush_potion": "A ridiculously sweet fizzy drink that makes the player hyperactive. (Boosts Dexterity, but lowers Endurance temporarily)",
		"book_of_bad_puns": "Reading this deals psychic damage to serious enemies or makes silly enemies laugh uncontrollably. (Boosts Intelligence)",
		"golden_cupcake": "The ultimate sweet treat baked by the sun itself. Fully restores HP and Energy, leaving a taste of pure joy.",
		"pocket_confetti": "A handful of colorful paper. Throwing this in combat confuses enemies and makes the battle instantly festive. (Boosts Charisma)"
	},
	"plot_milestones": {
		"intro_nap": "The player just woke up from a 100-year nap and feels very hungry. Goal: Survive and find breakfast in Sunflower Village.",
		"hunt_snacks": "The player must collect Golden Cupcakes dropped by silly monsters to fill their stomach.",
		"find_invites": "The player is searching for 3 legendary missing Party Invites to host the biggest festival in the entire kingdom.",
		"final_choice": "The player is at the center of the festival with the Ultimate Giant Cake. Must choose: eat it all alone, or share it with all the monsters and become a Party Legend."
	}
}

# Current Game State Variables
var current_location_id = "bouncy_caverns"
var current_enemy_id = "clumsy_mantis" 
var current_enemy_type = "silly" 
var current_time = "Morning"
# Story Tracking Variables
var current_plot_id = "hunt_snacks" 
var cupcakes_collected = 1 
var invites_found = 0

# Character Stats & Leveling
var player_level: int = 1
var player_exp: int = 0
var exp_to_next_level: int = 100

# Full Character Attributes
var stat_strength: int = 5      # Raw physical power and melee damage
var stat_dexterity: int = 5     # Accuracy, speed, agility, and dodging
var stat_endurance: int = 5     # Physical defense, stamina, and health points
var stat_intelligence: int = 5  # Magic, puzzle-solving, and witty remarks
var stat_awareness: int = 5     # Perception, noticing hidden items, secrets, or traps
var stat_charisma: int = 5      # Persuasion, bartering, and making friends with NPCs
var stat_luck: int = 10         # Critical hit chances and rare loot drops

# Inventory & Equipment
var inventory_items: Array = []
var inventory_equipment: Array = []
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_accessory: String = ""


func _ready() -> void:
	health.max_value = 100
	health.value = 100
	
	# Asumsi Anda punya EnergyBar dan ExpBar di UI
	if has_node("stat/EnergyBar"):
		Energy.max_value = 100
		Energy.value = 100
		
	if has_node("stat/ExpBar"):
		Exp.max_value = exp_to_next_level
		Exp.value = player_exp

	input_field.text_submitted.connect(_on_input_submitted)
	http_request.request_completed.connect(_on_request_completed)
	
	story_log.text = "System Ready. You wake up from a 100-year nap, feeling incredibly hungry. What will you do?\n"


func _on_input_submitted(new_text: String):
	if new_text.strip_edges() == "":
		return
		
	story_log.text += "\n[color=yellow]> " + new_text + "[/color]\n"
	input_field.clear()
	input_field.editable = false
	input_field.placeholder_text = "The AI DM is rolling the dice..."
	
	var d20_roll = randi_range(1, 20) 
	story_log.text += "[color=gray][System: Rolled a raw D20: %d][/color]\n" % d20_roll
	$root/rootMargin/rootVbox/HboxBot/PanelContainer3/Dice2D.roll_dice(d20_roll)
	
	var player_stats = "STR: %d | DEX: %d | END: %d | INT: %d | AWR: %d | CHA: %d | LCK: %d" % [stat_strength, stat_dexterity, stat_endurance, stat_intelligence, stat_awareness, stat_charisma, stat_luck]
	var loc_desc = world_database["locations"].get(current_location_id, "Unknown.")
	
	var enemy_data = world_database["bestiary"].get(current_enemy_id, {})
	var enemy_desc = enemy_data.get("desc", "None")
	var enemy_type = enemy_data.get("type", "none")
	var current_objective = world_database["plot_milestones"].get(current_plot_id, "Have fun.")
	
	var seed_text = """[Story Context]
Main Objective: %s

[Environmental Context]
Location: %s
Enemy: %s (Type: %s)

[Player Context]
HP: %d | Level: %d
Stats: %s
Raw D20 Roll: %d

Player Action: "%s"

[System Directive]
You are the AI DM. 
1. Decide which Stat best fits the Player Action.
2. Determine a logical Difficulty Class (DC) between 5 and 20.
3. Calculate Total Score = Raw D20 Roll + Chosen Stat.
4. If Total Score >= DC, the action is a SUCCESS. Otherwise, FAILURE.
5. Write a comedic narrative based on this outcome, then output the JSON.""" % [current_objective, loc_desc, enemy_desc, enemy_type, health.value, player_level, player_stats, d20_roll, new_text]

	var payload = { "prompt": seed_text }
	var json_string = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, json_string)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		var json_data = JSON.parse_string(response_string)
		
		if json_data != null and json_data.has("response"):
			var raw_ai_text = json_data["response"]
			_process_hybrid_response(raw_ai_text)
		else:
			story_log.text += "\n[color=red]System: Invalid JSON format received from server.[/color]\n"
	else:
		story_log.text += "\n[color=red]System: Server Error Code %d[/color]\n" % response_code
		input_field.editable = true


func _process_hybrid_response(raw_text: String):
	var parts = raw_text.split("`CODE_BLOCK_START`")
	var narrative = parts[0].strip_edges()
	
	story_log.text += "\n" + narrative + "\n"
	
	if parts.size() > 1:
		var json_part = parts[1].split("`CODE_BLOCK_END`")[0].strip_edges()
		json_part = json_part.replace("```json", "").replace("```", "").strip_edges()
		
		var logic_data = JSON.parse_string(json_part)
		if logic_data != null:
			_execute_game_logic(logic_data)
		else:
			print("System Warning: AI failed to generate valid logic JSON.")
			print("Raw faulty JSON: ", json_part)
			
	input_field.editable = true
	input_field.placeholder_text = "What will you do next?"


func _execute_game_logic(data: Dictionary):
	print("--- MENGAPLIKASIKAN EFEK DARI AI ---")
	print(data)
	
	var hp_change = data.get("player_hp_change", 0)
	var energy_change = data.get("player_energy_change", 0) 
	
	if hp_change != 0:
		var health_bar = health
		health_bar.value += hp_change
		health_bar.value = clamp(health_bar.value, 0, health_bar.max_value)
		health_bar.get_node("Label").text = "HP: " + str(health_bar.value) + "/" + str(health_bar.max_value)
		
		if hp_change < 0:
			story_log.text += "\n[color=red]>>> Ouch! You lost " + str(abs(hp_change)) + " HP! <<<[/color]\n"
		else:
			story_log.text += "\n[color=green]>>> Yay! You recovered " + str(hp_change) + " HP! <<<[/color]\n"
			
	if energy_change != 0 and has_node("stat/EnergyBar"):
		var energy_bar = Energy
		energy_bar.value += energy_change
		energy_bar.value = clamp(energy_bar.value, 0, energy_bar.max_value)
		energy_bar.get_node("Label").text = "Energy: " + str(energy_bar.value) + "/" + str(energy_bar.max_value)

	var exp_gained = data.get("exp_gained", 0)
	if exp_gained > 0:
		_add_exp(exp_gained)

	# CHARACTER STATS 
	if data.has("player_stat_change"):
		var stat_changes = data["player_stat_change"]
		var stat_text = ""
		
		if stat_changes.get("strength", 0) != 0:
			stat_strength += stat_changes["strength"]
			stat_text += "STR %+d  " % stat_changes["strength"]
		if stat_changes.get("dexterity", 0) != 0:
			stat_dexterity += stat_changes["dexterity"]
			stat_text += "DEX %+d  " % stat_changes["dexterity"]
		if stat_changes.get("endurance", 0) != 0:
			stat_endurance += stat_changes["endurance"]
			stat_text += "END %+d  " % stat_changes["endurance"]
		if stat_changes.get("intelligence", 0) != 0:
			stat_intelligence += stat_changes["intelligence"]
			stat_text += "INT %+d  " % stat_changes["intelligence"]
		if stat_changes.get("awareness", 0) != 0:
			stat_awareness += stat_changes["awareness"]
			stat_text += "AWR %+d  " % stat_changes["awareness"]
		if stat_changes.get("charisma", 0) != 0:
			stat_charisma += stat_changes["charisma"]
			stat_text += "CHA %+d  " % stat_changes["charisma"]
		if stat_changes.get("luck", 0) != 0:
			stat_luck += stat_changes["luck"]
			stat_text += "LCK %+d  " % stat_changes["luck"]
		if stat_text != "":
			story_log.text += "[color=cyan]>>> Status Update: " + stat_text + "<<<[/color]\n"

	var target_hp_change = data.get("target_hp_change", 0)
	var target_status = data.get("target_status_effect", "none")
	
	if target_hp_change < 0:
		story_log.text += "[color=orange]>>> Enemy took " + str(abs(target_hp_change)) + " damage! <<<[/color]\n"
	if target_status != "none" and target_status != "" and target_status != null:
		story_log.text += "[color=orange]>>> Enemy is now: " + str(target_status) + " <<<[/color]\n"

	# INVENTORY & EQUIPMENT GIVEN
	if data.has("items_given"):
		var new_items = data["items_given"]
		
		# 1. Sesuaikan path ini dengan letak HFlowContainer Anda yang baru
		
		
		for item in new_items:
			inventory_items.append(item)
			if item_hflow_ui:
				var item_button = Button.new()
				item_button.text = str(item).replace("_", " ") 
				item_hflow_ui.add_child(item_button)
				
			story_log.text += "[color=aqua]>>> You got a consumable: " + str(item) + " <<<[/color]\n"

	if data.has("equipment_given"):
		var new_equips = data["equipment_given"]
		var equip_list_ui = $items/EquipList # Buat UI List baru jika perlu
		for equip in new_equips:
			inventory_equipment.append(equip)
			if equip_list_ui: equip_list_ui.add_item(equip)
			story_log.text += "[color=magenta]>>> You got NEW EQUIPMENT: " + str(equip) + " <<<[/color]\n"

	# GAME OVER CHECK
	if health.value <= 0:
		story_log.text += "\n[color=red][b]=== YOU FAINTED D. THE FESTIVAL IS CANCELLED ===[/b][/color]\n"
		input_field.editable = false 


func _add_exp(amount: int):
	player_exp += amount
	story_log.text += "[color=gold]>>> Gained " + str(amount) + " EXP! <<<[/color]\n"
	
	while player_exp >= exp_to_next_level:
		_level_up()
		
	if has_node("stat/ExpBar"):
		Exp.max_value = exp_to_next_level
		Exp.value = player_exp
		#Exp.get_node("Label").text = "Exp     " + str(player_exp) + "/" + str(exp_to_next_level)

func _level_up():
	player_level += 1
	player_exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * 1.5)
	
	health.value = health.max_value
	#health.get_node("Label").text = "Health" + str(health.value) + "/" + str(health.max_value)
	
	story_log.text += "\n[color=yellow][b]*** LEVEL UP! You are now Level " + str(player_level) + "! ***[/b][/color]\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
