class_name Lattice
extends PanelContainer


@onready var anchors = %Anchors
@onready var regions = %Regions
@onready var domains = %Domains
@onready var capitals = %Capitals
@onready var borders = %Borders
@onready var roads = %Roads
@onready var sources = %Sources
@onready var biomes = %Biomes
@onready var lairs = %Lairs

@onready var anchor_scene = preload("res://entities/lattice/anchor/anchor.tscn")
@onready var region_scene = preload("res://entities/lattice/region/region.tscn")
@onready var domain_scene = preload("res://entities/lattice/region/domain/domain.tscn")
@onready var capital_scene = preload("res://entities/lattice/region/capital/capital.tscn")
@onready var border_scene = preload("res://entities/lattice/border/border.tscn")
@onready var road_scene = preload("res://entities/lattice/road/road.tscn")
@onready var source_scene = preload("res://entities/lattice/anchor/source/source.tscn")
@onready var biome_scene = preload("res://entities/lattice/anchor/biome/biome.tscn")
@onready var lair_scene = preload("res://entities/lattice/anchor/lair/lair.tscn")


var cradle_resource: CradleResource

var clusters: Dictionary
var anchor_borders: Dictionary

var dimensions: Vector2i
var center_position: Vector2

var anchor_r: float = 6
var grid_step: float = 50
var lair_acreage: float = 100
var n_dimension: int = 7

var terrain_noise: FastNoiseLite = FastNoiseLite.new()


func _ready() -> void:
	dimensions = Vector2i.ONE * n_dimension
	cradle_resource = CradleResource.new()
	
	#init_anchors()
	#init_regions()
	#rnd_shift_anchors()
	#init_borders()
	#init_domains()
	#init_roads()
	#init_sources()
	#init_biomes()
	#init_energy()
	#init_lairs()
	#init_skills()
	
func init_anchors() -> void:
	#anchors.position = custom_minimum_size * 0.5
	var vector = Vector2()
	add_anchor(vector)
	
	for _i in dimensions.y:
		add_cluster_row()
	
	#var anchor = clusters[0][dimensions.x - 1][4]
	#anchor.color = Color.RED
	#anchor = clusters[dimensions.y - 1][0][1]
	#anchor.color = Color.RED
	
	var no_corner = clusters[0][dimensions.x - 1][4].position
	var sw_corner = clusters[dimensions.y - 1][0][1].position
	center_position = (no_corner + sw_corner) / 2
	
	%Nodes2D.position = custom_minimum_size * 0.5 - center_position
	
	#for _i in range(anchors.get_child_count() - 1, -1, -1):
		#var anchor = anchors.get_child(_i)
		#
		#if anchor.position.x <= no_corner.x and anchor.position.x >= sw_corner.x and anchor.position.y >= no_corner.y and anchor.position.y <= sw_corner.y:
			#anchor.color = Color.LIGHT_SLATE_GRAY
	
func add_cluster_row() -> void:
	var row_index = clusters.keys().size()
	clusters[row_index] = []
	var anchor
	
	if row_index == 0:
		anchor = anchors.get_child(0)
	else:
		var vector = clusters[row_index - 1].front()[1].position + Vector2.from_angle(PI / 3) * grid_step
		anchor = add_anchor(vector)
	
	if !clusters[row_index].is_empty():
		anchor = clusters[row_index].back().back()
	
	add_cluster(anchor) 
	
	for _i in dimensions.x - 1:
		add_cluster(clusters[row_index].back().back())
	#pass
	
func add_cluster(anchor_: Anchor) -> void:
	var row_index = clusters.keys().size() - 1
	var col_index = clusters[row_index].size()
	var direction_a = Vector2(0, 1) * grid_step
	var direction_b = Vector2(1, 0) * grid_step
	var cluster = [anchor_]
	
	if  col_index % 2 == 1:
		direction_a = Vector2.from_angle(PI / 3) * grid_step
		direction_b = Vector2.from_angle(-PI / 6) * grid_step
	
	cluster.append(add_anchor(anchor_.position + direction_a))
	
	var vectors = [
		anchor_.position,
		anchor_.position + direction_a
	]
	
	for _i in range(1, 3, 1):
		for _j in vectors.size():
			var anchor
			
			if row_index > 0 and _i == 2 and _j == 0 and clusters[row_index - 1].size() > col_index + 1:
				anchor = clusters[row_index - 1][col_index + 1][1]
			else:
				anchor = add_anchor(vectors[_j] + direction_b * _i)
			
			cluster.append(anchor)
	
	clusters[row_index].append(cluster)
	
