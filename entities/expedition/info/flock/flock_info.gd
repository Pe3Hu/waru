class_name Flock
extends PanelContainer


@onready var alpha = %Alpha
@onready var beta = %Beta
@onready var delta = %Delta
@onready var alpha_rank = %AlphaRank
@onready var alpha_count = %AlphaCount
@onready var beta_rank = %BetaRank
@onready var beta_count = %BetaCount
@onready var delta_rank = %DeltaRank
@onready var delta_count = %DeltaCount

var resource: FlockResource:
	set(value_):
		resource = value_
		
		%Title.text = resource.lair.source.element.capitalize() + " "+ resource.lair.breed.kind.capitalize() + "  " + str(ceil(resource.lair.energy))
		
		update_subtypes()


func update_subtypes() -> void:
	for subtype in Global.arr.subtype:
		var node = get(subtype)
		node.visible = resource.subtypes.has(subtype)
		
		if resource.subtypes.has(subtype):
			var rank = get(subtype+"_rank")
			rank.text = "Rank " + str(1)
			var count = get(subtype+"_count")
			count.text = "Count " + str(resource.subtypes[subtype].size())
