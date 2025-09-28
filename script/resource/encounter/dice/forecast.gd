class_name ForecastResource
extends Resource


var dice_pool: DicePoolResource

var locked_value: int
var sum: int
var size: int

var chain_probability: float
var failure_probability: float


func _init(dice_pool_: DicePoolResource, data_: Dictionary) -> void:
	dice_pool = dice_pool_
	locked_value = data_.value
	sum = data_.sum
	size = data_.size
	chain_probability = data_.chain_probability
	
	calc_failure_probability()
	
func calc_failure_probability() -> void:
	var suitable_values = Global.arr.dice_value.duplicate()
	suitable_values = suitable_values.filter(func (a): return !dice_pool.locked_values.has(a) and a != locked_value)
	var success_probabilities = {}
	var not_locked_dices = {}
	
	for aspect in dice_pool.dice_kit.value_probabilities:
		not_locked_dices[aspect] = 0#[]
		success_probabilities[aspect] = 0
		
		for value in dice_pool.dice_kit.value_probabilities[aspect]: 
			if suitable_values.has(value):
				success_probabilities[aspect] += dice_pool.dice_kit.value_probabilities[aspect][value]
	
	for value in dice_pool.rolled_values:
		if value != locked_value:
			for dice in dice_pool.rolled_values[value]:
				not_locked_dices[dice.aspect] += 1#.append(dice)
	
	failure_probability = 1.0
	#print([locked_value, suitable_values, success_probabilities])
	
	for aspect in not_locked_dices:
		if not_locked_dices[aspect] > 0:
			var at_least_one_success_probability = pow(success_probabilities[aspect], not_locked_dices[aspect])
			#print([locked_value, aspect, success_probabilities[aspect], not_locked_dices[aspect], at_least_one_success_probability])
			failure_probability *= (1 - at_least_one_success_probability)
	
	
	#var locked_aspects = []
	#
	#for dice in dice_pool.rolled_values[locked_value]:
		#locked_aspects.append(dice.aspect)
	#print([locked_value, locked_aspects.size(), locked_aspects, ">", failure_probability, "<"])
