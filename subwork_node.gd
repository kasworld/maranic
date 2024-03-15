extends HBoxContainer

class_name SubWorkNode

signal del_subwork(index :int, sw :WorkList.SubWork)
signal add_subwork(index :int, sw :WorkList.SubWork)
signal time_reached(index :int, v :float) # v : overrun value (<=0)

var subwork :WorkList.SubWork
var subwork_index :int

func init()->void:
	var fsize = 100
	$MenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	$MenuButton.get_popup().index_pressed.connect(_on_menu_index_pressed)
	$TimeRecorder.init(0, fsize, TickLib.tick2str)
	$TimeRecorder.overrun.connect(_on_timerecorder_overrun)
	$IntEdit.init(0,fsize, TickLib.tick2str)
	$IntEdit.set_limits(0,true,0,99,false)
	$IntEdit.value_changed.connect(_on_edit_value_changed)
	$ToggleButton.theme.default_font_size = fsize
	mode_countdowntimer()

func set_subwork(i :int, sw :WorkList.SubWork)->void:
	subwork_index = i
	subwork = sw
	$NameEdit.text = subwork.name
	$MenuButton.text = subwork.name
	$TimeRecorder.set_initial_sec(subwork.second)
	$IntEdit.set_init_value(subwork.second)

func _on_timerecorder_overrun(v:float)->void:
	time_reached.emit(subwork_index, v)
	reset_time()

func _on_edit_value_changed(n:int) ->void:
	subwork.second = $IntEdit.get_value()
	if subwork.second < 0 :
		subwork.second = 0
	$TimeRecorder.set_initial_sec(subwork.second)
	reset_time()

func clear()->void:
	subwork_index = -1
	subwork = null
	$NameEdit.text = ""
	$IntEdit.set_init_value(0)
	$TimeRecorder.set_initial_sec(0)

func reset_time()->void:
	$TimeRecorder.reset()

# start and resume
func start(offset:float=0)->void:
	$TimeRecorder.start(offset)

# stop and pause
func pause()->void:
	$TimeRecorder.pause()

func disable_buttons(b :bool)->void:
	$MenuButton.disabled = b
	$IntEdit.disable_buttons(b)
	$TimeRecorder.disable_buttons(b)

func get_label_text()->String:
	return $NameEdit.text

func disable_menu(i :int, b :bool)->void:
	$MenuButton.get_popup().set_item_disabled(i,b)

func edit_name(b :bool)->void:
	$NameEdit.editable = b
	$NameEdit.visible = b
	$MenuButton.visible = not b

func _on_menu_index_pressed(sel :int)->void:
	match sel :
		0: # 서브워크이름바꾸기
			edit_name( true)
		1: # 서브워크지우기
			del_subwork.emit(subwork_index, subwork)
		2: # 서브워크추가하기
			add_subwork.emit(subwork_index, subwork)
		_: # unknown
			print_debug("unknown", sel)

func _on_name_edit_text_submitted(new_text: String) -> void:
	edit_name( false)
	subwork.name = $NameEdit.text
	$MenuButton.text = subwork.name

func _on_name_edit_focus_exited() -> void:
	edit_name( false)

func _on_name_edit_focus_entered() -> void:
	edit_name( true)

func mode_stopwatch()->void:
	$ToggleButton.text = "⏱"
	$TimeRecorder.set_stopwatch()
	$IntEdit.visible = false

func mode_countdowntimer()->void:
	$ToggleButton.text = "⏳"
	$IntEdit.visible = true
	$TimeRecorder.set_initial_sec($IntEdit.get_value())

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mode_stopwatch()
	else:
		mode_countdowntimer()
