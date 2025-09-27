class_name LatticeResource
extends Resource


var cradle: CradleResource

var anchors: Array[AnchorResource]
var regions: Array[RegionResource]
var domains: Array[DomainResource]
var borders: Array[BorderResource]
var capitals: Array[CapitalResource]
var roads: Array[RoadResource]
var sources: Array[SourceResource]
var biomes: Array[BiomeResource]
var lairs: Array[LairResource]

var clusters: Dictionary
var anchor_borders: Dictionary
var breeds: Dictionary

var dimensions: Vector2i
var center_position: Vector2

var anchor_r: float = 6
var grid_step: float = 50
var avg_lair_acreage: float = 100
var lair_ring_factor: float = 0.5

var ring_l: float = 180
var habitat_l: float
var habitat_r: float

var n_dimension: int = 7
var border_width: int = 3
var lair_count_limit: int = 16

var terrain_noise: FastNoiseLite = FastNoiseLite.new()
var defected_source: SourceResource


func _init(cradle_resource_: CradleResource) -> void:
	cradle = cradle_resource_
	cradle.lattice = self
	
	habitat_l = ring_l / 5
	habitat_r = habitat_l * sqrt(2) / 2
	dimensions = Vector2i.ONE * n_dimension
	
	init_anchors()
	init_regions()
	
	rnd_shift_anchors()
	init_borders()
	init_domains()
	init_roads()
	
	init_sources()
	init_biomes()
	init_energy()
	
	init_indexs()
	
	init_lairs()
	init_flocks()
	
func init_anchors() -> void:
	var vector = Vector2()
	add_anchor(vector)
	
	for _i in dimensions.y:
		add_cluster_row()
	
	var no_corner = clusters[0][dimensions.x - 1][4].position
	var sw_corner = clusters[dimensions.y - 1][0][1].position
	center_position = (no_corner + sw_corner) / 2
	
func add_cluster_row() -> void:
	var row_index = clusters.keys().size()
	clusters[row_index] = []
	var anchor
	
	if row_index == 0:
		anchor = anchors[0]
	else:
		var vector = clusters[row_index - 1].front()[1].position + Vector2.from_angle(PI / 3) * grid_step
		anchor = add_anchor(vector)
	
	if !clusters[row_index].is_empty():
		anchor = clusters[row_index].back().back()
	
	add_cluster(anchor) 
	
	for _i in dimensions.x - 1:
		add_cluster(clusters[row_index].back().back())
	
func add_cluster(anchor_: AnchorResource) -> void:
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
	
func add_anchor(vector_: Vector2) -> AnchorResource:
	var anchor = AnchorResource.new()
	anchor.lattice = self
	anchors.append(anchor)
	anchor.position = vector_
	return anchor
	
func init_regions() -> void:
	for _row in clusters:
		if _row + 1 < clusters.size():
			for _col in clusters[_row].size():
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
	
	var region = RegionResource.new()
	region.anchors.append_array(anchors_)
	region.lattice = self
	regions.append(region)
	
func check_acnhor_in_corners(anchor_: AnchorResource) -> bool:
	var no_corner = clusters[0][dimensions.x - 1][4].position
	var sw_corner = clusters[dimensions.y - 1][0][1].position
	return anchor_.position.x <= no_corner.x and anchor_.position.x >= sw_corner.x and anchor_.position.y >= no_corner.y and anchor_.position.y <= sw_corner.y
	
func rnd_shift_anchors() -> void:
	for region in regions:
		region.rnd_shift_anchors()
	
func init_borders() -> void:
	for region in regions:
		region.init_borders()
	
	for region in regions:
		region.update_acreage()
	
	for anchor in anchors:
		anchor.update_side_flag()
	
func add_border(region_: RegionResource, anchors_: Array[AnchorResource]) -> void:
	anchors_.sort_custom(func(a, b): return anchors.find(a) < anchors.find(b))
	var border
	
	if !anchor_borders.has(anchors_):
		border = BorderResource.new()
		border.anchors.append_array(anchors_)
		anchor_borders[anchors_] = border
		border.lattice = self
		borders.append(border)
	else:
		border = anchor_borders[anchors_]
	
	border.add_region(region_)
	
