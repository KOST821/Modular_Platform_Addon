@tool
@icon("push_button.svg")
## A button that is pressed only if an Object is above it.
extends Trigger
class_name PhysicalButton

## How much time the animation should be.
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var press_time:float = 1.0
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
	# 1. Guard clause: Ignore anything that isn't a physics object
	if not body is CollisionObject2D:
		return
		
	# 2. Add to tracking array if not already there
	if not _bodies_pressing.has(body):
		_bodies_pressing.append(body)
		
	# 3. If it wasn't pressed before, press it now
	if not is_pressed:
		is_pressed = true
		pressed.emit(self)
		toggle.emit(true, self)
		_animate_button(started_pos.y + offset)

func body_exit(body:Node2D) -> void:
	if not is_pressed:
		return
		
	if _bodies_pressing.has(body): 
		_bodies_pressing.erase(body)
	
	# Clean up any deleted bodies (enemies that died on the button)
	_bodies_pressing = _bodies_pressing.filter(func(b): return is_instance_valid(b))
	
	# If bodies are still on the button, do nothing
	if not _bodies_pressing.is_empty():
		return
		
	# The last body left, release the button
	is_pressed = false
	released.emit(self)
	toggle.emit(false, self)
	_animate_button(started_pos.y)

func _animate_button(target_y: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(sprite, "position:y", target_y, press_time)
