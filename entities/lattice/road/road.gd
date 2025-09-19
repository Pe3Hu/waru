class_name Road
extends Line2D


var resource: RoadResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	for capital in resource.capitals:
		var vertex = capital.position
		add_point(vertex)