func add_anchor(vector_: Vector2) -> Anchor:
	var anchor = anchor_scene.instantiate()
	anchor.lattice = self
	anchors.add_child(anchor)
	anchor.position = vector_
	return anchor
	
func init_regions() -> void:
	for _row in clusters:
		if _row + 1 < clusters.size():
			for _col in clusters[_row].size():
			#if _col + 1 < clusters[_row].size():
				var indexs = [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5]]
				var rows = [[1, 0, 1], [0, 1, 0], [1, 0, 1], [0, 1, 0]]
				
				if _col % 2 == 0:
					indexs = [[1, 0, 3], [0, 3, 2], [3, 2, 5], [2, 5, 4]]
					rows = [[0, 1, 0], [1, 0, 1], [0, 1, 0], [1, 0, 1]]
				
				for _i in rows.size():
					var _rows = rows[_i]
					var _indexs = indexs[_i]
					var anchors_ = []
					
					for _j in _rows.size():
						var index = _indexs[_j]
						var row = _row + _rows[_j]
						var anchor = clusters[row][_col][index]
						
						anchors_.append(anchor)
					
					add_region(anchors_)
	
	for row in clusters:
		for _anchors in clusters[row]:
			var shifts = [0, 2]
			var indexs = [0, 2, 3, 1]
			
			for _i in shifts:
				var anchors_ = []
				
				for _j in indexs:
					var index = _i + _j
					var anchor = _anchors[index]
					anchors_.append(anchor)
				
				add_region(anchors_)
	
func add_region(anchors_: Array) -> void:
	for anchor in anchors_:
		if !check_acnhor_in_corners(anchor):
			return
	
	var region = region_scene.instantiate()
	region.anchors.append_array(anchors_)
	region.lattice = self
	regions.add_child(region)
	
func check_acnhor_in_corners(anchor_: Anchor) -> bool:
	var no_corner = clusters[0][dimensions.x - 1][4].position
	var sw_corner = clusters[dimensions.y - 1][0][1].position
	return anchor_.position.x <= no_corner.x and anchor_.position.x >= sw_corner.x and anchor_.position.y >= no_corner.y and anchor_.position.y <= sw_corner.y
	
func rnd_shift_anchors() -> void:
	for region in regions.get_children():
		region.rnd_shift_anchors()
		
	for region in regions.get_children():
		region.update_polygon_vertexs()
	
func init_borders() -> void:
	for region in regions.get_children():
		region.init_borders()
	
	for region in regions.get_children():
		region.update_acreage()
	
	for anchor in anchors.get_children():
		anchor.update_side_flag()
	
func add_border(region_: Region, anchors_: Array) -> void:
	anchors_.sort_custom(func(a, b): return a.get_index() < b.get_index())
	var border
	
	if !anchor_borders.has(anchors_):
		border = border_scene.instantiate()
		border.anchors.append_array(anchors_)
		anchor_borders[anchors_] = border
		border.lattice = self
		borders.add_child(border)
	else:
		border = anchor_borders[anchors_]
	
	border.add_region(region_)
	
func init_domains() -> void:
	for region in regions.get_children():
		region.update_count_vacant_neighbors()
	
	var prepared_regions = prepare_regions_for_domain()
	var options = regions.get_children()
	var failures = []
	var counter_unoccupied = regions.get_child_count()
	
	while !options.is_empty() and counter_unoccupied > 0:
		counter_unoccupied -= 1
		
		for prepared_region in prepared_regions:
			options.erase(prepared_region)
			
			if prepared_region.failure_flag:
				failures.append(prepared_region)
		
		add_domain(prepared_regions)
		prepared_regions = prepare_regions_for_domain()
	
	fix_failure_regions()
	
	for domain in domains.get_children():
		domain.init_borders()
		domain.capital.calc_position()
		domain.recolor_regions()
	
	for border in borders.get_children():
		border.show_as_domain()
	
	for _i in range(anchors.get_child_count()-1,-1,-1):
		var anchor = anchors.get_child(_i)
		
		#if anchor.borders.keys().is_empty():
		if anchor.regions.is_empty():
			anchors.remove_child(anchor)
		
	#for region in regions.get_children():
		#if region.vacant_flag:
			#region.color = Color.GHOST_WHITE
		#if region.failure_flag:
			#region.color = Color.DIM_GRAY
	
