class_name SourceResource
extends Resource


var biome: BiomeResource
var anchor: AnchorResource:
	set(value_):
		anchor = value_
		
		anchor.source = self
		init_vertexs()
		update_acreage()

var lairs: Array[LairResource]
var vertexs: Array[Vector2]

var rings: Dictionary

var center = Vector2()

var element: String

var acreage: float
var energy: float

var habaitat_count: int = 0


func init_vertexs() -> void:
	for border in anchor.borders:
		var vertex = border.center
		vertexs.append(vertex)
		center += border.center / anchor.borders.keys().size()
	
	var temp_vertex = null
	
	if vertexs.size() == 3:
		temp_vertex = center + (anchor.position - center) * 2
		vertexs.append(temp_vertex)
	
	vertexs.sort_custom(func(a,b): return anchor.position.angle_to_point(a) < anchor.position.angle_to_point(b))
	
	if temp_vertex != null:
		var index = vertexs.find(temp_vertex)
		vertexs[index] = anchor.position
	
	if vertexs.size() == 2:
		vertexs.push_front(anchor.position)
	
func update_acreage() -> void:
	acreage = 0
	
	for _i in range(0, vertexs.size(), 1):
		var _j = (_i + 1) % vertexs.size()
		var points = [center, vertexs[_i], vertexs[_j]]
		acreage += Global.get_acreage_triangle(points)
	
func roll_element(exceptions_: Array) -> void:
	var options = {}
	
	for option in Global.dict.biome.title[biome.terrain]:
		if !exceptions_.has(option):
			options[option] = Global.dict.biome.title[biome.terrain][option]
	
	if options.keys().is_empty():
		options = Global.dict.biome.title[biome.terrain]
	
	element = Global.get_random_key(options)
	#%Element.color = Global.dict.color.element[element]
	init_lairs()
	init_rings()
	
func init_lairs() -> void:
	var free_acreage = float(acreage)
	var min_acreage = anchor.lattice.avg_lair_acreage * 0.75
	
	while free_acreage > min_acreage:
		var lair_acreage = min(free_acreage, randf_range(0.75, 1.25) * anchor.lattice.avg_lair_acreage)
		var beast_kind = Global.get_random_key(Global.dict.terrain.element[biome.terrain][element])
		anchor.lattice.add_lair(self, lair_acreage, beast_kind)
		free_acreage -= lair_acreage
	
	if biome.lattice.lair_count_limit <= lairs.size():
		var breeds = {}
		
		for lair in lairs:
			if !breeds.has(lair.breed):
				breeds[lair.breed] = []
			
			breeds[lair.breed].append(lair)
		
		var keys = breeds.keys()
		keys.sort_custom(func(a, b): return breeds[a].size() > breeds[b].size())
		var popular_breed = keys.front()
		
		while biome.lattice.lair_count_limit <= lairs.size():
			var lair = breeds[popular_breed].pop_back()
			lair.devastation()
	
	if 3 > lairs.size():
		var lair = lairs[0]
		lair.split()
	
	update_lairs_energy()
	
func update_lairs_energy() -> void:
	for lair in lairs:
		#lair.acreage = free_acreage / lairs.size()
		lair.energy = energy / lairs.size()
		lair.concentration = lair.energy / lair.acreage * 100
	
func init_rings() -> void:
	#var ring = RingResource.new()
	#ring.order = 0
	#ring.source = self
	#ring.init_habitats()
	#
	#ring = RingResource.new()
	#ring.order = 1
	#ring.source = self
	#ring.init_habitats()
	
	#ring = RingResource.new()
	#ring.order = 2
	#ring.source = self
	
	var ring_sizes = Global.dict.ring.size[lairs.size()]
	var lair_concentrations = lairs.duplicate()
	lair_concentrations.sort_custom(func (a, b): return a.concentration > b.concentration)
	
	var index = 0
	
	for _i in ring_sizes.size():
		var ring = RingResource.new()
		ring.order = _i
		ring.source = self
		rings[_i] = ring
		
		for _j in ring_sizes[_i]:
			#print([_i, _j, index])
			var lair = lair_concentrations[index]
			ring.lairs.append(lair)
			ring.acreage += lair.acreage
			index += 1
			lair.ring = _i
		
		ring.init_habitats()
