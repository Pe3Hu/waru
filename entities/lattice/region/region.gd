class_name Region
extends Polygon2D

var resource: RegionResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	var vertexs = []
	
	for anchor in resource.anchors:
		var vertex = anchor.position
		vertexs.append(vertex)
	
	polygon = vertexs
	
	if vertexs.size() == 4:
		color = Color.ORANGE_RED
	if vertexs.size() == 3:
		color = Color.YELLOW
		
	if resource.lattice.regions.size() % 2:
		color.v = 0.75
	
func recolor_energy() -> void:
	var v = 0.4
	color = Color.from_hsv(0.0, 0.0, v)
