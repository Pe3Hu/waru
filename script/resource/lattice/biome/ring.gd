class_name RingResource
extends Resource


var source: SourceResource:
	set(value_):
		source = value_
		
		source.rings[order] = self
		#init_habitats()

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
		var share = lair.acreage / acreage #round(lair.acreage / acreage * 100)
		acreage_shares.append(share)
		total_acreage_shares += share
	
	
	#for _i in 6:
		#var share = randf_range(3, 5)
		#acreage_shares.append(share)
		
	#var acreage_shares = [58, 40]
	#var acreage_shares_filler = 120
	#
	#for acreage_share in acreage_shares:
		#acreage_shares_filler -= acreage_share
	#
	#acreage_shares.append(acreage_shares_filler)
	#
	#for acreage_share in acreage_shares:
		#total_acreage_shares += acreage_share
	
	var percents = []
	var percent_begin = 0.0
	
	for acreage_share in acreage_shares:
		var percent_end = float(acreage_share) / total_acreage_shares + percent_begin
		percents.append([percent_begin, percent_end])
		percent_begin = percent_end
	
	#var check_value = float(percents.back().back()) - 1
	##print(percents)
	#if check_value > 0:
		##print(typeof(percents.back().back()))
		#print(check_value > 0, check_value != 0 )
		#print(["!", check_value, percents])
		
	var rind_order = 1
	#var last_angle = 0
	var parts = Global.dict.ring.windrose[rind_order].keys()
	var current_part = parts.front()
	var current_spread = 0
	#var last_percent = 0
	var first_part = null
	var last_part = null
	var share_datas = []
	
	#if source.anchor.index == 0:
		#print(percents)
	
	for _i in percents.size():
		#if source.anchor.index == 0:
				#print(["=", _i, current_part, first_part, last_part])
			
		var data = {}
		data.index = share_datas.size()
		data.first_offset = 0
		data.first_spread = 0
		data.last_spread = 0
		first_part = last_part
		var full_parts = []
		
		if !share_datas.is_empty():
			current_spread = share_datas.back().last_spread
	
	#if _i < percents.size() - 1:
		#var angle_begin = PI * 2 * percents[_i][0]
		#var angle_end = PI * 2 * percents[_i][1]
		var percent_remainder = percents[_i][1] - percents[_i][0]
		
		var origin_part_percent = Global.dict.ring.windrose[rind_order][current_part]
		var part_percent = float(origin_part_percent)
		
		if first_part != null:
			data.first_offset = current_spread
			part_percent -= current_spread * part_percent
			data.first_spread = part_percent / origin_part_percent
			
			if source.anchor.index == 0:
				pass
			
			percent_remainder -= part_percent
			
			if data.first_offset + data.first_spread >= 1:
				var next_index = (parts.find(current_part) + 1) % parts.size()
				current_part = parts[next_index]
				
				if percent_remainder == 0:
					last_part = current_part
		
		while percent_remainder > 0:
			origin_part_percent = Global.dict.ring.windrose[rind_order][current_part]
			part_percent = float(origin_part_percent)
			
			#if source.anchor.index == 0:
				#print(["<", _i, current_part, percent_remainder, part_percent, "|", percent_remainder / origin_part_percent, current_spread])
			
			if percent_remainder >= part_percent:
				#data.first_spread = 1 - current_spread
				if source.anchor.index == 0:
					pass
				percent_remainder -= part_percent
				full_parts.append(current_part)
				#if first_part != current_part:
					#full_parts.append(current_part)
				#else:
					#if source.anchor.index == 0:
						#pass
					#data.first_spread = percent_remainder / origin_part_percent
				
				var next_index = (parts.find(current_part) + 1) % parts.size()
				current_part = parts[next_index]
				last_part = null
			else:
				data.last_spread = percent_remainder / origin_part_percent# - current_spread
				
				if source.anchor.index == 0:
					pass
				#last_percent = part_percent - percent_remainder
				
				current_spread += float(data.last_spread)
				percent_remainder = 0
				last_part = current_part
			
			#last_percent += data.first_spread
			
			#if source.anchor.index == 0:
				#print([">", _i, current_part, percent_remainder, part_percent, "|", current_spread])
				
		
		data.first_part = first_part
		data.full_parts = full_parts
		data.last_part = last_part
		
		#if !full_parts.is_empty():
			#var full_part_name = full_parts.back().erase(full_parts.back().length() - 1, 1)
			#var last_part_name = last_part.erase(last_part.length() - 1, 1)
			#var full_index = Global.dict.part.direction.keys().find(full_part_name)
			#var last_index = Global.dict.part.direction.keys().find(last_part_name)
			#
			#if source.anchor.index == 0:
				#pass
			#if last_index < full_index:
				#data.last_part = null
			
		share_datas.append(data)
		
		#if source.anchor.index == 0:
			#print(data)
		
		#print([_i, current_part, percents[_i][1] - percents[_i][0], first_part, full_parts, last_part, last_percent])

	
	#if source.anchor.index == 0:
		#print(share_datas)
		
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
			#var part_name = data.last_part.erase(data.last_part.length() - 1, 1)
			#var shape = Global.dict.part.shape[part_name]
			
			#if shape == "triangle":
			#if data.first_part != null:
			#	data.last_percent = 1 - data.last_percent
			
			if data.last_part != data.first_part:
				habitat.add_shape(data.last_part, [0, data.last_spread])
		
		habitat.init_vertexs()
	
func analyze_defect() -> void:
	print("_")
	var total_acreage_shares = 0
	var acreage_shares = []
	acreage = 0
	
	for lair in lairs:
		acreage += lair.acreage
	
	for lair in lairs:
		var share = round(lair.acreage / acreage * 100) #lair.acreage / acreage
		acreage_shares.append(share)
		total_acreage_shares += share
	
	var percents = []
	var percent_begin = float(0.0)
	
	for acreage_share in acreage_shares:
		var percent_end = float(acreage_share / total_acreage_shares + percent_begin)
		percents.append([percent_begin, percent_end])
		percent_begin = percent_end
	
	#print(acreage_shares)
	#rint(percents)
	#print_vertexs()
	
	for habitat in habitats:
		print(habitat.shapes)
	
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
