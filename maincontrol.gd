extends Node2D
@onready var menu_tabs = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer
@onready var input_field = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/Story/InputPanel/InputMargin/InputVbox/Input
@onready var story_log = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/Story/StoryPanel/StoryMargin/Story
@onready var http_request = $HTTPRequest
@onready var health = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/HealthCont/health
@onready var Exp = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/ExpCont/Exp
@onready var Energy = $root/rootMargin/rootVbox/HboxBot/StatusPanel/Statusmargin/statusVobx/ExpCont2/Exp
@onready var item_hflow_ui = $root/rootMargin/rootVbox/HboxBot/ItemPanel/MarginContainer/VBoxContainer/ItemHflow
@onready var armor = $root/rootMargin/rootVbox/TopHbox/MenuPanel/MarginContainer/VBoxContainer2/VBoxContainer/armor
@onready var weapon = $root/rootMargin/rootVbox/TopHbox/MenuPanel/MarginContainer/VBoxContainer2/VBoxContainer/weapon
@onready var accessorys = $root/rootMargin/rootVbox/TopHbox/MenuPanel/MarginContainer/VBoxContainer2/VBoxContainer/accessory

# ON CHARACTER

@onready var char_health_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/HealtLabelCont/HealthNumLabel
@onready var char_health_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/health
@onready var char_exp_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/ExpLabelCont/ExpNumLabel
@onready var char_exp_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/Exp
@onready var char_energy_num = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/EnergyLabelCont/EnergyNumLabel
@onready var char_energy_bar = $root/rootMargin/rootVbox/TopHbox/MarginContainer/TabContainer/character/MarginContainer/CharacterVbox/botHbox/statVbox/Energy

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



const SERVER_URL = "http://localhost:8080/generate"


# Called when the node enters the scene tree for the first time.
var world_database = {
	"locations": {
		"oakhaven_village": "A classic starter village where the local tavern is rebuilt weekly due to 'adventurer incidents'. The locals are friendly but heavily insured.",
		"muttering_woods": "An ancient magical forest. The trees don't whisper dark secrets; they just passively-aggressively judge your fashion choices as you walk by.",
		"mount_inconvenience": "A jagged peak filled with goblin camps. It's not particularly deadly, but the stairs are incredibly steep and there are no handrails."
	},
	"bestiary": {
		"unionized_goblin": {
			"desc": "A standard green goblin wearing a tiny hardhat. He fights fiercely but will absolutely stop mid-swing if it's his mandated 15-minute union break.",
			"type": "humanoid"
		},
		"insecure_mimic": {
			"desc": "A terrifying monster that takes the shape of treasure chests. This one, however, disguised itself as a very unconvincing, slightly wobbly bar stool.",
			"type": "monstrosity"
		},
		"overencumbered_skeleton": {
			"desc": "An undead warrior carrying way too much useless loot. It rattles loudly and moves slowly because it refuses to drop its collection of rusty spoons.",
			"type": "undead"
		},
		"orc_life_coach": {
			"desc": "A massive, hulking Orc who hits you with a club while shouting motivational quotes like, 'PAIN IS JUST WEAKNESS LEAVING THE BODY!'",
			"type": "humanoid"
		},
		"dramatic_slime": {
			"desc": "A basic low-level slime that reacts to every attack like an actor in a tragic soap opera.",
			"type": "ooze"
		}
	},
	"npcs": {
		"mayor_bartholomew": {
			"desc": "The village mayor who is clearly corrupt but terrible at hiding it. He wears a monocle that keeps falling into his soup.",
			"personality": "Nervous, overly polite, and constantly sweating."
		},
		"archmage_fizzlebang": {
			"desc": "An incredibly powerful wizard who has retired from saving the world and now uses his cosmic magic strictly to ensure his tea is the perfect temperature.",
			"personality": "Wise, easily distracted, and obsessed with baked goods."
		},
		"iron_thumb_olga": {
			"desc": "A muscular, intimidating dwarven blacksmith with a booming voice. Secretly, she hates forging swords and just wants to open a knitting shop.",
			"personality": "Gruff on the outside, surprisingly gentle and motherly on the inside."
		},
		"sir_lancelittle": {
			"desc": "A paladin in shining armor who is incredibly brave but suffers from a terrible sense of direction. He's been looking for the dragon's lair for three years.",
			"personality": "Heroic, loud, and confidently incorrect."
		}
	},
	"equipment": {
		"weapons": {
			"slightly_used_broadsword": "A standard iron sword with a 'Return to Olga' tag tied to the hilt. It's reliable, if a bit blunt. (Boosts Strength)",
			"staff_of_splinters": "A magical wooden staff that crackles with arcane energy. Requires thick gloves to hold properly. (Boosts Intelligence)",
			"tactical_frying_pan": "Heavy, cast-iron, and surprisingly aerodynamic. Perfect for cooking breakfast or causing concussions. (Boosts Strength)"
		},
		"armor": {
			"chafing_chainmail": "Provides excellent defense against goblin arrows, but terrible for your inner thighs. (Boosts Endurance, lowers Dexterity)",
			"vegan_leather_tunic": "Tough armor made entirely from enchanted avocados. Surprisingly durable, but smells faintly of guacamole. (Boosts Dexterity)",
			"hand_me_down_robes": "Mage robes that belong to someone taller than you. You have to pull them up when you run. (Boosts Intelligence)"
		},
		"accessories": {
			"ring_of_mild_convenience": "A glowing magic ring. It doesn't grant power, but it perfectly regulates your body temperature so you're never too hot or cold. (Boosts Endurance)",
			"amulet_of_pointless_advice": "A talking necklace that whispers things like 'Don't forget to chew your food' during intense combat. (Boosts Awareness)",
			"lucky_d20_pendant": "A twenty-sided die worn on a string. Sometimes it lands on 20, sometimes on 1. (Boosts Luck)"
		}
	},
	"items": {
		"questionable_red_potion": "A standard healing potion. It restores your HP but tastes exactly like cherry cough syrup. (Restores HP)",
		"caffeinated_blue_elixir": "A mana potion packed with so much caffeine it makes your teeth vibrate. (Restores Energy, boosts Dexterity temporarily)",
		"tactical_pocket_sand": "A handful of coarse sand. Throw it in the enemy's eyes for a quick getaway! (Boosts Dexterity)",
		"scroll_of_fireball": "A highly destructive magic scroll. The warning label says 'Do not read indoors'. (Deals heavy damage)"
	},
	"plot_milestones": {
		"intro_tavern": "You are sitting in the Oakhaven Tavern, minding your own business, when a goblin crashes through the window. Typical Tuesday.",
		"find_the_macguffin": "The Mayor has hired you for 10 gold pieces to find a glowing orb. He doesn't know what it does, but it looks expensive.",
		"dungeon_delve": "You must navigate the traps of Mount Inconvenience to confront the Bandit King.",
		"final_boss": "You face the source of all evil in the region, only to discover it's just a misunderstood necromancer who wanted friends."
	}
}

