class_name CradleResource
extends Resource


var lattice: LatticeResource

var beasts: Array[BeastResource]
var humans: Array[HumanResource]
var encounters: Array[EncounterResource]

var ascensions: Dictionary
var defect_values: Dictionary

var n: int = 5
var limit_axis: int = 8
var limit_multiplication: int = 25
var aspect_base_value: int = 10
var aspect_rnd_value: int = 12
var encounter_basic_dice_default: int = 4


func _init() -> void:
	init_ascensions()
	#init_single_monte_carlo()
	#save_all_aspect_combiantions()
	#save_all_kit_avg_sums()
	
	#get_all_aspect_combiantions()
	#get_all_kit_avg_sums()
	lattice = LatticeResource.new(self)
	
func init_ascensions() -> void:
	init_defect_values()
	add_ascension("human", 10)
	add_ascension("beast", 12)
	
func init_defect_values() -> void:
	for _i in range(2, limit_axis, 1):
		for _j in range(2, limit_axis, 1):
			var defect_value = _i * _j
			
			if defect_value <= limit_multiplication:
				var defect_size = Vector2i(_j, _i)
				
				if !defect_values.has(defect_value):
					defect_values[defect_value] = []
				
				defect_values[defect_value].append(defect_size)
	
func add_ascension(type_: String, a_: float) -> void:
	var ascension = AscensionResource.new(self, type_, a_)
	ascensions[type_] = ascension
	
func init_avatars() -> void:
	var subtype = "delta"
	var prey_flock = FlockResource.new()
	var hunter_flock = FlockResource.new()
	var prey_desire = "anger"
	var hunter_desire = "sloth"
	var prey = add_beast(prey_flock, subtype, prey_desire)
	var hunter = add_beast(hunter_flock, subtype, hunter_desire)
	var encounter = add_encounter(hunter, prey)
	encounter.clash()
	
func add_beast(flock_: FlockResource, subtype_: String, desire_: String) -> BeastResource:
	var beast = BeastResource.new(self, subtype_, desire_)
	beast.flock = flock_
	beasts.append(beast)
	flock_.beasts.append(beast)
	return beast
	
func add_encounter(hunter_: AvatarResource, prey_: AvatarResource) -> EncounterResource:
	var encounter = EncounterResource.new(hunter_, prey_)
	encounters.append(encounter)
	return encounter
	
func init_all_monte_carlo() -> void:
	var count = 1
	var desire_pairs = [
		["anger", "sloth"], ["anger", "envy"], ["anger", "pride"], ["anger", "greed"],
		["sloth", "envy"], ["sloth", "pride"], ["sloth", "greed"],
		["envy", "pride"], ["envy", "greed"],    
		["pride", "greed"],    
	]
	
	var dice_counts = [8]#, 4, 5, 6]
	Global.arr.subtype = ["delta"]
	desire_pairs = [["anger", "sloth"]]
	
	
	for dice_count in dice_counts:
		encounter_basic_dice_default = dice_count
		
		for subtype in Global.arr.subtype:
			for desire_pair in desire_pairs:
				var prey_flock = FlockResource.new()
				var hunter_flock = FlockResource.new()
				var prey_desire = desire_pair.front()
				var hunter_desire = desire_pair.back()
				var prey = add_beast(prey_flock, subtype, prey_desire)
				var hunter = add_beast(hunter_flock, subtype, hunter_desire)
				var encounter = add_encounter(hunter, prey)
				
				var winrate = {}
				winrate.avg_turn = 0.0
				winrate[prey_desire] = 0
				winrate[hunter_desire] = 0
				
				for _i in count:
					encounter.reset()
					encounter.clash()
					
					if encounter.winner != null:
						winrate[encounter.winner.temper.desire] += 1
					
					winrate.avg_turn += float(encounter.turn) / count
				
				#print(winrate)
				print([dice_count, subtype, winrate.avg_turn, hunter_desire, prey_desire, round(float(winrate[hunter_desire]) / count * 100)])
	
