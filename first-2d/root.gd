extends Node2D

@onready var map_area := $MapArea
@onready var stats_label := $SidePanel/VBox/StatsLabel
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
@onready var card_slots_ui := [
	$SidePanel/VBox/VBoxCards/CardSlot1,
	$SidePanel/VBox/VBoxCards/CardSlot2,
	$SidePanel/VBox/VBoxCards/CardSlot3,
	$SidePanel/VBox/VBoxCards/CardSlot4,
	$SidePanel/VBox/VBoxCards/CardSlot5,
	$SidePanel/VBox/VBoxCards/CardSlot6
]
@onready var card_labels := [
	$SidePanel/VBox/VBoxCards/CardSlot1/Label,
	$SidePanel/VBox/VBoxCards/CardSlot2/Label,
	$SidePanel/VBox/VBoxCards/CardSlot3/Label,
	$SidePanel/VBox/VBoxCards/CardSlot4/Label,
	$SidePanel/VBox/VBoxCards/CardSlot5/Label,
	$SidePanel/VBox/VBoxCards/CardSlot6/Label
]

var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_index := 0

func _ready() -> void:
	map_area.dice_target = $SidePanel/VBox/CharacterIcon
	map_area.stats_changed.connect(update_stats_display)
	map_area.cards_changed.connect(update_cards_ui)
	map_area.poi_success.connect(_on_poi_success)
	map_area.poi_fail.connect(_on_poi_fail)
	map_area.sfx_requested.connect(play_sfx)
	$MenuBar/MenuButton.get_popup().id_pressed.connect(_on_menu_id_pressed)
	for i in 8:
		var s := AudioStreamPlayer.new()
		s.bus = "Master"
		add_child(s)
		sfx_pool.append(s)
	update_stats_display()
	update_cards_ui()
	_show_character_select()

func update_stats_display() -> void:
	stats_label.text = "Score: %d\nSpeed: %d\nVision: %d\nAttack: %d\nDefense: %d\nDice: %d" % [
		map_area.score,
		map_area.movement_speed,
		map_area.vision_range,
		map_area.attack,
		map_area.defense,
		map_area.dice_count
	]

func _on_menu_new_game() -> void:
	_show_character_select()

func _show_character_select() -> void:
	var dialog := preload("res://character_select_dialog.tscn").instantiate()
	add_child(dialog)
	dialog.character_selected.connect(_on_character_selected)
	dialog.popup()

func _on_character_selected(index: int) -> void:
	map_area.selected_character_sprite = index + 1
	map_area.reset_game()
	var bonuses := ["attack", "speed", "vision", "dice"]
	map_area.apply_character_starting_bonus(bonuses[index])
	update_stats_display()
	update_cards_ui()

func _on_menu_settings() -> void:
	print("Settings")

func _on_menu_about() -> void:
	print("About")

func _on_menu_id_pressed(id: int) -> void:
	match id:
		1:
			_on_menu_new_game()
		2:
			_on_menu_settings()
		3:
			_on_menu_about()

func _on_poi_success() -> void:
	var icon := $SidePanel/VBox/CharacterIcon
	icon.self_modulate = Color(0, 2.5, 0, 1)
	await get_tree().create_timer(1.2).timeout
	icon.self_modulate = Color(1, 1, 1, 1)

func _on_poi_fail() -> void:
	var icon := $SidePanel/VBox/CharacterIcon
	icon.self_modulate = Color(2.5, 0, 0, 1)
	await get_tree().create_timer(0.8).timeout
	icon.self_modulate = Color(1, 1, 1, 1)

const CARD_COLORS := {
	0: Color(0, 0.7, 0, 0.85),
	1: Color(0.8, 0, 0, 0.85),
	2: Color(0, 0.35, 0.85, 0.85),
	3: Color(0.5, 0, 0.6, 0.85)
}
const CARD_LABELS := {
	0: "S+1",
	1: "A+1",
	2: "D+1",
	3: "V+1"
}

func update_cards_ui() -> void:
	for i in 6:
		var card = map_area.card_slots[i]
		var panel = card_slots_ui[i]
		var label = card_labels[i]
		if card == null:
			panel.self_modulate = Color(0.25, 0.25, 0.25, 0.5)
			label.text = str(i + 1)
		else:
			panel.self_modulate = CARD_COLORS[card]
			label.text = CARD_LABELS[card]

func _on_card_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		map_area.use_card(slot_index)
		update_cards_ui()
		update_stats_display()

func _on_reveal_button_pressed() -> void:
	map_area.clear_all_fog()

func _on_button_pressed_1() -> void:
	map_area._on_button_pressed_1()

func play_sfx(sfx_name: String) -> void:
	var path := "res://assets/Audio/SFX/%s.wav" % sfx_name
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	var player := sfx_pool[sfx_index]
	player.stream = stream
	player.play()
	sfx_index = (sfx_index + 1) % sfx_pool.size()

func play_music(path: String, fade_time: float = 1.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	if music_player.playing:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_time / 2)
		await tween.finished
	music_player.stream = stream
	music_player.volume_db = -40.0
	music_player.play()
	var tween2 := create_tween()
	tween2.tween_property(music_player, "volume_db", -10.0, fade_time / 2)
