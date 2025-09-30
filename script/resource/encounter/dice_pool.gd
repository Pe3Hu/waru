class_name DicePoolResource
extends Resource


var avatar: AvatarResource
var encounter: EncounterResource
var dice_kit: DiceKitResource
var lock_forecast: ForecastResource

var total_dices: Array[DiceResource]
var locked_dices: Array[DiceResource]
var rolled_dices: Array[DiceResource]
var exiled_dices: Array[DiceResource]
var forecasts: Array[ForecastResource]

var locked_values: Dictionary
var rolled_values: Dictionary
var exiled_values: Dictionary

var sum: int

var risk_limit: float = 0.5

var is_rerolling: bool


func _init(encounter_: EncounterResource, avatar_: AvatarResource) -> void:
	encounter = encounter_
	avatar = avatar_
	encounter.dice_pools[avatar] = self
	
func reset() -> void:
	is_rerolling = true
	sum = 0
	total_dices = []
	locked_dices = []
	rolled_dices = []
	locked_values = {}
	rolled_values = {}
	
	for _i in encounter.cradle.encounter_basic_dice_default:
		add_dice("observation")
	
	add_dice("basic")
	add_dice("basic")
	#for _i in 2:
	#	add_dice("strength")
	
	#add_dice("observation")
	var aspects = []
	
	for dice in total_dices:
		aspects.append(dice.aspect)
	
	dice_kit = DiceKitResource.new(aspects)
	
func add_dice(aspect_: String) -> void:
	var dice = DiceResource.new(aspect_)
	total_dices.append(dice)
	
	#if !aspects.has(aspect_):
		#aspects[aspect_] = 0
	#
	#aspects[aspect_] += 1
	pass
	
func update_rolled_dices() -> void:
	is_rerolling = true
	rolled_dices = total_dices.duplicate()
	
func roll_dices() -> void:
	rolled_values = {}
	is_rerolling = true
	
	for dice in rolled_dices:
		var value = dice.roll()
		
		if !rolled_values.has(value):
			rolled_values[value] = []
		
		rolled_values[value].append(dice)
	
	dice_kit.lock_options = {}
	
	for value in rolled_values:
		if !locked_values.has(!value):
			dice_kit.lock_options[value] = rolled_values[value].size()
	
	if dice_kit.lock_options.keys().is_empty():
		exile_biggest_value()
	
func select_value_for_lock() -> void:
	lock_forecast = null
	forecasts = []
	var analyzed_datas = dice_kit.get_analyze_data()
	
	for data in analyzed_datas:
		var forecast = ForecastResource.new(self, data)
		forecasts.append(forecast)
	
	forecasts = forecasts.filter(func(a): return a.failure_probability < risk_limit)
	
	if !forecasts.is_empty():
		avatar.temper.select_tactic()
		var tactic_func_name = avatar.temper.tactic + "_tactic"
		call(tactic_func_name)
	
func crazy_tactic() -> void:
	lock_forecast = forecasts.pick_random()
	
func safe_tactic() -> void:
	forecasts.sort_custom(func (a, b): return a.failure_probability < b.failure_probability)
	lock_forecast = forecasts.front()
	
func rarest_tactic() -> void:
	forecasts.sort_custom(func (a, b): return a.chain_probability < b.chain_probability)
	lock_forecast = forecasts.front()
	
func chain_tactic() -> void:
	forecasts.sort_custom(func (a, b): return a.size > b.size)
	var options = []
	
	for forecast in forecasts:
		if forecasts.front().size == forecast.size:
			options.append(forecast)
	
	options.sort_custom(func (a, b): return a.locked_value > b.locked_value)
	lock_forecast = options.front()
	
func sum_tactic() -> void:
	forecasts.sort_custom(func (a, b): return a.sum > b.sum)
	lock_forecast = forecasts.front()
	
func lock_value() -> void:
	if lock_forecast != null:
		locked_values[lock_forecast.locked_value] = []
		
		for dice in rolled_values[lock_forecast.locked_value]:
			lock_dice(dice)
	else:
		is_rerolling = false
	
	if rolled_dices.is_empty():
		is_rerolling = false
	
func lock_dice(dice_: DiceResource) -> void:
	rolled_dices.erase(dice_)
	locked_dices.append(dice_)
	locked_values[lock_forecast.locked_value].append(dice_)
	sum += lock_forecast.locked_value
	
func exile_biggest_value() -> void:
	var options = locked_values.keys()
	options.sort()
	var biggest_value = options.back()
	
	exiled_values[biggest_value] = []
	exiled_values[biggest_value].append_array(locked_values[biggest_value])
	locked_values.erase(biggest_value)
	
	for dice in exiled_values[biggest_value]:
		locked_dices.erase(dice)
		exiled_dices.append(dice)
	
	sum -= biggest_value * exiled_values[biggest_value].size()