# Current Game State Variables
var current_location_id = "oakhaven_village"
var current_enemy_id = "unionized_goblin" 
var current_enemy_type = "humanoid" 
var current_time = "Morning"

# Story Tracking Variables
var current_plot_id = "intro_tavern"

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
var stat_luck: int = 9         # Critical hit chances and rare loot drops

# Inventory & Equipment
var inventory_items: Array = []
var inventory_equipment: Array = []
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_accessory: String = ""


func _ready() -> void:
	health.max_value = 100
	health.value = 100
	
	Energy.max_value = 100
	Energy.value = 50
		
	Exp.max_value = exp_to_next_level
	Exp.value = player_exp
	
	update_equipment_inventory_ui()
	
	
	# SET UP UI 
		
	char_health_bar.value = health.value
	char_exp_bar.value = Exp.value
	char_energy_bar.value = Energy.value
	
	char_health_num.text = "%s/%s" % [health.value, health.max_value]
	char_energy_num.text = "%s/%s" % [Energy.value, Energy.max_value]
	char_exp_num.text = "%s/%s" % [Exp.value, Exp.max_value]
	
	weapon.text = equipped_weapon
	armor.text = equipped_armor
	accessorys.text = equipped_accessory
	char_armor_name.text = equipped_armor
	char_weapon_name.text = equipped_weapon
	char_accessory_name.text = equipped_accessory
	
	show_Strength.text = str(stat_strength) 
	show_Dexterity.text = str(stat_dexterity)
	show_Endurance.text = str(stat_endurance)
	show_Intelligence.text = str(stat_intelligence)
	show_Awareness.text = str(stat_awareness)
	show_Charisma.text = str(stat_charisma)
	show_Luck.text = str(stat_luck)

	input_field.text_submitted.connect(_on_input_submitted)
	http_request.request_completed.connect(_on_request_completed)
	
	story_log.text = "[color=gray]System: Waking up Dungeon Master...\n[/color]"
	input_field.editable = false
	input_field.placeholder_text = "DM is Preparing the Story..."
	
	_request_intro_story()


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
You are the AI DM for a lighthearted, comedic D&D-style RPG. Evaluate the Player Action strictly:
1. Choose the MOST LOGICAL Stat for the action (e.g., CHA for talking, END for eating, STR for hitting, DEX for dodging).
2. Set a DC (Difficulty Class) between 5 and 20.
3. Calculate Total Score = Raw D20 Roll + Chosen Stat.
4. CRITICAL MATH RULE: You MUST evaluate the numbers! IF Total Score is GREATER THAN OR EQUAL to DC, "is_success" MUST be true. IF Total Score is LESS THAN DC, "is_success" MUST be false. Do not break this rule!
5. Write a short, funny 2nd-person narrative based on the outcome.

