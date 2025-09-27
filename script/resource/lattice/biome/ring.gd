class_name RingResource
extends Resource


var source: SourceResource:
	set(value_):
		source = value_
		
		source.rings[order] = self

var habitats: Array[HabitatResource]
var lairs: Array[LairResource]
var shapes: Array[String]

var order: int

var acreage: float


func init_habitats() -> void:
	if order == 0:
		var part = "ESWN0"
		var milestones = [0, 1]
		var habitat = HabitatResource.new()
		habitat.ring = self
		habitat.lair = lairs.front()
		habitat.add_shape(part, milestones)
		habitat.init_vertexs()
		return
	
	var total_acreage_shares = 0
	var acreage_shares = []
	acreage = 0
	
	for lair in lairs:
		acreage += lair.acreage
	
	for lair in lairs:
		var share = lair.acreage / acreage
		acreage_shares.append(share)
		total_acreage_shares += share
	
	var percents = []
	var percent_begin = 0.0
	
	for acreage_share in acreage_shares:
		var percent_end = float(acreage_share) / total_acreage_shares + percent_begin
		percents.append([percent_begin, percent_end])
		percent_begin = percent_end
		
	var rind_order = 1
	var parts = Global.dict.ring.windrose[rind_order].keys()
	var current_part = parts.front()
	var current_spread = 0
	var first_part = null
	var last_part = null
	var share_datas = []
	
	for _i in percents.size():
		var data = {}
		data.index = share_datas.size()
		data.first_offset = 0
		data.first_spread = 0
		data.last_spread = 0
		first_part = last_part
		var full_parts = []
		
		if !share_datas.is_empty():
			current_spread = share_datas.back().last_spread
		
		var percent_remainder = percents[_i][1] - percents[_i][0]
		
		var origin_part_percent = Global.dict.ring.windrose[rind_order][current_part]
		var part_percent = float(origin_part_percent)
		
		if first_part != null:
			data.first_offset = current_spread
			part_percent -= current_spread * part_percent
			data.first_spread = part_percent / origin_part_percent
			percent_remainder -= part_percent
			
			if data.first_offset + data.first_spread >= 1:
				var next_index = (parts.find(current_part) + 1) % parts.size()
				current_part = parts[next_index]
				
				if percent_remainder == 0:
					last_part = current_part
		
		while percent_remainder > 0:
			origin_part_percent = Global.dict.ring.windrose[rind_order][current_part]
			part_percent = float(origin_part_percent)
			
			if percent_remainder >= part_percent:
				percent_remainder -= part_percent
				full_parts.append(current_part)
				
				var next_index = (parts.find(current_part) + 1) % parts.size()
				current_part = parts[next_index]
				last_part = null
			else:
				data.last_spread = percent_remainder / origin_part_percent
				current_spread += float(data.last_spread)
				percent_remainder = 0
				last_part = current_part
		
		data.first_part = first_part
		data.full_parts = full_parts
		data.last_part = last_part
			
		share_datas.append(data)
		
	for _i in share_datas.size():
		var data = share_datas[_i]
		var habitat = HabitatResource.new()
		habitat.ring = self
		habitat.lair = lairs[_i]
		
		if data.first_part != null:
			habitat.add_shape(data.first_part, [data.first_offset, data.first_offset + data.first_spread])
		
		if !data.full_parts.is_empty():
			for part in data.full_parts:
				habitat.add_shape(part, [0, 1])
		
		if data.last_part != null:
			if data.last_part != data.first_part:
				habitat.add_shape(data.last_part, [0, data.last_spread])
		
		habitat.init_vertexs()
	
func analyze_defect() -> void:
	var total_acreage_shares = 0
	var acreage_shares = []
	acreage = 0
	
	for lair in lairs:
		acreage += lair.acreage
	
	for lair in lairs:
		var share = round(lair.acreage / acreage * 100)
		acreage_shares.append(share)
		total_acreage_shares += share
	
	var percents = []
	var percent_begin = float(0.0)
	
	for acreage_share in acreage_shares:
		var percent_end = float(acreage_share / total_acreage_shares + percent_begin)
		percents.append([percent_begin, percent_end])
		percent_begin = percent_end
	
func print_vertexs() -> void:
	var end_habitat = habitats.back()
	print(end_habitat.near_vertexs)
	print(end_habitat.far_vertexs)
	print(end_habitat.vertexs)
	
func apply_not_optimal_solution_to_last() -> void:
	var first_habitat = habitats.front()
	var last_habitat = habitats.back()
	var near_vector = first_habitat.near_vertexs.front()
	var far_vector = first_habitat.far_vertexs.front()
	last_habitat.insert_bugged_vertexs(near_vector, far_vector)
	
func apply_not_optimal_solution_to_corner() -> void:
	var first_habitat = habitats[habitats.size() - 2]
	var last_habitat = habitats.back()
	var near_vector = first_habitat.near_vertexs.front()
	var far_vector = first_habitat.far_vertexs.front()
	last_habitat.insert_bugged_vertexs(near_vector, far_vector)
