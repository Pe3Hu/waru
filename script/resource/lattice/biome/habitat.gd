class_name HabitatResource
extends Resource


var ring: RingResource:
	set(value_):
		ring = value_
		
		hue_index = int(ring.source.habaitat_count)
		index = ring.habitats.size()
		ring.habitats.append(self)
		ring.source.habaitat_count += 1
		#init_vertexs()

var squares: Array[String]
var rectangles: Array[String]
var triangles: Array[String]
var shapes: Array[String]
var vertexs: Array[Vector2]
var far_vertexs: Array[Vector2]
var near_vertexs: Array[Vector2]

var milestones: Dictionary

var percent: float

var index: int
var hue_index: int


func add_shape(part_: String, milestones_: Array) -> void:
	shapes.append(part_)
	
	if ring.source.anchor.index == 0:
		print([ring.habitats.find(self), part_, milestones_])
	var part_name = part_.erase(part_.length() - 1, 1)
	var shape = Global.dict.part.shape[part_name]
	var shape_array = get(shape + "s")
	shape_array.append(part_)
	milestones[part_] = milestones_
	
func init_vertexs() -> void:
	var l = ring.source.biome.lattice.habitat_l / 2
	
	if !squares.is_empty():
		for direction in Global.dict.direction.diagonal:
			var vertex = Vector2(direction) * l
			vertexs.append(vertex)
		
		return
	
	for part in milestones:
		add_shape_vertexs(part)
	
	vertexs.append_array(near_vertexs)
	
	for _i in range(far_vertexs.size() - 1, -1, -1):
		var vertex = far_vertexs[_i]
		vertexs.append(vertex)
	
func add_shape_vertexs(part_: String) -> void:
	var l = ring.source.biome.lattice.habitat_l 
	var part_name = part_.erase(part_.length() - 1, 1)
	var shape = Global.dict.part.shape[part_name]
	
	var near_vertex = Global.dict.part.near[ring.order][part_name] * l
	var far_vertex = Global.dict.part.far[ring.order][part_name] * l
	
	if milestones[part_].front() != 0:
		var _offset_length = get_offset_length(part_)
		far_vertex += Global.dict.part.direction[part_name] * l * _offset_length
	
	if index > 0 and shapes.find(part_) == 0:
		var previous_habitat = ring.habitats[index - 1]
		#var a = previous_habitat.near_vertexs.back()
		#var b = previous_habitat.far_vertexs.back()
		#print(a == near_vertex, b == far_vertex)
		if ring.source.anchor.index == 0:
			pass
		near_vertex = previous_habitat.near_vertexs.back()
		far_vertex = previous_habitat.far_vertexs.back()
		
	if near_vertexs.is_empty() or near_vertexs.back() != near_vertex:
		near_vertexs.append(near_vertex)
	
	if far_vertexs.is_empty() or far_vertexs.back() != far_vertex:
		far_vertexs.append(far_vertex)
	
	var cathetus_length = get_cathetus_length(part_)
	far_vertex += Global.dict.part.direction[part_name] * l * cathetus_length
	
	#if ring.source.anchor.index == 0:
		#print([milestones[part_], cathetus_length])
	
	#far_vertex = Global.dict.direction.diagonal[0] * l * ( 1 + ring.order * 2)
	if far_vertexs.back() != far_vertex:
		far_vertexs.append(far_vertex)
	
	if shape == "rectangle":
		if milestones[part_].front() != 0:
			var _offset_length = get_offset_length(part_)
			near_vertex += Global.dict.part.direction[part_name] * l * _offset_length
		
		near_vertex += Global.dict.part.direction[part_name] * l * cathetus_length
		
		if near_vertexs.back() != near_vertex:
			near_vertexs.append(near_vertex)
	
	#if ring.source.anchor.index == 0:
		#print(["far", part_, far_vertexs])
		#print(["near", part_, near_vertexs])
		#print([ring.habitats.find(self), milestones[part_].front() == 0, milestones[part_]])
	
func get_cathetus_length(part_: String) -> float:
	var cathetus_scale = milestones[part_][1] - milestones[part_][0]
	#var part_name = part_.erase(part_.length() - 1, 1)
	var l = cathetus_scale#2 * cathetus_scale / sqrt(2)
	
	#if Global.dict.part.shape[part_name] == "rectangle":
		#l /= 3.0 / 2
	
	#if ring.source.anchor.index == 0:
		#print([part_, l, cathetus_scale, milestones])
	return l
	
func get_offset_length(part_: String) -> float:
	var offset_scale = milestones[part_][0]
	var l = offset_scale
	return l
