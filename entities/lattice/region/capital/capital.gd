class_name Capital
extends Polygon2D


var resource: CapitalResource:
	set(value_):
		resource = value_
		
		init_vertexs()

	
func init_vertexs() -> void:
	position = resource.position
	var vertexs = []
	
	for direction in Global.dict.direction.linear2:
		var vertex = direction * resource.domain.lattice.anchor_r
		vertexs.append(vertex)
	
	polygon = vertexs
