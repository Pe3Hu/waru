class_name RoadResource
extends Resource


var lattice: LatticeResource:
	set(value_):
		lattice = value_
		
		capitals[0].roads[self] = capitals[1]
		capitals[1].roads[self] = capitals[0]

var capitals: Array[CapitalResource]