func init_domains() -> void:
	for region in regions:
		region.update_count_vacant_neighbors()
	
	var prepared_regions = prepare_regions_for_domain()
	var options = regions.duplicate()
	var failures = []
	var counter_unoccupied = regions.size()
	
	while !options.is_empty() and counter_unoccupied > 0:
		counter_unoccupied -= 1
		
		for prepared_region in prepared_regions:
			options.erase(prepared_region)
			
			if prepared_region.failure_flag:
				failures.append(prepared_region)
		
		add_domain(prepared_regions)
		prepared_regions = prepare_regions_for_domain()
	
	fix_failure_regions()
	
	for domain in domains:
		domain.init_borders()
		domain.capital.calc_position()
	
	for _i in range(anchors.size()-1,-1,-1):
		var anchor = anchors[_i]
		
		if anchor.regions.is_empty():
			anchors.erase(anchor)
	
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
	var isolated_regions = regions
	
	if domains.size() > 0:
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
	
	var domain = DomainResource.new()
	
	for region in regions_:
		domain.add_region(region)
	
	domain.lattice = self
	domains.append(domain)
	domain.capital = CapitalResource.new()
	domain.capital.domain = domain
	capitals.append(domain.capital)
	
func fix_failure_regions() -> void:
	var failure_regions = regions.filter(func (a): return a.failure_flag)
	
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
	
	for domain in domains:
		for neighbor in domain.domain_borders:
			var capital_pair = [domain.capital, neighbor.capital]
			capital_pair.sort_custom(func (a, b): return domains.find(a.domain) > domains.find(b.domain))
			
			if !capital_pairs.has(capital_pair):
				capital_pairs.append(capital_pair)
	
	for capital_pair in capital_pairs:
		add_road(capital_pair)
	
func init_indexs() -> void:
	for _i in anchors.size():
		var anchor = anchors[_i]
		anchor.index = _i
	
func add_road(capitals_: Array) -> void:
	var road = RoadResource.new()
	road.capitals.append_array(capitals_)
	road.lattice = self
	roads.append(road)
	
func init_sources() -> void:
	for anchor in anchors:
		add_source(anchor)
	
func add_source(anchor_: AnchorResource) -> void:
	var source = SourceResource.new()
	source.anchor = anchor_
	sources.append(source)
	
func init_biomes() -> void:
	var source_acreage = 0
	
	for source in sources:
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
	var unoccupied_anchors = anchors.duplicate()
	
	for anchor in anchors:
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
	
	for anchor in anchors:
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
	
	for biome in biomes:
		erase_from_biome_options(biome_options, unoccupied_anchors, biome.sources.front().anchor)
	
	var biomes_ordered = biomes.duplicate()
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
	
	
	var stopper = unoccupied_anchors.size()
	
	while !unoccupied_anchors.is_empty() and stopper > 0:
		stopper -= 1
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
	
	for biome in biomes:
		biome.update_acreage()
		
		if !terrain_acreages.has(biome.terrain):
			terrain_acreages[biome.terrain] = 0
		
		terrain_acreages[biome.terrain] += biome.acreage / source_acreage
	
	var ordered_terrains = terrain_acreages.keys()
	ordered_terrains.sort_custom(func (a, b): return terrain_acreages[a] > terrain_acreages[b])
	
func add_biome(biome_terrain_: String, anchor_: AnchorResource, biome_size_: String) -> BiomeResource:
	var biome = BiomeResource.new()
	biome.lattice = self
	biome.terrain = biome_terrain_
	biome.size = biome_size_
	biome.add_source(anchor_.source)
	biomes.append(biome)
	return biome
	
func erase_from_biome_options(biome_options_:Dictionary, unoccupied_anchors_: Array, anchor_: AnchorResource) -> void:
	unoccupied_anchors_.erase(anchor_)
	
	for biome in biome_options_:
		biome_options_[biome] = biome_options_[biome].filter(func(a): return unoccupied_anchors_.has(a))
	
