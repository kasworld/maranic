extends HBoxContainer

signal del_subwork(index :int, sw :WorkList.SubWork)
signal add_subwork(index :int, sw :WorkList.SubWork)

var subwork :WorkList.SubWork
var subwork_index :int
var remainSec = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	$MenuButton.get_popup().index_pressed.connect(menu_index_pressed)
	$TimeEdit.init(0,true,0,99,false,TickLib.tick2stri)
	$TimeEdit.value_changed.connect(set_subwork_second)

func set_subwork_second() ->void:
	subwork.second = $TimeEdit.get_value()
	if subwork.second < 0 :
		subwork.second = 0
	reset_time()
	update_time_labels()

func set_subwork(i :int, sw :WorkList.SubWork)->void:
	subwork_index = i
	subwork = sw
	$NameEdit.text = subwork.name
	$MenuButton.text = subwork.name

func reset()->void:
	subwork_index = -1
	subwork = null
	remainSec = 0
	update_time_labels()
	$NameEdit.text = ""
	$TimeEdit.reset()

func update_time_labels()->void:
	$SecRemainLabel.text = TickLib.tick2stri(remainSec)

func disable_buttons(b :bool)->void:
	$MenuButton.disabled = b
	$TimeEdit.disable_buttons(b)

func reset_time()->void:
	remainSec = subwork.second
	$TimeEdit.set_init_value(remainSec)

func get_label_text()->String:
	return $NameEdit.text

func dec_remain_sec() -> bool:
	remainSec -= 1
	if remainSec <= 0:
		return false # not success
	return true

func disable_menu(i :int, b :bool)->void:
	$MenuButton.get_popup().set_item_disabled(i,b)

func edit_name(b :bool)->void:
	$NameEdit.editable = b
	$NameEdit.visible = b
	$MenuButton.visible = not b

func menu_index_pressed(sel :int)->void:
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



