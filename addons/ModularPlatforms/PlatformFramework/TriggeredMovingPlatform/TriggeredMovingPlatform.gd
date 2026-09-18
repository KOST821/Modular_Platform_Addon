@tool
@icon("itinerary.svg")
extends MovingPlatform
## A moving platform that moves only if a [Trigger] is pressed.
class_name TriggeredMovingPlatform

## The [Trigger] that will move the platform.
@export var trigger: Trigger

# We use this to tell _physics_process if it should run the graph logic
var _is_graph_active: bool = false 

func _validate_property(property: Dictionary) -> void:
	match movement_type:
		MovementType.CLASSIC:
			if property.name == "graph":
				property.usage = PROPERTY_USAGE_NO_EDITOR
		MovementType.ACCELERATED:
			if property.name == "graph":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "wait_time":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _from_start() -> void:
	if Engine.is_editor_hint():
		return
		
	if not trigger:
		push_error('You have not assigned a trigger to ', name)
		set_process(false)
		set_physics_process(false)
		return
		
	# Hijack the path creation from the parent
	_create_path_follow()
	set_physics_process(false)
	set_process(false)
	
	_move_type()

func _move_type() -> void:
	if Engine.is_editor_hint():
		# --- EDITOR PREVIEW MODE ---
		# When you hit the "Play" button in the inspector, we fake a trigger press 
		# so you can preview the graph movement.
		_create_path_follow()
		if movement_type == MovementType.GRAPH:
			_is_graph_active = true
			_moving_forward = true
			sample_point = 0.0
			set_physics_process(true)
		else:
			# Let the parent's tween handle the classic/accelerated preview
			super._move_type()
		return

	# --- IN-GAME MODE ---
	if not trigger: return
	
	# Safely connect signals without leaking
	if trigger.toggle.is_connected(_trigger_status):
		trigger.toggle.disconnect(_trigger_status)
	if trigger.toggle.is_connected(_move_like_graph):
		trigger.toggle.disconnect(_move_like_graph)

	if movement_type == MovementType.CLASSIC or movement_type == MovementType.ACCELERATED:
		trigger.toggle.connect(_trigger_status)
	elif movement_type == MovementType.GRAPH:
		trigger.toggle.connect(_move_like_graph)

func _trigger_status(is_on: bool, _trigger: Trigger) -> void:
	# Your math here is still brilliant. Don't change it.
	if _tween and _tween.is_valid():
		_tween.kill()
	
	var target_ratio: float = 1.0 if is_on else 0.0
	var distance_to_travel = abs(target_ratio - _path_follow.progress_ratio)
	var actual_duration = get_travel_duration() * distance_to_travel
	var trans_type = Tween.TRANS_SINE if movement_type == MovementType.ACCELERATED else Tween.TRANS_LINEAR
	
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(_path_follow, "progress_ratio", target_ratio, actual_duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(trans_type)

func _move_like_graph(is_on: bool, _trigger: Node2D) -> void:
	# Set our direction and wake up the physics engine
	_moving_forward = is_on
	_is_graph_active = true
	set_physics_process(true)

# We DO NOT use _process(). Everything happens safely in physics.
func _physics_process(delta: float) -> void:
	
	if movement_type == MovementType.GRAPH:
		if not graph:
			push_error("MovementType is GRAPH, but no Curve is assigned!")
			set_physics_process(false)
			return
			
		# If the graph isn't supposed to be moving, put the engine back to sleep
		if not _is_graph_active:
			set_physics_process(false)
			return
			
		var time_step = delta / get_travel_duration()
		
		# Handle BOTH forward and backward safely inside the physics frame
		if _moving_forward:
			sample_point += time_step
			if sample_point >= 1.0:
				sample_point = 1.0
				_is_graph_active = false # We reached the end, stop processing
		else:
			sample_point -= time_step
			if sample_point <= 0.0:
				sample_point = 0.0
				_is_graph_active = false # We reached the start, stop processing
				
		_path_follow.progress_ratio = graph.sample(sample_point)
