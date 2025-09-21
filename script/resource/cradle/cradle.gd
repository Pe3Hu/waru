class_name CradleResource
extends Resource


var avatars: Array[AvatarResource]

var ascensions: Dictionary
var defect_values: Dictionary

var n: int = 5
var limit_axis: int = 8
var limit_multiplication: int = 25
var aspect_base_value: int = 10
var aspect_rnd_value: int = 12


func _init() -> void:
	init_ascensions()
	init_avatars()
	
func init_ascensions() -> void:
	init_defect_values()
	add_ascension("human", 10)
	add_ascension("beast", 12)
	
func init_defect_values() -> void:
	for _i in range(2, limit_axis, 1):
		for _j in range(2, limit_axis, 1):
			var defect_value = _i * _j
			
			if defect_value <= limit_multiplication:
				var defect_size = Vector2i(_j, _i)
				
				if !defect_values.has(defect_value):
					defect_values[defect_value] = []
				
				defect_values[defect_value].append(defect_size)
	
func add_ascension(type_: String, a_: float) -> void:
	var ascension = AscensionResource.new(self, type_, a_)
	ascensions[type_] = ascension
	
func init_avatars() -> void:
	#var avatar = add_avatar("human")
	pass
	
func add_avatar(type_: String) -> AvatarResource:
	var avatar = AvatarResource.new(self, type_)
	avatars.append(avatar)
	
	return avatar
