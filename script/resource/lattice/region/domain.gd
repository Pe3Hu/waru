class_name DomainResource
extends Resource


var capital: CapitalResource
var lattice: LatticeResource:
	set(value_):
		lattice = value_
		
		update_acreage()

var anchors: Array[AnchorResource]
var regions: Array[RegionResource]
#var domains: Array[DomainResource]

var domain_borders: Dictionary

var acreage: float


func add_region(region_: RegionResource) -> void:
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
	
func update_acreage() -> void:
	acreage = 0
	
	for region in regions:
		acreage += region.total_acreage
	
func init_borders() -> void:
	var internal_borders = []
	var external_borders = []
	
	for region in regions:
		for border in region.borders:
			if external_borders.has(border):
				external_borders.erase(border)
				internal_borders.append(border)
			
			external_borders.append(border)
	
	for border in external_borders:
		var external_region = border.regions[0]
		
		if regions.has(external_region):
			external_region = border.regions[1]
		
		var neighbor = external_region.domain
		
		if neighbor != null:
			if !domain_borders.has(neighbor):
				domain_borders[neighbor] = []
			
			domain_borders[neighbor].append(border)
