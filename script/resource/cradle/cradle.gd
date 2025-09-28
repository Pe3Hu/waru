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
	init_monte_carlo()
	
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
	
func init_monte_carlo() -> void:
	var count = 1000
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
		encounter.clash()
		
		if encounter.winner != null:
			winrate[encounter.winner.temper.desire] += 1
	
	#print(winrate)
	print(float(winrate[hunter_desire]) / count)
