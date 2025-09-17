class_name Capital
extends Polygon2D


@export var domain: Domain

var roads: Dictionary


func _ready() -> void:
	init_vertexs()
	
func init_vertexs() -> void:
	var vertexs = []
	
	for direction in Global.dict.direction.linear2:
		var vertex = direction * domain.lattice.anchor_r
		vertexs.append(vertex)
	
	polygon = vertexs
	
func calc_position() -> void:
	position = Vector2()
	
	for anchor in domain.anchors:
		position += anchor.position / domain.anchors.size()
