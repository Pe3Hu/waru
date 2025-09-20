class_name Source
extends Area2D


@onready var terrain = %Terrain
@onready var element = %Element
@onready var collision_polygon = %CollisionPolygon2D

@export var lattice: Lattice

var resource: SourceResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func _ready() -> void:
	collision_polygon.polygon = %Terrain.polygon
	
func init_vertexs() -> void:
	%Terrain.polygon = resource.vertexs
	var vertexs = []
	
	for point in resource.vertexs:
		var vertex = resource.center + (point - resource.center) * 0.7
		vertexs.append(vertex)
	
	%Element.polygon = vertexs
	
func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("click"):
		lattice.select_source(self)
	
