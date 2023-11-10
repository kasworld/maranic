extends PanelContainer

func show_message(msg :String, sec :float = 3)->void:
	$VBoxContainer/Label.text = msg
	visible = true
	$Timer.start(sec)

func _on_timer_timeout() -> void:
	visible = false
