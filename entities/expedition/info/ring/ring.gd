class_name Ring
extends Node2D


@onready var habitat_scene = preload("res://entities/expedition/info/habitat/habitat.tscn")

@export var resource: RingResource:
	set(value_):
		resource = value_
		
		update_habitats()


func update_habitats() -> void:
	while get_child_count() > 0:
		var habitat = get_child(0)
		remove_child(habitat)
		habitat.queue_free()
	
	for habitat_resource in resource.habitats:
		var habitat = habitat_scene.instantiate()
		habitat.resource = habitat_resource
		add_child(habitat)
