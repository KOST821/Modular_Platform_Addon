@tool
@icon("itinerary.svg")
extends MovingPlatform
## A moving platform that moves only if a [Trigger] is pressed.
class_name TriggeredMovingPlatform

## The [Trigger] that will move the platform.
@export var trigger:Trigger

var _tween:Tween

func _from_start() -> void:
	if not Engine.is_editor_hint():
		if not trigger:
			push_error('You have not assigned a trigger.')
			set_process(false)
			set_physics_process(false)
			return
			
		_create_path_follow()
		set_physics_process(false)
		set_process(false)
	
		if movement_type == MovementType.CLASSIC or movement_type == MovementType.ACCELERATED:
			if !trigger.toggle.is_connected(_trigger_status):
				trigger.toggle.connect(_trigger_status)
		elif movement_type == MovementType.GRAPH:
			if !trigger.toggle.is_connected(_move_like_graph):
				trigger.toggle.connect(_move_like_graph)

func _trigger_status(is_on:bool, _trigger:Trigger)->void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	var target_ratio:float = 1.0 if is_on else 0.0
	
	# Calculate exactly how far we actually have left to move
	var distance_to_travel = abs(target_ratio - _path_follow.progress_ratio)
	
	# Time = Total Time * Percentage of path remaining
	var actual_duration = get_travel_duration() * distance_to_travel
	
	var trans_type = Tween.TRANS_SINE if acc_acceleration_enable else Tween.TRANS_LINEAR
	
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(_path_follow, "progress_ratio",\
	target_ratio, actual_duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(trans_type)

func _move_like_graph(is_on:bool,_trigger:Node2D) -> void:
	if is_on:
		set_physics_process(true)
	else:
		set_physics_process(false)
		_moving_forward = false
		set_process(true)

func _process(delta: float) -> void:
	if not _path_follow: 
		set_process(false)
		return
	if _moving_forward:
		set_process(false)
		_path_follow.progress_ratio = 0.0
	
	else:
		var time_step = delta / get_travel_duration()
		
		sample_point -= time_step
		if sample_point <= 0.0:
			sample_point = 0.0
			_moving_forward = true
		
		_path_follow.progress_ratio = graph.sample(sample_point)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if graph_movement_enable:
		if not graph:
			push_error("MovementType is GRAPH, but no Curve is assigned!")
			set_physics_process(false)
			return
	
		# Step 1: Calculate the exact mathematical step for this frame
		var time_step = delta / get_travel_duration()
		
		# Step 2: Move the sample point back and forth between 0.0 and 1.0
		if _moving_forward:
			sample_point += time_step
			if sample_point >= 1.0:
				sample_point = 1.0
				_moving_forward = false
		
		# Step 3: Apply the Curve's Y-value directly to the PathFollower
		_path_follow.progress_ratio = graph.sample(sample_point)
