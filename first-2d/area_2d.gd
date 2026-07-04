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
var is_rock := false: set = set_is_rock
var is_poi := false: set = set_is_poi
var poi_level := 0: set = set_poi_level
var mouse_point := false
var is_fogged := true: set = set_fogged
var player_sprite := 0: set = set_player_sprite

@onready var _poly := $Polygon2D
@onready var _coll := $CollisionPolygon2D
@onready var _poi_label := $PoiLabel

const ROCK_PATHS := [
	"res://assets/Rocks/Rock1_1.png",
	"res://assets/Rocks/Rock2_1.png",
	"res://assets/Rocks/Rock5_1.png"
]

const POI_PATHS := [
	"",
	"res://assets/Interests/PNG/1/Brown-gray_ruins1.png",
	"res://assets/Interests/PNG/2/Sand_ruins1.png",
	"res://assets/Interests/PNG/3/Snow_ruins1.png",
	"res://assets/Interests/PNG/4/Water_ruins1.png"
]

var _ground_poly: Polygon2D
var _poi_sprite: Sprite2D
var _rock_sprite: Sprite2D
var _player_sprite_node: Sprite2D
var _pass_path_outline: Line2D
var _fog_node: Node2D
var _poi_lines: Array = []

static var _star_tex: ImageTexture

func set_shape(new_shape: PackedVector2Array):
	_poly.set_polygon(new_shape)
	_poly.color = Color.WHITE
	_poly.color.a = 0.15
	_coll.set_polygon(new_shape)
	shape = new_shape
	_setup_pass_path(new_shape)
	_setup_ground()
	_setup_fog(new_shape)
	_apply_fog()

func set_fogged(val: bool) -> void:
	is_fogged = val
	if not is_node_ready():
		return
	_apply_fog()

func set_player_sprite(val: int) -> void:
	player_sprite = val
	if not is_node_ready():
		return
	if val > 0:
		_add_player_sprite()
	else:
		if _player_sprite_node != null:
			_player_sprite_node.queue_free()
			_player_sprite_node = null

func set_is_rock(val: bool) -> void:
	is_rock = val
	if val and is_node_ready():
		_add_rock_sprite()

func set_is_poi(val: bool) -> void:
	is_poi = val
	if val:
		if poi_level > 0 and is_node_ready():
			_add_poi_sprite()
	else:
		if _poi_sprite != null:
			_poi_sprite.queue_free()
			_poi_sprite = null

func set_poi_level(val: int) -> void:
	poi_level = val
	if val > 0 and is_poi and is_node_ready():
		_add_poi_sprite()

func _setup_pass_path(poly: PackedVector2Array) -> void:
	_pass_path_outline = Line2D.new()
	_pass_path_outline.name = "PassPathOutline"
	_pass_path_outline.width = 3
	_pass_path_outline.default_color = Color.BLACK
	var pts := PackedVector2Array(poly)
	pts.append(poly[0])
	_pass_path_outline.points = pts
	_pass_path_outline.visible = false
	add_child(_pass_path_outline)

func _setup_ground() -> void:
	if _ground_poly != null:
		return
	var tex := load("res://assets/Desert/PNG/bg.png") as Texture2D
	if tex == null:
		return
	_ground_poly = Polygon2D.new()
	_ground_poly.polygon = shape
	_ground_poly.texture = tex
	_ground_poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_ground_poly.color = Color.WHITE
	_ground_poly.name = "GroundPoly"
	_ground_poly.z_index = -1
	add_child(_ground_poly)

func _add_player_sprite() -> void:
	if _player_sprite_node != null:
		return
	var tex := load("res://assets/Heroes/" + str(player_sprite) + "/Protect.png") as Texture2D
	if tex == null:
		return
	_player_sprite_node = Sprite2D.new()
	_player_sprite_node.texture = tex
	_player_sprite_node.name = "PlayerSprite"
	_player_sprite_node.z_index = 1
	add_child(_player_sprite_node)
	var bounds := _poly_bounds(shape)
	_player_sprite_node.position = bounds.get_center()
	var tex_size := tex.get_size()
	var hex_size := bounds.size.length() / 2.0
	var scale_factor := hex_size / tex_size.length() * 1.8
	_player_sprite_node.scale = Vector2(scale_factor, scale_factor)