func prepare_regions_for_domain() -> Array:
	var vertex_options = {
		[]: [],
		[3]: [3, 4],
		[4]: [3, 4],
		[3, 3]: [3, 4],
		[3, 4]: [3],
		[4, 4]: [],
		[3, 3, 3]: [3],
		[3, 3, 4]: [],
		[3, 3, 3, 3]: [],
	}
	
	var exceptions = []
	var isolated_region = get_isolated_region()
	
	if isolated_region != null:
		var prepared_regions = [isolated_region]
		var current_vertexs = [isolated_region.anchors.size()]
		var current_options = vertex_options[current_vertexs]
		
		while !current_options.is_empty():
			var neighbors = []
			
			for region in prepared_regions:
				for neighbor in region.neighbors:
					if !neighbors.has(neighbor) and !prepared_regions.has(neighbor) and !exceptions.has(neighbor) and current_options.has(neighbor.anchors.size()):
						neighbors.append(neighbor)
			
			neighbors = neighbors.filter(func (a): return a.domain == null and !a.failure_flag)
			neighbors.sort_custom(func(a, b): return a.vacant_neighbors < b.vacant_neighbors)
			
			if !neighbors.is_empty():
				var min_count = neighbors.front().vacant_neighbors
				neighbors = neighbors.filter(func (a): return a.vacant_neighbors == min_count)
				var prepared_neighbor = neighbors.pick_random()
				prepared_regions.append(prepared_neighbor)
				current_vertexs.append(prepared_neighbor.anchors.size())
				current_vertexs.sort()
				current_options = vertex_options[current_vertexs]
			else:
				var exception = prepared_regions.pop_back()
				exceptions.append(exception)
				current_vertexs.pop_back()
				current_options = vertex_options[current_vertexs]
				
				if current_options.is_empty():
					isolated_region.failure_flag = true
					
					for prepared_region in prepared_regions:
						prepared_region.color = Color.DIM_GRAY
						prepared_region.failure_flag = true
					
					return prepared_regions
		
		return prepared_regions
	
	return []
	
func get_isolated_region() -> Variant:
	var isolated_regions = regions.get_children()
	
	if domains.get_child_count() > 0:
		isolated_regions = isolated_regions.filter(func (a): return a.vacant_flag and a.domain == null and !a.failure_flag)
	
	if isolated_regions.is_empty():
		return null
	
	isolated_regions.sort_custom(func(a, b): return a.vacant_neighbors < b.vacant_neighbors)
	var min_count = isolated_regions.front().vacant_neighbors
	isolated_regions = isolated_regions.filter(func (a): return a.vacant_neighbors == min_count)
	var region = isolated_regions.pick_random()
	return region
	
func add_domain(regions_: Array) -> void:
	if regions_.is_empty():
		return
		
	if regions_.front().failure_flag:
		return
	
	var domain = domain_scene.instantiate()
	
	for region in regions_:
		domain.add_region(region)
	
	domain.lattice = self
	domains.add_child(domain)
	domain.capital = capital_scene.instantiate()
	domain.capital.domain = domain
	capitals.add_child(domain.capital)
	
func fix_failure_regions() -> void:
	var failure_regions = regions.get_children().filter(func (a): return a.failure_flag)
	
	for failure_region in failure_regions:
		var neighbor_domains = []
		
		for neighbor in failure_region.neighbors:
			if !neighbor_domains.has(neighbor.domain) and neighbor.domain != null:
				neighbor_domains.append(neighbor.domain)
		
		neighbor_domains.sort_custom(func (a, b): return a.acreage < b.acreage)
		var neighbor_domain = neighbor_domains.front()
		neighbor_domain.add_region(failure_region)
		neighbor_domain.update_acreage()
	
func init_roads() -> void:
	var capital_pairs = []
	
	for domain in domains.get_children():
		for neighbor in domain.domain_borders:
			var capital_pair = [domain.capital, neighbor.capital]
			capital_pair.sort_custom(func (a, b): return a.domain.get_index() > b.domain.get_index())
			
			if !capital_pairs.has(capital_pair):
				capital_pairs.append(capital_pair)
	
	for capital_pair in capital_pairs:
		add_road(capital_pair)
	
func add_road(capitals_: Array) -> void:
	var road = road_scene.instantiate()
	road.capitals.append_array(capitals_)
	road.lattice = self
	roads.add_child(road)
	
func init_sources() -> void:
	for anchor in anchors.get_children():
		add_source(anchor)
		
