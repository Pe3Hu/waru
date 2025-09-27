class_name SourceInfo
extends PanelContainer


@export var expedition: Expedition

@onready var lair_scene = preload("res://entities/lattice/anchor/source/lair/lair.tscn")
@onready var rings = %Rings
@onready var ring_panel = %RingPanel
@onready var flock = %Flock


var source: Source:
	set(value_):
		source = value_
		visible = source != null
		
		%Terrain.text = source.resource.biome.terrain.capitalize()
		%Element.text = source.resource.element
		#%Energy.text = str(int(source.resource.energy))
		update_habitats()


func _ready() -> void:
	if expedition.lattice.resource != null:
		ring_panel.custom_minimum_size = Vector2.ONE * expedition.lattice.resource.ring_l
		ring_panel.size = ring_panel.custom_minimum_size
		rings.position = ring_panel.size * 0.5
	
func update_habitats() -> void:
	for _i in source.resource.rings.size():
		var ring = %Rings.get_child(_i)
		ring.resource = source.resource.rings[_i]
		
	flock.resource = %Rings.get_child(0).resource.habitats.front().lair.flock