func add_to_biome_options(biome_options_:Dictionary, unoccupied_anchors_: Array, anchor_: AnchorResource, biome_: BiomeResource) -> void:
	if biome_.sources.size() == 1:
		biome_options_[biome_] = []
		biome_options_[biome_].append_array(anchor_.neighbors.keys())
	else:
		for neighbor in anchor_.neighbors:
			if unoccupied_anchors_.has(neighbor) and neighbor.source.biome == null:
				biome_options_[biome_].append(neighbor)
	
func init_energy() -> void:
	var unoccupied_regions = regions
	var waves = []
	var next_wave = []
	var max_noise = 0.0
	var min_noise = 1.0
	
	for region in regions:
		var noise_value = terrain_noise.get_noise_2dv(region.center)
		
		if noise_value > max_noise:
			max_noise = noise_value
		if noise_value < min_noise:
			min_noise = noise_value
		
		var region_biomes = []
		
		for anchor in region.anchors:
			if !region_biomes.has(anchor.source.biome):
				region_biomes.append(anchor.source.biome)
		
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
			region.energy = ceil(pow(1.0 + v, 3) * 12.5)
	
	for source in sources:
		for region in source.anchor.regions:
			source.energy += region.energy / region.anchors.size()
	
func init_lairs() -> void:
	var source_acreage = 0
	var exceptions = []
	
	for source in sources:
		source_acreage += source.acreage
	
	var elements_limit = {}
	
	for element in Global.dict.color.element:
		elements_limit[element] = source_acreage / Global.dict.color.element.keys().size()
	
	for source in sources:
		source.roll_element(exceptions)
		elements_limit[source.element] -= source.acreage
		
		if elements_limit[source.element] <= 0:
			exceptions.append(source.element)
	
	var sizes = {}
	
	for source in sources:
		if !sizes.has(source.lairs.size()):
			sizes[source.lairs.size()] = 0
		
		sizes[source.lairs.size()] += 1
	
	fix_defect_ring()
	
func add_lair(source_: SourceResource, acreage_: float, kind_: String) -> void:
	var breed = null
	
	if !breeds.has(kind_):
		breeds[kind_] = {}
		
	if breeds[kind_].has(source_.element):
		breed = breeds[kind_][source_.element]
	else:
		breed = BreedResource.new()
		breed.kind = kind_
		breed.element = source_.element
		breeds[breed.kind][breed.element] = breed
	
	var lair = LairResource.new()
	lair.source = source_
	lair.breed = breed
	lair.acreage = acreage_
	lairs.append(lair)
	source_.lairs.append(lair)
	
	#lair.add_flock()
	
func init_flocks() -> void:
	for lair in lairs:
		lair.spread_energy()
	
func init_skills() -> void:
	pass
	
func find_defect_ring() -> void:
	#for source in sources:
		#if check_defect_in_last(source.rings[2]):
			#defected_source = source
			#return
	
	
	for source in sources:
		if check_defect_in_corner(source.rings[2]):
			defected_source = source
			return
	
func fix_defect_ring() -> void:
	fix_last_habitat()
	#fix_corner_habitat()
	
func fix_last_habitat() -> void:
	for source in sources:
		if check_defect_in_last(source.rings[2]):
			source.rings[2].apply_not_optimal_solution_to_last()
	
func fix_corner_habitat() -> void:
	for source in sources:
		if check_defect_in_corner(source.rings[2]):
			source.rings[2].apply_not_optimal_solution_to_corner()
	
func check_defect_in_last(ring_: RingResource) -> bool:
	var begin_vertex = ring_.habitats.front().far_vertexs.front() 
	var end_vertex = ring_.habitats.back().far_vertexs.back() 
	
	return begin_vertex != end_vertex
	
func check_defect_in_corner(ring_: RingResource) -> bool:
	var begin_vertex = ring_.habitats[ring_.habitats.size() - 2].far_vertexs.front() 
	var end_vertex = ring_.habitats.back().far_vertexs.back() 
	
	return begin_vertex != end_vertex