func add_source(anchor_: Anchor) -> void:
	var source = source_scene.instantiate()
	source.anchor = anchor_
	sources.add_child(source)
	
func init_biomes() -> void:
	var source_acreage = 0
	
	for source in sources.get_children():
		source_acreage += source.acreage
	
	var biome_sizes = {}
	biome_sizes["desert"] = ["average", "small", "small"]
	biome_sizes["mountain"] = ["average", "small", "small"]
	biome_sizes["plain"] = ["large"]
	biome_sizes["swamp"] = ["average", "small", "small"]
	biome_sizes["forest"] = ["average", "small", "small"]
	var share_size = {}
	share_size["large"] = 5
	share_size["average"] = 3
	share_size["small"] = 1
	var total_shares = 0
	var biome_acreages = {}
	
	for biome_terrain in biome_sizes:
		for size_type in biome_sizes[biome_terrain]:
			total_shares += share_size[size_type]
	
	for biome_terrain in biome_sizes:
		var biome_share = 0
		
		for size_type in biome_sizes[biome_terrain]:
			biome_share += share_size[size_type]
		
		biome_acreages[biome_terrain] = float(biome_share) / total_shares * source_acreage
	
	var biome_vertexs = {}
	biome_vertexs["desert"] = [Vector2(0, 1), Vector2(-0.4, -1), Vector2(0.6, -1)]
	biome_vertexs["mountain"] = [Vector2(1, 0), Vector2(-1, -0.85), Vector2(-1, 0.5)]
	biome_vertexs["plain"] = [Vector2(0, 0)]
	biome_vertexs["swamp"] = [Vector2(-1, 0), Vector2(1, -0.5), Vector2(1, 0.85)]
	biome_vertexs["forest"] = [Vector2(0, -1), Vector2(-0.6, 1), Vector2(0.4, 1)]
	
	var biome_anchor_options = {}
	
	for biome_terrain in biome_vertexs:
		biome_anchor_options[biome_terrain] = {}
		
		for biome_vertex in biome_vertexs[biome_terrain]:
			biome_anchor_options[biome_terrain][biome_vertex] = []
	
	var max_d = center_position.length() / n_dimension * 0.75
	var biome_options = {}
	var unoccupied_anchors = anchors.get_children()
	
	for anchor in anchors.get_children():
		if anchor.flag_side:
			var biome_flag = false
			
			for biome_terrain in biome_vertexs:
				if !biome_flag:
					for biome_vertex in biome_anchor_options[biome_terrain]:
						var d = (center_position - anchor.position).distance_to(biome_vertex * center_position * 0.5)
						
						if d < max_d:
							biome_anchor_options[biome_terrain][biome_vertex].append(anchor)
							biome_flag = true
							break
	
	for anchor in anchors.get_children():
		for biome_vertex in biome_anchor_options["plain"]:
			var d = (center_position - anchor.position).distance_to(biome_vertexs["plain"].front() * center_position * 0.5)
			
			if d < max_d:
				biome_anchor_options["plain"][biome_vertex].append(anchor)
	
	for biome_terrain in biome_vertexs:
		for _i in biome_anchor_options[biome_terrain].keys().size():
			var biome_size = biome_sizes[biome_terrain][_i]
			var biome_vertex = biome_anchor_options[biome_terrain].keys()[_i]
			biome_anchor_options[biome_terrain][biome_vertex].shuffle()
			var anchor = biome_anchor_options[biome_terrain][biome_vertex].pop_back()
			
			while anchor.source.biome != null:
				anchor = biome_anchor_options[biome_terrain][biome_vertex].pop_back()
			
			if anchor != null:
				var biome = add_biome(biome_terrain, anchor, biome_size)
				biome_acreages[biome_terrain] -= anchor.source.acreage
				add_to_biome_options(biome_options, unoccupied_anchors, anchor, biome)
	
	for biome in biomes.get_children():
		erase_from_biome_options(biome_options, unoccupied_anchors, biome.sources.front().anchor)
	
	var biomes_ordered = biomes.get_children()
	biomes_ordered.shuffle()
	biomes_ordered.sort_custom(func(a, b): return share_size[a.size] < share_size[b.size])
	var counter_unoccupied = unoccupied_anchors.size()
	var counter_prevented = unoccupied_anchors.size()
	
	while counter_unoccupied > 0 and counter_prevented > 0:
		counter_prevented -= 1
		
		if biomes_ordered.is_empty():
			counter_unoccupied = 0
		
		var next_biomes = biomes_ordered.duplicate()
		
		while !next_biomes.is_empty():
			var biome = next_biomes.pop_back()
			
			if counter_unoccupied > 0:
				for _i in share_size[biome.size]:
					if biome_options.keys().has(biome):
						var anchor = null
						
						if !biome_options[biome].is_empty():
							anchor = biome_options[biome].pick_random()
						
						if anchor == null:
							biome_options.erase(biome)
						else:
							counter_unoccupied -= 1
							biome.add_source(anchor.source)
							biome_acreages[biome.terrain] -= anchor.source.acreage
							erase_from_biome_options(biome_options, unoccupied_anchors, anchor)
							add_to_biome_options(biome_options, unoccupied_anchors, anchor, biome)
						
						if biome_acreages[biome.terrain] <= 0:
							for _j in range(biomes_ordered.size() - 1, -1, -1):
								if biomes_ordered[_j].terrain == biome.terrain:
									var biome_ = biomes_ordered[_j]
									biomes_ordered.erase(biome_)
									biome_options.erase(biome_)
					else:
						break
	
	while !unoccupied_anchors.is_empty():
		var anchor = unoccupied_anchors.pop_front()
		var neighbor_biomes = []
		
		for neighbor in anchor.neighbors:
			if neighbor.source.biome != null and !neighbor_biomes.has(neighbor.source.biome):
				neighbor_biomes.append(neighbor.source.biome)
		
		if neighbor_biomes.is_empty():
			unoccupied_anchors.append(anchor)
		else:
			var biome = neighbor_biomes.pick_random()
			biome.add_source(anchor.source)
	
	var terrain_acreages = {}
	
	for biome in biomes.get_children():
		biome.update_acreage()
		
		if !terrain_acreages.has(biome.terrain):
			terrain_acreages[biome.terrain] = 0
		
		terrain_acreages[biome.terrain] += biome.acreage / source_acreage
	
	var ordered_terrains = terrain_acreages.keys()
	ordered_terrains.sort_custom(func (a, b): return terrain_acreages[a] > terrain_acreages[b])
	
