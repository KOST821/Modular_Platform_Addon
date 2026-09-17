@tool
@icon("bomb.svg")
extends PropOrHazard
## A basic Hazard.
class_name Hazard

func _enter_tree() -> void:
	is_hazard = true
