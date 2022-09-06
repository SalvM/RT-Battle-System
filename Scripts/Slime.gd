extends KinematicBody2D

signal hero_damage(amount)
signal health_changed(health)

var hp = 4
var movement = Vector2()
var velocity = Vector2(0, 0)
var speed = 32; # pixel per second
var gravity = 0
var isAttacking = false
var isDead = false
var heroInRange = false
var inCooldown = false

func move_character(delta):
	velocity.x = -speed
	velocity.y += gravity
	var collision = move_and_collide(velocity * delta)

func refresh_hp():
	$HpControl/Container/ProgressBar.value = 100 - ( (4 * 100 - hp * 100) / 4 )

func _ready():
	$AnimatedSprite.play("Idle")

func die():
	isDead = true
	isAttacking = false
	$AnimatedSprite.stop()
	$Vision/Collision.disabled = true
	$HurtBox/Collision.disabled = true
	$Collision.disabled = true
	$AnimatedSprite.play("Perish")
	yield($AnimatedSprite, "animation_finished")
	queue_free()

func attack():
	if inCooldown || isDead:
		return
	isAttacking = true
	inCooldown = true
	$Timer.start(0.4)
	$AnimatedSprite.play("Attack")
	yield($AnimatedSprite, "animation_finished")
	$Cooldown.start(1)
	
func damage(amount):
	hp -= amount;
	refresh_hp()
	$SFX/Splash.play()
	
func _physics_process(delta):
	if(!isAttacking && !isDead):
		move_character(delta)

func _on_Area2D_area_entered(area):
	if area.is_in_group("HeroAttacks"):
		damage(1)
		if hp == 0:
			die()
	return

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack":
		isAttacking = false
		$AnimatedSprite.play("Idle")

func _on_Timer_timeout():
	if heroInRange:
		emit_signal("hero_damage", 4)

func _on_Cooldown_timeout():
	inCooldown = false
	if heroInRange:
		attack()

func _on_Vision_body_entered(body):
	if body.is_in_group("Hero"):
		heroInRange = true
		if(isAttacking || isDead): return
		attack()

func _on_Vision_body_exited(body):
	if body.is_in_group("Hero"):
		heroInRange = false
