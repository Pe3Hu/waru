class_name SkillResource
extends Resource


var technique: TechniqueResource

var defects: Array[DefectResource]

var size: Vector2i

var weight: int = 0
var cooldown: int


func _init(technique_: TechniqueResource, size_: Vector2i) -> void:
	technique = technique_
	size = size_
	cooldown = randi_range(3, 5)
	
	init_defects()
	
func init_defects() -> void:
	var x = randi_range(1, size.x - 1)
	var defect_sizes = [Vector2i(x, size.y), Vector2i(size.x - x, size.y)]
	var aspect_pair = Global.arr.aspect_pair.pick_random()
	
	for _i in aspect_pair.size():
		var defect_size = defect_sizes[_i]
		var defect_aspect = aspect_pair[_i]
		add_defect(defect_aspect, defect_size)
	
func add_defect(aspect_: String, size_: Vector2i) -> void:
	var defect = DefectResource.new(self, aspect_, size_)
	defects.append(defect)
	weight += defect.value
