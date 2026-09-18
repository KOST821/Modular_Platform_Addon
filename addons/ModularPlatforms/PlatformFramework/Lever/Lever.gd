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
	## The starting position of the lever is Right.
	RIGHT
}

@export_category("Setup")
## The starting position of the lever
@export var starting_position:STARTING_POS = STARTING_POS.RIGHT

var _is_left:bool = false

@export_category("Settings")
## If [b]true[/b], the [Lever] is going to turn if it is pushed from the correct side.
@export var directional_lever:bool = true
## If the sprite is an [AnimatedSprite2D] sets the animation true run.
@export var animation_play:WAY = WAY.RIGHT_TO_LEFT
## Time (in seconds) that the [Lever] cannot be turned. If you use an [AnimatedSprite2D] it is overwritten by the seconds of the animation.
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var anim_time:float = 0.27

var _switched:bool = false

func _from_start() -> void:
	set_process(false)
	match starting_position:
		
		STARTING_POS.LEFT:
			_is_left = true
		
		STARTING_POS.RIGHT:
			_is_left = false
	
	use_point.body_entered.connect(_switch)

func _switch(body:Node2D) -> void:
	if _switched:
		return
	
	if directional_lever:
		if not _is_left and body.global_position.x < global_position.x:
			# Lever is pointing Right, but player is on the Left. Do nothing.
			return 
		elif _is_left and body.global_position.x > global_position.x:
			# Lever is pointing Left, but player is on the Right. Do nothing.
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
	
	var is_on: bool = (_is_left and starting_position == STARTING_POS.RIGHT\
	 or not _is_left and starting_position == STARTING_POS.LEFT)
	if is_on:
		pressed.emit(self)
	else:
		released.emit(self)
	toggle.emit(is_on, self)
	
	if sprite is AnimatedSprite2D:
		await sprite.animation_finished
	else:
		await get_tree().create_timer(anim_time).timeout
	
	_switched = false
