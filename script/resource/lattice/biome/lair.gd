class_name LairResource
extends Resource


var source: SourceResource
var breed: BreedResource
var habitat: HabitatResource

var flocks: Array[FlockResource]

var ring: int

var acreage: float
var concentration: float
var energy: float


func add_flock() -> void:
	var flock = FlockResource.new()
	flock.lair = self
	flocks.append(flock)
	
func devastation() -> void:
	var split_acreage = acreage / (source.lairs.size() - 1)
	source.lairs.erase(self)
	
	for lair in source.lairs:
		lair.acreage += split_acreage
	
func split() -> void:
	var lair_acreage = acreage / 2
	acreage -= lair_acreage
	var beast_kind = breed.kind
	source.anchor.lattice.add_lair(source, lair_acreage, beast_kind)
