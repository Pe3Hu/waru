class_name EncounterResource
extends Resource


var cradle: CradleResource
var habitat: HabitatResource
var hunter: AvatarResource
var prey: AvatarResource
var winner: AvatarResource

var avatars: Array[AvatarResource]

var dice_pools: Dictionary

var clash_flag: bool


#func _init(habitat_: HabitatResource, hunter_: AvatarResource, prey_: AvatarResource) -> void:
func _init(hunter_: AvatarResource, prey_: AvatarResource) -> void:
	#habitat = habitat_
	hunter = hunter_
	prey = prey_
	cradle = hunter.cradle
	
	avatars.append(hunter)
	avatars.append(prey)
	
	hunter.opponent = prey
	prey.opponent = hunter
	
	for avatar in avatars:
		dice_pools[avatar] = DicePoolResource.new(self, avatar)
	
	reset()
	
func clash() -> void:
	var counter = 10
	
	while clash_flag and counter < 20:
		counter += 1
		clash_flag = false
		
		for avatar in avatars:
			var dice_pool = dice_pools[avatar]
			
			if dice_pool.is_rerolling:
				dice_pool.roll_dices()
				dice_pool.select_value_for_lock()
				dice_pool.lock_value()
				#print(dice_pool.lock_forecast)
				clash_flag = true
			
			#var values = dice_pool.rolled_values.keys()
			#values.sort()
			
			#for value in values:
			#	print([avatars.find(avatar), value, dice_pool.rolled_values[value].size()])
	
	#print([dice_pools[hunter].sum, dice_pools[prey].sum])
	if dice_pools[hunter].sum > dice_pools[prey].sum:
		winner = hunter
		
	if dice_pools[hunter].sum < dice_pools[prey].sum:
		winner = prey
	
	#for avatar in avatars:
		#print([avatars.find(avatar), dice_pools[avatar].sum, dice_pools[avatar].locked_values])
	
func reset() -> void:
	winner = null
	clash_flag = true
	
	for avatar in avatars:
		dice_pools[avatar].reset()
	
	#for avatar in avatars:
		#avatar.technique.roll_skill()
		#var dice_distribution = avatar.technique.get_dices()
		#
		#for distribution in dice_distribution:
			#var target_avatar
			#
			#match distribution:
				#"give":
					#target_avatar = avatar.opponent
				#"take":
					#target_avatar = avatar
			#
			#
			#for aspect in dice_distribution[distribution]:
				#var count = dice_distribution[distribution][aspect]
				#print([avatars.find(avatar), avatars.find(target_avatar), distribution, aspect, count])
				#
				#for _i in count:
					#dice_pools[target_avatar].add_dice(aspect)
	#
	
	for avatar in avatars:
		dice_pools[avatar].update_rolled_dices()
		
		#for aspect in dice_pool.aspects:
		#	print([avatars.find(avatar), aspect, dice_pool.aspects[aspect]])
	
	#avatars.pop_back()
