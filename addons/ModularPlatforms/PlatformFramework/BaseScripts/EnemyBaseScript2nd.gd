@tool
extends CharacterBody2D
class_name Enemy2

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

@export var attack_see_distance:float = 36.0

@export var players:Array[CharacterBody2D] = []

var gravity:float
var speed:float
var _move_direction:float = -1.0:
	set(value):
		if _disable_change_directions: return
		_move_direction = value
		_disable_change_directions = true
		await get_tree().create_timer(0.5).timeout
		_disable_change_directions = false
var _stationary:bool
var _disable_change_directions:bool = false
var _attack_raycast:RayCast2D
var _is_attacking:bool = false
var _multiplayers:bool = false
var _direction_cooldown_timer: float = 0.0

func _ready() -> void:
	if not stats:
		push_error("You need to identify your Enemy, you have to add Stats!")
		return
	else:
		if stats.has_method(&"get_setup_data"):
			_setup_stats()
		else:
			push_error("You did not have the get_setup_data method! Check Documents!")
			return
	
	_attack_raycast = RayCast2D.new()
	add_child(_attack_raycast)
	
	_attack_raycast.target_position = Vector2(attack_see_distance, 0.0)
	
	if players.is_empty():
		push_error("You have no players added!")
		return
	
	_multiplayers = true if players.size() > 1 else false
	
	_from_start()


func _process(delta: float) -> void:
	_update(delta)

func _physics_process(delta: float) -> void:
	_physics_update(delta)
	
	if not Engine.is_editor_hint():
		if _direction_cooldown_timer > 0.0:
			_direction_cooldown_timer -= delta
		
		_update_targeting()
		
		if move_preset == Movement.DEFAULT:
			if not is_on_floor():
				velocity.y += gravity * delta
			
			if not _stationary:
				velocity.x = speed * _move_direction
			
			if _is_attacking:
				velocity = Vector2.ZERO
				var target:CharacterBody2D = _attack_raycast.get_collider()
				
			
			if is_on_wall() and _direction_cooldown_timer <= 0.0:
				_move_direction = - _move_direction
				_direction_cooldown_timer = 0.5

		move_and_slide()

func _update_targeting() -> void:
	if players.is_empty():
		return

	var nearest_target: Node2D = null
	var min_distance_sq: float = INF

	for node in players:
		var target := node as Node2D
		if not is_instance_valid(target):
			continue
		var dist_sq: float = global_position.distance_squared_to(target.global_position)
		if dist_sq < min_distance_sq:
			min_distance_sq = dist_sq
			nearest_target = target

	if nearest_target:
		_attack_raycast.look_at(nearest_target.global_position)
		_is_attacking = _attack_raycast.is_colliding()
	else:
		_is_attacking = false

#----------------------Inharitance Functions-----------------------

## A [b]_ready[/b] replacement. Do not use [b]_ready[/b]!
func _from_start() -> void: pass

## A [b]_process[/b] replacement. Do not use [b]_process[/b]!
func _update(_delta:float) -> void:pass

## A [b]_physics_process[/b] replacement. Do not use [b]_physics_process[/b]!
func _physics_update(_delta:float) -> void:pass

func _setup_stats() -> void:
	var dict:Dictionary = stats.get_setup_data()
	speed = dict["speed"]
	gravity = dict["gravity"]
	_stationary = dict["stationary"]
	#damage = dict["damage"]
