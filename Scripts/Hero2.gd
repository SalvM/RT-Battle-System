extends KinematicBody2D

signal hero_damage(damage)
signal health_changed(new_health)
signal stamina_changed(new_stamina)


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
export (float) var max_stamina = 10
export (float) var stamina = 10 setget _set_stamina

func health_in_percentage(value):
	return 100 / (max_health / value)

func stamina_in_percentage(value):
	return 100 / (max_stamina / value)

func die():
	isDead = true
	collision.disabled = true
	animationPlayer.play("Dead")
	yield(animationPlayer, "animation_finished")

func damage(amount):
	_set_health(health - amount)

func consumeStamina(amount):
	_set_stamina(stamina - amount)

func _set_health(value):
	var prev_health = health;
	health = clamp(value, 0, max_health);
	if health == 0:
		emit_signal("health_changed", 0)
		die()
	elif health != prev_health:
		emit_signal("health_changed", health_in_percentage(health))

func _set_stamina(value):
	var prev_stamina = stamina;
	stamina = clamp(value, 0, max_stamina);
	if stamina == 0:
		emit_signal("stamina_changed", 0)
	elif stamina != prev_stamina:
		emit_signal("stamina_changed", stamina_in_percentage(stamina))

func changeAnimation(type):
	animationPlayer.play(type)

func attack():
	isAttacking = true
	consumeStamina(2)
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
	if Input.is_action_just_pressed("Attack") && stamina > 0:
		movement.x = 0;
		attack()
	move_and_collide(movement * delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	if isAttacking:
		isAttacking = false
		changeAnimation("Idle")

func _on_Slime_hero_damage(amount):
	damage(amount)

func _on_StaminaTimer_timeout():
	consumeStamina(-1.5)
