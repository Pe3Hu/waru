extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}


func _ready() -> void:
	if dict.keys().is_empty():
		init_arr()
		init_color()
		init_dict()
	
	#get_tree().bourse.resource.after_init()
	
func init_arr() -> void:
	arr.aspect = ["strength", "agility", "observation", "endurance"]
	arr.battle_aspect = ["strength", "agility", "observation"]
	arr.aspect_pair = [
		["strength", "agility"],
		["agility", "observation"],
		["observation", "strength"],
		["agility", "strength"],
		["observation", "agility"],
		["strength", "observation"],
	]
	arr.windrose = ["NE", "E", "SE", "S", "SW", "W", "NW", "N"]
	
func init_dict() -> void:
	init_direction()
	init_windrose()
	init_ring()
	
	init_biome()
	init_lair()
	
func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear2 = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2i( 1,-1),
		Vector2i( 1, 1),
		Vector2i(-1, 1),
		Vector2i(-1,-1)
	]
	
	dict.direction.hybrid = []
	
	for _i in dict.direction.linear2.size():
		var direction = dict.direction.linear2[_i]
		dict.direction.hybrid.append(direction)
		direction = dict.direction.diagonal[_i]
		dict.direction.hybrid.append(direction)
	
func init_ring() -> void:
	dict.ring = {}
	dict.ring.size = {}
	dict.ring.size[3] = [1, 1, 1]
	dict.ring.size[4] = [1, 1, 2]
	dict.ring.size[5] = [1, 2, 2]
	dict.ring.size[6] = [1, 2, 3]
	dict.ring.size[7] = [1, 2, 4]
	dict.ring.size[8] = [1, 3, 4]
	dict.ring.size[9] = [1, 3, 5]
	dict.ring.size[10] = [1, 3, 6]
	dict.ring.size[11] = [1, 3, 7]
	dict.ring.size[12] = [1, 4, 7]
	dict.ring.size[13] = [1, 4, 8]
	dict.ring.size[14] = [1, 4, 9]
	dict.ring.size[15] = [1, 5, 9]
	
	dict.ring.windrose = {}
	var shares = {}
	shares["triangle"] = 1
	shares["rectangle"] = 2
	
	for _i in range(1, 3, 1):
		dict.ring.windrose[_i] = {}
		var total_percent = 0
		
		for windrose in dict.windrose.part:
			for part in dict.windrose.part[windrose]:
				var l = 1
				var shape = dict.part.shape[part]
				
				if shape == "rectangle" and _i == 2:
					l = 3
				
				for _j in l:
					var part_name = part + str(_j)
					total_percent += shares[shape]
					dict.ring.windrose[_i][part_name] = shares[shape]
		
		for _j in dict.ring.windrose[_i]:
			dict.ring.windrose[_i][_j] = float(dict.ring.windrose[_i][_j]) / total_percent
	
	#var a = dict.ring.windrose[1]
	pass
	#var total_percent = 12
	#dict.ring.windrose = {}
	#dict.ring.windrose[1] = {}
	#dict.ring.windrose[1]["NE"] = [1, 1]
	#dict.ring.windrose[1]["E"] = [2]
	#dict.ring.windrose[1]["SE"] = [1, 1]
	#dict.ring.windrose[1]["S"] = [2]
	#dict.ring.windrose[1]["SW"] = [1, 1]
	#dict.ring.windrose[1]["W"] = [2]
	#dict.ring.windrose[1]["NW"] = [1, 1]
	#dict.ring.windrose[1]["N"] = [2]
	#
	#for windrose in dict.ring.windrose[1]:
		#for _i in dict.ring.windrose[1][windrose].size():
			#dict.ring.windrose[1][windrose][_i] = float(dict.ring.windrose[1][windrose][_i]) / total_percent
	#
	#total_percent = 20
	#dict.ring.windrose = {}
	#dict.ring.windrose[2] = {}
	#dict.ring.windrose[2]["NE"] = [1, 1]
	#dict.ring.windrose[2]["E"] = [2, 2, 2]
	#dict.ring.windrose[2]["SE"] = [1, 1]
	#dict.ring.windrose[2]["S"] = [2, 2, 2]
	#dict.ring.windrose[2]["SW"] = [1, 1]
	#dict.ring.windrose[2]["W"] = [2, 2, 2]
	#dict.ring.windrose[2]["NW"] = [1, 1]
	#dict.ring.windrose[2]["N"] = [2, 2, 2]
	#
	#for windrose in dict.ring.windrose[2]:
		#for _i in dict.ring.windrose[2][windrose].size():
			#dict.ring.windrose[2][windrose][_i] = float(dict.ring.windrose[2][windrose][_i]) / total_percent
	
