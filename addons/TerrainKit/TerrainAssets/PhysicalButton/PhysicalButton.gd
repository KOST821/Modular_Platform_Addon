@tool
@icon("push_button.svg")
## A button that is pressed only if an Object is above it.
extends Trigger
class_name PhysicalButton

## How many pixels should the button go down.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var offset:float = 10.0


var is_pressed:bool = false

var _tween:Tween

var started_pos:Vector2

var _bodies_pressing:Array[CollisionObject2D] = []

func _from_start() -> void:
	started_pos = sprite.position
	
	if !use_point.body_entered.is_connected(body_enter):
		use_point.body_entered.connect(body_enter)
	if !use_point.body_exited.is_connected(body_exit):
		use_point.body_exited.connect(body_exit)
	if !use_point.area_entered.is_connected(body_enter):
		use_point.area_entered.connect(body_enter)
	if !use_point.area_exited.is_connected(body_exit):
		use_point.area_exited.connect(body_exit)

func body_enter(body:Node2D) -> void:
	if body is CollisionObject2D and is_pressed: 
		_bodies_pressing.append(body)
		return
	elif body is CollisionObject2D:
		is_pressed = true
		_bodies_pressing.append(body)
		pressed.emit(self)
		toggle.emit(true, self)
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		var target_pos:float = started_pos.y + offset
		_tween.tween_property(sprite,"position:y",target_pos,1.0)

func body_exit(body:Node2D) -> void:
	if not is_pressed:
		return
	elif _bodies_pressing.has(body): _bodies_pressing.erase(body)
	
	_bodies_pressing = _bodies_pressing.filter(func(b): return is_instance_valid(b))
	
	if ! _bodies_pressing.is_empty():
		return
	is_pressed = false
	_bodies_pressing.clear()
	released.emit(self)
	toggle.emit(false, self)
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var target_pos:float = started_pos.y
	_tween.tween_property(sprite,"position:y",target_pos,1.0)
