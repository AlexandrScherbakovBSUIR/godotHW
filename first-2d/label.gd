extends Label


func _on_button_pressed() -> void:
	set_process(not is_processing())
