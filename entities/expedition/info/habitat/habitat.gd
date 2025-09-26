class_name Habitat
extends Area2D


@export var ring: Ring

var resource: HabitatResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	var l = float(resource.ring.source.habaitat_count)
	var hue = (resource.hue_index) / l
	%Kind.color = Color.from_hsv(hue, 0.8, 0.8)
	%Kind.polygon = resource.vertexs
	
	for vertex in resource.border_vertexs:
		%Border.add_point(vertex)
	#%CollisionPolygon2D.polygon = %Kind.polygon
	
	var shifeted_vertexs = []
	
	for vertex in resource.vertexs:
		shifeted_vertexs.append(vertex + Vector2(0, 200))
	
	%CollisionPolygon2D.polygon = shifeted_vertexs
	#
	if resource.vertexs.is_empty():
		pass
	pass



func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("click"):
		print([resource.ring.order, resource.index, resource.lair.breed.kind])
		resource.ring.print_vertexs()
	
