@tool
@abstract
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

@export var stats:Resource = null
@export var move_preset:Movement = Movement.DEFAULT

var speed:float
var gravity:float
var stationary:bool
var damage:float

var _move_direction:float = 1.0

func _ready() -> void:
	_from_start()
	if not stats:
		push_error("You need to identify your Enemy, you have to add Stats!")
		return
	else:
		if stats.has_method(&"give_setup"):
			_setup_stats()
		else:
			push_error("You did not have the give_setup method! Check Documents!")
			return

func _process(delta: float) -> void:
	_update(delta)

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
	var dict:Dictionary = stats.give_setup()
	speed = dict["speed"]
	gravity = dict["gravity"]
	stationary = dict["stationary"]
	damage = dict["damage"]

#----------------------Inharitance Functions-----------------------

## A [b]_ready[/b] replacement. Do not use [b]_ready[/b]!
func _from_start() -> void: pass

## A _process replacement. Do not use _process!
func _update(_delta:float) -> void:pass

## A _physics_process replacement. Do not use _physics_process!
func _physics_update(_delta:float) -> void:pass
