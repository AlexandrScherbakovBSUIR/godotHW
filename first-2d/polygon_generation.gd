extends Node2D

const HexagonScene := preload("res://Hexagon.tscn")
const HEX_SIZE := 35.0
const HEX_GAP := 4.0
const VISUAL_SIZE := HEX_SIZE - HEX_GAP
const SQRT3 := sqrt(3.0)
const HEX_HEIGHT := SQRT3 * HEX_SIZE
const _step_x := int(HEX_SIZE * 3.0)
const _step_y := int(HEX_HEIGHT)
const GRID_STEP_X := _step_x + (_step_x % 2)
const GRID_STEP_Y := _step_y + (_step_y % 2)
const GRID_OFFSET_X := GRID_STEP_X / 2
const GRID_OFFSET_Y := GRID_STEP_Y / 2

var hexagon_grid_positions := PackedVector2Array()
var hexagon_array := Array()
var movement_speed := 2
var vision_range := 3
var attack := 2
var defense := 3
var dice_count := 1
var score := 0
var path_hexagon_counter := 0

signal stats_changed
signal cards_changed
var card_slots: Array = []

const CARD_SPEED := 0
const CARD_ATTACK := 1
const CARD_DICE := 2
const CARD_VISION := 3

const CARD_COLORS := {
	CARD_SPEED: Color(0, 0.7, 0, 0.85),
	CARD_ATTACK: Color(0.8, 0, 0, 0.85),
	CARD_DICE: Color(0, 0.35, 0.85, 0.85),
	CARD_VISION: Color(0.5, 0, 0.6, 0.85)
}
const CARD_LABELS := {
	CARD_SPEED: "S+1",
	CARD_ATTACK: "A+1",
	CARD_DICE: "D+1",
	CARD_VISION: "V+1"
}
var player_start_pos := 10
var player_grid_pos := Vector2.ZERO

const MENU_HEIGHT := 48
const RIGHT_PANEL_WIDTH := 320

var margin := 50

func _ready() -> void:
	var screen_size := get_viewport_rect().size
	var hex_extent_x := HEX_SIZE + VISUAL_SIZE
	var hex_extent_y := HEX_HEIGHT / 2.0 + VISUAL_SIZE * SQRT3 / 2.0
	var right_margin := RIGHT_PANEL_WIDTH + margin
	var top_offset := MENU_HEIGHT + margin
	var end_x := int(screen_size.x - right_margin - GRID_OFFSET_X - hex_extent_x)
	var end_y := int(screen_size.y - top_offset - global_position.y - GRID_OFFSET_Y - hex_extent_y)
	for x in range(margin, end_x, GRID_STEP_X):
		for y in range(margin, end_y, GRID_STEP_Y):
			hexagon_grid_positions.append(Vector2(x, y))
			hexagon_grid_positions.append(Vector2(x + GRID_OFFSET_X, y + GRID_OFFSET_Y))
	hexagon_grid_positions.sort()
	for grid_pos in hexagon_grid_positions:
		hexagon_array.append(create_hexagon(grid_pos))
	generate_rocks()
	generate_poi()
	var start_hex := hexagon_array[10] as Hexagon
	start_hex.is_player_step_on = true
	player_grid_pos = hexagon_grid_positions[player_start_pos]
	hexagon_selected(player_grid_pos)
	update_fog(player_grid_pos)
	_init_cards()

func create_hexagon(grid_pos: Vector2) -> Hexagon:
	var hexagon := HexagonScene.instantiate() as Hexagon
	add_child(hexagon)

	var center := Vector2(grid_pos.x + HEX_SIZE, grid_pos.y + HEX_HEIGHT / 2.0)
	var shape := PackedVector2Array()
	for i in range(6):
		var angle := deg_to_rad(60.0 * i + 240.0)
		shape.append(center + VISUAL_SIZE * Vector2(cos(angle), sin(angle)))
	hexagon.set_shape(shape)
	hexagon.grid_pos = grid_pos
	hexagon.set_neighbours(grid_pos)
	hexagon.region_selected.connect(hexagon_selected.bind(grid_pos))
	return hexagon

func hexagon_selected(grid_pos: Vector2) -> void:
	var poi_hex: Hexagon = null
	for hexagon in hexagon_array:
		var h := hexagon as Hexagon
		if h.grid_pos == grid_pos and h.is_poi:
			poi_hex = h
		h.is_player_step_on = h.grid_pos == grid_pos
		if h.grid_pos != grid_pos:
			h.is_on_player_pass = false

	if poi_hex != null:
		poi_hex.is_poi = false
		_handle_poi_reward()

	player_grid_pos = grid_pos
	create_path(grid_pos, movement_speed)
	update_fog(grid_pos)
	path_hexagon_counter = 0