func init_windrose() -> void:
	dict.windrose = {}
	dict.windrose.part = {}
	dict.windrose.part["NE"] = ["NNE", "ENE"]
	dict.windrose.part["E"] = ["E"]
	dict.windrose.part["SE"] = ["ESE", "SSE"]
	dict.windrose.part["S"] = ["S"]
	dict.windrose.part["SW"] = ["SSW", "WSW"]
	dict.windrose.part["W"] = ["W"]
	dict.windrose.part["NW"] = ["WNW", "NNW"]
	dict.windrose.part["N"] = ["N"]
	#dict.windrose.part = ["NNE", "ENE", "ESE", "SSE", "SSW", "WSW", "WNW", "NNW"]
	
	dict.part = {}
	#dict.part.windrose = {}
	#dict.part.windrose["NNE"] = "NE"
	#dict.part.windrose["ENE"] = "NE"
	#dict.part.windrose["E"] = "E"
	#dict.part.windrose["ESE"] = "SE"
	#dict.part.windrose["SSE"] = "SE"
	#dict.part.windrose["S"] = "S"
	#dict.part.windrose["SSW"] = "SW"
	#dict.part.windrose["WSW"] = "SW"
	#dict.part.windrose["W"] = "W"
	#dict.part.windrose["WNW"] = "NW"
	#dict.part.windrose["NNW"] = "NW"
	#dict.part.windrose["N"] = "N"
	
	dict.part.shape = {}
	dict.part.shape["ESWN"] = "square"
	dict.part.shape["NNE"] = "triangle"
	dict.part.shape["ENE"] = "triangle"
	dict.part.shape["E"] = "rectangle"
	dict.part.shape["ESE"] = "triangle"
	dict.part.shape["SSE"] = "triangle"
	dict.part.shape["S"] = "rectangle"
	dict.part.shape["SSW"] = "triangle"
	dict.part.shape["WSW"] = "triangle"
	dict.part.shape["W"] = "rectangle"
	dict.part.shape["WNW"] = "triangle"
	dict.part.shape["NNW"] = "triangle"
	dict.part.shape["N"] = "rectangle"
	
	dict.part.direction = {}
	dict.part.direction["NNE"] = Vector2i(1, 0)
	dict.part.direction["ENE"] = Vector2i(0, 1)
	dict.part.direction["E"] = Vector2i(0, 1)
	dict.part.direction["ESE"] = Vector2i(0, 1)
	dict.part.direction["SSE"] = Vector2i(-1, 0)
	dict.part.direction["S"] = Vector2i(-1, 0)
	dict.part.direction["SSW"] = Vector2i(-1, 0)
	dict.part.direction["WSW"] = Vector2i(0, -1)
	dict.part.direction["W"] = Vector2i(0, -1)
	dict.part.direction["WNW"] = Vector2i(0, -1)
	dict.part.direction["NNW"] = Vector2i(1, 0)
	dict.part.direction["N"] = Vector2i(1, 0)
	
	dict.part.near = {}
	dict.part.far = {}
	var orders = [1, 2]
	
	for order in orders:
		dict.part.near[order] = {}
		dict.part.far[order] = {}
		
		for part in dict.part.shape:
			match dict.part.shape[part]:
				"triangle":
					match part:
						"NNE":
							dict.part.near[order][part] = Global.dict.direction.diagonal[0] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[0])
						"ENE":
							dict.part.near[order][part] = Global.dict.direction.diagonal[0] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.diagonal[0])
						"ESE":
							dict.part.near[order][part] = Global.dict.direction.diagonal[1] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[1])
						"SSE":
							dict.part.near[order][part] = Global.dict.direction.diagonal[1] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.diagonal[1])
						"SSW":
							dict.part.near[order][part] = Global.dict.direction.diagonal[2] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[2])
						"WSW":
							dict.part.near[order][part] = Global.dict.direction.diagonal[2] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.diagonal[2])
						"WNW":
							dict.part.near[order][part] = Global.dict.direction.diagonal[3] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[3])
						"NNW":
							dict.part.near[order][part] = Global.dict.direction.diagonal[3] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.diagonal[3])
				"rectangle":
					match part:
						"E":
							dict.part.near[order][part] = Global.dict.direction.diagonal[0] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[1])
						"S":
							dict.part.near[order][part] = Global.dict.direction.diagonal[1] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[2])
						"W":
							dict.part.near[order][part] = Global.dict.direction.diagonal[2] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[3])
						"N":
							dict.part.near[order][part] = Global.dict.direction.diagonal[3] * order * 0.5
							dict.part.far[order][part] = dict.part.near[order][part] + Vector2(Global.dict.direction.linear2[0])
	
