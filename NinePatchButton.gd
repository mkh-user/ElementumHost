extends Button
@extends Button

@export var texture : Texture2D = null :
	set( _new_value ):
		texture = _new_value
		if nine_patch_rect:
			nine_patch_rect.texture = _new_value

@export var draw_center : bool = true :
	set( _new_value ):
		draw_center = _new_value
		if nine_patch_rect:
			nine_patch_rect.draw_center = _new_value


@export_subgroup( "Region Rects" )

@export var region_normal : Rect2 = Rect2( Vector2.ZERO, Vector2.ZERO ) :
	set( _new_value ):
		region_normal = _new_value
		if nine_patch_rect:
			if not disabled and not button_pressed:
				nine_patch_rect.region_rect = _new_value

@export var region_pressed : Rect2 = Rect2( Vector2.ZERO, Vector2.ZERO ) :
	set( _new_value ):
		region_pressed = _new_value
		if nine_patch_rect:
			if toggle_mode and button_pressed:
				nine_patch_rect.region_rect = _new_value

@export var region_hover : Rect2 = Rect2( Vector2.ZERO, Vector2.ZERO )

@export var region_disabled : Rect2 = Rect2( Vector2.ZERO, Vector2.ZERO ) :
	set( _new_value ):
		region_disabled = _new_value
		if nine_patch_rect:
			if disabled:
				nine_patch_rect.region_rect = _new_value


@export_subgroup( "Patch Margins" )

@export var margin_left : int = 0 :
	set( _new_value ):
		margin_left = _new_value
		if nine_patch_rect:
			nine_patch_rect.patch_margin_left = _new_value

@export var margin_top : int = 0 :
	set( _new_value ):
		margin_top = _new_value
		if nine_patch_rect:
			nine_patch_rect.patch_margin_top = _new_value

@export var margin_right : int = 0 :
	set( _new_value ):
		margin_right = _new_value
		if nine_patch_rect:
			nine_patch_rect.patch_margin_right = _new_value

@export var margin_bottom : int = 0 :
	set( _new_value ):
		margin_bottom = _new_value
		if nine_patch_rect:
			nine_patch_rect.patch_margin_bottom = _new_value


@export_subgroup( "Axis Stretch" )

enum NPB_PatchAxisStretch {
	STRETCH = NinePatchRect.AXIS_STRETCH_MODE_STRETCH,
	TILE = NinePatchRect.AXIS_STRETCH_MODE_TILE,
	TILE_FIT = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
}

@export var horizontal_stretch : NPB_PatchAxisStretch = NPB_PatchAxisStretch.STRETCH :
	set( _new_value ):
		horizontal_stretch = _new_value
		if nine_patch_rect:
			nine_patch_rect.axis_stretch_horizontal = int(_new_value) as NinePatchRect.AxisStretchMode

@export var vertical_stretch : NPB_PatchAxisStretch = NPB_PatchAxisStretch.STRETCH :
	set( _new_value ):
		vertical_stretch = _new_value
		if nine_patch_rect:
			nine_patch_rect.axis_stretch_vertical = int(_new_value) as NinePatchRect.AxisStretchMode



var nine_patch_rect : NinePatchRect = null


func _set( _name, _new_value ):
	match _name:
		"toggle_mode":
			if nine_patch_rect:
				if _new_value:
					if button_pressed:
						nine_patch_rect.region_rect = region_pressed
					else:
						nine_patch_rect.region_rect = region_normal
				else:
					nine_patch_rect.region_rect = region_normal
			
		"disabled":
			if nine_patch_rect:
				if _new_value:
					nine_patch_rect.region_rect = self.region_disabled
				else:
					if toggle_mode:
						if button_pressed:
							nine_patch_rect.region_rect = region_pressed
						else:
							nine_patch_rect.region_rect = region_normal
					else:
						nine_patch_rect.region_rect = region_normal
			
		"button_pressed":
			if nine_patch_rect:
				if toggle_mode:
					if _new_value:
						nine_patch_rect.region_rect = region_pressed
					else:
						nine_patch_rect.region_rect = region_normal
			
		"flat":
			update_configuration_warnings()
			if not _new_value:
				printerr( "NinePatchButton needs flat to be true")


func _get_configuration_warnings():
	var warnings = []
	
	if flat == false:
		warnings.append( "NinePatchButton needs flat to be true." )
	
	return warnings


func _on_button_down():
	if button_pressed:
		nine_patch_rect.region_rect = region_pressed
	else:
		nine_patch_rect.region_rect = region_hover


func _on_button_up():
	if button_pressed:
		nine_patch_rect.region_rect = region_pressed
	elif is_hovered():
		nine_patch_rect.region_rect = region_hover
	else:
		nine_patch_rect.region_rect = region_normal


func _on_mouse_entered():
	if not disabled:
		if toggle_mode:
			if not button_pressed:
				nine_patch_rect.region_rect = region_hover
		elif not button_pressed:
			nine_patch_rect.region_rect = region_hover
		elif not keep_pressed_outside:
			nine_patch_rect.region_rect = region_pressed


func _on_mouse_exited():
	if not disabled:
		if toggle_mode:
			if not button_pressed:
				nine_patch_rect.region_rect = region_normal
		elif button_pressed:
			if not keep_pressed_outside:
				nine_patch_rect.region_rect = region_normal
		else:
			nine_patch_rect.region_rect = region_normal


func _on_resized():
	if nine_patch_rect:
		nine_patch_rect.size = size


func _init():
	flat = true


func _ready():
	resized.connect( _on_resized )
	mouse_entered.connect( _on_mouse_entered )
	mouse_exited.connect( _on_mouse_exited )
	button_down.connect( _on_button_down )
	button_up.connect( _on_button_up )
	
	nine_patch_rect = NinePatchRect.new()
	add_child( nine_patch_rect )
	nine_patch_rect.size = size
	nine_patch_rect.show_behind_parent = true
	
	nine_patch_rect.texture = texture
	nine_patch_rect.draw_center = draw_center
	
	if disabled:
		nine_patch_rect.region_rect = region_disabled
	elif toggle_mode and button_pressed:
		nine_patch_rect.region_rect = region_pressed
	else:
		nine_patch_rect.region_rect = region_normal
	
	nine_patch_rect.patch_margin_left = margin_left
	nine_patch_rect.patch_margin_top = margin_top
	nine_patch_rect.patch_margin_right = margin_right
	nine_patch_rect.patch_margin_bottom = margin_bottom
	
	nine_patch_rect.axis_stretch_horizontal = int(horizontal_stretch) as NinePatchRect.AxisStretchMode
	nine_patch_rect.axis_stretch_vertical = int(vertical_stretch) as NinePatchRect.AxisStretchMode