func create_path(start_pos: Vector2, max_steps: int):
	var visited := PackedVector2Array()
	var queue := []
	queue.append(start_pos)
	queue.append(0)

	var front := 0
	while front < queue.size():
		var pos := queue[front] as Vector2
		var dist := queue[front + 1] as int
		front += 2

		if visited.find(pos) >= 0:
			continue
		visited.append(pos)

		var idx := hexagon_grid_positions.find(pos)
		if idx < 0:
			continue

		var hexagon := hexagon_array[idx] as Hexagon
		path_hexagon_counter += 1

		if hexagon.is_rock:
			continue

		if not hexagon.is_player_step_on:
			hexagon.is_on_player_pass = true

		if dist < max_steps:
			var nd := dist + 1
			for n in [hexagon.neighbour_1, hexagon.neighbour_2, hexagon.neighbour_3,
					  hexagon.neighbour_4, hexagon.neighbour_5, hexagon.neighbour_6]:
				if n != Vector2.ZERO and visited.find(n) < 0:
					queue.append(n)
					queue.append(nd)

func generate_rocks() -> void:
	var start_pos := hexagon_grid_positions[player_start_pos]
	for hex in hexagon_array:
		var h := hex as Hexagon
		if h.grid_pos.distance_to(start_pos) < 200.0:
			continue
		if randf() < 0.15:
			h.is_rock = true

func generate_poi() -> void:
	var start_pos := hexagon_grid_positions[player_start_pos]
	for hex in hexagon_array:
		var h := hex as Hexagon
		if h.is_rock or h.grid_pos.distance_to(start_pos) < 200.0:
			continue
		if randf() < 0.10:
			h.is_poi = true

func roll_dice() -> void:
	var dice_label := Label.new()
	dice_label.text = "?"
	dice_label.add_theme_font_size_override("font_size", 72)
	dice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dice_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(dice_label)

	var result := randi_range(1, 6)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)

	for i in range(12):
		var val := randi_range(1, 6)
		tween.tween_callback(dice_label.set_text.bind(str(val)))
		tween.tween_interval(0.06 + i * 0.02)

	tween.tween_callback(dice_label.set_text.bind(str(result)))
	tween.tween_interval(1.0)
	tween.tween_callback(dice_label.queue_free)
	tween.tween_callback(_on_dice_done.bind(result))

func _on_dice_done(result: int) -> void:
	score += result
	stats_changed.emit()

func _has_empty_card_slot() -> bool:
	for i in card_slots.size():
		if card_slots[i] == null:
			return true
	return false

func _handle_poi_reward() -> void:
	if _has_empty_card_slot() and randi() % 2 == 0:
		_give_random_card()
		stats_changed.emit()
		cards_changed.emit()
	else:
		roll_dice()

func _give_random_card() -> void:
	var types := [CARD_SPEED, CARD_ATTACK, CARD_DICE, CARD_VISION]
	var card = types[randi() % types.size()]
	for i in card_slots.size():
		if card_slots[i] == null:
			card_slots[i] = card
			match card:
				CARD_SPEED:
					movement_speed += 1
				CARD_ATTACK:
					attack += 1
				CARD_DICE:
					dice_count += 1
				CARD_VISION:
					vision_range += 1
			if card == CARD_VISION:
				update_fog(player_grid_pos)
			return

func update_fog(player_grid_pos: Vector2) -> void:
	for hexagon in hexagon_array:
		var h := hexagon as Hexagon
		h.is_fogged = true

	var visited := PackedVector2Array()
	var queue := []
	queue.append(player_grid_pos)
	queue.append(0)

	var front := 0
	while front < queue.size():
		var pos := queue[front] as Vector2
		var dist := queue[front + 1] as int
		front += 2

		if visited.find(pos) >= 0:
			continue
		visited.append(pos)

		var idx := hexagon_grid_positions.find(pos)
		if idx < 0:
			continue

		var hexagon := hexagon_array[idx] as Hexagon
		hexagon.is_fogged = false

		if dist < vision_range:
			var nd := dist + 1
			for n in [hexagon.neighbour_1, hexagon.neighbour_2, hexagon.neighbour_3,
					  hexagon.neighbour_4, hexagon.neighbour_5, hexagon.neighbour_6]:
				if n != Vector2.ZERO and visited.find(n) < 0:
					queue.append(n)
					queue.append(nd)

func _on_button_pressed_1() -> void:
	movement_speed = randi_range(1, 3)

func _init_cards() -> void:
	card_slots.resize(6)

func use_card(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= card_slots.size():
		return
	var card = card_slots[slot_index]
	if card == null:
		return

	match card:
		CARD_SPEED:
			movement_speed += 1
		CARD_ATTACK:
			attack += 1
		CARD_DICE:
			dice_count += 1
		CARD_VISION:
			vision_range += 1

	card_slots[slot_index] = null
	if card == CARD_VISION:
		update_fog(player_grid_pos)
