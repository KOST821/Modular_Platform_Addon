@tool
@icon("tree_evergreen.svg")
@abstract class_name PropOrHazard
## A modular entity that can act as a static background prop, a solid obstacle, or a deadly hazard.
extends StaticBody2D

@export_category("Nodes")
## The [Sprite2D] that holds the texture.[br] 
## It is [b]useless[/b] if [member PropOrHazard.visual_type] is [i]Animated[/i].
@export var sprite_still: Sprite2D:
	set(value):
		sprite_still = value
		update_configuration_warnings()
## The [AnimatedSprite2D] that holds the texture.[br] 
## It is [b]useless[/b] if [member PropOrHazard.visual_type] is [i]Still[/i].
@export var sprite_animated: AnimatedSprite2D:
	set(value):
		sprite_animated = value
		update_configuration_warnings()
## The [CollisionShape2D] that defines the collision of the [b]Prop[/b] or [b]Hazard[/b].
@export var collision_shape: CollisionShape2D:
	set(value):
		collision_shape = value
		update_configuration_warnings()
## The [HitBox] that is used to deal damage.[br]
## If it is a Prop there is no need of it being added.
@export var hitbox_component: HitBox:
	set(value):
		hitbox_component = value
		update_configuration_warnings()
## The [CollisionShape2D] that defines the [HitBox] of the Hazard.
@export var hitbox_shape: CollisionShape2D:
	set(value):
		hitbox_shape = value
		update_configuration_warnings()

@export_category("Prop Type")
## Choose whether this prop uses a still texture or an animated sequence.
@export_enum("Still", "Animated") var visual_type: int = 0:
	set(value):
		visual_type = value
		_update_visuals()
## The texture if it has a Still [member PropOrHazard.visual_type].
@export var texture_still: Texture2D:
	set(value):
		texture_still = value
		_update_visuals()
		update_configuration_warnings()
## The texture if it has a Animated [member PropOrHazard.visual_type].
@export var texture_animated: SpriteFrames:
	set(value):
		texture_animated = value
		_update_visuals()
		update_configuration_warnings()

@export_category("Hazard Settings")
@export_group('Is Hazard')
## If enabled, this prop will deal damage to HurtBoxes.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_hazard: bool = false:
	set(value):
		is_hazard = value
		_update_hazard_state()

## The amount of health points this hazard reduses.
@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var damage: float = 10.0:
	set(value):
		damage = value
		if is_node_ready() and hitbox_component != null:
			hitbox_component.damage = damage

@export_subgroup("Pulsing Timer", "pulse_")
## The time (in seconds) the hazard stays active.
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_control", "suffix:sec") var pulse_active_time: float = 0.0
## The time (in seconds) the hazard waits before activating.
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_control", "suffix:sec") var pulse_rest_time: float = 0.0

var _is_active: bool = false
var _active_timer: float = 0.0
var _rest_timer: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	
	if visual_type == 0: # Still
		if sprite_still == null:
			warnings.append("You have a Visual Type of Still but no Sprite Still.")
		
		if texture_still == null:
			warnings.append("You have a Visual Type of Still but no Texture Still.")
	
	elif  visual_type == 1: # Animated
		if sprite_animated == null:
			warnings.append("You have a Visual Type of Animated but no Sprite Animated.")
		
		if texture_animated == null:
			warnings.append("You have a Visual Type of Animated but no Texture Animated.")
	
	if is_hazard:
		if hitbox_component == null:
			warnings.append("You have a Hazard but no HitBox, it will do no damage.")
		
		if hitbox_shape == null:
			warnings.append("You have a Hazard but no HitBox Shape.")
	
	if collision_shape == null:
		warnings.append("To work attach a Colision Shape")
	
	return warnings

func _ready() -> void:
	if not Engine.is_editor_hint():
		if hitbox_component != null:
			hitbox_component.damage = damage
			
		_active_timer = pulse_active_time
		_rest_timer = pulse_rest_time
		
		# If both timers are 0, it's a constant hazard. Turn off processing to save CPU.
		if pulse_active_time <= 0.0 and pulse_rest_time <= 0.0:
			set_process(false)
		
		_update_visuals()
		_update_hazard_state()
		_from_start()

func _update_visuals() -> void:
	if not is_node_ready(): return
	
	if visual_type == 0 and sprite_still != null:
		sprite_still.visible = true
		sprite_still.texture = texture_still
		if sprite_animated != null:
			sprite_animated.visible = false
	elif visual_type == 1 and sprite_animated != null:
		sprite_animated.visible = true
		sprite_animated.sprite_frames = texture_animated
		if sprite_still != null:
			sprite_still.visible = false
		if not Engine.is_editor_hint():
			sprite_animated.play()

func _update_hazard_state() -> void:
	if not is_node_ready() or hitbox_shape == null: return
	
	if Engine.is_editor_hint():
		hitbox_shape.set_deferred("disabled", not is_hazard)
	else:
		# During gameplay, force the starting state based on the rest timer
		if is_hazard:
			_is_active = (pulse_rest_time <= 0.0)
			hitbox_shape.set_deferred("disabled", not _is_active)
		else:
			hitbox_shape.set_deferred("disabled", true)

func _process(delta: float) -> void:
	_update(delta)
	if Engine.is_editor_hint() or not is_hazard or hitbox_shape == null: 
		return
		
	if _is_active:
		if _active_timer > 0.0:
			_active_timer -= delta
			if _active_timer <= 0.0:
				_is_active = false
				_active_timer = pulse_active_time # Reset for next cycle
				hitbox_shape.set_deferred("disabled", true)
	else:
		if _rest_timer > 0.0:
			_rest_timer -= delta
			if _rest_timer <= 0.0:
				_is_active = true
				_rest_timer = pulse_rest_time # Reset for next cycle
				hitbox_shape.set_deferred("disabled", false)

func _physics_process(delta: float) -> void:
	_physics_update(delta)

## A replacement of [b]_ready[/b]
func _from_start()->void:pass
## A replacement of [b]_process[/b]
func _update(delta:float)->void:pass
## A replacement of [b]_physics_process[/b]
func _physics_update(delta:float)->void:pass
