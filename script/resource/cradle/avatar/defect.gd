class_name DefectResource
extends Resource


var skill: SkillResource

var size: Vector2i

var value: int

var aspect: String


func _init(skill_: SkillResource, aspect_: String, size_: Vector2i) -> void:
	skill = skill_
	aspect = aspect_
	size = size_
	value = size.x * size.y#value = round(sqrt(size.x * size.y))
