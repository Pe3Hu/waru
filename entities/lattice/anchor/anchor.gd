class_name Anchor
extends Polygon2D


var resource: AnchorResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	position = resource.position
	var vertexs = []
	
	for direction in Global.dict.direction.diagonal:
		var vertex = direction * resource.lattice.anchor_r / 2
		vertexs.append(vertex)
	
	polygon = vertexs
