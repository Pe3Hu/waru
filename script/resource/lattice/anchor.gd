class_name AnchorResource
extends Resource


var lattice: LatticeResource
var source: SourceResource

var regions: Array[RegionResource]

var borders: Dictionary
var neighbors: Dictionary

var position: Vector2

var flag_side: bool = false

var index: int


func update_side_flag() -> void:
	flag_side = false
	var border_counter = 0
	
	for border in borders:
		if border.regions.size() == 1:
			border_counter += 1
	
	if border_counter == 2:
		flag_side = true
