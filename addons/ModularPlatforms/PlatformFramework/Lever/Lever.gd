@tool
@icon("lever.svg")
extends Trigger
## A [Trigger] that if pushed away of the starting position activates and what it is pushed to the starting position it closes.
class_name Lever

enum WAY\
{
	## The animation is played from Left to Right.
	LEFT_TO_RIGHT,
	## The animation is played from Right to Left.
	RIGHT_TO_LEFT
}

enum STARTING_POS\
{
	## The starting position of the lever is Left.
	LEFT,
	## The starting position of the lever is Left.
	RIGHT
}

@export_category("Setup")
## The starting position of the lever
@export var starting_position:STARTING_POS = STARTING_POS.RIGHT
## The collision of the [member Trigger.use_point]
@export var collision: Node2D:
	set(value):
		collision = value
		update_configuration_warnings()

var _is_left:bool = false

@export_category("Settings")
## The width of your Sprite.
@export_range(0, 100, 1,"or_greater", "hide_control", "suffix:px") var texture_width:int = 32
## If the sprite is an [AnimatedSprite2D] sets the animation true run.
@export var animation_play:WAY = WAY.RIGHT_TO_LEFT

var _switched:bool = false

const TIME:float = 0.27

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray
	
	if use_point == null:
		warnings.append('You have no "use_point", you MUST add an Area2D')
	
	if sprite == null:
		warnings.append('You did not filled the "sprite"')
	
	elif not (sprite is AnimatedSprite2D or sprite is Sprite2D):
		warnings.append('Your sprite MUST be an AnimatedSprite2D or Sprite2D')
	
	if collision == null:
		warnings.append('You did not filled the "collision"')
	
	elif not (collision is CollisionPolygon2D or collision is CollisionShape2D):
		warnings.append('Your collision MUST be an CollisionPolygon2D or CollisionShape2D')
	
	return warnings

func _from_start() -> void:
	set_process(false)
	match starting_position:
		STARTING_POS.LEFT:
			_is_left = true
		STARTING_POS.RIGHT:
			_is_left = false
	
	use_point.body_entered.connect(_switch)
	set_correct_collision()

func set_correct_collision() -> void:
	collision.position.x = 0.0
	
	match _is_left:
		true:
			collision.position.x -= texture_width
		false:
			collision.position.x += texture_width

func _switch(_body:Node2D) -> void:
	if _switched:
		return
	
	if sprite is AnimatedSprite2D:
		# Determine if we should play forward based on the physical state
		var play_forward: bool = true
		
		if _is_left:
			play_forward = (starting_position == STARTING_POS.LEFT)
		else:
			play_forward = (starting_position == STARTING_POS.RIGHT)
			
		# Invert the playback if the native animation is drawn right-to-left
		if animation_play == WAY.RIGHT_TO_LEFT:
			play_forward = !play_forward

		if play_forward:
			sprite.play()
		else:
			sprite.play_backwards()
			
	elif sprite is Sprite2D:
		sprite.flip_h = !sprite.flip_h
	
	_switched = true
	_is_left = !_is_left
	set_correct_collision()
	
	var is_on: bool = (_is_left and starting_position == STARTING_POS.RIGHT\
	 or not _is_left and starting_position == STARTING_POS.LEFT)
	if is_on:
		pressed.emit(self)
	else:
		released.emit(self)
	toggle.emit(is_on, self)
	
	await get_tree().create_timer(TIME).timeout
	_switched = false
