class_name Lair
extends Area2D


var source_info: SourceInfo

var resource: LairResource:
	set(value_):
		resource = value_
		
		init_vertexs()


func init_vertexs() -> void:
	var long = (resource.ring + 1) * 0.33 * source_info.lair_l
	var short = resource.ring * 0.33  * source_info.lair_l
	var angles = []
	var lengths = []
	
	if resource.source.ring_lairs[resource.ring].size() == 1:
		#long = 0.5 * source_info.lair_l
		var n = 4
		
		for _i in n :
			angles.append(PI * 2 / n  * _i)
			lengths.append(long)
	else:
		var ring_index = resource.source.ring_lairs[resource.ring].find(resource)
		var start_angle = -PI / 2
		
		for _i in ring_index:
			var previous_lair = resource.source.ring_lairs[resource.ring][_i]
			start_angle += previous_lair.acreage / resource.source.ring_acreages[resource.ring] * PI * 2
		
		var end_angle = resource.acreage / resource.source.ring_acreages[resource.ring] * PI * 2
		end_angle += start_angle
		angles = [start_angle, end_angle, end_angle, start_angle]
		lengths = [long, long, short, short]
	
	var vertexs = []
	
	for _i in angles.size():
		var angle = angles[_i]
		var length = lengths[_i]
		var vertex = Vector2.from_angle(angle) * length
		vertexs.append(vertex)
		%Outline.add_point(vertex)
	
	
	%CollisionPolygon2D.polygon = vertexs
	%Terrain.polygon = vertexs
	%Terrain.color = Global.dict.color.element[resource.breed.element]
