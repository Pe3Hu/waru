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

var center = Vector2()

var acreage: float


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

func update_acreage() -> void:
	acreage = 0
	
	for _i in range(0, polygon.size(), 1):
		var _j = (_i + 1) % polygon.size()
		var points = [center, polygon[_i], polygon[_j]]
		acreage += Global.get_acreage_triangle(points)
