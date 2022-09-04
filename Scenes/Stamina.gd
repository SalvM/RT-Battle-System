extends Container

onready var stamina_bar = $ProgressBar;
onready var update_tween = $UpdateTween;

export (Color) var stamina_color = Color.orange

func _on_stamina_updated(new_stamina):
	stamina_bar.value = new_stamina

func _on_max_stamina_updated(max_stamina):
	stamina_bar.max_value = max_stamina;

func _on_Hero2_stamina_changed(max_stamina):
	_on_stamina_updated(max_stamina)