[JSON Strict Rules]
- "total_score" MUST be a single integer (e.g., 15), NEVER an equation.
- "target_hp_change" MUST be 0 unless the player specifically attacks the enemy.
- "player_stat_change" should only be 1 or -1 for a single stat, the rest must be 0.
- Include "new_plot_id" if the story should progress (choose from: "intro_tavern", "find_the_macguffin", "dungeon_delve", "final_boss"). If the scene isn't over yet, keep the current one.
- Include "new_location_id" if the player moves to a new area (choose from: "oakhaven_village", "muttering_woods", "mount_inconvenience").
- Include "enemy_defeated": true ONLY if the enemy's HP reaches 0 or they run away. Otherwise false.
""" % [current_objective, loc_desc, enemy_desc, enemy_type, health.value, player_level, player_stats, d20_roll, new_text]

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
	var clean_text = raw_text.replace("`", "")
	
	var parts = clean_text.split("CODE_BLOCK_START")
	var narrative = parts[0].strip_edges()
	
	story_log.text += "\n" + narrative + "\n"
	
	if parts.size() > 1:
		var json_part = parts[1].split("CODE_BLOCK_END")[0].strip_edges()
		
		if json_part.begins_with("json"):
			json_part = json_part.substr(4).strip_edges()
		
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
		char_health_bar.value = health_bar.value
		char_health_num.text = str(health_bar.value) + "/" + str(health_bar.max_value)
		
		if hp_change < 0:
			story_log.text += "\n[color=red]>>> Ouch! You lost " + str(abs(hp_change)) + " HP! <<<[/color]\n"
		else:
			story_log.text += "\n[color=green]>>> Yay! You recovered " + str(hp_change) + " HP! <<<[/color]\n"
			
	if energy_change != 0 :
		var energy_bar = Energy
		energy_bar.value += energy_change
		energy_bar.value = clamp(energy_bar.value, 0, energy_bar.max_value)
		char_energy_bar.value = energy_bar.value
		char_energy_num.text = str(energy_bar.value) + "/" + str(energy_bar.max_value)
	
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
			
		show_Strength.text = str(stat_strength)
		show_Dexterity.text = str(stat_dexterity)
		show_Endurance.text = str(stat_endurance)
		show_Intelligence.text = str(stat_intelligence)
		show_Awareness.text = str(stat_awareness)
		show_Charisma.text = str(stat_charisma)
		show_Luck.text = str(stat_luck)


	var target_hp_change = data.get("target_hp_change", 0)
	var target_status = data.get("target_status_effect", "none")
	
	if target_hp_change < 0:
		story_log.text += "[color=orange]>>> Enemy took " + str(abs(target_hp_change)) + " damage! <<<[/color]\n"
	if target_status != "none" and target_status != "" and target_status != null:
		story_log.text += "[color=orange]>>> Enemy is now: " + str(target_status) + " <<<[/color]\n"

	if data.has("items_given"):
		var new_items = data["items_given"]
		for item in new_items:
			var safe_id = str(item).to_lower().replace(" ", "_").replace("'", "")
			
			if not world_database["items"].has(safe_id):
				world_database["items"][safe_id] = "Benda aneh pemberian DM. Kelihatannya tidak berguna."
				
			inventory_items.append(safe_id)
			story_log.text += "[color=aqua]>>> You got a consumable: " + str(item).capitalize() + " <<<[/color]\n"
			
		update_items_inventory_ui()

	if data.has("equipment_given"):
		var new_equips = data["equipment_given"]
		for equip in new_equips:
			var safe_id = str(equip).to_lower().replace(" ", "_").replace("'", "")
			
			var is_known = world_database["equipment"]["weapons"].has(safe_id) or world_database["equipment"]["armor"].has(safe_id) or world_database["equipment"]["accessories"].has(safe_id)
			
			if not is_known:
				world_database["equipment"]["accessories"][safe_id] = "Sebuah perlengkapan konyol yang dipaksa masuk oleh DM ke tasmu."
				
			inventory_equipment.append(safe_id)
			story_log.text += "[color=magenta]>>> You got NEW EQUIPMENT: " + str(equip).capitalize() + " <<<[/color]\n"
			
		update_equipment_inventory_ui()
		
	# --- SISTEM PROGRESI CERITA ---
	if data.get("enemy_defeated", false) == true:
		story_log.text += "\n[color=yellow][b]>>> The " + str(current_enemy_id).replace("_", " ").capitalize() + " is defeated or gone! <<<[/b][/color]\n"
		current_enemy_id = "" # Kosongkan musuh
	
	# 2. Cek apakah AI memindahkan plot cerita
	if data.has("new_plot_id"):
		var next_plot = data["new_plot_id"]
		if next_plot != current_plot_id and world_database["plot_milestones"].has(next_plot):
			current_plot_id = next_plot
			story_log.text += "\n[color=cyan][b]>>> STORY ADVANCED: " + str(current_plot_id).replace("_", " ").capitalize() + " <<<[/b][/color]\n"
	
	# 3. Cek apakah AI memindahkan lokasi pemain
	if data.has("new_location_id"):
		var next_loc = data["new_location_id"]
		if next_loc != current_location_id and world_database["locations"].has(next_loc):
			current_location_id = next_loc
			story_log.text += "\n[color=cyan][b]>>> MOVED TO: " + str(current_location_id).replace("_", " ").capitalize() + " <<<[/b][/color]\n"
		
	# GAME OVER CHECK
	if health.value <= 0:
		story_log.text += "\n[color=red][b]=== YOU FAINTED D. THE FESTIVAL IS CANCELLED ===[/b][/color]\n"
		input_field.editable = false 


func _add_exp(amount: int):
	player_exp += amount
	story_log.text += "[color=gold]>>> Gained " + str(amount) + " EXP! <<<[/color]\n"
	print_debug(player_exp)
	Exp.value = player_exp
	char_exp_bar.value = player_exp
	char_exp_num.text = str(player_exp) + "/" + str(exp_to_next_level)
	while player_exp >= exp_to_next_level:
		_level_up()
		


func _level_up():
	player_level += 1
	player_exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * 1.5)
	
	health.value = health.max_value
	Exp.value = player_exp
	char_exp_bar.value = player_exp
	char_exp_num.text = str(player_exp) + "/" + str(exp_to_next_level)

		
	story_log.text += "\n[color=yellow][b]*** LEVEL UP! You are now Level " + str(player_level) + "! ***[/b][/color]\n"
func update_equipment_inventory_ui():
	if not equipment_list:
		return
		
	# 1. Bersihkan daftar lama
	for child in equipment_list.get_children():
		child.queue_free()
		
	var custom_font = load("res://assets/font/Merriweather-VariableFont_opsz,wdth,wght.ttf") 


	# --- FITUR BARU: TOMBOL UNEQUIP KHUSUS ---
	# Memunculkan tombol untuk melepas barang di bagian atas daftar
	var has_equipped_something = false
	var equipped_slots = [
		{"type": "weapon", "id": equipped_weapon},
		{"type": "armor", "id": equipped_armor},
		{"type": "accessory", "id": equipped_accessory}
	]
	
	for slot in equipped_slots:
		if slot["id"] != "":
			has_equipped_something = true
			var row_hbox = HBoxContainer.new()
			row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var item_label = Label.new()
			item_label.text = "[Wearing] " + str(slot["id"]).replace("_", " ").capitalize()
			item_label.add_theme_color_override("font_color", Color("#9C4543")) # Warna merah pudar
			if custom_font != null: item_label.add_theme_font_override("font", custom_font)
			item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
			
			var unequip_btn = Button.new()
			unequip_btn.text = "Unequip"
			if custom_font != null: unequip_btn.add_theme_font_override("font", custom_font)
			
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color("#9C4543") # Tombol merah
			btn_style.content_margin_left = 10
			btn_style.content_margin_right = 10
			unequip_btn.add_theme_stylebox_override("normal", btn_style)
			unequip_btn.add_theme_color_override("font_color", Color("#F2EBE1"))
			
			# Sambungkan ke fungsi lepas barang
			unequip_btn.pressed.connect(func(): _unequip_slot(slot["type"]))
			
			row_hbox.add_child(item_label)
			row_hbox.add_child(unequip_btn)
			equipment_list.add_child(row_hbox)

	# Tambahkan garis pembatas jika ada tombol unequip di atas
	if has_equipped_something:
		var separator = HSeparator.new()
		equipment_list.add_child(separator)
	# -----------------------------------------

	# 2. Cek apakah tas perlengkapan kosong
	if inventory_equipment.size() == 0:
		var empty_label = Label.new()
		empty_label.text = "- Bag is empty -"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color("#B0A89D")) 
		equipment_list.add_child(empty_label)
		return

	# 3. Masukkan item dari tas (Sama seperti sebelumnya)
	for equip_id in inventory_equipment:
		var row_hbox = HBoxContainer.new()
		row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		
		var item_label = Label.new()
		var clean_name = str(equip_id).replace("_", " ").capitalize()
		item_label.text = clean_name
		item_label.add_theme_color_override("font_color", Color("#4A443F"))
		if custom_font != null:
			item_label.add_theme_font_override("font", custom_font)
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		
		var equip_button = Button.new()
		equip_button.text = "Equip"
		if custom_font != null:
			equip_button.add_theme_font_override("font", custom_font)
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#4A443F") 
		btn_style.content_margin_left = 10
		btn_style.content_margin_right = 10
		equip_button.add_theme_stylebox_override("normal", btn_style)
		equip_button.add_theme_color_override("font_color", Color("#F2EBE1")) 
		
		equip_button.pressed.connect(func(): _on_equipment_item_selected(equip_id))
		
		row_hbox.add_child(item_label)
		row_hbox.add_child(equip_button)
		
		equipment_list.add_child(row_hbox)

func _on_equipment_item_selected(equip_id: String):
	var equipment_db = world_database["equipment"]
	var equip_type = ""
	var equip_desc = ""

	if equipment_db["weapons"].has(equip_id):
		equip_type = "weapon"
		equip_desc = equipment_db["weapons"][equip_id]
	elif equipment_db["armor"].has(equip_id):
		equip_type = "armor"
		equip_desc = equipment_db["armor"][equip_id]
	elif equipment_db["accessories"].has(equip_id):
		equip_type = "accessory"
		equip_desc = equipment_db["accessories"][equip_id]

	#if equip_type == "":
		#print("Sistem Error: Item ", equip_id, " tidak ditemukan di world_database!")
		#return

	var old_equip = ""
	
	if equip_type == "weapon":
		old_equip = equipped_weapon
		equipped_weapon = equip_id
	elif equip_type == "armor":
		old_equip = equipped_armor
		equipped_armor = equip_id
	elif equip_type == "accessory":
		old_equip = equipped_accessory
		equipped_accessory = equip_id

	inventory_equipment.erase(equip_id)
	
	if old_equip != "" and old_equip != "None":
		inventory_equipment.append(old_equip)

	var clean_name = equip_id.replace("_", " ").capitalize()

	if equip_type == "weapon":
		weapon.text = clean_name
		char_weapon_name.text = clean_name
		char_weapon_desc.text = equip_desc
	elif equip_type == "armor":
		armor.text = clean_name
		char_armor_name.text = clean_name
		char_armor_desc.text = equip_desc
	elif equip_type == "accessory":
		accessorys.text = clean_name
		char_accessory_name.text = clean_name
		char_accessory_desc.text = equip_desc

	story_log.text += "\n[color=yellow]>>> You equipped: " + clean_name + " <<<[/color]\n"
	
	update_equipment_inventory_ui()
	
func update_items_inventory_ui():
	if not item_hflow_ui:
		return
		
	for child in item_hflow_ui.get_children():
		child.queue_free()
		
	var custom_font = load("res://assets/font/Merriweather-VariableFont_opsz,wdth,wght.ttf")
		
	for item_id in inventory_items:
		var item_button = Button.new()
		
		item_button.text = str(item_id).replace("_", " ").capitalize()
		
		if custom_font != null:
			item_button.add_theme_font_override("font", custom_font)
			
		item_button.add_theme_color_override("font_color", Color("#4A443F"))
		item_button.add_theme_color_override("font_hover_color", Color("#9C4543"))
		item_button.add_theme_color_override("font_pressed_color", Color("#9C4543"))
		
		item_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		item_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		item_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		item_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		item_button.pressed.connect(func(): _on_inventory_item_selected(item_id))
		
		item_hflow_ui.add_child(item_button)
func _on_inventory_item_selected(item_id: String):
	# Hapus item dari tas
	inventory_items.erase(item_id)
	
	var clean_name = item_id.replace("_", " ").capitalize()
	story_log.text += "\n[color=yellow]>>> You used: " + clean_name + " <<<[/color]\n"
	
	if item_id == "golden_cupcake":
		health.value = health.max_value
		Energy.value = Energy.max_value
		story_log.text += "[color=green]>>> HP and Energy fully restored! You feel pure joy. <<<[/color]\n"
	elif item_id == "sugar_rush_potion":
		stat_dexterity += 2
		stat_endurance -= 1
		story_log.text += "[color=green]>>> You feel incredibly fast! (DEX +2, END -1) <<<[/color]\n"
	elif item_id == "book_of_bad_puns":
		stat_intelligence += 2
		story_log.text += "[color=green]>>> You learned a terrible joke! (INT +2) <<<[/color]\n"
	elif item_id == "pocket_confetti":
		stat_charisma += 1
		story_log.text += "[color=green]>>> It's a party! (CHA +1) <<<[/color]\n"
	else:
		story_log.text += "[color=gray]>>> You stare at it. It does absolutely nothing, but you feel slightly more absurd. <<<[/color]\n"
		
	char_health_bar.value = health.value
	char_health_num.text = "%s/%s" % [health.value, health.max_value]
	char_energy_bar.value = Energy.value
	char_energy_num.text = "%s/%s" % [Energy.value, Energy.max_value]
	
	update_items_inventory_ui()

func _unequip_slot(slot_type: String):
	var item_to_remove = ""
	
	# 1. Tentukan apa yang mau dilepas, lalu kosongkan slotnya
	if slot_type == "weapon" and equipped_weapon != "":
		item_to_remove = equipped_weapon
		equipped_weapon = ""
		weapon.text = "-"
		char_weapon_name.text = "Bare Hands"
		char_weapon_desc.text = ""
	elif slot_type == "armor" and equipped_armor != "":
		item_to_remove = equipped_armor
		equipped_armor = ""
		armor.text = "-"
		char_armor_name.text = "No Armor"
		char_armor_desc.text = ""
	elif slot_type == "accessory" and equipped_accessory != "":
		item_to_remove = equipped_accessory
		equipped_accessory = ""
		accessorys.text = "-"
		char_accessory_name.text = "No Accessory"
		char_accessory_desc.text = ""
		
	# 2. Jika ada barang yang dilepas, masukkan ke tas dan perbarui UI
	if item_to_remove != "":
		inventory_equipment.append(item_to_remove)
		var clean_name = item_to_remove.replace("_", " ").capitalize()
		story_log.text += "\n[color=orange]>>> You took off: " + clean_name + " <<<[/color]\n"
		
		# Gambar ulang daftarnya
		update_equipment_inventory_ui()
		
func _request_intro_story():
	var loc_desc = world_database["locations"].get(current_location_id, "Unknown.")
	var current_objective = world_database["plot_milestones"].get(current_plot_id, "Have fun.")
	
	# Instruksi khusus agar AI membuat cerita pembuka yang ceria
	var intro_prompt = """[System Directive]
You are the AI DM for a lighthearted, comedic D&D-style RPG.
The game is just starting. Introduce the player to the world!

[Context]
Location: %s
Current Situation: %s

[Task]
Write a funny, engaging opening paragraph (2nd-person perspective) welcoming the player to the world, setting the scene, and explaining their bizarre current situation. End by asking them what they want to do.

After the narrative, output a default JSON block wrapped in `CODE_BLOCK_START` and `CODE_BLOCK_END` with 0 changes, like this:
`CODE_BLOCK_START`
{
  "player_hp_change": 0,
  "player_energy_change": 0,
  "exp_gained": 0,
  "target_hp_change": 0,
  "items_given": [],
  "equipment_given": []
}
`CODE_BLOCK_END`""" % [loc_desc, current_objective]

	var payload = { "prompt": intro_prompt }
	var json_string = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	
	# Kirim ke server C++
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, json_string)

func _process(delta: float) -> void:
	
	pass


func _on_button_story_pressed() -> void:
	menu_tabs.current_tab = 1


func _on_button_character_pressed() -> void:
	menu_tabs.current_tab = 2


func _on_button_settings_pressed() -> void:
	menu_tabs.current_tab = 0
