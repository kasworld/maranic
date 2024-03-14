extends HBoxContainer

class_name TimeRow

signal started(n:int) # emit when 1st start

# ⌚  U+0231A  WATCH
# ⌛  U+0231B  HOURGLASS
# ⏰  U+023F0  ALARM CLOCK
# ⏱  U+023F1  STOPWATCH
# ⏲  U+023F2  TIMER CLOCK
# ⏳  U+023F3  HOURGLASS WITH FLOWING SAND
# ⧖  U+029D6  WHITE HOURGLASS
# ⧗  U+029D7  BLACK HOURGLASS

func init(idx :int, fsize :int)->void:
	$TimeRecorder.init(idx,fsize, TickLib.tick2str)
	$IntEdit.init(fsize, TickLib.tick2stri)
	$IntEdit.set_limits( 0,true,0,99,false)
	$TimeRecorder.started.connect(_on_tr_started)
	$ToggleButton.theme.default_font_size = fsize
	$IntEdit.value_changed.connect(_on_edit_value_changed)
	$IntEdit.disable_buttons(true)

func _on_tr_started(n:int)->void:
	started.emit(n)

func _on_edit_value_changed()->void:
	var v = $IntEdit.get_value()
	$TimeRecorder.set_initial_sec(v)

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ToggleButton.text = "⏳"
		$IntEdit.disable_buttons(false)
	else:
		$ToggleButton.text = "⏱"
		$IntEdit.disable_buttons(true)
		$TimeRecorder.set_stopwatch()
		$IntEdit.set_init_value(0)
