extends Area2D
class_name Hexagon

signal region_selected
#signal move_hero_to_the_hexagon

var shape : PackedVector2Array: set = set_shape
# TODO: think about hexagon which know their neighbours 
var neighbour_1 = Vector2(0,0) #top 
var neighbour_2 = Vector2(0,0) #right top
var neighbour_3 = Vector2(0,0) #right bottom
var neighbour_4 = Vector2(0,0) #bottom
var neighbour_5 = Vector2(0,0) #left bottom
var neighbour_6 = Vector2(0,0) #left top
var is_player_step_on : bool = false
var value : int = randi() % 5
var is_on_player_pass : bool = false
var is_rock : bool = false
var mouse_point : bool = false

@onready var _poly := $Polygon2D
@onready var _coll := $CollisionPolygon2D

func set_shape(new_shape: PackedVector2Array):

	_poly.set_polygon(new_shape)
	_poly.color = Color("DARK_KHAKI")
	_poly.color.a = 0.6
	_coll.set_polygon(new_shape)
	shape = new_shape

func _on_Hexagon_mouse_entered():
	mouse_point = true
	#print(_poly.get_polygon())
	#print(_coll.get_polygon())
	#_poly.color.a = 1

func _on_Hexagon_mouse_exited():
	mouse_point = false
	#_poly.color.a = 0.6

func _on_Hexagon_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		#_poly.color = Color("BLUE")
		if is_on_player_pass:
			is_player_step_on = true
			region_selected.emit()
		
func _process(delta: float) -> void:
	if is_player_step_on:
		_poly.color = Color("BLACK")
	if !is_player_step_on:
		_poly.color = Color("DARK_KHAKI")
	if is_on_player_pass:
		_poly.color.a = 0.3
	if !is_on_player_pass:
		if mouse_point:
			_poly.color.a = 0.6
		else:
			_poly.color.a = 1
		
	
func set_neighbours(start_point : Vector2) ->void:
	var screen_size = get_viewport_rect().size
	var m = 50
	if start_point.y - 70 >= m:
		neighbour_1 = Vector2(start_point.x, start_point.y - 70)
	if start_point.x + 60 <= screen_size.x - m && start_point.y - 35 >= m:
		neighbour_2 = Vector2(start_point.x + 60, start_point.y - 35)
	if start_point.x + 60 <= screen_size.x - m && start_point.y + 35 <= screen_size.y - m:
		neighbour_3 = Vector2(start_point.x + 60, start_point.y + 35)
	if start_point.y + 70 <= screen_size.y - m:
		neighbour_4 = Vector2(start_point.x, start_point.y + 70)
	if start_point.x - 60 >= m && start_point.y + 35 <= screen_size.y - m:
		neighbour_5 = Vector2(start_point.x - 60, start_point.y + 35)
	if start_point.x - 60 >= m && start_point.y - 35 >= m:
		neighbour_6 = Vector2(start_point.x - 60, start_point.y - 35)

	#neighbour_1 = Vector2(start_point[0],start_point[1]-65)
	#neighbour_2 = Vector2(start_point[0] + 55,start_point[1]-30)
	#neighbour_3 = Vector2(start_point[0] + 55 ,start_point[1]+35)
	#neighbour_4 = Vector2(start_point[0] + 110,start_point[1])
	#neighbour_5 = Vector2(start_point[0] - 55,start_point[1]+35)
	#neighbour_6 = Vector2(start_point[0] - 55,start_point[1]-30)
	#for x in range(50,1300,110): # TODO: make variables not hardcode and use matrix - not a just array 
		#for y in range(50,900,65):
