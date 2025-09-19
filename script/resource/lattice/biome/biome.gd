class_name BiomeResource
extends Resource


@export_enum("desert", "mountain", "plain", "swamp", "forest") var terrain

var lattice: LatticeResource

var sources: Array[SourceResource]

var size: String

var acreage: float


func add_source(source_: SourceResource) -> void:
	if sources.has(source_):
		pass
	if source_.biome != null:
		pass
	
	sources.append(source_)
	source_.biome = self
	pass
	
func update_acreage() -> void:
	acreage = 0
	
	for source in sources:
		acreage += source.acreage
