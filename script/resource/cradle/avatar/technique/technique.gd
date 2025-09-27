class_name TechniqueResource
extends Resource


var avatar: AvatarResource

var skills: Array[SkillResource]
var active_skills: Dictionary
var cooldown_skills: Dictionary

var skill_aspects: Dictionary


func _init(avatar_: AvatarResource) -> void:
	avatar = avatar_
	
	init_defects()
	reset_active_skills()
	
func init_defects() -> void:
	var aspect_pairs = avatar.cradle.ascensions[avatar.type].aspect_pairs.pick_random()
	
	for aspect_pair in aspect_pairs:
		var defect_size = avatar.cradle.defect_values[aspect_pair].pick_random()
		add_skill(defect_size)
	
func add_skill(size_: Vector2i) -> void:
	var skill = SkillResource.new(self, size_)
	skills.append(skill)
	
func reset_active_skills() -> void:
	active_skills = {}
	
	for skill in skills:
		active_skills[skill] = skill.weight
	
func roll_skill() -> SkillResource:
	reset_skill_aspects()
	
	var skill = Global.get_random_key(active_skills)
	
	for defect in skill.defects:
		skill_aspects[defect.aspect] = avatar.aspects[defect.aspect].current_value - defect.value
	
	if !cooldown_skills.has(skill.cooldown):
		cooldown_skills[skill.cooldown] = []
	
	cooldown_skills[skill.cooldown].append(skill)
	active_skills.erase(skill)
	
	print(skill_aspects)
	
	#for aspect in Global.arr.battle_aspect:
		#print(["battle", aspect, avatar.aspects[aspect].current_value])
		#
	#for defect in skill.defects:
		#print(["defect", defect.aspect, -defect.value])
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
			active_skills[skill] = skill.weight
		
		cooldown_skills.erase(0)
	
func encounter_preparation() -> void:
	pass
	
func get_dices() -> Dictionary:
	var dices = {}
	dices["give"] = {}
	dices["take"] = {}
	
	for aspect in skill_aspects:
		var count = int(floor(sqrt(abs(skill_aspects[aspect]))))
		
		if skill_aspects[aspect] > 0:
			dices["take"][aspect] = count
		
		if skill_aspects[aspect] < 0:
			dices["give"][aspect] = count
	
	return dices
