class_name AvatarResource
extends Resource


var cradle: CradleResource
var technique: TechniqueResource

var aspects: Dictionary

var type: String


func _init(cradle_: CradleResource, type_: String) -> void:
	cradle = cradle_
	type = type_
	
	init_aspects()
	technique = TechniqueResource.new(self)
	
func init_aspects() -> void:
	var aspects_values = {}
	
	for aspect in Global.arr.aspect:
		aspects_values[aspect] = cradle.aspect_base_value
	
	var limit_value = int(cradle.aspect_rnd_value)
	var rnd_aspcets = Global.arr.aspect.duplicate()
	rnd_aspcets.shuffle()
	
	while limit_value > 0:
		var aspect = rnd_aspcets.pop_back()
		var rnd_value = randi_range(0, floor(limit_value * 0.5))
		
		if rnd_aspcets.is_empty():
			rnd_value = limit_value
		
		limit_value -= rnd_value
		aspects_values[aspect] += rnd_value
		
	
	for aspect in aspects_values:
		add_aspect(aspect, aspects_values[aspect])
	
func add_aspect(type_: String, value_: int) -> void:
	var aspect = AspectResource.new(self, type_, value_)
	aspects[type_] = aspect 
	
