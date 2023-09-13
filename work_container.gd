extends HBoxContainer

signal del_sub_work(index :int, sw :WorkList.SubWork)
signal add_sub_work(index :int, sw :WorkList.SubWork)

var sub_work :WorkList.SubWork
var sub_work_index :int
var remainSec = 0
var incSec = 10

func set_sub_work(i :int,  sw :WorkList.SubWork)->void:
	sub_work_index = i
	sub_work = sw
	$NameEdit.text = sub_work.name

func update_time_labels()->void:
	$SecLabel.text = sub_work.second2text(sub_work.second)
	$SecRemainLabel.text = sub_work.second2text(remainSec)

func disable_buttons(disable :bool)->void:
	$MenuButton.disabled = disable
	$SecDecButton.disabled = disable
	$SecIncButton.disabled = disable

func reset_time()->void:
	remainSec = sub_work.second

func get_label_text()->String:
	return $NameEdit.text

func dec_remain_sec() -> bool:
	remainSec -= 1
	if remainSec <= 0:
		return false # not success
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	pass # Replace with function body.

func _on_sec_dec_button_pressed() -> void:
	sub_work.second -= incSec
	if sub_work.second < 0 :
		sub_work.second = 0
	reset_time()
	update_time_labels()

func _on_sec_inc_button_pressed() -> void:
	sub_work.second += incSec
	reset_time()
	update_time_labels()


func _on_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = $MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	match sel :
		0: # 서브워크이름바꾸기
			$NameEdit.editable = true
		1: # 서브워크지우기
			del_sub_work.emit(sub_work_index, sub_work)
		2: # 서브워크추가하기
			add_sub_work.emit(sub_work_index, sub_work)
		_: # unknown
			print_debug("unknown", sel)


func _on_name_edit_text_submitted(new_text: String) -> void:
	$NameEdit.editable = false
	sub_work.name = $NameEdit.text
