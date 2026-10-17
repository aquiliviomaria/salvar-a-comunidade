extends Node

signal resources_changed(water: int, food: int, medicine: int, money: int)

var money := 500
var water := 5
var food := 3
var medicine := 2
var wood := 8
var seedlings := 6
var built_houses := 0
var planted_trees := 0


func reset() -> void:
	money = 500
	water = 5
	food = 3
	medicine = 2
	wood = 8
	seedlings = 6
	built_houses = 0
	planted_trees = 0
	_emit_changed()


func add_money(amount: int) -> void:
	money += amount
	_emit_changed()


func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	_emit_changed()
	return true


func add_water(amount: int) -> void:
	water = max(0, water + amount)
	if amount > 0:
		MissionManager.progress_action("collect_water", amount)
	_emit_changed()


func add_food(amount: int) -> void:
	food = max(0, food + amount)
	if amount > 0:
		MissionManager.progress_action("collect_food", amount)
	_emit_changed()


func add_medicine(amount: int) -> void:
	medicine = max(0, medicine + amount)
	if amount > 0:
		MissionManager.progress_action("collect_medicine", amount)
	_emit_changed()


func add_wood(amount: int) -> void:
	wood = max(0, wood + amount)
	_emit_changed()


func add_seedlings(amount: int) -> void:
	seedlings = max(0, seedlings + amount)
	_emit_changed()


func can_build_house() -> bool:
	return wood >= 3 and water >= 1


func build_house() -> bool:
	if not can_build_house():
		return false
	wood -= 3
	water -= 1
	built_houses += 1
	_emit_changed()
	return true


func can_plant_tree() -> bool:
	return seedlings >= 1 and water >= 1


func plant_tree() -> bool:
	if not can_plant_tree():
		return false
	seedlings -= 1
	water -= 1
	planted_trees += 1
	_emit_changed()
	return true


func get_summary() -> String:
	return "💰 %d MT   💧 %d   🍚 %d   💊 %d   🪵 %d   🌱 %d" % [
		money,
		water,
		food,
		medicine,
		wood,
		seedlings
	]


func get_state() -> Dictionary:
	return {
		"money": money,
		"water": water,
		"food": food,
		"medicine": medicine,
		"wood": wood,
		"seedlings": seedlings,
		"built_houses": built_houses,
		"planted_trees": planted_trees
	}


func apply_state(state: Dictionary) -> void:
	money = int(state.get("money", money))
	water = int(state.get("water", water))
	food = int(state.get("food", food))
	medicine = int(state.get("medicine", medicine))
	wood = int(state.get("wood", wood))
	seedlings = int(state.get("seedlings", seedlings))
	built_houses = int(state.get("built_houses", built_houses))
	planted_trees = int(state.get("planted_trees", planted_trees))
	_emit_changed()


func _emit_changed() -> void:
	resources_changed.emit(water, food, medicine, money)
