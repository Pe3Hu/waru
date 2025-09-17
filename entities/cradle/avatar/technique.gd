class_name TechniqueResource
extends Resource


var avatar: AvatarResource

var battle_skills: Dictionary
var cooldown_skills: Dictionary
var skills: Dictionary

var skill_aspects: Dictionary


func _init(avatar_: AvatarResource) -> void:
	avatar = avatar_
	
	roll_defects()
	reset_battle_skills()
	var skill = roll_skill()
	pass
	
func roll_defects() -> void:
	var aspect_pairs = avatar.cradle.ascensions[avatar.type].aspect_pairs.pick_random()
	
	for aspect_pair in aspect_pairs:
		var defect_size = avatar.cradle.defect_values[aspect_pair].pick_random()
		add_skill(defect_size)
	
func add_skill(size_: Vector2i) -> void:
	var skill = SkillResource.new(self, size_)
	skills[skill] = skill.weight
	
func reset_battle_skills() -> void:
	battle_skills = {}
	
	for skill in skills:
		battle_skills[skill] = skill.weight
	
func roll_skill() -> SkillResource:
	reset_skill_aspects()
	
	var skill = Global.get_random_key(battle_skills)
	
	for defect in skill.defects:
		skill_aspects[defect.aspect] = avatar.aspects[defect.aspect].current_value - defect.value
	
	if !cooldown_skills.has(skill.cooldown):
		cooldown_skills[skill.cooldown] = []
	
	cooldown_skills[skill.cooldown].append(skill)
	battle_skills.erase(skill)
	
	print(skill_aspects)
	
	for aspect in Global.arr.battle_aspect:
		print([aspect, avatar.aspects[aspect].current_value])
		
	for defect in skill.defects:
		print([defect.aspect, -defect.value])
	return skill
	
func reset_skill_aspects() -> void:
	for aspect in Global.arr.battle_aspect:
		skill_aspects[aspect] = 0
	
func recharge_skills() -> void:
	var new_cooldowns = {}
	
	for cooldown in cooldown_skills:
		new_cooldowns[cooldown - 1] = []
		new_cooldowns[cooldown - 1].append_array(cooldown_skills[cooldown])
	
	cooldown_skills = new_cooldowns
	
	if cooldown_skills.has(0):
		for skill in cooldown_skills[0]:
			battle_skills[skill] = skill.weight
		
		cooldown_skills.erase(0)
