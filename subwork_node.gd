extends HBoxContainer

signal del_subwork(index :int, sw :WorkList.SubWork)
signal add_subwork(index :int, sw :WorkList.SubWork)

var subwork :WorkList.SubWork
var subwork_index :int
var remainSec = 0
var incSec = 10

func set_subwork(i :int,  sw :WorkList.SubWork)->void:
	subwork_index = i
	subwork = sw
	$NameEdit.text = subwork.name

func update_time_labels()->void:
	$SecLabel.text = subwork.second2text(subwork.second)
	$SecRemainLabel.text = subwork.second2text(remainSec)

func disable_buttons(disable :bool)->void:
	$MenuButton.disabled = disable
	$SecDecButton.disabled = disable
	$SecIncButton.disabled = disable

func reset_time()->void:
	remainSec = subwork.second

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
	subwork.second -= incSec
	if subwork.second < 0 :
		subwork.second = 0
	reset_time()
	update_time_labels()

func _on_sec_inc_button_pressed() -> void:
	subwork.second += incSec
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
			del_subwork.emit(subwork_index, subwork)
		2: # 서브워크추가하기
			add_subwork.emit(subwork_index, subwork)
		_: # unknown
			print_debug("unknown", sel)


func _on_name_edit_text_submitted(new_text: String) -> void:
	$NameEdit.editable = false
	subwork.name = $NameEdit.text