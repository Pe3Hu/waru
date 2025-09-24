class_name SourceInfo
extends PanelContainer


@export var expedition: Expedition

@onready var lair_scene = preload("res://entities/expedition/info/lair/lair.tscn")
@onready var rings = %Rings
@onready var ring_panel = %RingPanel
#@onready var ring_0 = %Ring0
#@onready var ring_1 = %Ring1
#@onready var ring_2 = %Ring2

var source: Source:
	set(value_):
		source = value_
		visible = source != null
		
		%Terrain.text = source.resource.biome.terrain
		%Element.text = source.resource.element
		#update_lairs()
		update_habitats()
		#update_rings()


func _ready() -> void:
	ring_panel.custom_minimum_size = Vector2.ONE * expedition.lattice.resource.ring_l
	rings.position = ring_panel.custom_minimum_size * 0.5
	pass
	
#func update_rings() -> void:
	#for _i in source.resource.ring_lairs:
		#var ring = get_node("%Ring" + str(_i))
		#var colors = []
		#var shares = []
		#
		#for lair in source.resource.ring_lairs[_i]:
			#colors.append(Global.dict.color.element[lair.breed.element])
			#shares.append(lair.acreage / lair.source.ring_acreages[_i])
		#
		#if shares.size() > 1:
			#shares.pop_back()
		#else:
			#shares[0] += 0.1
		#
		#pass
		#ring.material.set_shader_parameter('num_colors',source.resource.ring_lairs[_i].size())
		#ring.material.set_shader_parameter('colors',colors)
		#ring.material.set_shader_parameter('shares',shares)
	
#func update_lairs_old() -> void:
	#var index = 0
	#
	#while lairs.get_child_count() > 0:#source.resource.lairs.size():
		#var lair = lairs.get_child(0)
		#lairs.remove_child(lair)
		#lair.queue_free()
	#
	#for _i in source.resource.ring_lairs:
		#for lair_resource in source.resource.ring_lairs[_i]:
			#var lair
			#
			#if lairs.get_child_count() > index:
				#lair = lairs.get_child(index)
			#else:
				#lair = lair_scene.instantiate()
				#lair.source_info = self
				#lair.resource = lair_resource
				#lairs.add_child(lair)
			#
			##lair.resou
			#index += 1
	#
	##var a = lairs.get_child_count()
	#pass
	#
	
func update_habitats() -> void:
	for _i in source.resource.rings.size():
		var ring = %Rings.get_child(_i)
		ring.resource = source.resource.rings[_i]
