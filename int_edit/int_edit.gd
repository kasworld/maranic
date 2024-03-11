extends PanelContainer

class_name IntEdit

@onready var vallabel = $HBoxContainer/ValueLabel
@onready var incbtn = $HBoxContainer/VBoxContainer/IncButton
@onready var decbtn = $HBoxContainer/VBoxContainer/DecButton

signal value_changed() # emit button up
signal over_limit_low_reached() # emit when try dec on low limit value
signal over_limit_high_reached() # emit when try inc on high limit value

var limit_high :int
var use_limit_high :bool
var init_value :int
var limit_low :int
var use_limit_low :bool
var current_value :int
var formater :Callable

func _ready() -> void:
	pass

func init(llow :int, uselow :bool, val :int, lhigh :int, usehigh :bool, fmt :Callable=default_formater)->void:
	limit_low = llow
	use_limit_low = uselow
	init_value = val
	limit_high = lhigh
	use_limit_high = usehigh
	formater = fmt
	reset()

func set_init_value(v :int)->void:
	init_value = v
	reset()

func reset()->void:
	current_value = init_value
	update_label()

func default_formater(v:int)->String:
	return "%d" % v

func update_label()->void:
	vallabel.text = formater.call(current_value)

func get_value()->int:
	return current_value

func disable_buttons(b :bool)->void:
	decbtn.disabled = b
	incbtn.disabled = b

func inc(v :int)->void:
	var oldval = current_value
	current_value += v
	if use_limit_high:
		if current_value >= limit_high:
			current_value = limit_high
			over_limit_high_reached.emit()
	if current_value != oldval:
		value_changed.emit()
		update_label()

func dec(v :int)->void:
	var oldval = current_value
	current_value -= v
	if use_limit_low:
		if current_value <= limit_low:
			current_value = limit_low
			over_limit_low_reached.emit()
	if current_value != oldval:
		value_changed.emit()
		update_label()

const click_inc_sec = 1
var repeat_inc_sec = 0

func _on_dec_button_button_down() -> void:
	repeat_inc_sec = -1
	$Timer.start(0.1)
func _on_dec_button_button_up() -> void:
	if repeat_inc_sec == -1 :
		dec(click_inc_sec)
	repeat_inc_sec = 0
	$Timer.stop()

func _on_inc_button_button_down() -> void:
	repeat_inc_sec = 1
	$Timer.start(0.1)
func _on_inc_button_button_up() -> void:
	if repeat_inc_sec == 1 :
		inc(click_inc_sec)
	repeat_inc_sec = 0
	$Timer.stop()

func _on_timer_timeout() -> void:
	if repeat_inc_sec < 0 :
		dec(-repeat_inc_sec)
		repeat_inc_sec -=1
	else :
		inc(repeat_inc_sec)
		repeat_inc_sec +=1
