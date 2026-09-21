@tool
extends Resource
class_name EnemyStats

## The name of your enemy.
@export_placeholder("Name") var name: String
## An key that is the same for all of this type of enemies.
@export var id: StringName
## How fast your enemy moves.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var speed: float
## How much weight does your enemy have.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²") var gravity: float
## If [b]true[/b], your enemy is not moving.
@export var stationary: bool = false
## How much damage the enemy deals.
@export var damage: float

## Generate an ID that will be given to this resource instances.
func random_id() -> void:
	if !id.is_empty(): return
	var array:Array[String] = []
	for i in 4:
		array.append(str(randi_range(0,9)))
	for i in 2:
		array.append(char(randi_range(97, 122)))
	
	array.shuffle()
	array.shuffle()
	array.shuffle()
	
	for i in array:
		id += i

## If you make your own stats, copy paste this function and change non "" variables with your matching names of your own.
func get_setup_data() -> Dictionary:
	return\
	{
		"speed": speed,
		"gravity": gravity,
		"stationary": stationary,
		"damage": damage
	}

## Get the ID that is given to this resource instances.
func get_id() -> StringName:
	return id

## Get the unique ID of the current instance of this resource.
func get_unique_id() -> StringName:
	return str(get_instance_id())