func init_single_monte_carlo() -> void:
	var count = 1
	var subtype = "delta"
	var prey_flock = FlockResource.new()
	var hunter_flock = FlockResource.new()
	var prey_desire = "greed"
	var hunter_desire = "sloth"
	var prey = add_beast(prey_flock, subtype, prey_desire)
	var hunter = add_beast(hunter_flock, subtype, hunter_desire)
	var encounter = add_encounter(hunter, prey)
	
	var winrate = {}
	winrate[prey_desire] = 0
	winrate[hunter_desire] = 0
	
	for _i in count:
		encounter.reset()
		encounter.init_clashs()
		
		if encounter.winner != null:
			winrate[encounter.winner.temper.desire] += 1
	
	#print(winrate)
	print([subtype, hunter_desire, prey_desire, float(winrate[hunter_desire]) / count])
	
func save_all_kit_avg_sums() -> Dictionary:
	var first_time = Time.get_unix_time_from_system()
	var datas = {}
	var all_aspect_combiantions_path = "res://assets/jsons/kit_all_aspects.json"
	var all_aspect_combiantions = Global.load_data(all_aspect_combiantions_path)
	
	for aspect_combiantion in all_aspect_combiantions:
		var dice_kit = DiceKitResource.new(aspect_combiantion)
		var avg_sum = dice_kit.get_avg_chain_sum()
		var str_aspect_combiantion = ""
		
		for aspect in aspect_combiantion:
			str_aspect_combiantion += aspect + "|"
		
		str_aspect_combiantion = str_aspect_combiantion.left(-1)
		datas[str_aspect_combiantion] = avg_sum
	
	var second_time = Time.get_unix_time_from_system()
	var a = snappedf((second_time - first_time), 0.01)
	print(["time save_all_kit_avg_sums" , a ])
	var path = "res://assets/jsons/kit_avg_sum.json"
	Global.save(path, datas)
	return datas
	
func save_all_aspect_combiantions() -> void:
	var first_time = Time.get_unix_time_from_system()
	var dices_in_kit = 7
	var index_counter = pow(Global.arr.involute.size(), dices_in_kit)
	
	var all_aspect_combiantions = []
	
	for _i in index_counter:
		var aspect_combiantion = []
		var temp_index = int(_i)
		
		for _j in dices_in_kit:
			var index = temp_index % Global.arr.involute.size()
			var aspect = Global.arr.involute[index]
			aspect_combiantion.append(aspect)
			temp_index = temp_index / Global.arr.involute.size()
		
		aspect_combiantion.sort_custom(func (a, b): return Global.arr.involute.find(a) < Global.arr.involute.find(b))
		
		if !all_aspect_combiantions.has(aspect_combiantion):
			all_aspect_combiantions.append(aspect_combiantion)
	
	var second_time = Time.get_unix_time_from_system()
	var c = snappedf((second_time - first_time), 0.01)
	print(["time save_all_aspect_combiantions" , c ])
	#print(all_aspect_combiantions.size(),all_aspect_combiantions)
	var path = "res://assets/jsons/kit_all_aspects.json"
	Global.save(path, all_aspect_combiantions)

func get_all_kit_avg_sums() -> void:
	var all_kit_avg_sums_path = "res://assets/jsons/kit_avg_sum.json"
	var all_kit_avg_sums = Global.load_data(all_kit_avg_sums_path)
	var all_aspect_combiantions_path = "res://assets/jsons/kit_all_aspects.json"
	var all_aspect_combiantions = Global.load_data(all_aspect_combiantions_path)
	
	for aspects in all_aspect_combiantions:
		print([aspects, all_kit_avg_sums[aspects]])
	
func get_all_aspect_combiantions() -> void:
	var all_aspect_combiantions_path = "res://assets/jsons/kit_all_aspects.json"
	var all_aspect_combiantions = Global.load_data(all_aspect_combiantions_path)
	
	for aspects in all_aspect_combiantions:
		print(aspects)
