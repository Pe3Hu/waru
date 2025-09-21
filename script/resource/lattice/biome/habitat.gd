class_name HabitatResource
extends Resource


var ring: RingResource:
	set(value_):
		ring = value_
		
		ring.habitats.append(self)
		init_vertexs()

var squares: Array[String]
var rectangles: Array[String]
var triangles: Array[String]
var milestones: Dictionary

var percent: float

var vertexs: Array[Vector2]
var far_vertexs: Array[Vector2]
var close_vertexs: Array[Vector2]


func add_shape(part_: String, milestones_: Array) -> void:
	var part_name = part_.erase(part_.length() - 1, 1)
	var shape = Global.dict.part.shape[part_name]
	var shapes = get(shape + "s")
	shapes.append(part_)
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
		
	pass
	
func add_shape_vertexs(part_: String) -> void:
	var l = ring.source.biome.lattice.habitat_l 
	var part_name = part_.erase(part_.length() - 1, 1)
	var shape = Global.dict.part.shape[part_name]
	
	match shape:
		"triangle":
			var close_vertex = Global.dict.direction.diagonal[0] * l * ring.order / 2
			var far_vertex = close_vertex + Global.dict.direction.linear2[0] * l
			close_vertexs.append(close_vertex)
			far_vertexs.append(far_vertex)
			var cathetus_length = get_cathetus_length(part_)
			far_vertex += Global.dict.part.direction[part_name] * l * cathetus_length
			#far_vertex = Global.dict.direction.diagonal[0] * l * ( 1 + ring.order * 2)
			far_vertexs.append(far_vertex)
	
	vertexs.append_array(close_vertexs)
	
	for _i in range(far_vertexs.size() - 1, -1, -1):
		var vertex = far_vertexs[_i]
		vertexs.append(vertex)
	
func get_cathetus_length(part_: String) -> float:
	var cathetus_scale = milestones[part_][1] - milestones[part_][0]
	var l = 2 * cathetus_scale / sqrt(2)
	return l
