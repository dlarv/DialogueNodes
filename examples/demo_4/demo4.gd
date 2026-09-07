extends Node3D

var _points := 0


func _process(_delta: float) -> void:
	if Input.is_action_just_released('ui_focus_next'):
		$DialogueBox.start("START")


func _on_timer_timeout() -> void:
	$DialogueBox.show()
	StoryManager.set_variable("points", _points)
	StoryManager.end_event()


func _on_dialogue_box_dialogue_signal(value: Variant) -> void:
	if value != "start_game": return
	_points = 0
	$DialogueBox.hide()
	$Timer.wait_time = StoryManager.get_variable("timer_length")
	$Timer.stop()
	$Timer.start()


func _on_box_1_clicked() -> void:
	_points += 1
