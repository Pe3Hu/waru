class_name Domain
extends Polygon2D


var capital: Capital
var anchors: Array[Anchor]
var regions: Array[Region]
#var domains: Array[Domain]
var domain_borders: Dictionary

var acreage: float

var lattice: Lattice:
	set(value_):
		lattice = value_
		
		update_acreage()
		#switch_regions()


func add_region(region_: Region) -> void:
	if region_.domain != null:
		pass
	
	regions.append(region_)
	region_.domain = self
	region_.vacant_flag = false
	
	for anchor in region_.anchors:
		if !anchors.has(anchor):
			anchors.append(anchor)
	
	for neighbor in region_.neighbors:
		neighbor.vacant_neighbors -= 1
		
		if neighbor.vacant_neighbors > 0 and neighbor.domain == null:
			neighbor.vacant_flag = true
	
func recolor_regions() -> void:
	var h = float(get_index()) / lattice.domains.get_child_count()
	var region_color = color.from_hsv(h, 0.8, 0.8)
	
	for region in regions:
		region.color = region_color
	
func switch_regions() -> void:
	for region in regions:
		##region.visible = !region.visible
		
		for anchor in region.anchors:
			anchor.visible = false
	
func update_acreage() -> void:
	acreage = 0
	
	for region in regions:
		acreage += region.acreage
	
func init_borders() -> void:
	var internal_borders = []
	var external_borders = []
	
	for region in regions:
		#print([region.anchors.size()])
		for border in region.borders:
			if external_borders.has(border):
				external_borders.erase(border)
				internal_borders.append(border)
			
			external_borders.append(border)
	
	#print([internal_borders.size(), external_borders.size()])
	
	for border in external_borders:
		var external_region = border.regions[0]
		
		if regions.has(external_region):
			external_region = border.regions[1]
		
		var neighbor = external_region.domain
		
		if !domain_borders.has(neighbor):
			domain_borders[neighbor] = []
		
		domain_borders[neighbor].append(border)
