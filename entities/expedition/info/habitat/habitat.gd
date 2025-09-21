class_name Habitat
extends Area2D


@export var ring: RingResource

var resource: HabitatResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	%Kind.color = Color.from_hsv(randf(), 0.8, 0.8)
	%Kind.polygon = resource.vertexs
	%CollisionPolygon2D.polygon = resource.vertexs
	pass
