extends KinematicBody2D

# signals
signal hero_damage(damage)
signal health_changed(new_health)
signal stamina_changed(new_stamina)

# instances
onready var attack = $Attack
onready var hurtBox = $HurtBox
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var collision = $Collision

# statuses
var isAttacking = false
var isMovingLeft = false
var isDead = false

var movement = Vector2(0, 0)
var up = Vector2(0, -1)
var speed = 200

# stats
export (float) var max_health = 20
export (float) var health = 20 setget _set_health
export (float) var max_stamina = 10
export (float) var stamina = 10 setget _set_stamina

var basic_attack_cost = 2
var last_collision_box = null

# combo
var timeTillNextInput = 0.2
var inputCooldown = timeTillNextInput
var usedKeys = ""
var wasInputMode = false

func health_in_percentage(value):
	return 100 / (max_health / value)

func stamina_in_percentage(value):
	return 100 / (max_stamina / value)

func die():
	isDead = true
	collision.disabled = true
	changeAnimation("Dead")
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
	changeHurtBoxCollision(type)

func useCombo(combo):
	if combo.cost <= stamina:
		print("Executing combo... ", combo.name)
		animationPlayer.stop()
		isAttacking = true
		consumeStamina(combo.cost)
		changeAnimation(combo.name)
	else:
		print("You need more ", combo.cost - stamina, " stamina to execute that combo") 

func canAttack():
	return Input.is_action_just_pressed("Attack") && stamina >= basic_attack_cost
	
func attack(character):
	isAttacking = true
	consumeStamina(basic_attack_cost)
	match character:
		"I":
			changeAnimation("Attack_2")
		_:
			changeAnimation("Attack_1")

func flipHero():
	isMovingLeft = !isMovingLeft;
	scale.x = -scale.x

func resetAttackCollision():
	for child in attack.get_children():
		child.disabled = true

func changeHurtBoxCollision(type):
	if type == last_collision_box: return
	last_collision_box = type
	var box = hurtBox.get_node(type)
	if !box: return
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

func _input(event):
	if isAttacking || isDead: return
	# Sign an input key only once
	if event is InputEventKey:
		if event.pressed and not event.echo:
			# Temporarily stores the char from the input
			var character = OS.get_scancode_string(event.scancode)
			#if Combo.moveKeys.find(character) >= 0:
			
			# Check if the character is valid for the combo
			if Combo.inputKeys.find(character) >= 0:
				wasInputMode = true
				inputCooldown = timeTillNextInput
				usedKeys += character
				var comboToExecute = Combo.checkForWords(usedKeys)
				if comboToExecute:
					useCombo(Combo.fightCombos[comboToExecute]);
					
					# It stores the last input to chain new combos
					usedKeys = usedKeys[usedKeys.length() - 1]
				elif canAttack():
					attack(character)
				
func _process(delta):
	if wasInputMode:
		inputCooldown -= delta
		if inputCooldown < 0 && usedKeys != null:
			wasInputMode = false
			inputCooldown = timeTillNextInput

func _physics_process(delta):
	if isAttacking || isDead: return
	move()
	# if canAttack():
		# movement.x = 0;
		# attack()
	move_and_collide(movement * delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	if isAttacking:
		isAttacking = false
		changeAnimation("Idle")

func _on_Slime_hero_damage(amount):
	damage(amount)

func _on_StaminaTimer_timeout():
	consumeStamina(-1.5)
