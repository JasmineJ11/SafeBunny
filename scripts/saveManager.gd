extends Node


const SAVE_PATH := "user://save_data.json"

var data: Dictionary = {}

# players is a Dictionary: key = player_name (String), value = player_data (Dictionary)

# player_data fields:
# - history: Array[Dictionary]
# - best_score: float

# each history entry fields:
# - name: String
# - total_score: int
# - safety_score: int
# - shared_hearts: int
# - collected_hearts: int
# - played_at: String




# 启动时加载本地存档
func _ready() -> void:
	load_data()

# 从磁盘加载存档数据
func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _default_data()
		save_data()
		return data

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		data = _default_data()
		return data

	# get text
	var raw_text := file.get_as_text()
	file.close()
	
	# parse data
	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		data = _default_data()
		save_data()
		return data

	data = parsed
	_ensure_root_keys()
	return data


# 返回默认存档结构
func _default_data() -> Dictionary:
	return {
		"active_player_name": "",
		"players": {}, # dictionary
		"leaderboard": [],
		"save_version": 1
	}


# 将当前存档写入磁盘
func save_data() -> void:
	_ensure_root_keys()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write save file: %s" % SAVE_PATH)
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


# 确保根键存在，防止旧存档缺字段
func _ensure_root_keys() -> void:
	if not data.has("active_player_name"):
		data["active_player_name"] = ""
	if not data.has("players"):
		data["players"] = {}
	if not data.has("leaderboard"):
		data["leaderboard"] = []
	if not data.has("save_version"):
		data["save_version"] = 1

# ==============================================================

# 设置当前登录玩家 when type your name
func set_active_player_name(player_name: String) -> bool:
	var clean_name := _clean_name(player_name)
	if clean_name.is_empty():
		return false

	_get_or_create_player_data(clean_name)
	data["active_player_name"] = clean_name
	save_data()
	return true


# 清理玩家名（去前后空格）
func _clean_name(player_name: String) -> String:
	return player_name.strip_edges()	


# 获取或创建某个玩家的数据
func _get_or_create_player_data(player_name: String) -> Dictionary:
	var players := _get_players() # empty now
	if not players.has(player_name): # for and find one
		players[player_name] = {
			"history": [],
			"best_score": 0.0
		} # create dictionary

	var player_data: Dictionary = players[player_name]
	player_data = _normalize_player_record(player_data)
	players[player_name] = player_data
	return player_data

# 读取 players 字典
func _get_players() -> Dictionary:
	_ensure_root_keys()
	return data["players"]	


# 规范单个玩家记录（补 history 和 best_score）
func _normalize_player_record(player_data: Dictionary) -> Dictionary:
	var history: Array = player_data.get("history", [])
	player_data["history"] = history

	var history_best := 0.0
	for entry in history:
		if entry is Dictionary:
			history_best = max(history_best, _entry_composite_score(entry))

	var saved_best := float(player_data.get("best_score", 0.0))
	player_data["best_score"] = max(saved_best, history_best)
	return player_data	


# 从一条成绩记录中读取综合分
func _entry_composite_score(entry: Dictionary) -> float:
	var total_score : int = int(entry.get("total_score", 0))
	var safety_score : int = int(entry.get("safety_score", 0))
	return float(total_score) * 0.5 + float(safety_score) * 0.5



# 获取当前登录玩家名
func get_active_player_name() -> String:
	_ensure_root_keys()
	return str(data.get("active_player_name", ""))



# in show_game_over()（ history + update board）
func record_result(
	player_name: String,
	total_score: int,
	safety_score: int,
	shared_hearts: int,
	collected_hearts: int
) -> void:
	var clean_name := _clean_name(player_name)
	if clean_name.is_empty():
		return

	var session := {
		"name": clean_name,
		"total_score": total_score,
		"safety_score": safety_score,
		"shared_hearts": shared_hearts,
		"collected_hearts": collected_hearts,
		"played_at": Time.get_datetime_string_from_system()
	}

	var players := _get_players()
	var player_data := _get_or_create_player_data(clean_name)
	var history: Array = player_data.get("history", [])
	history.append(session)
	player_data["history"] = history
	var current_best := float(player_data.get("best_score", 0.0))
	player_data["best_score"] = max(current_best, _entry_composite_score(session))
	players[clean_name] = player_data

	_upsert_leaderboard_best(session)

	save_data()




# update board 一个人的最好成绩session
func _upsert_leaderboard_best(new: Dictionary) -> void:
	var name := str(new.get("name", ""))
	if name.is_empty():
		return

	var leaderboard: Array = data.get("leaderboard", [])

	# check new player
	var replaced := false 

	for i in range(leaderboard.size()):
		var old = leaderboard[i]
		if typeof(old) != TYPE_DICTIONARY:
			continue
		if str(old.get("name", "")) != name:
			continue

		# if name is same, compare new score and old score
		if _is_better_score(new, old):
			leaderboard[i] = new
		replaced = true
		break

	if not replaced:
		leaderboard.append(new)

	data["leaderboard"] = leaderboard


# 判断成绩 new 是否优于 b
func _is_better_score(a: Dictionary, b: Dictionary) -> bool:
	var a_composite := _entry_composite_score(a)
	var b_composite := _entry_composite_score(b)
	if !is_equal_approx(a_composite, b_composite):
		return a_composite > b_composite

	var a_total := int(a.get("total_score", 0))
	var b_total := int(b.get("total_score", 0))
	if a_total == b_total:
		return int(a.get("safety_score", 0)) > int(b.get("safety_score", 0))
	return a_total > b_total



func _get_personal_best(player_name_value: String) -> float:
	if player_name_value.is_empty():
		return 0.0
	var clean_name := _clean_name(player_name_value)
	var players := _get_players()
	if not players.has(clean_name):
		return 0.0
	var player_data := _normalize_player_record(players[clean_name])
	players[clean_name] = player_data
	return float(player_data.get("best_score", 0.0))


# 获取排行榜文本（默认 Top5）
func _build_leaderboard_text(limit: int = 5) -> String:
	var entries: Array = get_leaderboard(limit)
	if entries.is_empty():
		return "No local scores yet."

	var lines: PackedStringArray = []
	for i in range(entries.size()):
		var e: Dictionary = entries[i]
		var composite := _entry_composite_score(e)
		lines.append("%d. %s: %.1f" % [
			i + 1,
			str(e.get("name", "Unknown")),
			composite
		])

	return "\n".join(lines)

# 获取排行榜（默认 Top5）
func get_leaderboard(limit: int = 5) -> Array:
	_ensure_root_keys()
	var best_by_name: Dictionary = {}

	for entry in data.get("leaderboard", []):
		# get name from entry
		var name := str(entry.get("name", ""))
		

		var old_entry = best_by_name.get(name, null)
		
		# if old is null || new entry > old
		if old_entry == null or _is_better_score(entry, old_entry):
			best_by_name[name] = entry

	var entries: Array = best_by_name.values()
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _is_better_score(a, b)
	)

	if limit > 0 and entries.size() > limit:
		return entries.slice(0, limit)
	return entries
