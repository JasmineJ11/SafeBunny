extends Node
@onready var game_manager: Node = get_node("/root/Game/GameManager")

const SAVE_PATH := "user://save_data.json"
var data: Dictionary = {}
func _ready() -> void:
	load_data()
	# reset_data()

# func reset_data():
# 	data = _default_data()
# 	save_data()

# load from file
func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _default_data()
		save_data()
		return data

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		data = _default_data()
		return data

	var raw_text := file.get_as_text()
	file.close()
	
	# parse data
	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		data = _default_data()
		save_data()
		return data

	data = parsed
	return data

# return deault data
func _default_data() -> Dictionary:
	return {}

# save data to file
func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write save file: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

# call by game_manager.gd
func update_score(player_name: String, new_score:  float):
	if data[player_name] == null or new_score > data[player_name]:
		data[player_name] = new_score
		save_data()

func higher_score(pair1, pair2):
	return pair1[1] > pair2[1]

func get_top_scores():
	var array := []
	for key in data.keys():
		array.append([key, data[key]])
		array.sort_custom(higher_score)
	return array

# leaderboard
func _build_leaderboard_text() -> String:
	var array = get_top_scores()
	var lines: PackedStringArray = []
	var count = min(array.size(), 5)
	for idx in range(count):
		var player_name = array[idx][0]
		var composite = array[idx][1]
		lines.append("%d. %s: %.1f" % [
			idx + 1,
			player_name,
			composite
		])
	return "\n".join(lines)
