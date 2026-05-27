extends Window

signal character_selected(char_index: int)

var _characters: Array = []
var _current_index := 0

@onready var icon_container := $VBox/HBox/Center/IconContainer
@onready var icon_letter := $VBox/HBox/Center/IconContainer/Letter
@onready var name_label := $VBox/NameLabel
@onready var desc_label := $VBox/DescLabel

func _ready() -> void:
	_load_characters()
	_update_display()

func _load_characters() -> void:
	var file := FileAccess.open("res://characters.json", FileAccess.READ)
	if file == null:
		push_error("Cannot open characters.json")
		return
	var text := file.get_as_text()
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		push_error("characters.json parse error: ", json.get_error_message())
		return
	_characters = json.data
	for c in _characters:
		var arr: Array = c.color
		c.color = Color(arr[0], arr[1], arr[2])

func _update_display() -> void:
	var c: Dictionary = _characters[_current_index]
	var style := StyleBoxFlat.new()
	style.bg_color = c.color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	icon_container.add_theme_stylebox_override("panel", style)
	icon_letter.text = c.letter
	name_label.text = c.name
	desc_label.text = c.desc

func _on_left_pressed() -> void:
	_current_index = (_current_index - 1 + _characters.size()) % _characters.size()
	_update_display()

func _on_right_pressed() -> void:
	_current_index = (_current_index + 1) % _characters.size()
	_update_display()

func _on_select_pressed() -> void:
	character_selected.emit(_current_index)
	queue_free()
