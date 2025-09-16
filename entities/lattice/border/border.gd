class_name Border
extends Line2D


var lattice: Lattice:
	set(value_):
		lattice = value_
		
		init_vertexs()

var anchors: Array[Anchor]
var regions: Array[Region]

var center: Vector2

var internal_flag: bool = false


func init_vertexs() -> void:
	for anchor in anchors:
		var vertex = anchor.position
		add_point(vertex)
		center += vertex / anchors.size()
	
	anchors[0].borders[self] = anchors[1]
	anchors[1].borders[self] = anchors[0]
	
	anchors[0].neighbors[anchors[1]] = self
	anchors[1].neighbors[anchors[0]] = self
	
func add_region(region_: Region) -> void:
	regions.append(region_)
	region_.all_borders.append(self)
	
	if regions.size() == 2:
		#for _i in regions.size():
		#	var _j = (_i + 1) % regions.size()
		var region_a = regions.front()
		var region_b = regions.back()
		region_a.borders[self] = region_b
		region_b.borders[self] = region_a
		
		region_a.neighbors[region_b] = self
		region_b.neighbors[region_a] = self
	
func show_as_domain() -> void:
	if regions.size() == 1:
		return
	
	if regions.front().domain == regions.back().domain:
		visible = false
	
func get_another_region(region_: Region) -> Region:
	#var _regions = regions.filter(func(a): return a != region_)
	#return _regions.front()
	var index = 0
	
	if regions[index] == region_:
		index = 1
	
	return regions[index]
	
func get_another_anchor(anchor_: Anchor) -> Anchor:
	var index = 0
	
	if anchors[index] == anchor_:
		index = 1
	
	return anchors[index]
