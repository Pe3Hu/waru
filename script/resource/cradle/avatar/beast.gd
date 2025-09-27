class_name BeastResource
extends AvatarResource



var flock: FlockResource

var subtype: String

var consumption: float


func _init(cradle_: CradleResource, subtype_: String) -> void:
	cradle = cradle_
	subtype = subtype_
	type = "beast"
	consumption = Global.dict.beast.consumption[subtype] * randf_range(0.85, 1.15)
	
	init_aspects()
	technique = TechniqueResource.new(self)
