class_name Anchor
extends Polygon2D


var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()
var source: Source

var borders: Dictionary
var neighbors: Dictionary
var regions: Array[Region]

var flag_side: bool = false


func init_vertexs() -> void:
	var vertexs = []
	
	for direction in Global.dict.direction.diagonal:
		var vertex = direction * lattice.anchor_r / 2
		vertexs.append(vertex)
	
	polygon = vertexs
	
func update_side_flag() -> void:
	flag_side = false
	var border_counter = 0
	
	for border in borders:
		if border.regions.size() == 1:
			border_counter += 1
	
	if border_counter == 2:
		flag_side = true
