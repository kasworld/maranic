extends PanelContainer

@onready var seclabel = $HBoxContainer/SecLabel
@onready var incbtn = $HBoxContainer/VBoxContainer/SecIncButton
@onready var decbtn = $HBoxContainer/VBoxContainer/SecDecButton

signal time_changed(diff :int)

var click_inc_sec = 10
var repeat_inc_sec = 0
var max_inc_sec = 60

func set_sec(s :int)->void:
	seclabel.text = TickLib.tick2str(s)

func clear()->void:
	seclabel.text = TickLib.tick2str(0)

func disable_buttons(b :bool)->void:
	decbtn.disabled = b
	incbtn.disabled = b

func _on_sec_dec_button_button_down() -> void:
	repeat_inc_sec = -1
	$Timer.start(0.1)
func _on_sec_dec_button_button_up() -> void:
	if repeat_inc_sec == -1 :
		time_changed.emit(-click_inc_sec)
	repeat_inc_sec = 0
	$Timer.stop()

func _on_sec_inc_button_button_down() -> void:
	repeat_inc_sec = 1
	$Timer.start(0.1)
func _on_sec_inc_button_button_up() -> void:
	if repeat_inc_sec == 1 :
		time_changed.emit(click_inc_sec)
	repeat_inc_sec = 0
	$Timer.stop()

func _on_timer_timeout() -> void:
	time_changed.emit(repeat_inc_sec)
	if repeat_inc_sec < 0 :
		repeat_inc_sec -=1
		if repeat_inc_sec < -max_inc_sec :
			repeat_inc_sec = -max_inc_sec
	else :
		repeat_inc_sec +=1
		if repeat_inc_sec > max_inc_sec :
			repeat_inc_sec = max_inc_sec
