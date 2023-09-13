extends HBoxContainer

var totalSec = 0
var remainSec = 0
var incSec = 10

func second2text(sec :int)->String:
	return "%02d:%02d" %[ sec/60,sec % 60]

func update_time_labels()->void:
	$SecLabel.text = second2text(totalSec)
	$SecRemainLabel.text = second2text(remainSec)

func disable_buttons(disable :bool)->void:
	$MenuButton.disabled = disable
	$SecDecButton.disabled = disable
	$SecIncButton.disabled = disable

func reset_time()->void:
	remainSec = totalSec

func set_label_total_sec(s,sec)->void:
	$NameEdit.text = s
	totalSec = sec

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
	totalSec -= incSec
	if totalSec < 0 :
		totalSec = 0
	reset_time()
	update_time_labels()

func _on_sec_inc_button_pressed() -> void:
	totalSec += incSec
	reset_time()
	update_time_labels()
