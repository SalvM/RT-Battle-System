extends KinematicBody

# signals
signal hero_damage(amount)

# instances
onready var attack = $Attack
onready var animationPlayer = $AnimationPlayer

# statuses
var isAttacking = false
var isCooldown = false
var isMovingLeft = false
var isDead = false
var animationStatus = ""
var followHero = false
var heroInRange = false

# stats
export (float) var health = 5
export (float) var max_health = 5

# vectors
var velocity = Vector3(0, 0, 0)
var target = Vector3(0, 0, 0)
const SPEED = 1.4

func get_distance_offset(target: Vector3):
	var position = get_global_transform().origin
	return (position - target).normalized()

func flip():
	self.scale.x = -self.scale.x
	isMovingLeft = !isMovingLeft

func changeAnimation(type):
	if animationStatus == type: return
	animationStatus = type
	animationPlayer.play(animationStatus)

func attack():
	if isAttacking || isCooldown || isDead: return
	isAttacking = true
	isCooldown = true
	changeAnimation("Attack")
	$AttackCooldown.start(2)

func move(velocity):
	if isDead: return
	move_and_slide(velocity)
	if velocity.x == 0 && velocity.z == 0:
		changeAnimation("Idle")
	else:
		changeAnimation("Walk")

func follow():
	if isAttacking || !followHero || isDead: return
	var offset = get_distance_offset(target)
	if isMovingLeft && offset.x < 0 || !isMovingLeft && offset.x > 0:
		flip()
	velocity.x = -offset.x * SPEED
	velocity.z = -offset.z * SPEED
	move(velocity)
	
func die():
	isDead = true
	isAttacking = false
	$CollisionShape.queue_free()
	$Vision.queue_free()
	$AttackRange.queue_free()
	$Attack.queue_free()
	changeAnimation("Perish")

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if isAttacking || isDead: return
	if followHero:
		follow()

func _on_Vision_body_entered(body):
	if body.is_in_group("Hero"):
		followHero = true
		target = Vector3(body.transform[3])

func _on_Vision_body_exited(body):
	if body.is_in_group("Hero"):
		followHero = false
		move(Vector3(0,0,0))

func _on_AttackRange_body_entered(body):
	if body.is_in_group("Hero"):
		heroInRange = true
		if isAttacking || isDead: return
		attack()

func _on_Attack_body_entered(body):
	if body.is_in_group("Hero"):
		emit_signal("hero_damage", 4)

func _on_AttackRange_body_exited(body):
	heroInRange = false

func _on_HurtBox_area_entered(area):
	if area.is_in_group("HeroAttacks"):
		health = health - 1
		print('skeletron damaged')
		if health <= 0:
			die()

func _on_AttackCooldown_timeout():
	isCooldown = false
	if heroInRange:
		attack()
	elif followHero:
		follow()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		isAttacking = false
	elif anim_name == "Perish":
		$Perish.start()

func _on_Perish_timeout():
	queue_free()
