class_name Source
extends Polygon2D


var anchor: Anchor:
	set(value_):
		anchor = value_
		
		anchor.source = self
		init_vertexs()
		update_acreage()
var biome: Biome:
	set(value_):
		biome = value_
		
		color = Global.dict.color.terrain[biome.terrain]
		#roll_element()

var lairs: Array[Lair]

var center = Vector2()

var element: String

var acreage: float
var energy: float


func init_vertexs() -> void:
	var vertexs = []
	
	for border in anchor.borders:
		var vertex = border.center
		vertexs.append(vertex)
		center += border.center / anchor.borders.keys().size()
	
	var temp_vertex = null
	
	if vertexs.size() == 3:
		temp_vertex = center + (anchor.position - center) * 2
		vertexs.append(temp_vertex)
	
	vertexs.sort_custom(func(a,b): return anchor.position.angle_to_point(a) < anchor.position.angle_to_point(b))
	
	if temp_vertex != null:
		var index = vertexs.find(temp_vertex)
		vertexs[index] = anchor.position
	
	if vertexs.size() == 2:
		vertexs.push_front(anchor.position)
	
	polygon = vertexs
	vertexs = []
	
	for point in polygon:
		var vertex = center + (point - center) * 0.7
		vertexs.append(vertex)
	
	%Element.polygon = vertexs

func update_acreage() -> void:
	acreage = 0
	
	for _i in range(0, polygon.size(), 1):
		var _j = (_i + 1) % polygon.size()
		var points = [center, polygon[_i], polygon[_j]]
		acreage += Global.get_acreage_triangle(points)
	
func roll_element(exceptions_: Array) -> void:
	var options = {}
	
	for option in Global.dict.biome.title[biome.terrain]:
		if !exceptions_.has(option):
			options[option] = Global.dict.biome.title[biome.terrain][option]
	
	if options.keys().is_empty():
		options = Global.dict.biome.title[biome.terrain]
	
	element = Global.get_random_key(options)
	%Element.color = Global.dict.color.element[element]
	roll_lairs()
	
func roll_lairs() -> void:
	var free_acreage = float(acreage)
	var min_acreage = anchor.lattice.lair_acreage * 0.75
	
	while free_acreage > min_acreage:
		var lair_acreage = randf_range(0.75, 1.25) * anchor.lattice.lair_acreage
		var beast_type = Global.get_random_key(Global.dict.terrain.element[biome.terrain][element])
		free_acreage -= lair_acreage
		anchor.lattice.add_lair(self, lair_acreage, beast_type)
	
	for lair in lairs:
		lair.acreage += free_acreage / lairs.size()
		lair.energy = energy / lairs.size()
		lair.concentration = lair.energy / lair.acreage * 100
