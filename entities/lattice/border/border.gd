class_name Border
extends Line2D


var resource: BorderResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	width = resource.lattice.border_width
	
	for anchor in resource.anchors:
		var vertex = anchor.position
		add_point(vertex)
	
func show_as_domain_border() -> void:
	if resource.regions.size() == 1:
		return
	
	if resource.regions.front().domain == resource.regions.back().domain:
		visible = false
