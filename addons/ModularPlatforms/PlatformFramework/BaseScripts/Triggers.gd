@tool
@icon("crate.svg")
@abstract
## An abstract class that contains triggers that can connect with TriggerPlatforms.
class_name Trigger
extends Node2D

## Emitted when pressed.
signal pressed(trigger:Node2D)
## Emitted when released.
signal released(trigger:Node2D)
## Emitted when toggled.
signal toggle(is_on:bool, trigger:Node2D)

## The [Area2D] that searches for a person to trigger it.
@export var use_point: Area2D:
	set(area):
		use_point = area
		update_configuration_warnings()

## The [Sprite2D] or [AnimatedSprite2D] that holds your visual.
@export var sprite: Node2D:
	set(sprite2d):
		sprite = sprite2d
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	
	if sprite == null:
		warnings.append('You do not have a value added in "sprite".')
	
	elif not (sprite is AnimatedSprite2D or sprite is Sprite2D):
		warnings.append('Your sprite MUST be an AnimatedSprite2D or Sprite2D')
	
	if use_point == null:
		warnings.append('You do not have a Area2D added in "use_point".')
	
	return warnings

func _ready() -> void:
	_from_start()


func _from_start() -> void: pass
