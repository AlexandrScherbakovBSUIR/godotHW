extends Node2D

@onready var map_area := $MapArea
@onready var stats_label := $SidePanel/VBox/StatsLabel
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

func _ready() -> void:
	map_area.stats_changed.connect(update_stats_display)
	map_area.cards_changed.connect(update_cards_ui)
	update_stats_display()
	update_cards_ui()

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
	print("New Game")

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

func _on_button_pressed_1() -> void:
	map_area._on_button_pressed_1()
