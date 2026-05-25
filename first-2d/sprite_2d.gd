extends Sprite2D

var speed = 50
var angular_speed = PI
var input_speed = 0
var velocity = Vector2.ZERO
var button_2_blinking = false

func _init():
	input_speed = 10
	velocity = Vector2.UP * input_speed
	print(input_speed)
	print (angular_speed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction =0
	var location_x = get
	#velocity = Vector2.ONE
	if Input.is_action_pressed("ui_right"):
		direction = 1
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed
		#input_speed = input_speed +1
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation) * speed
		#input_speed = input_speed - 1
	
	
	rotation += angular_speed * direction * delta
	#velocity = Vector2.UP.rotated(rotation) * input_speed 
	position += velocity * delta
	
	
	
	
func _on_direction_to_much():
	move_local_x(1)
	move_local_y(1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	if button_2_blinking:
		visible = not visible
	else:
		visible = true
	#visible = not visible

func _on_button_pressed() -> void:
	set_process(not is_processing())
	#visible = true
	move_local_x(5)
	move_local_y(5)
	
	
	


func _on_button_2_pressed() -> void:
	button_2_blinking = not button_2_blinking
