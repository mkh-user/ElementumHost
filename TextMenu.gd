@tool
#extends Control
extends Control

## A text menu dicoverable with keyboard

## Emits when current option changes.
signal option_changed(index: int)
## Emits when user press ENTER
signal option_selected(index: int)

## Menu side to show cursor
enum CursorSide {
	LEFT_TOP, ## Left of options for vertical, top of options for horizontal
	RIGHT_BOTTOM, ## Right of options for vertical, bottom of options for horizontal
}

## List of menu options (texts)
@export var options: Array[String] = []:
	set(e):
		options = e
		_clear()
		_create_options()
		_reposition_options()
		_reposition_cursor()
## Initial selected option
@export var initial_option := 0:
	set(i):
		initial_option = i % options.size()
		set_option_as_current(initial_option)
## Menu is enable or not
@export var enabled := true:
	set(e):
		enabled = e
		var editor := Engine.is_editor_hint()
		if e:
			_cursor.show()
			if editor:
				_blinking_timer.stop()
			else:
				_blinking_timer.start(cursor_blinking_gap)
				set_process_input(true)
		else:
			_cursor.hide()
			_blinking_timer.stop()
			set_process_input(false)
@export_group("Visual")
## Items orientation
@export var orientation := Orientation.VERTICAL:
	set(o):
		orientation = o
		_reposition_options()
		_reposition_cursor()
## Items offset
@export var offset := 0:
	set(o):
		offset = o
		_reposition_options()
		_reposition_cursor()
## Options color
@export var options_color := Color.WHITE:
	set(c):
		options_color = c
		_update_color()
@export_subgroup("Cursor", "cursor_")
## Which side to show cursor (see [emun CursorSide])
@export var cursor_side := CursorSide.LEFT_TOP:
	set(s):
		cursor_side = s
		_reposition_cursor()
## Offset to place cursor
@export var cursor_offset := 0:
	set(o):
		cursor_offset = o
		_reposition_cursor()
## Blinking cursor or not
@export var cursor_blinking := false:
	set(b):
		cursor_blinking = b
		enabled = enabled
## Time when cursor stay visible at blinking
@export var cursor_blinking_gap := 0.5
## Cursor color
@export var cursor_color := Color.WHITE:
	set(c):
		cursor_color = c
		_update_color()

var _current_option := 0
var _blinking_timer := Timer.new()
var _cursor: Label
var _options: Control

func _init() -> void:
	_cursor = Label.new()
	_options = Control.new()
	add_child(_cursor)
	add_child(_options)
	add_child(_blinking_timer)
	_blinking_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not cursor_blinking:
		return
	if _cursor.visible:
		_cursor.hide()
		_blinking_timer.start(cursor_blinking_gap / 2.0)
	else:
		_cursor.show()
		_blinking_timer.start(cursor_blinking_gap)

func _clear() -> void:
	for option: Label in _options.get_children():
		option.queue_free()
	_current_option = 0

func _create_options() -> void:
	_clear()
	for option: String in options:
		var label := Label.new()
		label.set_text(option)
		_options.add_child(label)

func _update_color() -> void:
	for option: Label in _options.get_children():
		option.add_theme_color_override("font_color", options_color)
	_cursor.add_theme_color_override("font_color", cursor_color)

func _reposition_options():
	var width := 0.0
	var height := 0.0
	for option: Label in _options.get_children():
		if orientation == Orientation.HORIZONTAL:
			option.position = Vector2(width, 0)
			width += offset + option.size.x
			height = max(height, option.size.y)
		elif orientation == Orientation.VERTICAL:
			option.position = Vector2(0, height)
			height += offset + option.size.y
			width = max(width, option.size.x)
	set_size(Vector2(width, height))

func _reposition_cursor():
	_current_option = _current_option % options.size()
	var option_pos: Vector2 = _options.get_child(_current_option).position
	var option_size: Vector2 = _options.get_child(_current_option).size
	if cursor_side == CursorSide.LEFT_TOP and orientation == Orientation.VERTICAL:
		_cursor.set_text(">")
		_cursor.position = Vector2(
			option_pos.x - (cursor_offset + _cursor.get_size().x),
			option_pos.y
		)
	elif cursor_side == CursorSide.LEFT_TOP and orientation == Orientation.HORIZONTAL:
		_cursor.set_text("v")
		_cursor.position = Vector2(
			option_pos.x + (option_size.x / 2.0) - (_cursor.get_size().x / 2.0),
			option_pos.y - (_cursor.get_size().y + cursor_offset)
		)
	elif cursor_side == CursorSide.RIGHT_BOTTOM and orientation == Orientation.VERTICAL:
		_cursor.set_text("<")
		_cursor.position = Vector2(
			option_pos.x + option_size.x + cursor_offset,
			option_pos.y
		)
	elif cursor_side == CursorSide.RIGHT_BOTTOM and orientation == Orientation.HORIZONTAL:
		_cursor.set_text("^")
		_cursor.position = Vector2(
			option_pos.x + (option_size.x / 2.0) - (_cursor.get_size().x / 2.0),
			option_pos.y + _cursor.get_size().y + cursor_offset
		)

func _ready() -> void:
	_reposition_options()
	_reposition_cursor()
	enabled = enabled

func set_option_as_current(index: int) -> void:
	_current_option = index % options.size()
	_reposition_cursor()

func _previous_index() -> int:
	return (_current_option if _current_option != 0 else options.size()) - 1

func _next_index() -> int:
	return _current_option + 1 if _current_option != options.size() - 1 else 0

func _input(event: InputEvent) -> void:
	_cursor.show()
	_blinking_timer.start(cursor_blinking_gap)
	if event is not InputEventKey or not event.pressed:
		return
	if Input.is_action_just_pressed_by_event("ui_up", event):
		if orientation == Orientation.VERTICAL:
			set_option_as_current(_previous_index())
			option_changed.emit(_current_option)
	if Input.is_action_just_pressed_by_event("ui_down", event):
		if orientation == Orientation.VERTICAL:
			set_option_as_current(_next_index())
			option_changed.emit(_current_option)
	if Input.is_action_just_pressed_by_event("ui_right", event):
		if orientation == Orientation.HORIZONTAL:
			set_option_as_current(_next_index())
			option_changed.emit(_current_option)
	if Input.is_action_just_pressed_by_event("ui_left", event):
		if orientation == Orientation.HORIZONTAL:
			set_option_as_current(_previous_index())
			option_changed.emit(_current_option)
	if Input.is_action_just_pressed_by_event("ui_accept", event):
		option_selected.emit(_current_option)
