@tool
extends EditorScript

func _run() -> void:
	var chars = [
		{ "id": 1, "color": Color(0.85, 0.2, 0.15), "name": "Warrior" },
		{ "id": 2, "color": Color(0.15, 0.7, 0.2), "name": "Scout" },
		{ "id": 3, "color": Color(0.15, 0.25, 0.85), "name": "Seer" },
		{ "id": 4, "color": Color(0.7, 0.15, 0.7), "name": "Gambler" }
	]
	for c in chars:
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color.TRANSPARENT)
		var col: Color = c.color
		var cloak2 := col.darkened(0.2)
		_draw_hero(img, col, cloak2)
		var dir := "res://assets/Heroes/%d" % c.id
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
		var path := dir + "/Protect.png"
		img.save_png(ProjectSettings.globalize_path(path))
		print("Generated: ", path)

func _draw_hero(img: Image, cloak1: Color, cloak2: Color) -> void:
	var skin := Color(0.87, 0.72, 0.53)
	var hair := Color(0.23, 0.14, 0.03)
	var eye := Color(0.1, 0.04, 0.0)
	var feet := Color(0.4, 0.26, 0.13)
	var sword := Color(0.25, 0.41, 0.88)
	var glow := Color(0.0, 0.75, 1.0)
	var guard := Color(1.0, 0.84, 0.0)
	_fill_rect(img, 12, 4, 19, 6, hair)
	_fill_rect(img, 11, 7, 20, 12, skin)
	_fill_rect(img, 13, 8, 14, 9, eye)
	_fill_rect(img, 17, 8, 18, 9, eye)
	_fill_rect(img, 9, 13, 22, 22, cloak1)
	_fill_rect(img, 10, 23, 21, 28, cloak2)
	img.set_pixel(10, 16, skin)
	img.set_pixel(21, 16, skin)
	_fill_rect(img, 11, 29, 14, 30, feet)
	_fill_rect(img, 17, 29, 20, 30, feet)
	_fill_rect(img, 24, 5, 25, 20, sword)
	img.set_pixel(24, 8, glow)
	img.set_pixel(25, 8, glow)
	img.set_pixel(24, 14, glow)
	img.set_pixel(25, 14, glow)
	_fill_rect(img, 23, 21, 26, 22, guard)
	img.set_pixel(24, 23, feet)
	img.set_pixel(25, 23, feet)

func _fill_rect(img: Image, x1: int, y1: int, x2: int, y2: int, col: Color) -> void:
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			img.set_pixel(x, y, col)