func _add_poi_sprite() -> void:
	if _poi_sprite != null:
		return
	var tex := load(POI_PATHS[poi_level]) as Texture2D
	if tex == null:
		return
	_poi_sprite = Sprite2D.new()
	_poi_sprite.texture = tex
	_poi_sprite.name = "PoiSprite"
	_poi_sprite.z_index = 1
	add_child(_poi_sprite)
	var bounds := _poly_bounds(shape)
	_poi_sprite.position = bounds.get_center()
	var tex_size := tex.get_size()
	var hex_size := bounds.size.length() / 2.0
	var scale_factor := hex_size / tex_size.length() * 1.6
	_poi_sprite.scale = Vector2(scale_factor, scale_factor)

func _add_rock_sprite() -> void:
	if _rock_sprite != null:
		return
	var tex := load(ROCK_PATHS[randi() % ROCK_PATHS.size()]) as Texture2D
	if tex == null:
		return
	_rock_sprite = Sprite2D.new()
	_rock_sprite.texture = tex
	_rock_sprite.name = "RockSprite"
	_rock_sprite.z_index = 1
	add_child(_rock_sprite)
	var bounds := _poly_bounds(shape)
	_rock_sprite.position = bounds.get_center()
	var tex_size := tex.get_size()
	var hex_size := bounds.size.length() / 2.0
	var scale_factor := hex_size / tex_size.length() * 1.6
	_rock_sprite.scale = Vector2(scale_factor, scale_factor)

func _apply_fog() -> void:
	_fog_node.visible = is_fogged
	_poly.visible = not is_fogged
	_poi_label.visible = not is_fogged and is_poi
	_coll.disabled = is_fogged
	if _ground_poly != null:
		_ground_poly.visible = not is_fogged
	if _rock_sprite != null:
		_rock_sprite.visible = not is_fogged
	if _player_sprite_node != null:
		_player_sprite_node.visible = not is_fogged
	if _pass_path_outline != null:
		_pass_path_outline.visible = not is_fogged and is_on_player_pass
	if _poi_sprite != null:
		_poi_sprite.visible = not is_fogged

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

func _setup_poi_lines(poly: PackedVector2Array) -> void:
	var node := Node2D.new()
	node.name = "PoiLines"
	add_child(node)
	var bounds := _poly_bounds(poly)
	for level in 4:
		var line := Line2D.new()
		line.width = 5
		line.default_color = Color.RED
		var t := (level + 1) / 5.0
		var y := lerpf(bounds.position.y, bounds.position.y + bounds.size.y, t)
		var lr := _hex_x_at_y(y, poly)
		line.points = PackedVector2Array([Vector2(lr.x, y), Vector2(lr.y, y)])
		line.visible = false
		node.add_child(line)
		_poi_lines.append(line)

func _hex_x_at_y(y: float, poly: PackedVector2Array) -> Vector2:
	var left := INF
	var right := -INF
	for i in 6:
		var j := (i + 1) % 6
		var a := poly[i]
		var b := poly[j]
		if (a.y <= y and b.y >= y) or (b.y <= y and a.y >= y):
			if a.y == b.y:
				continue
			var t := (y - a.y) / (b.y - a.y)
			var x := a.x + t * (b.x - a.x)
			if x < left: left = x
			if x > right: right = x
	return Vector2(left, right)

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
		for line in _poi_lines:
			line.visible = false
		return
	if _pass_path_outline != null:
		_pass_path_outline.visible = is_on_player_pass
	_poi_label.visible = is_poi and _poi_sprite == null
	for i in 4:
		if i < _poi_lines.size():
			_poi_lines[i].visible = is_poi and _poi_sprite == null and i < poi_level
	if is_rock:
		_poly.color = Color(0.6, 0.6, 0.6, 0.9)
		return
	_poly.color = Color.WHITE
	_poly.color.a = 0.15 if not mouse_point else 0.35

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
