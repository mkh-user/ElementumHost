class_name TweenExpo extends Node

func tween_in_expo(thing: Node3D, time: float) -> Tween:
	if not thing:
		return null
	var tween = thing.create_tween()
	var defsize: Vector3 = thing.scale
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	thing.scale = Vector3.ZERO
	tween.tween_property(thing, "scale", defsize, time)
	return tween

func tween_out_expo(thing: Node3D, time: float) -> Tween:
	if not thing:
		return null
	var tween = thing.create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(thing, "scale", Vector3.ZERO, time)
	return tween
