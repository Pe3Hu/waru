class_name EncounterResource
extends Resource


var cradle: CradleResource
var habitat: HabitatResource
var hunter: AvatarResource
var prey: AvatarResource

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
	
func clash() -> void:
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
		
		for aspect in dice_pools[avatar].aspects:
			print([avatars.find(avatar), aspect, dice_pools[avatar].aspects[aspect]])
	
	while clash_flag:
		clash_flag = false
		
		for avatar in avatars:
			dice_pools[avatar].roll_dices()
			
			for value in dice_pools[avatar].rolled_values:
				print([avatars.find(avatar), value, dice_pools[avatar].rolled_values[value].size(), dice_pools[avatar].sum])
