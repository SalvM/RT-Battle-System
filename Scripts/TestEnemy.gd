extends KinematicBody
var SPEED = 3
var velocity = Vector3(0,0,0)

func move():
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")
	var up_pressed = Input.is_action_pressed("ui_up")
	var down_pressed = Input.is_action_pressed("ui_down")

	if left_pressed and right_pressed:
		velocity.x = 0
	elif left_pressed:
		velocity.x = -SPEED
	elif right_pressed:
		velocity.x = SPEED
	else:
		#velocity.x = lerp(velocity.x, 0, 0.5)
		velocity.x = 0
		
	if up_pressed and down_pressed:
		velocity.z = 0
	elif up_pressed:
		velocity.z = -SPEED
	elif down_pressed:
		velocity.z = SPEED
	else:
		#velocity.z = lerp(velocity.z, 0, 0.5)
		#velocity.y = lerp(velocity.y, -1, 0.5)
		velocity.z = 0
		velocity.y = 0
	move_and_slide(velocity)

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	move()

func hurt():
	print("Your hurt the enemy")

func _on_Area_body_entered(body):
	print('_on_Area_body_entered ', body)
	pass # Replace with function body.
