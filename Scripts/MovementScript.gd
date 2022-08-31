extends KinematicBody2D

signal hero_damage(damage)
signal health_changed(new_health)

onready var animatedSprite = $AnimatedSprite
onready var ColliderScript = $Colliders

var movement = Vector2();
var up = Vector2(0, -1);
var speed = 200;

var isAttacking = false;
var isMovingLeft = false;

export (float) var max_health = 20;
export (float) var health = 20 setget _set_health

func health_in_percentage(value):
	return 100 / (max_health / value)

func changeAnimation(type):
	animatedSprite.play(type)
	
func changeAttackCollision(type):
	$Attacks/Attack_1.disabled = true;
	$Attacks/Attack_2.disabled = true;
	$Attacks/Attack_3.disabled = true;
	var node = "Attacks/" + type;
	get_node(node).disabled = false;

func damage(amount):
	_set_health(health - amount)
	
func kill():
	pass

func _set_health(value):
	var prev_health = health;
	health = clamp(value, 0, max_health);
	if health == 0:
		emit_signal("health_changed", 0)
		kill()
	elif health != prev_health:
		emit_signal("health_changed", health_in_percentage(health))

func flipHero():
	isMovingLeft = !isMovingLeft;
	scale.x = -scale.x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if(Input.is_action_pressed("ui_left")) && !isAttacking:
		if(!isMovingLeft):
			flipHero();
		movement.x = -speed;
		changeAnimation('Run');
	elif (Input.is_action_pressed("ui_right")) && !isAttacking:
		if(isMovingLeft):
			flipHero();
		movement.x = speed;
		changeAnimation('Run');
	elif (Input.is_action_pressed("ui_down") && !isAttacking):
		movement.x = 0;
		changeAnimation("Crouched");
		$HurtBox/CrouchedColl.disabled = false;
		$HurtBox/IdleColl.disabled = true;
	#elif (Input.is_action_pressed("ui_up") && !isAttacking):
	#	movement.y = -speed;
	#	changeAnimation("Jumping");
	else:
		movement.x = 0;
		$HurtBox/CrouchedColl.disabled = true;
		$HurtBox/IdleColl.disabled = false;
		if(!isAttacking):
			changeAnimation('Idle');
	if(Input.is_action_just_pressed("Attack")):
		isAttacking = true;
		$SFX/Swoosh.play()
		if(Input.is_action_pressed("ui_up")):
			changeAnimation("Attack_2");
			changeAttackCollision("Attack_2");
		elif (Input.is_action_pressed("ui_down")):
			changeAnimation("Attack_3");
			changeAttackCollision("Attack_3")
		else:
			changeAnimation("Attack_1");
			changeAttackCollision("Attack_1");
	movement = move_and_slide(movement, up * delta);


func _on_AnimatedSprite_animation_finished():
	if isAttacking:
		$Attacks/Attack_1.disabled = true;
		$Attacks/Attack_2.disabled = true;
		$Attacks/Attack_3.disabled = true;
		isAttacking = false;
		changeAnimation('Idle');
	pass # Replace with function body.


func _on_Slime_hero_damage(amount):
	damage(amount)
	pass # Replace with function body.
