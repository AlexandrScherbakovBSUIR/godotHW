extends Area2D
class_name Hexagon

const GRID_STEP_X := 106
const GRID_STEP_Y := 60
const GRID_OFFSET_X := GRID_STEP_X / 2
const GRID_OFFSET_Y := GRID_STEP_Y / 2

signal region_selected

var shape : PackedVector2Array: set = set_shape
var grid_pos := Vector2.ZERO
var neighbour_1 := Vector2.ZERO
var neighbour_2 := Vector2.ZERO
var neighbour_3 := Vector2.ZERO
var neighbour_4 := Vector2.ZERO
var neighbour_5 := Vector2.ZERO
var neighbour_6 := Vector2.ZERO
var is_player_step_on := false
var value := randi() % 5
var is_on_player_pass := false
var is_rock := false
var is_poi := false
var mouse_point := false
var is_fogged := true: set = set_fogged

@onready var _poly := $Polygon2D
@onready var _coll := $CollisionPolygon2D
@onready var _poi_label := $PoiLabel

var _fog_node: Node2D

static var _star_tex: ImageTexture

func set_shape(new_shape: PackedVector2Array):
	_poly.set_polygon(new_shape)
	_poly.color = Color("DARK_KHAKI")
	_poly.color.a = 0.6
	_coll.set_polygon(new_shape)
	shape = new_shape
	_setup_fog(new_shape)
	_apply_fog()

func set_fogged(val: bool) -> void:
	is_fogged = val
	if not is_node_ready():
		return
	_apply_fog()

func _apply_fog() -> void:
	_fog_node.visible = is_fogged
	_poly.visible = not is_fogged
	_poi_label.visible = not is_fogged and is_poi
	_coll.disabled = is_fogged

func _setup_fog(poly: PackedVector2Array) -> void:
	_fog_node = Node2D.new()
	_fog_node.name = "FogLayer"
	add_child(_fog_node)

	var fog_poly := Polygon2D.new()
	fog_poly.polygon = poly
	fog_poly.color = Color(0.12, 0.02, 0.22, 0.92)
	_fog_node.add_child(fog_poly)

	if _star_tex == null:
		var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		for x in 6:
			for y in 6:
				var d := Vector2(x - 2.5, y - 2.5).length()
				if d <= 2.0:
					img.set_pixel(x, y, Color(1, 1, 1, 1.0 - d / 2.5))
		_star_tex = ImageTexture.create_from_image(img)

	var rng := RandomNumberGenerator.new()
	var bounds := _poly_bounds(poly)
	for _i in range(3 + rng.randi() % 4):
		var star := Sprite2D.new()
		star.texture = _star_tex
		var s := 0.6 + rng.randf() * 1.8
		star.scale = Vector2(s, s)
		star.self_modulate = Color(1, 1, 1, 0.4 + rng.randf() * 0.6)
		for _attempt in 20:
			var pos := Vector2(
				rng.randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
				rng.randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
			)
			if Geometry2D.is_point_in_polygon(pos, poly):
				star.position = pos
				break
		_fog_node.add_child(star)

func _poly_bounds(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for i in range(1, poly.size()):
		r = r.expand(poly[i])
	return r

func _on_Hexagon_mouse_entered():
	mouse_point = true

func _on_Hexagon_mouse_exited():
	mouse_point = false

func _on_Hexagon_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if is_on_player_pass:
			is_player_step_on = true
			region_selected.emit()

func _process(delta: float) -> void:
	if is_fogged:
		return
	_poi_label.visible = is_poi
	if is_rock:
		_poly.color = Color("SADDLE_BROWN")
		_poly.color.a = 1.0
		return
	if is_poi:
		_poly.color = Color("GOLD")
		_poly.color.a = 1.0
	elif is_player_step_on:
		_poly.color = Color("BLACK")
	else:
		_poly.color = Color("DARK_KHAKI")
	if is_on_player_pass:
		_poly.color.a = 0.3
	else:
		_poly.color.a = 1.0 if not mouse_point else 0.6

func set_neighbours(gp: Vector2) -> void:
	var screen_size := get_viewport_rect().size
	var m := 50

	var n1 := gp + Vector2(0, -GRID_STEP_Y)
	if n1.y >= m:
		neighbour_1 = n1

	var n2 := gp + Vector2(GRID_OFFSET_X, -GRID_OFFSET_Y)
	if n2.x <= screen_size.x - m and n2.y >= m:
		neighbour_2 = n2

	var n3 := gp + Vector2(GRID_OFFSET_X, GRID_OFFSET_Y)
	if n3.x <= screen_size.x - m and n3.y <= screen_size.y - m:
		neighbour_3 = n3

	var n4 := gp + Vector2(0, GRID_STEP_Y)
	if n4.y <= screen_size.y - m:
		neighbour_4 = n4

	var n5 := gp + Vector2(-GRID_OFFSET_X, GRID_OFFSET_Y)
	if n5.x >= m and n5.y <= screen_size.y - m:
		neighbour_5 = n5

	var n6 := gp + Vector2(-GRID_OFFSET_X, -GRID_OFFSET_Y)
	if n6.x >= m and n6.y >= m:
		neighbour_6 = n6
