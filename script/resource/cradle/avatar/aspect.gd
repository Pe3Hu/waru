class_name AspectResource
extends Resource


var avatar: AvatarResource

var type: String

var max_value: int
var current_value: int


func _init(avatar_: AvatarResource, type_: String, value_: int) -> void:
	avatar = avatar_
	type = type_
	max_value = value_
	current_value = value_
