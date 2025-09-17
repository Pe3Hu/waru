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
	
func init_dict() -> void:
	init_direction()
	
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
