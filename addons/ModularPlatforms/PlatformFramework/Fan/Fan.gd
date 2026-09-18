@tool
class_name Fan
extends PropOrHazard

enum AIR_DIR \
{
	## Air pushes the body that entered it's [member Fan.wind_zone] up.
	UP,
	## Air pushes the body that entered it's [member Fan.wind_zone] down.
	DOWN,
	## Air pushes the body that entered it's [member Fan.wind_zone] left.
	LEFT,
	## Air pushes the body that entered it's [member Fan.wind_zone] right.
	RIGHT
}

@export_category("Wind Settings")
## The Area2D that defines the volume of the wind stream.
@export var wind_zone: Area2D
## The direction the wind blows.
@export var wind_direction: AIR_DIR = AIR_DIR.UP
## How strong the wind pushes. To overcome gravity for CharacterBodies pushing UP, this needs to be high (e.g., 1500+).
@export var wind_strength: float = 1500.0
## A number that reduses the force to non physics objects like [Area2D].
@export_range(0.01, 1.0, 0.01, "prefer_slider") var non_physics_dampener:float = 0.05

var _entities_in_wind: Array[Node2D] = []

func _from_start() -> void:
	if not Engine.is_editor_hint() and wind_zone != null:
		# Connect the signals to track what enters/leaves the wind
		
		## Bodies
		if !wind_zone.body_entered.is_connected(_on_entity_entered):
			wind_zone.body_entered.connect(_on_entity_entered)
		if !wind_zone.body_exited.is_connected(_on_entity_exited):
			wind_zone.body_exited.connect(_on_entity_exited)
		
		## Areas
		if !wind_zone.area_entered.is_connected(_on_entity_entered):
			wind_zone.area_entered.connect(_on_entity_entered)
		if !wind_zone.area_exited.is_connected(_on_entity_exited):
			wind_zone.area_exited.connect(_on_entity_exited)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super() # Keep the base class warnings
	if wind_zone == null:
		warnings.append("Fan requires a Wind Zone (Area2D) to function.")
	return warnings

func _on_entity_entered(entity: Node2D) -> void:
	if !entity is CollisionObject2D:return
	if not _entities_in_wind.has(entity) and entity != self:
		_entities_in_wind.append(entity)

func _on_entity_exited(entity: Node2D) -> void:
	if _entities_in_wind.has(entity):
		_entities_in_wind.erase(entity)

func _physics_update(delta: float) -> void:
	if Engine.is_editor_hint() or _entities_in_wind.is_empty():
		return
	
	# Determine the direction vector based on the enum
	var dir_vector: Vector2 = _calculate_air_direction()

	var force: Vector2 = dir_vector * wind_strength
	
	for entity in _entities_in_wind:
		if not is_instance_valid(entity):
			continue
			
		if entity is RigidBody2D:
			# RigidBodies handle gravity internally. We just apply a continuous central force.
			entity.apply_central_force(force)
			
		elif entity is CharacterBody2D:
			# CharacterBodies require direct velocity manipulation. 
			# This adds continuous acceleration, allowing it to fight gravity.
			entity.velocity += force * delta
			if wind_direction == AIR_DIR.UP and entity.is_on_floor():
				entity.global_position.y -= 1.0
			# 1. Break Godot's floor snapping violently.
			# If pushing horizontally while on the floor, lift them 2 pixels into the air.
			if (wind_direction == AIR_DIR.LEFT or wind_direction == AIR_DIR.RIGHT) and entity.is_on_floor():
				var displacement = force * delta * delta
				entity.global_position += displacement
			
		elif entity is Area2D:
			# Areas do not have physics bodies. We manually translate them.
			# Scaled down drastically so they don't instantly fly off screen.
			entity.global_position += force * delta * non_physics_dampener
			
		elif entity is StaticBody2D:
			# Ignored intentionally. Static bodies are fixed in space by definition. 
			# Attempting to move them breaks physics engine assumptions.
			pass

func _calculate_air_direction() -> Vector2:
	match wind_direction:
		AIR_DIR.UP: return Vector2.UP
		AIR_DIR.DOWN: return Vector2.DOWN
		AIR_DIR.LEFT: return Vector2.LEFT
		AIR_DIR.RIGHT: return Vector2.RIGHT
	return Vector2.ZERO
