extends KinematicBody2D

signal hero_damage(amount)
signal health_changed(health)

var isDead = false;
var hp = 4;

var movement = Vector2();
var velocity = Vector2(0, 0);
var speed = 32; # pixel per second
var gravity = 0;
var isAttacking = false;
var heroInRange = false;

func move_character(delta):
	velocity.x = -speed;
	velocity.y += gravity;
	var collision = move_and_collide(velocity * delta);
	
func refresh_hp():
	$HpControl/Container/ProgressBar.value = 100 - ( (4 * 100 - hp * 100) / 4 )

func _ready():
	$AnimatedSprite.play("Idle");

func _process(delta):
	pass
	
func _physics_process(delta):
	if(!isDead && !isAttacking):
		move_character(delta);

func _on_Area2D_area_entered(area):
	if(isDead): return;
	if area.is_in_group("HeroAttacks"):
		hp -= 1;
		refresh_hp();
		$SFX/Splash.play()
		if hp == 0:
			isAttacking = false;
			isDead = true;
			$Vision/Collision.disabled = true;
			# $Attack/Collision.disabled = true;
			$HurtBox/Collision.disabled = true;
			$Collision.disabled = true;
			$AnimatedSprite.play("Perish");
			yield($AnimatedSprite, "animation_finished");
			queue_free()
	return


func _on_Vision_area_entered(area):
	if(isAttacking || isDead): return;
	if area.is_in_group("HeroHurtBox"):
		heroInRange = true;
		isAttacking = true;
		$Timer.start(0.4);
		$AnimatedSprite.play("Attack");
		return # Replace with function body.

func _on_Vision_area_exited(area):
	if area.is_in_group('HeroHurtBox'):
		heroInRange = false;


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack":
		isAttacking = false;
		$AnimatedSprite.play("Idle");


func _on_Timer_timeout():
	if heroInRange:
		emit_signal("hero_damage", 2);
