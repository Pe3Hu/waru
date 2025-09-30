class_name ClashResource
extends Resource


var encounter: EncounterResource
var active_avatar: AvatarResource

var end_flag: bool = false

var reroll_index: int


func _init(encounter_: EncounterResource) -> void:
	encounter = encounter_
	active_avatar = encounter.hunter

func init_rerolls() -> void:
	while end_flag and reroll_index < 20:
		end_flag = false
		
		active_avatar_rerolling()
		swtich_active_avatar()
		reroll_index += 1
			
		#var values = dice_pool.rolled_values.keys()
		#values.sort()
		
		#for value in values:
		#	print([avatars.find(avatar), value, dice_pool.rolled_values[value].size()])
	
	#print([dice_pools[hunter].sum, dice_pools[prey].sum])

	
	
	#for avatar in avatars:
		#print([avatars.find(avatar), dice_pools[avatar].sum, dice_pools[avatar].locked_values])
	
func active_avatar_rerolling() -> void:
	var dice_pool = encounter.dice_pools[active_avatar]
	
	if dice_pool.is_rerolling:
		dice_pool.roll_dices()
		dice_pool.select_value_for_lock()
		dice_pool.lock_value()
		#print(dice_pool.lock_forecast)
		end_flag = true
	
func swtich_active_avatar() -> void:
	active_avatar = active_avatar.opponent