func add_biome(biome_terrain_: String, anchor_: Anchor, biome_size_: String) -> Biome:
	var biome = biome_scene.instantiate()
	biome.lattice = self
	biome.terrain = biome_terrain_
	biome.size = biome_size_
	biome.add_source(anchor_.source)
	biomes.add_child(biome)
	return biome
	
func erase_from_biome_options(biome_options_:Dictionary, unoccupied_anchors_: Array, anchor_: Anchor) -> void:
	unoccupied_anchors_.erase(anchor_)
	
	for biome in biome_options_:
		biome_options_[biome] = biome_options_[biome].filter(func(a): return unoccupied_anchors_.has(a))
	
func add_to_biome_options(biome_options_:Dictionary, unoccupied_anchors_: Array, anchor_: Anchor, biome_: Biome) -> void:
	if biome_.sources.size() == 1:
		biome_options_[biome_] = []
		biome_options_[biome_].append_array(anchor_.neighbors.keys())
	else:
		for neighbor in anchor_.neighbors:
			if unoccupied_anchors_.has(neighbor) and neighbor.source.biome == null:
				biome_options_[biome_].append(neighbor)
#func get_next_biome_anchor(unoccupied_anchors_: Array, biome_: Biome) -> Variant:
	#if unoccupied_anchors_[biome_].is_empty():
		#return null
	#
	#return unoccupied_anchors_[biome_].pick_random()
	
