class_name CapitalResource
extends Resource


@export var domain: DomainResource

var roads: Dictionary

var position: Vector2


func calc_position() -> void:
	position = Vector2()
	
	for anchor in domain.anchors:
		position += anchor.position / domain.anchors.size()
