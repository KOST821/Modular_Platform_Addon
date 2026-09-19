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

## If you make your own stats, copy paste this function and change non "" variables with your matching names of your own.
func get_setup_data() -> Dictionary:
	return\
	{
		"speed": speed,
		"gravity": gravity,
		"stationary": stationary,
		"damage": damage
	}
