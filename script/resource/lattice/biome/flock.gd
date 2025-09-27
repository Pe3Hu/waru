class_name FlockResource
extends Resource


var lair: LairResource
var beasts: Array[BeastResource]

var subtypes = {}


func add_beast() -> BeastResource:
	var subtype = Global.get_random_key(Global.dict.ring.subtype[lair.habitat.ring.order])
	var beast = lair.source.anchor.lattice.cradle.add_beast(self, subtype)
	
	if !subtypes.has(subtype):
		subtypes[subtype] = []
	
	subtypes[subtype].append(beast)
	return beast
