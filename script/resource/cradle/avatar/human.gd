class_name HumanResource
extends AvatarResource




func _init(cradle_: CradleResource) -> void:
	cradle = cradle_
	type = "human"
	
	init_aspects()
	technique = TechniqueResource.new(self)
