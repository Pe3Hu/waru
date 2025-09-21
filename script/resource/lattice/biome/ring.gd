class_name RingResource
extends Resource


var source: SourceResource:
	set(value_):
		source = value_
		
		source.rings[order] = self
		init_habitats()

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
		habitat.add_shape(part, milestones)
		habitat.ring = self
		return
	
	if order == 2:
		return
	
	var total_acreage_shares = 0
	var acreage_shares = [2]
	var acreage_shares_filler = 32
	
	for acreage_share in acreage_shares:
		acreage_shares_filler -= acreage_share
	
	acreage_shares.append(acreage_shares_filler)
	
	var percents = []
	var percent_begin = 0
	
	for acreage_share in acreage_shares:
		total_acreage_shares +=  acreage_share
		
	for acreage_share in acreage_shares:
		var percent_end =  float(acreage_share) / total_acreage_shares + percent_begin
		percents.append([percent_begin, percent_end])
		percent_begin = percent_end
	
	var rind_order = 1
	#var last_angle = 0
	var parts = Global.dict.ring.windrose[rind_order].keys()
	var current_part = parts.front()
	var last_percent = 0
	var first_part = null
	var last_part = null
	var share_datas = []
	
	for _i in percents.size():
		var data = {}
		data.first_percent = 0
		data.last_percent = 0
		first_part = last_part
		var full_parts = []
		
		if _i < percents.size() - 1:
			#var angle_begin = PI * 2 * percents[_i][0]
			#var angle_end = PI * 2 * percents[_i][1]
			var percent_remainder = percents[_i][1] - percents[_i][0]
			
			while percent_remainder > 0:
				var part_percent = Global.dict.ring.windrose[rind_order][current_part]
				
				if first_part != null:
					data.first_percent = (part_percent - last_percent) / part_percent
					part_percent = last_percent
				
				if percent_remainder >= part_percent:
					percent_remainder -= part_percent
					
					if first_part != current_part:
						full_parts.append(current_part)
					
					var next_index = parts.find(current_part) + 1
					current_part = parts[next_index]
				else:
					data.last_percent = (part_percent - percent_remainder) / part_percent
					last_percent = part_percent - percent_remainder
					percent_remainder = 0
					last_part = current_part
				
				#print([_i, current_part, percent_remainder, last_percent])
			
			data.first_part = first_part
			data.full_parts = full_parts
			data.last_part = last_part
			share_datas.append(data)
			#print([_i, current_part, percents[_i][1] - percents[_i][0], first_part, full_parts, last_part, last_percent])
	
	for data in share_datas:
		var habitat = HabitatResource.new()
		
		if data.last_part != null:
			habitat.add_shape(data.last_part, [0, data.last_percent])
		
		habitat.ring = self
	
	if source.anchor.index == 0:
		pass
	
