extends Container

onready var health_bar = $ProgressBar;
onready var update_tween = $UpdateTween;

export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellowgreen
export (Color) var danger_color  = Color.red
export (float, 0, 1, 0.05) var caution_zone = 0.6
export (float, 0, 1, 0.05) var danger_zone = 0.3

func _ready():
	pass

func _on_health_updated(new_health):
	health_bar.value = new_health
	_assign_color(new_health)

func _assign_color(health):
	var prev_tint = health_bar.get("custom_styles/fg").get_bg_color()
	var new_tint = null
	if health < health_bar.max_value * danger_zone:
		new_tint = danger_color
	elif health < health_bar.max_value * caution_zone:
		new_tint = caution_color
	else:
		new_tint = healthy_color
	update_tween.interpolate_method(health_bar.get("custom_styles/fg"), "set_bg_color", prev_tint, new_tint, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	update_tween.start()

func _on_max_health_updated(max_health):
	health_bar.max_value = max_health;

func _on_Hero_health_changed(new_health):
	_on_health_updated(new_health)
	pass # Replace with function body.

func _on_Hero2_health_changed(new_health):
	_on_health_updated(new_health)
	pass # Replace with function body.
