extends Node2D
## Game — the vertical-slice level: the ground floor of Cape Marrow Light.
## Builds the room, player, interactables, HUD prompt, dialogue box, and a
## pause overlay in code.

const DIALOGUE := "res://data/dialogue/keeper_intro.json"
const INTERACT_RADIUS := 90.0
const ROOM := Rect2(120, 140, 1040, 460)

var _player: Player
var _interactables: Array[Interactable] = []
var _prompt: Label
var _nearest: Interactable = null


func _ready() -> void:
	_build_room()
	_build_player()
	_build_interactables()
	_build_hud()

	var dialogue_box := preload("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue_box)

	DialogueManager.dialogue_started.connect(func(): _set_movement(false))
	DialogueManager.dialogue_finished.connect(func(): _set_movement(true))


func _build_room() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#0f1a22")
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var floor_rect := ColorRect.new()
	floor_rect.color = Color("#1c2b34")
	floor_rect.position = ROOM.position
	floor_rect.size = ROOM.size
	add_child(floor_rect)

	var title := Label.new()
	title.text = "Cape Marrow Light — ground floor"
	title.position = Vector2(ROOM.position.x, ROOM.position.y - 34)
	title.modulate = Color(1, 1, 1, 0.5)
	add_child(title)


func _build_player() -> void:
	_player = Player.new()
	_player.bounds = ROOM.grow(-30)
	_player.position = Vector2(ROOM.position.x + ROOM.size.x * 0.5, ROOM.position.y + ROOM.size.y - 60)
	add_child(_player)

	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	_player.add_child(camera)
	camera.make_current()


func _build_interactables() -> void:
	_add_interactable("Logbook", "Read the keeper's log", "logbook",
		Vector2(ROOM.position.x + 160, ROOM.position.y + 120), Color("#8a6f4b"))
	_add_interactable("Radio set", "Call the mainland", "radio",
		Vector2(ROOM.position.x + ROOM.size.x - 180, ROOM.position.y + 130), Color("#4b6f8a"))
	_add_interactable("Lamp-room stair", "Climb toward the light", "door",
		Vector2(ROOM.position.x + ROOM.size.x * 0.5, ROOM.position.y + 60), Color("#3a4a54"))


func _add_interactable(label: String, prompt: String, start_id: String, pos: Vector2, color: Color) -> void:
	var item := Interactable.new()
	item.label = label
	item.prompt_text = prompt
	item.dialogue_path = DIALOGUE
	item.dialogue_start = start_id
	item.color = color
	item.position = pos
	add_child(item)
	item.setup()
	_interactables.append(item)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	_prompt = Label.new()
	_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.offset_top = -70
	_prompt.offset_left = -200
	_prompt.offset_right = 200
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 20)
	_prompt.modulate = Color("#ffd466")
	_prompt.hide()
	layer.add_child(_prompt)


func _process(_delta: float) -> void:
	_nearest = _find_nearest()
	if _nearest != null:
		_prompt.text = "[ Enter ] %s" % _nearest.prompt_text
		_prompt.show()
	else:
		_prompt.hide()


func _find_nearest() -> Interactable:
	var best: Interactable = null
	var best_dist := INTERACT_RADIUS
	for item in _interactables:
		if not item.can_interact():
			continue
		var dist := _player.position.distance_to(item.position)
		if dist <= best_dist:
			best_dist = dist
			best = item
	return best


func _unhandled_input(event: InputEvent) -> void:
	if DialogueManager.is_active:
		return
	if event.is_action_pressed("ui_accept") and _nearest != null:
		_nearest.interact()
		get_viewport().set_input_as_handled()


func _set_movement(enabled: bool) -> void:
	if _player != null:
		_player.can_move = enabled
