class_name RingResource
extends Resource


var habitats: Array[HabitatResource]
var lairs: Array[LairResource]
var shapes: Array[String]

var order: int

var acreage: float


func init_habitats() -> void:
	if order == 0:
		shapes.append("NESW")
	#else:
		#for _i in 

func calc_shapes() -> void:
	pass