func init_biome() -> void:
	dict.biome = {}
	dict.biome.title = {}
	
	var path = "res://assets/jsons/waru_biome.json"
	var array = load_data(path)
	var exceptions = ["title"]
	
	for biome in array:
		dict.biome.title[biome.title] = {}
		var elements = biome.keys().filter(func (a): return !exceptions.has(a))
		
		for element in elements:
			dict.biome.title[biome.title][element] = biome[element]
	
func init_lair() -> void:
	dict.terrain = {}
	dict.terrain.element = {}
	
	var path = "res://assets/jsons/waru_lair.json"
	var array = load_data(path)
	var exceptions = ["terrain", "element"]
	
	for lair in array:
		if !dict.terrain.element.has(lair.terrain):
			dict.terrain.element[lair.terrain] = {}
			
		if !dict.terrain.element[lair.terrain].has(lair.element):
			dict.terrain.element[lair.terrain][lair.element] = {}
		
		var beasts = lair.keys().filter(func (a): return !exceptions.has(a))
		
		for beast in beasts:
			dict.terrain.element[lair.terrain][lair.element][beast] = lair[beast]
	
func init_color():
	var h = 360.0
	
	dict.color = {}
	dict.color.terrain = {}
	dict.color.terrain["desert"] = Color.from_hsv(60 / h, 0.8, 0.5)
	dict.color.terrain["mountain"] = Color.from_hsv(210 / h, 0.8, 0.5)
	dict.color.terrain["plain"] = Color.from_hsv(30 / h, 0.8, 0.5)
	dict.color.terrain["swamp"] = Color.from_hsv(270 / h, 0.8, 0.5)
	dict.color.terrain["forest"] = Color.from_hsv(120 / h, 0.8, 0.5)
	
	dict.color.element = {}
	dict.color.element["wind"] = Color.from_hsv(60 / h, 0.9, 0.7)
	dict.color.element["ice"] = Color.from_hsv(170 / h, 0.9, 0.7)
	dict.color.element["aqua"] = Color.from_hsv(210 / h, 0.9, 0.7)
	dict.color.element["nature"] = Color.from_hsv(120 / h, 0.9, 0.7)
	dict.color.element["earth"] = Color.from_hsv(30 / h, 0.9, 0.7)
	dict.color.element["lava"] = Color.from_hsv(330 / h, 0.9, 0.7)
	dict.color.element["fire"] = Color.from_hsv(0 / h, 0.9, 0.7)
	dict.color.element["lightning"] = Color.from_hsv(270 / h, 0.9, 0.7)
	
func save(path_: String, data_): #: String
	var file = FileAccess.open(path_, FileAccess.WRITE)
	file.store_string(data_)
	
func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()
	
func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null
	
func get_acreage_triangle(points_: Array) -> float:
	var a = points_[0]
	var b = points_[1]
	var c = points_[2]
	return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2)
