extends Node2D
class_name LampRoom
## Lamp-room chapter (Public Demo scaffold).
##
## The spiral stair from the ground floor (see scripts/game.gd, the "door"
## interactable) leads here. Relighting the great light is the demo's closing
## beat. This is a scaffold: the room builds an empty space and a placeholder
## lamp; the puzzle + dialogue land in the demo content pass.

@onready var _state := GameState


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#0b1216")
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var lamp := ColorRect.new()
	lamp.color = Color("#2a2f33")  # dead lamp; lights once relit
	lamp.size = Vector2(120, 120)
	lamp.position = Vector2(580, 220)
	add_child(lamp)

	# TODO(demo): player + interactable "great lamp"; relight sets a flag and
	# plays the lamp-room dialogue (data/dialogue/lamp_room.json).


func is_lamp_lit() -> bool:
	return bool(_state.get_flag("lamp_relit", false))
