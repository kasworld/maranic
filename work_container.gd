extends HBoxContainer

var totalSec = 0
var remainSec = 0
var incSec = 30

func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func updateTimeLabels():
	$SecLabel.text = second2text(totalSec)
	$SecRemainLabel.text = second2text(remainSec)

func buttonsDisable(disable :bool):
	$SecDecButton.disabled =disable
	$SecIncButton.disabled =disable

func resetTime():
	remainSec = totalSec

func setLabelTotalSec(str,sec):
	$Label.text = str
	totalSec = sec

func getLabelText():
	return $Label.text

func decRemainSec() -> bool:
	remainSec -= 1
	if remainSec <= 0:
		return false # not success 
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sec_dec_button_pressed() -> void:
	totalSec -= incSec
	if totalSec < 0 :
		totalSec = 0
	resetTime()
	updateTimeLabels()


func _on_sec_inc_button_pressed() -> void:
	totalSec += incSec
	resetTime()
	updateTimeLabels()
