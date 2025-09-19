class_name RegionResource
extends Resource


@export var anchors: Array[AnchorResource]
@export var all_borders: Array[BorderResource]

var borders: Dictionary
var neighbors: Dictionary

var lattice: LatticeResource:
	set(value_):
		lattice = value_
		
		init_regions()
var domain: DomainResource = null:
	set(value_):
		domain = value_
		
		vacant_flag = false
		update_total_acreage()

var center = Vector2()

var vacant_neighbors: int = 0
var total_acreage: float
var captured_acreage: float
var energy: float

var vacant_flag: bool = false
var failure_flag: bool = false


func init_regions() -> void:
	for anchor in anchors:
		anchor.regions.append(self)

func init_borders() -> void:
	for _i in anchors.size():
		var _j = (_i + 1) % anchors.size()
		var anchor_a = anchors[_i]
		var anchor_b = anchors[_j]
		lattice.add_border(self, [anchor_a, anchor_b])
	
func update_count_vacant_neighbors() -> void:
	vacant_neighbors = 0
	
	for border in borders:
		if borders[border].domain == null:
			vacant_neighbors += 1
		else:
			vacant_flag = true
	
	if domain != null:
		vacant_flag = false
	
func rnd_shift_anchors() -> void:
	for anchor in anchors:
		center += anchor.position / anchors.size()
	
	for anchor in anchors:
		var direction = anchor.position - center
		var rnd_scale = 1#randf_range(0.9, 1.1)
		anchor.position = center + direction * rnd_scale
	
func update_acreage() -> void:
	center = Vector2()
	
	for anchor in anchors:
		center += anchor.position / anchors.size()
	
	update_total_acreage()
	update_captured_acreage()
	
func update_total_acreage() -> void:
	total_acreage = 0
	
	for _i in range(0, anchors.size(), 1):
		var _j = (_i + 1) % anchors.size()
		var points = [center, anchors[_i].position, anchors[_j].position]
		total_acreage += Global.get_acreage_triangle(points)
	
func update_captured_acreage() -> void:
	captured_acreage = 0
	
	for _i in range(0, all_borders.size(), 1):
		var _j = (_i + 1) % all_borders.size()
		var points = [center, all_borders[_i].center, all_borders[_j].center]
		captured_acreage += Global.get_acreage_triangle(points)
