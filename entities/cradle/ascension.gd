class_name AscensionResource
extends Resource


var cradle: CradleResource

var diameters: Dictionary
var acreages: Dictionary

var aspect_pairs: Array

var type: String

var l: float


func _init(cradle_: CradleResource,type_: String, l_: float) -> void:
	cradle = cradle_
	type = type_
	l = l_
	
	calc_vars()
	init_aspect_pairs()
	
func calc_vars() -> void:
	var k = 3
	diameters[k] = l / sin(PI / k) / 2
	acreages[k] = pow(diameters[k], 2) * PI
	
	for _i in range(k + 1, cradle.n + 1, 1):
		diameters[_i] = diameters[_i - 1] / cos(PI / _i)
		acreages[_i] = pow(diameters[_i], 2) * PI
	
	#print(a)
	#print(diameters)
	#print(acreages)
	
func init_aspect_pairs() -> void:
	var values = cradle.defect_values.keys()
	values.sort_custom(func (a, b): return a > b)
	
	var first_triplets = [
		[values[0], values[0], values[0]],
		[values[0], values[0], values[1]],
		[values[0], values[1], values[1]],
		[values[1], values[1], values[1]],
	]
	
	match type:
		"human":
			var max_gap = 0
			var last_values = values.filter(func (a): return values.find(a) > 1)
			var value_options = {}
			
			for first_triplet in first_triplets:
				var first_sum = int(acreages[3]) - first_triplet[0] - first_triplet[1] - first_triplet[2]
				
				#for first_value in first_triplet:
					#first_sum -= first_value
				
				for _i in last_values.size():
					for _j in range(_i, last_values.size(), 1):
						for _l in range(_j, last_values.size(), 1):
							var last_sum = first_sum - last_values[_i] - last_values[_j] - last_values[_l]
							
							if abs(last_sum) <= max_gap:
								var option = first_triplet.duplicate()
								option.append_array([last_values[_i], last_values[_j], last_values[_l]])
								var total_sum = int(acreages[3] + last_sum)
								
								if !value_options.has(total_sum):
									value_options[total_sum] = []
								
								value_options[total_sum].append(option)
			
			for total_sum in value_options:
				#print([total_sum, value_options[total_sum].size()])
				aspect_pairs.append_array(value_options[total_sum])
		"beast":
			var worst_option = []
			
			for _i in 6:
				worst_option.append(values[0])
			
			aspect_pairs.append(worst_option)
