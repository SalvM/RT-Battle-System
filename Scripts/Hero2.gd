extends KinematicBody2D

signal hero_damage(damage)
signal health_changed(new_health)

onready var attack = $Attack
onready var hurtBox = $HurtBox
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var collision = $Collision

var isAttacking = false
var isMovingLeft = false
var isDead = false

var movement = Vector2(0, 0)
var up = Vector2(0, -1)
var speed = 200

export (float) var max_health = 20
export (float) var health = 20 setget _set_health

func health_in_percentage(value):
	return 100 / (max_health / value)

func die():
	isDead = true
	collision.disabled = true
	animationPlayer.play("Dead")
	yield(animationPlayer, "animation_finished")

func damage(amount):
	_set_health(health - amount)

func _set_health(value):
	var prev_health = health;
	health = clamp(value, 0, max_health);
	if health == 0:
		emit_signal("health_changed", 0)
		die()
	elif health != prev_health:
		emit_signal("health_changed", health_in_percentage(health))

func changeAnimation(type):
	animationPlayer.play(type)

func attack():
	isAttacking = true
	if Input.is_action_pressed("ui_up"):
		changeAnimation("Attack_2")
	else:
		changeAnimation("Attack_1")

func flipHero():
	isMovingLeft = !isMovingLeft;
	scale.x = -scale.x

func resetAttackCollision():
	for child in attack.get_children():
		child.disabled = true

func changeHurtBoxCollision(type):
	var box = hurtBox.get_node(type)
	collision.shape = box.shape
	collision.transform = box.transform
	collision.position = box.position

func move():
	if Input.is_action_pressed("ui_left"):
		if(!isMovingLeft):
			flipHero();
		movement.x = -speed;
		changeAnimation('Run');
	elif Input.is_action_pressed("ui_right"):
		if(isMovingLeft):
			flipHero();
		movement.x = speed;
		changeAnimation('Run');
	elif Input.is_action_pressed("ui_down"):
		movement.x = 0;
		changeAnimation("Crouch");
	else:
		movement.x = 0;
		changeAnimation('Idle');

func _physics_process(delta):
	if isAttacking || isDead: return
	move()
	if Input.is_action_just_pressed("Attack"):
		movement.x = 0;
		attack()
	move_and_collide(movement * delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	if isAttacking:
		isAttacking = false
		changeAnimation("Idle")

func _on_Slime_hero_damage(amount):
	damage(amount)
