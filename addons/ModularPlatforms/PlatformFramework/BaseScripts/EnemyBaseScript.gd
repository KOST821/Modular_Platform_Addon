@tool
#@abstract
class_name Enemy
extends CharacterBody2D


enum Movement\
{
	## Movement is default.
	DEFAULT,
	## Movement is custom.
	CUSTOM,
	## Movement is created by a FSM.
	FINITE
}

## The stats of this enemy.
@export var stats:EnemyStats = null:
	set(stat):
		if stat != null:
			stats = stat.duplicate_deep()
			print(stats)
			if stats.has_method(&"random_id"):
				stats.random_id()
				print("id")
		else:
			stats = stat

## How will the enemy move.
@export var move_preset:Movement = Movement.DEFAULT
## The racast which scans for enviroment layer.
@export var enviroment_seer: RayCast2D
## How far will the enemy be before reaching a wall when he starts moving backwards.
@export var enviroment_see_distance:float = 36.0
## The enviroment layer.
@export var enviroment_layer:int = 3
## How far can the enemy see for an attack, x is for x axis y for y axis.
@export var damage_see_distance:Vector2 = Vector2(5.0, 1.0)

@export var damage_targets_layers:Array[int] = []

@export var enemy_collision:CollisionShape2D = null

@export var attack_offset:Vector2

var speed:float
var gravity:float
var stationary:bool
var damage:float

var _move_direction:float = 1.0
var _collision_shape: CollisionShape2D = null
var _damage_area: Area2D = null

func _ready() -> void:
	_from_start()
	if not stats:
		push_error("You need to identify your Enemy, you have to add Stats!")
		return
	else:
		if stats.has_method(&"get_setup_data"):
			_setup_stats()
		else:
			push_error("You did not have the get_setup_data method! Check Documents!")
			return
	
	if is_instance_valid(enviroment_seer): 
		enviroment_seer.collision_mask = enviroment_layer
		enviroment_seer.target_position = Vector2(enviroment_see_distance, 0)
	
	_damage_area = Area2D.new()
	_damage_area.collision_layer = 0
	_damage_area.collision_mask = 0
	
	for col in damage_targets_layers:
		_damage_area.set_collision_mask_value(col, true)
	
	add_child(_damage_area)
	_damage_area.position = Vector2.ZERO
	
	_collision_shape = CollisionShape2D.new()
	
	var offset_centre:Vector2 = Vector2.ZERO
	
	if damage_see_distance.x == damage_see_distance.y:
		_collision_shape.shape = CircleShape2D.new()
		_collision_shape.shape.radius = damage_see_distance.x
		offset_centre.x = damage_see_distance.x
	else:
		_collision_shape.shape = RectangleShape2D.new()
		_collision_shape.shape.size.x = damage_see_distance.x
		_collision_shape.shape.size.y = damage_see_distance.y
		offset_centre = damage_see_distance
	
	_damage_area.add_child(_collision_shape)
	_damage_area.position = attack_offset
	_collision_shape.position = offset_centre

func _process(delta: float) -> void:
	_update(delta)
	if not Engine.is_editor_hint():
		if !is_instance_valid(enviroment_seer): return
		if enviroment_seer.is_colliding():
			_move_direction *= -1
			enviroment_seer.scale.x = - enviroment_seer.scale.x
			_damage_area.position.x = - _damage_area.position.x
			enviroment_seer.force_raycast_update()

func _physics_process(delta: float) -> void:
	_physics_update(delta)
	if !Engine.is_editor_hint():
		if move_preset == Movement.DEFAULT:
			if !is_on_floor():
				velocity.y += gravity * delta
			
			if !stationary:
				velocity.x = speed * _move_direction
				
				if is_on_wall():
					_move_direction *= -1
			move_and_slide()

func _setup_stats() -> void:
	var dict:Dictionary = stats.get_setup_data()
	speed = dict["speed"]
	gravity = dict["gravity"]
	stationary = dict["stationary"]
	damage = dict["damage"]

#----------------------Inharitance Functions-----------------------

## A [b]_ready[/b] replacement. Do not use [b]_ready[/b]!
func _from_start() -> void: pass

## A [b]_process[/b] replacement. Do not use [b]_process[/b]!
func _update(_delta:float) -> void:pass

## A [b]_physics_process[/b] replacement. Do not use [b]_physics_process[/b]!
func _physics_update(_delta:float) -> void:pass
