class_name LairResource
extends Resource


var source: SourceResource
var breed: BreedResource

var flocks: Array[FlockResource]

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
