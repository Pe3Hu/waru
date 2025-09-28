class_name DiceKitResource
extends Resource


var aspect_array: Array[String]

var aspect_dict: Dictionary
var value_probabilities: Dictionary
var chain_probabilities: Dictionary
var lock_options: Dictionary


func _init(aspects_: Array) -> void:
	aspect_array.append_array(aspects_)
	
	for aspect in aspects_: 
		if !aspect_dict.has(aspect):
			aspect_dict[aspect] = 0
		
		aspect_dict[aspect] += 1
	
	init_value_probabilities()
	#var roll_values = get_roll_values()
	#analyze_roll(roll_values)
	
func init_value_probabilities() -> void:
	value_probabilities = {}
	var values = []
	
	for aspect in aspect_dict: 
		value_probabilities[aspect] = {}
		
		var involute = load("res://script/resource/encounter/dice/dice_involute_" + aspect + ".tres")
		
		for value in involute.values:
			if !value_probabilities[aspect].has(value):
				value_probabilities[aspect][value] = 0
			
			value_probabilities[aspect][value] += 1.0 / involute.values.size()
			
			if !values.has(value):
				values.append(value)
	
	for aspect in aspect_dict:
		for value in values:
			if !value_probabilities[aspect].has(value):
				value_probabilities[aspect][value] = 0
	
func get_combinations(size_: int) -> Dictionary:
	var unique_combinations = {}
	var indexs = combine(aspect_array.size(), size_)
	
	for _indexs in indexs:
		var combination = {}
		
		for _i in _indexs:
			var aspect = aspect_array[_i - 1]
			
			if !combination.has(aspect):
				combination[aspect] = 0
			
			combination[aspect] += 1
		
		if !unique_combinations.has(combination):
			unique_combinations[combination] = 0
		
		unique_combinations[combination] += 1
	
	return unique_combinations
	
func combine(n_: int, k_: int) -> Array:
	var result = []
	backtrack(result, n_, k_, 1, [])
	return result
	
func backtrack(result_: Array,n_: int, k_: int, start_: int, indexs_: Array):
	if len(indexs_) == k_:
		result_.append(indexs_.duplicate())
		return
	
	for _i in range(start_, n_ + 1):
		indexs_.append(_i)
		backtrack(result_, n_, k_, _i + 1, indexs_)
		indexs_.pop_back()
	
func calc_chain_probability(combination_: Dictionary, value_: int) -> float:
	var success_probability = 1.0
	var failure_probability = 1.0
	var failure_combination = aspect_dict.duplicate()
	
	for aspect in combination_:
		failure_combination[aspect] -= combination_[aspect]
		
		for _i in combination_[aspect]:
			success_probability *= value_probabilities[aspect][value_]
	
	for aspect in failure_combination:
		for _i in failure_combination[aspect]:
			failure_probability *= 1 - value_probabilities[aspect][value_]
	
	return success_probability * failure_probability
	
func init_monte_carlo() -> Dictionary:
	var count = 100000
	
	var chains = {}
	
	for _i in count:
		var roll_values = {}
		
		for aspect in aspect_array:
			var value = Global.get_random_key(value_probabilities[aspect])
			
			if !roll_values.has(value):
				roll_values[value] = 0
			
			roll_values[value] += 1
		
		for value in roll_values:
			var chain_size = roll_values[value]
			
			if chain_size > 1:
				if !chains.has(chain_size):
					chains[chain_size] = {}
				
				if !chains[chain_size].has(value):
					chains[chain_size][value] = 0
				
				chains[chain_size][value] += 1.0 / count
	
	#var values = chains[size_].keys()
	#values.sort()
	#
	#for value in values:
		#print(["MC", value, chains[size_][value]])
	return chains
	
func get_roll_values() -> Dictionary:
	var roll_values = {}
	
	for aspect in aspect_array:
		var value = Global.get_random_key(value_probabilities[aspect])
		
		if !roll_values.has(value):
			roll_values[value] = 0
		
		roll_values[value] += 1
	
	return roll_values
	
func get_analyze_data() -> Array:
	var sizes = []
	
	for value in lock_options:
		var chain_size = lock_options[value]
		
		if !sizes.has(chain_size): #chain_size > 1 and 
			sizes.append(chain_size)
	
	sizes.sort()
	var datas = []
	
	for size in sizes:
		var combinations = get_combinations(size)
		#print(combinations)
		
		for value in lock_options.keys():
			if lock_options[value] == size:
				var chain_probability = 0
				
				for combination in combinations:
					var combination_chain_probability = calc_chain_probability(combination, value)
					chain_probability += combination_chain_probability * combinations[combination]
				
				var data = {}
				data.sum = value * size
				data.value = value
				data.size = size
				data.chain_probability = chain_probability
				datas.append(data)
	
	#datas.sort_custom(func(a, b): return a.probability < b.probability)
	#print(datas)
	return datas
	
func init_all_chain_probabilities(sizes_: Array, values_: Array) -> void:
	chain_probabilities = {}
	#var mc_chains = init_monte_carlo()
	
	for size in sizes_:
		chain_probabilities[size] = {}
		var combinations = get_combinations(size)
		#print(combinations)
		
		for value in values_:
			var chain_probability = 0
			
			for combination in combinations:
				var combination_chain_probability = calc_chain_probability(combination, value)
				chain_probability += combination_chain_probability * combinations[combination]
			
			chain_probabilities[size][value] = chain_probability
		
		#for value in values:
			#if chain_probabilities[size][value] > 0:
				#var a = chain_probabilities[size].has(value)
				#var b = mc_chains[size].has(value)
				#var error = (chain_probabilities[size][value] - mc_chains[size][value]) / chain_probabilities[size][value] * 100
				#
				#if abs(error) > 5:
					#print([size, value, error, chain_probabilities[size][value], mc_chains[size][value]])
	
