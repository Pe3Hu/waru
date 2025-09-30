class_name Lattice
extends PanelContainer


@onready var anchors = %Anchors
@onready var regions = %Regions
@onready var capitals = %Capitals
@onready var borders = %Borders
@onready var roads = %Roads
@onready var sources = %Sources

@onready var anchor_scene = preload("res://entities/lattice/anchor/anchor.tscn")
@onready var region_scene = preload("res://entities/lattice/region/region.tscn")
@onready var capital_scene = preload("res://entities/lattice/region/capital/capital.tscn")
@onready var border_scene = preload("res://entities/lattice/border/border.tscn")
@onready var road_scene = preload("res://entities/lattice/road/road.tscn")
@onready var source_scene = preload("res://entities/lattice/anchor/source/source.tscn")

@export var canvas_layer: CanvasLayer
@export var expedition: Expedition
@export var selected: ColorRect

var cradle_resource: CradleResource
var resource: LatticeResource


func _ready() -> void:
	cradle_resource = CradleResource.new()
	resource = cradle_resource.lattice
	#resource = LatticeResource.new()#cradle_resource
	#resource.cradle = cradle_resource
	#cradle_resource.lattice = resource
	
	if resource != null:
		if !resource.anchors.is_empty():
			init_anchors()
			init_regions()
			init_borders()
			init_capitals()
			init_roads()
			init_sources()
			
			await get_tree().create_timer(0.05).timeout
			select_source(sources.get_child(0))
			
			if resource.defected_source != null:
				for source in sources.get_children():
					if source.resource == resource.defected_source:
						select_source(source)
						source.resource.rings[2].analyze_defect()
						break
	
func init_anchors() -> void:
	for anchor_resource in resource.anchors:
		var anchor = anchor_scene.instantiate()
		anchor.resource = anchor_resource
		anchors.add_child(anchor)
	
	var no_corner = resource.clusters[0][resource.dimensions.x - 1][4].position
	var sw_corner = resource.clusters[resource.dimensions.y - 1][0][1].position
	var center = (no_corner + sw_corner) / 2
	var x = abs(no_corner.x - sw_corner.x) + resource.border_width
	var y = abs(no_corner.y - sw_corner.y) + resource.border_width
	custom_minimum_size = Vector2(x, y)
	size = custom_minimum_size
	
	%Nodes2D.position = custom_minimum_size * 0.5 - center
	set_anchors_preset(Control.PRESET_CENTER)
	#set("anchors_preset", "Bottom Right")
	
func init_regions() -> void:
	for region_resource in resource.regions:
		var region = region_scene.instantiate()
		region.resource = region_resource
		regions.add_child(region)
	
func init_borders() -> void:
	for border_resource in resource.borders:
		var border = border_scene.instantiate()
		border.resource = border_resource
		borders.add_child(border)
	
	recolor_border_based_on_domain()
	
func init_capitals() -> void:
	for domain_resource in resource.domains:
		#var domain = domain_scene.instantiate()
		#domain.resource = domain_resource
		#domains.add_child(domain)
		#
		var capital = capital_scene.instantiate()
		capital.resource = domain_resource.capital
		capitals.add_child(capital)
	
	recolor_region_based_on_domain_index()
	
func init_roads() -> void:
	for road_resource in resource.roads:
		var road = road_scene.instantiate()
		road.resource = road_resource
		roads.add_child(road)
	
func init_sources() -> void:
	for source_resource in resource.sources:
		var source = source_scene.instantiate()
		source.resource = source_resource
		source.lattice = self
		sources.add_child(source)
	
	recolor_sources_based_on_terrain()
	#recolor_sources_based_on_energy()
	#recolor_regions_based_on_energy()
	
func recolor_sources_based_on_terrain() -> void:
	for source in sources.get_children():
		if source.resource.biome != null:
			source.terrain.color = Global.dict.color.terrain[source.resource.biome.terrain]
	
func recolor_regions_based_on_energy() -> void:
	var max_energy = 0.0
	var min_energy = regions.get_child(0).resource.energy
	
	for region in regions.get_children():
		if max_energy < region.resource.energy:
			max_energy = region.resource.energy
		if min_energy > region.resource.energy:
			min_energy = region.resource.energy
	
	for region in regions.get_children():
		region.visible = true
		var energy_weight = remap(region.resource.energy, min_energy, max_energy, 0, 1)
		region.color = Color.from_hsv(0.0, 0.0, energy_weight)
	
func recolor_sources_based_on_energy() -> void:
	var h = 360.0
	var hues = {}
	hues["desert"] = 60.0 / h
	hues["mountain"] = 210.0 / h
	hues["plain"] = 30.0 / h
	hues["swamp"] = 270.0 / h
	hues["forest"] = 120.0 / h
	
	var max_energy = 0.0
	var min_energy = regions.get_child(0).resource.energy * 4
	
	for source in sources.get_children():
		if max_energy < source.resource.energy:
			max_energy = source.resource.energy
		if min_energy > source.resource.energy:
			min_energy = source.resource.energy
	
	for source in sources.get_children():
		if source.resource.biome != null:
			var energy_weight = remap(source.resource.energy, min_energy, max_energy, 0, 1)
			source.color = Color.from_hsv(hues[source.resource.biome.terrain], 0.8, energy_weight)
	
func recolor_border_based_on_domain() -> void:
	for border in borders.get_children():
		border.show_as_domain_border()
	
func recolor_region_based_on_domain_index() -> void:
	for region in regions.get_children():
		var index = resource.domains.find(region.resource.domain)
		var hue = float(index) / resource.domains.size()
		region.color = Color.from_hsv(hue, 0.9, 0.7)
	
func select_source(source_: Source) -> void:
	expedition.source_info.source = source_
	selected.position = source_.resource.center - selected.size / 2
