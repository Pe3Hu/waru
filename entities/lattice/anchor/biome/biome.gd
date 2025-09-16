class_name Biome
extends Node2D


@export_enum("desert", "mountain", "plain", "swamp", "forest") var terrain

var lattice: Lattice

var sources: Array[Source]

var size: String

var acreage: float


func add_source(source_: Source) -> void:
	if sources.has(source_):
		pass
	if source_.biome != null:
		pass
	
	sources.append(source_)
	source_.biome = self
	
func update_acreage() -> void:
	acreage = 0
	
	for source in sources:
		acreage += source.acreage
