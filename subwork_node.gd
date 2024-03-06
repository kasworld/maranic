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
	$TimeEdit.time_changed.connect(add_subwork_second)

func add_subwork_second(diff :int) ->void:
	subwork.second += diff
	if subwork.second < 0 :
		subwork.second = 0
	reset_time()
	update_time_labels()

func set_subwork(i :int, sw :WorkList.SubWork)->void:
	subwork_index = i
	subwork = sw
	$NameEdit.text = subwork.name

func reset()->void:
	subwork_index = -1
	subwork = null
	$TimeEdit.clear()
	$SecRemainLabel.text = "00:00"
	$NameEdit.text = ""

func update_time_labels()->void:
	$TimeEdit.set_sec(subwork.second)
	$SecRemainLabel.text = subwork.second2text(remainSec)

func disable_buttons(b :bool)->void:
	$MenuButton.disabled = b
	$TimeEdit.disable_buttons(b)
	#$SecDecButton.disabled = b
	#$SecIncButton.disabled = b

func reset_time()->void:
	remainSec = subwork.second

func get_label_text()->String:
	return $NameEdit.text

func dec_remain_sec() -> bool:
	remainSec -= 1
	if remainSec <= 0:
		return false # not success
	return true

func disable_menu(i :int, b :bool)->void:
	$MenuButton.get_popup().set_item_disabled(i,b)

func menu_index_pressed(sel :int)->void:
	match sel :
		0: # 서브워크이름바꾸기
			$NameEdit.editable = true
		1: # 서브워크지우기
			del_subwork.emit(subwork_index, subwork)
		2: # 서브워크추가하기
			add_subwork.emit(subwork_index, subwork)
		_: # unknown
			print_debug("unknown", sel)

func _on_name_edit_text_submitted(new_text: String) -> void:
	$NameEdit.editable = false
	subwork.name = $NameEdit.text

func _on_name_edit_focus_exited() -> void:
	$NameEdit.editable = false

func _on_name_edit_focus_entered() -> void:
	$NameEdit.editable = true



