class_name LairResource
extends Resource


var source: SourceResource:
	set(value_):
		source = value_
		
		flock.lair = self
var breed: BreedResource
var habitat: HabitatResource
var flock: FlockResource = FlockResource.new()

var ring: int

var acreage: float
var concentration: float
var energy: float


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
	
func spread_energy() -> void:
	return
	#var free_energy = float(energy)
	#
	#for beast in flock.beasts:
		#free_energy -= beast.consumption
	#
	#while free_energy > 0:
		#var beast = flock.add_beast()
		#free_energy -= beast.consumption
