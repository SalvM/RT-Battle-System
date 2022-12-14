extends KinematicBody

# signals
signal hero_damage(damage)
signal health_changed(new_health)
signal stamina_changed(new_stamina)

# instances
onready var attacks = $Attack
onready var hurtBox = $HurtBox
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite3D
onready var collision = $Collision
onready var healthBar = $HealthBar3D/Viewport/HealthBar
onready var staminaBar = $HealthBar3D/Viewport2/StaminaBar

# statuses
var isAttacking = false
var isMovingLeft = false
var isDead = false
var animationStatus = ""

# stats
export (float) var max_health = 20
export (float) var health = 20 setget _set_health
export (float) var max_stamina = 10
export (float) var stamina = 10 setget _set_stamina

# basic attacks
const basic_attack_cost = 2
var last_collision_box = null

# combo
const timeTillNextInput = 0.1
var inputCooldown = timeTillNextInput
var usedKeys = ""

# movement in 3D space
var velocity = Vector3(0, 0, 0)
const SPEED = 5

# Sprite3D
const spriteOffset = [8, -2]

func bar_value_in_percentage(value, max_value):
	return 100 / (max_value / value)

func health_in_percentage(value):
	return bar_value_in_percentage(value, max_health)

func stamina_in_percentage(value):
	return bar_value_in_percentage(value, max_stamina)

# the hero gets damages
func damage(amount):
	var newValue = health - amount
	var newPercentage = 0
	_set_health(newValue)
	if newValue > 0:
		newPercentage = health_in_percentage(newValue)
	healthBar.value = newPercentage

func consumeStamina(amount):
	var newValue = stamina - amount
	var newPercentage = 0
	_set_stamina(newValue)
	if newValue > 0:
		newPercentage = stamina_in_percentage(newValue)
	staminaBar.value = newPercentage

func changeHurtBoxCollision(type):
	if type == last_collision_box: return
	last_collision_box = type
	var box = hurtBox.get_node(type)
	if !box: return
	collision.shape = box.shape
	collision.transform = box.transform

func changeAnimation(type):
	if animationStatus == type: return
	animationStatus = type
	animationPlayer.play(animationStatus)
	# changeHurtBoxCollision(animationStatus)

func die():
	isDead = true
	collision.disabled = true
	changeAnimation("Dead")
	yield(animationPlayer, "animation_finished")

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

func canAttack():
	return !isAttacking && inputCooldown <= 0 && Input.is_action_just_pressed("Attack") && stamina >= basic_attack_cost

# Executes the right animation for the character input, es: "J"
func attack(character):
	isAttacking = true
	consumeStamina(basic_attack_cost)
	match character:
		"I":
			changeAnimation("Attack_2")
		_:
			changeAnimation("Attack_1")

# Flips Hero and all his children (collisions too!)
func flipHero():
	isMovingLeft = !isMovingLeft;
	sprite.offset.x = -sprite.offset.x
	sprite.flip_h = !sprite.flip_h

func updateInputsOnScreen():
	$Inputs/Label.text = "Current combo chain: " + usedKeys

func _ready():
	pass

func move():
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")
	var up_pressed = Input.is_action_pressed("ui_up")
	var down_pressed = Input.is_action_pressed("ui_down")

	if left_pressed and right_pressed:
		velocity.x = 0
	elif left_pressed:
		if(!isMovingLeft):
			flipHero()
		velocity.x = -SPEED
	elif right_pressed:
		if(isMovingLeft):
			flipHero()
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
		
	if velocity.x == 0 && velocity.z == 0:
		changeAnimation("Idle")
	else:
		changeAnimation("Run")
	move_and_slide(velocity)

func useCombo(combo):
	if combo.cost <= stamina:
		print("Executing combo: ", combo.name)
		animationPlayer.stop()
		isAttacking = true
		consumeStamina(combo.cost)
		changeAnimation(combo.name)
	else:
		print("You need more ", combo.cost - stamina, " stamina to execute that combo")

func _physics_process(delta):
	if isAttacking || isDead: return
	move()
	pass

func _process(delta):
	if inputCooldown <= 0: return
	inputCooldown -= delta

func _input(event):
	if !canAttack() || isDead: return
	# Sign an input key only once
	if event is InputEventKey:
		if event.pressed and not event.echo:
			# Temporarily stores the char from the input
			var character = OS.get_scancode_string(event.scancode)
			
			# Check if the character is valid for the attack
			if Combo.inputKeys.find(character) >= 0:
				var comboPattern = Combo.checkForWords(usedKeys)
				var combo = false
				if comboPattern:
					combo = Combo.fightCombos[comboPattern]
				var canExecuteCombo = combo && combo.cost <= stamina
				if canAttack():
					inputCooldown = timeTillNextInput
					usedKeys += character
				if canExecuteCombo:
					useCombo(combo)
					# It stores only the last input to chain new combos
					usedKeys = usedKeys[usedKeys.length() - 1]
				else:
					if !canExecuteCombo && combo:
						print("You need more ", combo.cost - stamina, " stamina to execute that combo")
					attack(character)
				updateInputsOnScreen()

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name || "Slashing" in anim_name:
		isAttacking = false
		changeAnimation("Idle")

func _on_StaminaTimer_timeout():
	consumeStamina(-1.5)

func _on_Skeleton_hero_damage(amount):
	damage(amount)

func _on_Attack_body_entered(body):
	print('attack >> ', body)
	if body.has_method("hurt"):
		body.hurt(1)
