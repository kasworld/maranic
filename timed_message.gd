extends PanelContainer

func show_message(msg):
	$Label.text = msg
	visible = true
	$Timer.start(3.0)

func _on_timer_timeout() -> void:
	visible = false
