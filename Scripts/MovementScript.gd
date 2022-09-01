extends KinematicBody2D

signal hero_damage(damage)
signal health_changed(new_health)

onready var animatedSprite = $AnimatedSprite
onready var ColliderScript = $Colliders

var movement = Vector2()
var up = Vector2(0, -1)
var speed = 200;

var isAttacking = false
var isMovingLeft = false
var isDead = false

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
	
func die():
	isDead = true
	$HurtBox/IdleColl.disabled = true
	$HurtBox/CrouchedColl.disabled = true
	$AnimatedSprite.play("Die")
	yield($AnimatedSprite, "animation_finished")

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

func flipHero():
	isMovingLeft = !isMovingLeft;
	scale.x = -scale.x
	
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
		changeAnimation("Crouched");
		$HurtBox/CrouchedColl.disabled = false;
		$HurtBox/IdleColl.disabled = true;
	else:
		movement.x = 0;
		$HurtBox/CrouchedColl.disabled = true;
		$HurtBox/IdleColl.disabled = false;
		changeAnimation('Idle');
	
func attack():
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

func _physics_process(delta):
	if isAttacking || isDead:
		return
	move()
	if Input.is_action_just_pressed("Attack"):
		attack()
	movement = move_and_slide(movement, up * delta);

func _on_AnimatedSprite_animation_finished():
	if isAttacking:
		$Attacks/Attack_1.disabled = true;
		$Attacks/Attack_2.disabled = true;
		$Attacks/Attack_3.disabled = true;
		isAttacking = false;
		changeAnimation('Idle');

func _on_Slime_hero_damage(amount):
	damage(amount)
