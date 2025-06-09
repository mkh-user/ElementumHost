extends GridContainer
#extends GridContainer

@export var shift_last_row_to_right: bool = false:
	set(value):
		shift_last_row_to_right = value
		pre_sort_children.emit()


func _ready() -> void:
	pre_sort_children.connect(_sort_childs)


func _sort_childs() -> void:
	for child in get_children():
		if child.get_meta("type", "") == "GridPlaceholder":
			remove_child(child)
	if shift_last_row_to_right:
		var last_childern_number = get_child_count() % columns
		if last_childern_number == 0: return
		for placeholder_index in range(columns - last_childern_number):
			var placeholder_node := _create_placeholder()
			add_child(placeholder_node)
			move_child(placeholder_node, last_childern_number * -1 - 1)


func _create_placeholder() -> Control:
	var placeholder := Control.new()
	placeholder.set_meta("type", "GridPlaceholder")
	return placeholder
