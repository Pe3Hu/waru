class_name DicePoolResource
extends Resource


var avatar: AvatarResource
var encounter: EncounterResource

var total_dices: Array[DiceResource]
var locked_dices: Array[DiceResource]
var rolled_dices: Array[DiceResource]

var aspects: Dictionary

var locked_values: Dictionary
var rolled_values: Dictionary

var sum: int

var is_rerolling: bool


func _init(encounter_: EncounterResource, avatar_: AvatarResource) -> void:
	encounter = encounter_
	avatar = avatar_
	encounter.dice_pools[avatar] = self
	
	
func reset() -> void:
	sum = 0
	aspects = {}
	total_dices = []
	locked_dices = []
	rolled_dices = []
	
	for _i in encounter.cradle.encounter_basic_dice_default:
		add_dice("basic")
	
func add_dice(aspect_: String) -> void:
	var dice = DiceResource.new(aspect_)
	total_dices.append(dice)
	
	if !aspects.has(aspect_):
		aspects[aspect_] = 0
	
	aspects[aspect_] += 1
	pass
	
func update_rolled_dices() -> void:
	rolled_dices = total_dices.duplicate()
	
func roll_dices() -> void:
	is_rerolling = true
	
	for dice in rolled_dices:
		var value = dice.roll()
		
		if !rolled_values.has(value):
			rolled_values[value] = []
		
		rolled_values[value].append(dice)
	
func select_value_for_lock() -> void:
	pass
