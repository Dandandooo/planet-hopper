extends Node

# List of levels in order
var levels: Array = [
	"res://levels/tutorial_level.tscn",
	"res://levels/level1.tscn",
	"res://levels/level2.tscn",
	"res://levels/level3.tscn",
]

var current_level_index: int = 0

var highest_level_unlocked: int = 0


func get_current_level() -> String:
	"""Returns the path to the current level"""
	if current_level_index < levels.size():
		return levels[current_level_index]
	return ""


func advance_to_next_level() -> void:
	"""Move to the next level and update progress"""
	current_level_index += 1
	print("Moving to next level")
	if current_level_index > highest_level_unlocked:
		highest_level_unlocked = current_level_index
	go_to_level(current_level_index)


func go_to_level(index: int) -> void:
	"""Jump to a specific level by index"""
	if index >= 0 and index < levels.size():
		current_level_index = index
		get_tree().change_scene_to_file(get_current_level())


func reset_progress() -> void:
	current_level_index = 0


func is_last_level() -> bool:
	return current_level_index >= levels.size() - 1


func get_level_count() -> int:
	return levels.size()


# Optional: Save/Load functions for persistence
func save_game() -> void:
	"""Save current progress to disk"""
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if save_file:
		var save_data = {
			"current_level": current_level_index,
			"highest_unlocked": highest_level_unlocked
		}
		save_file.store_var(save_data)
		save_file.close()


func load_game() -> void:
	"""Load saved progress from disk"""
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			current_level_index = save_data.get("current_level", 0)
			highest_level_unlocked = save_data.get("highest_unlocked", 0)
			save_file.close()
