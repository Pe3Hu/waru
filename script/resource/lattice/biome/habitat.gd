class_name HabitatResource
extends Resource


var lair: LairResource
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
var border_vertexs: Array[Vector2]

var milestones: Dictionary

var percent: float

var index: int
var hue_index: int

var end_bug_flag: bool = false


func add_shape(part_: String, milestones_: Array) -> void:
	shapes.append(part_)
	
	#if ring.source.anchor.index == 0:
		#print([ring.habitats.find(self), part_, milestones_])
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
		
		update_boreder_vertexs()
		return
	
	for part in milestones:
		add_shape_vertexs(part)
	
	skip_line_vertexs()
	update_boreder_vertexs()
	
func skip_line_vertexs() -> void:
	var vertex_queue = []
	vertex_queue.append_array(near_vertexs)
	
	for _i in range(far_vertexs.size() - 1, -1, -1):
		vertex_queue.append(far_vertexs[_i])
	
	vertexs.append(vertex_queue.front())
	
	for _i in range(1, vertex_queue.size() - 1, 1):
		var vertex = vertex_queue[_i]
		
		if abs(vertex.x) == abs(vertex.y):
			vertexs.append(vertex)
		else:
			var previous_vertex = vertex_queue[_i - 1]
			var next_vertex = vertex_queue[_i + 1]
			var on_line_flag = Global.check_3_dots_on_line(previous_vertex, vertex, next_vertex)
			
			if !on_line_flag:
				vertexs.append(vertex)
	
	vertexs.append(vertex_queue.back())
	
	if vertexs.size() >= 3:
	
		if Global.check_3_dots_on_line(vertexs[1], vertexs.front(), vertexs.back()):
			vertexs.erase(vertexs.front())
	
func skip_line_vertexs_old() -> void:
	#if near_vertexs.size() >= 3:
		#var skip_flag_second = Global.check_3_dots_on_line(near_vertexs[0], near_vertexs[1], near_vertexs[2])
		#
		#if ring.source.anchor.index == 0 and index == 1:
			#pass
		#if skip_flag_second:
			#near_vertexs.remove_at(1)
			#if ring.source.anchor.index == 0 and index == 1:
				#pass
	#
	#vertexs.append_array(near_vertexs)
	
	var last_vertex = near_vertexs.front()
	vertexs.append(last_vertex)
	
	for _i in range(1, near_vertexs.size() - 1, 1):
		var vertex = near_vertexs[_i]
		
		#if ring.source.anchor.index == 0 and index == 1:
			#print([_i, last_vertex, vertex, next_vertex])
		if abs(vertex.x) == abs(vertex.y):
			vertexs.append(vertex)
			if ring.source.anchor.index == 0 and index == 1:
				pass
		else:
			var next_vertex = near_vertexs[_i + 1]
			var skip_flag = Global.check_3_dots_on_line(last_vertex, vertex, next_vertex)
			
			if skip_flag:
				vertexs.append(vertex)
			
		last_vertex = vertex
	
	last_vertex = near_vertexs.back()
	vertexs.append(last_vertex)
	
	last_vertex = far_vertexs.back()
	#var last_vertex = far_vertexs.back()
	vertexs.append(last_vertex)
	
	for _i in range(far_vertexs.size() - 2, 0, -1):
		var vertex = far_vertexs[_i]
		
		if abs(vertex.x) == abs(vertex.y):
			vertexs.append(vertex)
			
		else:
			var next_vertex = far_vertexs[_i - 1]
			var skip_flag = Global.check_3_dots_on_line(last_vertex, vertex, next_vertex)
			
			#if ring.source.anchor.index == 0 and index == 1:
				#print([_i, last_vertex, vertex, next_vertex, skip_flag])
			#var skip_flag = false
			#
			#if last_vertex.x == vertex.x and last_vertex.x == vertex.x or last_vertex.y == next_vertex.y:
				#skip_flag = true
		#
			if !skip_flag:
				vertexs.append(vertex)
		
		last_vertex = vertex
	
	vertexs.append(far_vertexs.front())
	
	last_vertex = vertexs.back()
	
	for _i in range(vertexs.size() - 2, 0, -1):
		var vertex = vertexs[_i]
		
		if abs(vertex.x) != abs(vertex.y):
			var next_vertex = vertexs[_i - 1]
			var skip_flag = Global.check_3_dots_on_line(last_vertex, vertex, next_vertex)
			
			if !skip_flag:
				#vertexs.remove_at(_i)
				#print([_i, vertex])
				last_vertex = vertex
				pass
			else:
				last_vertex = vertex
		else:
			last_vertex = vertex
		
	#if ring.source.anchor.index == 0 and index == 1:
		#print([index, near_vertexs])
		#print([index, far_vertexs])
		#print([index, vertexs])
	
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
			#near_vertex += Global.dict.part.direction[part_name] * l * (1 - _offset_length)
		#else:
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
	
func update_boreder_vertexs() -> void:
	border_vertexs.clear()
	border_vertexs.append_array(vertexs)
	border_vertexs.append(vertexs.front())
	
	#var center = Vector2()
	#var scaled_vertexs = []
	#var scale_value = 1.0
	#
	#for vertex in vertexs:
		#center += vertex / vertexs.size()
		#
	#for vertex in vertexs:
		#var scaled_vertex = (vertex - center) * scale_value + center
		#scaled_vertexs.append(scaled_vertex)
	#
	#border_vertexs.clear()
	#border_vertexs.append_array(scaled_vertexs)
	#border_vertexs.append(border_vertexs.front())
	
func insert_bugged_vertexs(near_vertex_: Vector2, far_vertex_: Vector2) -> void:
	end_bug_flag = true
	near_vertexs.pop_back()
	#far_vertexs.pop_back()
	#near_vertexs.insert(0, near_vertex_)
	far_vertexs.append(far_vertex_)
	#far_vertexs.insert(0, far_vertex_)
	near_vertexs.append(near_vertex_)
	vertexs = []
	skip_line_vertexs()
	update_boreder_vertexs()