func init_energy() -> void:
	var unoccupied_regions = regions.get_children()
	var waves = []
	var next_wave = []
	var max_noise = 0.0
	var min_noise = 1.0
	
	for region in regions.get_children():
		var noise_value = terrain_noise.get_noise_2dv(region.center)
		
		if noise_value > max_noise:
			max_noise = noise_value
		if noise_value < min_noise:
			min_noise = noise_value
		
		var region_biomes = []
		
		for anchor in region.anchors:
			if !region_biomes.has(anchor.source.biome):
				region_biomes.append(anchor.source.biome)
		
		region.visible = false
		
		if region_biomes.size() > 2:
			next_wave.append(region)
	
	waves.append(next_wave)
	unoccupied_regions = unoccupied_regions.filter(func(a): return !next_wave.has(a))
	var stopper = 10
	
	while stopper > 0 and !unoccupied_regions.is_empty():
		stopper -= 1
		var previous_wave = waves.back()
		next_wave = []
		
		for region in previous_wave:
			for neighbor in region.neighbors:
				if unoccupied_regions.has(neighbor) and !next_wave.has(neighbor):
					next_wave.append(neighbor)
		
		if next_wave.is_empty():
			stopper = 0
		else:
			waves.append(next_wave)
			unoccupied_regions = unoccupied_regions.filter(func(a): return !next_wave.has(a))
		
	for _i in waves.size():
		var wave = waves[_i]
		var wave_weight = 1.0 / (waves.size() - 1) * _i
		
		for region in wave:
			var noise_weight = remap(terrain_noise.get_noise_2dv(region.center), min_noise, max_noise, 0, 1)
			var v = (wave_weight * 4 + noise_weight * 3) / 7
			#region.color = Color.from_hsv(0.0, 0.0, v)
			#region.visible = true
			#region.energy = ceil(pow(1.0 + float(_i + 1) / waves.size(), 3) * 12.5)
			region.energy = ceil(pow(1.0 + v, 3) * 12.5)
	
	for source in sources.get_children():
		for region in source.anchor.regions:
			source.energy += region.energy / region.anchors.size()
	
	#recolor_sources_by_energy()
	#recolor_regions_by_energy()
	
func recolor_regions_by_energy() -> void:
	var max_energy = 0.0
	var min_energy = regions.get_child(0).energy
	
	for region in regions.get_children():
		if max_energy < region.energy:
			max_energy = region.energy
		if min_energy > region.energy:
			min_energy = region.energy
	
	for region in regions.get_children():
		region.visible = true
		var energy_weight = remap(region.energy, min_energy, max_energy, 0, 1)
		region.color = Color.from_hsv(0.0, 0.0, energy_weight)
	
func recolor_sources_by_energy() -> void:
	var h = 360.0
	var hues = {}
	hues["desert"] = 60.0 / h
	hues["mountain"] = 210.0 / h
	hues["plain"] = 30.0 / h
	hues["swamp"] = 270.0 / h
	hues["forest"] = 120.0 / h
	
	var max_energy = 0.0
	var min_energy = regions.get_child(0).energy * 4
	
	for source in sources.get_children():
		if max_energy < source.energy:
			max_energy = source.energy
		if min_energy > source.energy:
			min_energy = source.energy
	
	for source in sources.get_children():
		var energy_weight = remap(source.energy, min_energy, max_energy, 0, 1)
		source.color = Color.from_hsv(hues[source.biome.terrain], 0.8, energy_weight)
	
func init_lairs() -> void:
	var source_acreage = 0
	var exceptions = []
	
	for source in sources.get_children():
		source_acreage += source.acreage
	
	var elements_limit = {}
	
	for element in Global.dict.color.element:
		elements_limit[element] = source_acreage / Global.dict.color.element.keys().size()
	
	for source in sources.get_children():
		source.roll_element(exceptions)
		elements_limit[source.element] -= source.acreage
		
		if elements_limit[source.element] <= 0:
			#elements_limit.erase(source.element)
			exceptions.append(source.element)
	
	#var elements = {}
	#
	#for source in sources.get_children():
		#if !elements.has(source.element):
			#elements[source.element] = 0
		#
		#elements[source.element] += source.acreage / source_acreage * 100
	
	#var avg_acreage = 0
	#print(source_acreage/ sources.get_child_count())
	
	var min_concentration = 1000
	var avg_concentration = 0
	var max_concentration = 0
	
	for lair in lairs.get_children():
		avg_concentration += lair.concentration / lairs.get_child_count()
		
		if lair.concentration > max_concentration:
			max_concentration = lair.concentration
		if lair.concentration < min_concentration:
			min_concentration = lair.concentration
	
	print([min_concentration, avg_concentration, max_concentration])
	var beasts = {}
	
	for lair in lairs.get_children():
		if !beasts.has(lair.beast):
			beasts[lair.beast] = {}
			beasts[lair.beast].total = 0
		
		if !beasts[lair.beast].has(lair.source.element):
			beasts[lair.beast][lair.source.element] = 0
		
		beasts[lair.beast].total += 1
		beasts[lair.beast][lair.source.element] += 1
	
func add_lair(source_: Source, acreage_: float, beast_: String) -> void:
	var lair = lair_scene.instantiate()
	lair.source = source_
	lair.acreage = acreage_
	lair.beast = beast_
	lairs.add_child(lair)
	source_.lairs.append(lair)
	
func init_skills() -> void:
	pass
