class_name Anchor
extends Polygon2D


var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()
var borders: Dictionary
var regions: Array[Region]

func init_vertexs() -> void:
	var vertexs = []
	
	for direction in Global.dict.direction.diagonal:
		var vertex = direction * lattice.anchor_r / 2
		vertexs.append(vertex)
	
	polygon = vertexs
