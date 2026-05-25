extends Node2D

const HexagonScene := preload("res://Hexagon.tscn")

var hexagon_start_points_array  = Array()
var hexagon_array = Array() # : Array[Hexagon] = Array[Hexagon].new()
var movement_speed : int = 3
var path_hexagon_counter : int = 0
var player_start_pos :int = 10

var margin := 50
var checked_vectors : PackedVector2Array

func _ready() -> void:
	print("ready")
	var screen_size = get_viewport_rect().size
	for x in range(margin, screen_size.x - margin, 120):
		for y in range(margin, screen_size.y - margin, 70):
			var point = Vector2(x, y)
			hexagon_start_points_array.append(point)
			var point2 = Vector2(x + 60, y + 35)
			hexagon_start_points_array.append(point2)
	hexagon_start_points_array.sort()
	print("points array:", hexagon_start_points_array)
	for point in hexagon_start_points_array:
		hexagon_array.append(create_hexagon(point))  
	var start_hex : Hexagon = hexagon_array.get(10)
	start_hex.is_player_step_on = true
	hexagon_selected(hexagon_start_points_array.get(player_start_pos)) 
	print("count of generated hexagons: ",hexagon_array.size())

#func _process(delta: float) -> void:
	#for hexagon in hexagon_array:
		#if hexagon.is_player_step_on:
			#var value = 1
		#var vvalue = 2
	#var mouse_point = get_local_mouse_position()
	#print(mouse_point)
 

func create_hexagon(point):
	var start_point = point
	#print("point: ",point)
	var hexagon : Hexagon = HexagonScene.instantiate()
	add_child(hexagon)

	hexagon.set_shape(PackedVector2Array([
		start_point,
		Vector2(start_point[0] + 30,start_point[1] + 0),
		Vector2(start_point[0] + 50,start_point[1] + 30),
		Vector2(start_point[0] + 30,start_point[1] + 60),
		Vector2(start_point[0] +  0,start_point[1] + 60),
		Vector2(start_point[0] - 20,start_point[1] + 30),
		]))
	hexagon.set_indexed("str",start_point)
	hexagon.set_neighbours(start_point)
	hexagon.set_script(load("res://area_2d.gd"))
	hexagon.region_selected.connect(hexagon_selected.bind(start_point))
	#hexagon.mouse_entered.connect(_on_Hexagon_mouse_entered)
	#hexagon.connect(_on_MapRegion_mouse_entered)
	#add_child(hexagon)
	#hexagon.set_script("res://polygon_2d_mouse_listener.gd")
	#print("create a hexagon: " , area," script: ", area.get_script())
	return hexagon
	
#func change_hexagon_color(hexagon):
	#hexagon.set_color("BRAUN")
#
#func find_hexagon(point):
	#var hexagon_start_point
	#
	#
	#return hexagon_start_point
	
func hexagon_selected(position : Vector2) -> void:
	print("hexagon_selected")
	print("position: " , position)
	#hexagon_array.find_custom(hexagon.shape[0])
	var hexagon_position = 0
	for hexagon in hexagon_array:
		if hexagon.shape[0] == position:
			hexagon_position = hexagon_array.find(hexagon)
			
			#print(vect)
		else:
			hexagon.is_player_step_on = false
			hexagon.is_on_player_pass = false
			
	checked_vectors.clear()
	print("start find path: ", position, " ", movement_speed)
	create_path(position,movement_speed)
	print("++++++++++++++++++++++++++++++++++++++++++")
	print("counter", ": ", path_hexagon_counter)
	print("++++++++++++++++++++++++++++++++++++++++++")
	path_hexagon_counter = 0




func make_hexagon_on_player_path(hexagon : Hexagon) -> void:
	hexagon.is_on_player_pass = true
	
func create_path(vect : Vector2, ms : int):
#	TODO: to reduse calls of recurcive method add parameter to list already processed VECTORS
	#checked_vectors.append(vect)
	path_hexagon_counter = path_hexagon_counter +1
	#print("create_path")
	#print("vect: ", vect)
	var position = hexagon_start_points_array.find(vect,0)
	#print("position: " , position)
	var hexagon = hexagon_array.get(position)
	if !hexagon.is_player_step_on:
		hexagon.is_on_player_pass = true
		#print(hexagon.is_on_player_pass, hexagon.shape[0])
	if ms >0:
		#print(position, " ", ms)
		ms = ms -1
		if hexagon.neighbour_1 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_1) < 0:
			create_path(hexagon.neighbour_1,ms)
		if hexagon.neighbour_2 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_2) < 0:
			create_path(hexagon.neighbour_2,ms)
		if hexagon.neighbour_3 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_3) < 0:
			create_path(hexagon.neighbour_3,ms)
		if hexagon.neighbour_4 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_4) < 0:
			create_path(hexagon.neighbour_4,ms)
		if hexagon.neighbour_5 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_5) < 0:
			create_path(hexagon.neighbour_5,ms)
		if hexagon.neighbour_6 != Vector2(0,0):# && checked_vectors.find(hexagon.neighbour_6) < 0:
			create_path(hexagon.neighbour_6,ms)
	
func correct_position(position : int) -> int:
	if  position < 0:
		return 0
	if position > hexagon_start_points_array.size()-1:
		return hexagon_start_points_array.size() -1
	return position


func _on_button_pressed_1() -> void:
	movement_speed = randi_range(1,3)
