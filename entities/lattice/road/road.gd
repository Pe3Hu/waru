class_name Road
extends Line2D


var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()

var capitals: Array[Capital]


func init_vertexs() -> void:
	for capital in capitals:
		var vertex = capital.position
		add_point(vertex)
	
	capitals[0].roads[self] = capitals[1]
	capitals[1].roads[self] = capitals[0]
