class_name TemperResource
extends Resource


var avatar: AvatarResource

var pool_tactics: Dictionary

var tactic: String
var desire: String


func _init(avatar_: AvatarResource, desire_: String) -> void:
	avatar = avatar_
	desire = desire_
	
	match desire:
		"anger":
			pool_tactics["crazy"] = 1.0
		"sloth":
			pool_tactics["safe"] = 1.0
		"envy":
			pool_tactics["rarest"] = 1.0
		"pride":
			pool_tactics["chain"] = 1.0
		"greed":
			pool_tactics["sum"] = 1.0
	
func select_tactic() -> String:
	tactic = Global.get_random_key(pool_tactics)
	return tactic
