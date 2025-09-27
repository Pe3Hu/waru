class_name DiceResource
extends Resource


@export var involute: DiceInvoluteResource
@export_enum("basic", "strength", "agility", "observation") var aspect:
	set(value_):
		aspect = value_
		involute = load("res://script/resource/encounter/dice/dice_involute_" + aspect + ".tres")

var current_index: int = -1

var flag_failure: bool


func _init(aspect_: String) -> void:
	aspect = aspect_
	
func roll() -> int:
	current_index = randi_range(0, involute.values.size() - 1)
	flag_failure = current_index <= 1
	return involute.values[current_index]
