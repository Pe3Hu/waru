class_name EncounterResource
extends Resource


var cradle: CradleResource
var habitat: HabitatResource
var hunter: AvatarResource
var prey: AvatarResource
var winner: AvatarResource

var avatars: Array[AvatarResource]
var clashs: Array[ClashResource]

var dice_pools: Dictionary

var end_flag: bool

var turn: int


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
	
func reset() -> void:
	turn = 0
	winner = null
	end_flag = false
	
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
	
func init_clashs() -> void:
	if !end_flag:
		dice_pools[hunter].dice_kit.calc_avg_chain_sum()
	
	while !end_flag:
		add_clash()
		end_flag = true
	
	
	if dice_pools[hunter].sum > dice_pools[prey].sum:
		winner = hunter
		
	if dice_pools[hunter].sum < dice_pools[prey].sum:
		winner = prey
	
func add_clash() -> void:
	var clash = ClashResource.new(self)
	clashs.append(clash)
