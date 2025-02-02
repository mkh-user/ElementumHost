extends Node

onready var slowdown_timer := Timer.new()

func _ready() -> void:
	get_tree().root.call_deferred("add_child", slowdown_timer)
	slowdown_timer.one_shot = true
	slowdown_timer.connect("timeout", self, "_on_slowdown_timer_timeout")


# Wrapper for call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)
func call_group(groupName: String, funcName: String) -> void:
	var tree := get_tree()
	tree.call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)

func get_camera() -> Camera2D:
	var tree := get_tree()
	return tree.current_scene.find_node("PlayerController").get_node("Camera") as Camera2D

func get_view_position() -> Vector2:
	return get_camera().get_camera_screen_center() - get_viewport().get_visible_rect().size / 2

func choose(items: Array):
	return items[randi() % items.size()]

func time_slowdown(time_scale: float, duration: float) -> void:
	Engine.time_scale = time_scale
	slowdown_timer.start(time_scale * duration)

func time_convert(time_in_sec: int) -> String:
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	var hours = (time_in_sec/60)/60

	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _on_slowdown_timer_timeout() -> void:
	Engine.time_scale = 1.0
