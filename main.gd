extends Node2D


var programs = [
	#총시간초,걷기초,달리기초 
	[ 1800, 60*3,   60*1   ],
	[ 1800, 60*3,   60*1.5 ],
	[ 1800, 60*3,   60*2   ],
	[ 1800, 60*2,   60*2   ],
	[ 1800, 60*2,   60*3   ],
	[ 1800, 60*1,   60*3   ],
	[ 1800, 60*1,   60*4   ],
	[ 1800, 60*2,   60*5   ],
	[ 1800, 60*3,   60*7   ],
	[ 1800, 60*4,   60*10  ],
	[ 1800, 60*2,   60*13  ],
	[ 1800, 60*2,   60*15  ],
	[ 1800, 60*3,   60*5   ],
	[ 1800, 60*2,   60*20  ],
	[ 1800, 60*2.5, 60*25  ],
	[ 1800, 60*0,   60*30  ],
]


func updateTimeLabels():
	$VBoxContainer/TotalWork.updateTimeLabels()
	$VBoxContainer/WalkWork.updateTimeLabels()
	$VBoxContainer/RunWork.updateTimeLabels()

func buttonsDisable(disable :bool):
	$VBoxContainer/TitleContainer/MenuButton.disabled =disable
	$VBoxContainer/TotalWork.buttonsDisable(disable)
	$VBoxContainer/WalkWork.buttonsDisable(disable)
	$VBoxContainer/RunWork.buttonsDisable(disable)
	

func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func program2text(i):
	var data = programs[i]
	return "%s,%s" % [ second2text(data[1]), second2text(data[2]) ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len( programs)):
		$VBoxContainer/TitleContainer/MenuButton.get_popup().add_item(program2text(i),i)
	$VBoxContainer/TotalWork/Label.text = "총시간"
	$VBoxContainer/WalkWork/Label.text = "걷기"
	$VBoxContainer/RunWork/Label.text = "뛰기"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	$VBoxContainer/TotalWork.remainSec -= 1 
	if $VBoxContainer/TotalWork.remainSec <= 0 :
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	updateTimeLabels()


func _on_menu_button_toggled(button_pressed: bool) -> void:
	var sel = $VBoxContainer/TitleContainer/MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	$VBoxContainer/TotalWork.totalSec =  programs[sel][0]
	$VBoxContainer/WalkWork.totalSec =  programs[sel][1]
	$VBoxContainer/RunWork.totalSec =  programs[sel][2]
	resetTime()
	updateTimeLabels()

func resetTime():
	$VBoxContainer/TotalWork.resetTime()
	$VBoxContainer/WalkWork.resetTime()
	$VBoxContainer/RunWork.resetTime()




func _on_start_button_toggled(button_pressed: bool) -> void:
	if button_pressed :
		if $VBoxContainer/TotalWork.remainSec<=0:
			resetTime()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		$Timer.stop()
	buttonsDisable(button_pressed)


