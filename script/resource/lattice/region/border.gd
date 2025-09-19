class_name BorderResource
extends Resource


var lattice: LatticeResource:
	set(value_):
		lattice = value_
		
		anchors[0].borders[self] = anchors[1]
		anchors[1].borders[self] = anchors[0]
		
		anchors[0].neighbors[anchors[1]] = self
		anchors[1].neighbors[anchors[0]] = self
		
		for anchor in anchors:
			center += anchor.position / 2

var anchors: Array[AnchorResource]
var regions: Array[RegionResource]

var center: Vector2

var internal_flag: bool = false


func add_region(region_: RegionResource) -> void:
	regions.append(region_)
	region_.all_borders.append(self)
	
	if regions.size() == 2:
		var region_a = regions.front()
		var region_b = regions.back()
		region_a.borders[self] = region_b
		region_b.borders[self] = region_a
		
		region_a.neighbors[region_b] = self
		region_b.neighbors[region_a] = self
	
func get_another_region(region_: RegionResource) -> RegionResource:
	var index = 0
	
	if regions[index] == region_:
		index = 1
	
	return regions[index]
	
func get_another_anchor(anchor_: AnchorResource) -> AnchorResource:
	var index = 0
	
	if anchors[index] == anchor_:
		index = 1
	
	return anchors[index]
