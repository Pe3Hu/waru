class_name Region
extends Polygon2D


var anchors: Array[Anchor]
var all_borders: Array[Border]

var borders: Dictionary
var neighbors: Dictionary

var domain: Domain = null:
	set(value_):
		domain = value_
		
		vacant_flag = false
		update_total_acreage()

var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()

var center = Vector2()

var vacant_neighbors: int = 0
var total_acreage: float
var captured_acreage: float
var energy: float

var vacant_flag: bool = false
var failure_flag: bool = false


func init_vertexs() -> void:
	var vertexs = []
	
	for anchor in anchors:
		var vertex = anchor.position
		vertexs.append(vertex)
		anchor.regions.append(self)
	
	polygon = vertexs
	
	if vertexs.size() == 4:
		color = Color.ORANGE_RED
	if vertexs.size() == 3:
		color = Color.YELLOW
		
	if lattice.regions.get_child_count() % 2:
		color.v = 0.75
	
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
	#var shifted_vertexs = []
	
	for anchor in anchors:
		center += anchor.position / anchors.size()
	
	for anchor in anchors:
		var direction = anchor.position - center
		var rnd_scale = 1#randf_range(0.9, 1.1)
		anchor.position = center + direction * rnd_scale
	
func update_polygon_vertexs() -> void:
	init_vertexs()
	
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
	
	#var points = [anchors[0].position, anchors[1].position, anchors[2].position]
	#total_acreage += Global.get_acreage_triangle(points)
	#
	#if anchors.size() > 3:
		#points = [anchors[0].position, anchors[3].position, anchors[2].position]
		#total_acreage += Global.get_acreage_triangle(points)
	
func update_captured_acreage() -> void:
	captured_acreage = 0
	
	for _i in range(0, all_borders.size(), 1):
		var _j = (_i + 1) % all_borders.size()
		var points = [center, all_borders[_i].center, all_borders[_j].center]
		captured_acreage += Global.get_acreage_triangle(points)
	
func recolor_energy() -> void:
	var v = 0.4
	color = Color.from_hsv(0.0, 0.0, v)
