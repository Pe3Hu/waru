class_name Region
extends Polygon2D


var anchors: Array[Anchor]
var borders: Dictionary
var neighbors: Dictionary
var domain: Domain = null:
	set(value_):
		domain = value_
		
		vacant_flag = false
		update_acreage()

var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()

var vacant_neighbors: int = 0
var acreage: float

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
	
func update_acreage() -> void:
	acreage = 0
	
	var points = [anchors[0].position, anchors[1].position, anchors[2].position]
	acreage += Global.get_acreage_triangle(points)
	
	if anchors.size() > 3:
		points = [anchors[0].position, anchors[3].position, anchors[2].position]
		acreage += Global.get_acreage_triangle(points)
	
func rnd_shift_anchors() -> void:
	var center = Vector2()
	var shifted_vertexs = []
	
	for anchor in anchors:
		center += anchor.position / anchors.size()
	
	for anchor in anchors:
		var direction = anchor.position - center
		var rnd_scale = randf_range(0.9, 1.1)
		anchor.position = center + direction * rnd_scale
	
	update_acreage()
	
func update_polygon_vertexs() -> void:
	init_vertexs()
