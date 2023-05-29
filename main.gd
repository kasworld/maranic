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

var totalSecond = 0
var totalSecondRemain = 0
var walkSecond = 0
var walkSecondRemain = 0
var runSecond = 0
var runSecondRemain = 0

func updateTimeLabels():
	$VBoxContainer/TotalSecContainer/TotalSecLabel.text = second2text(totalSecond)
	$VBoxContainer/WalkSecContainer/WalkSecLabel.text = second2text(walkSecond)
	$VBoxContainer/RunSecContainer/RunSecLabel.text = second2text(runSecond)
	$VBoxContainer/TotalSecContainer/TotalSecRemainLabel.text = second2text(totalSecondRemain)
	$VBoxContainer/WalkSecContainer/WalkSecRemainLabel.text = second2text(walkSecondRemain)
	$VBoxContainer/RunSecContainer/RunSecRemainLabel.text = second2text(runSecondRemain)

func buttonsDisable(disable :bool):
	$VBoxContainer/TitleContainer/MenuButton.disabled =disable
	$VBoxContainer/TotalSecContainer/TotalSecDecButton.disabled =disable
	$VBoxContainer/TotalSecContainer/TotalSecIncButton.disabled =disable
	$VBoxContainer/WalkSecContainer/WalkSecDecButton.disabled =disable
	$VBoxContainer/WalkSecContainer/WalkSecIncButton.disabled =disable
	$VBoxContainer/RunSecContainer/RunSecDecButton.disabled =disable
	$VBoxContainer/RunSecContainer/RunSecIncButton.disabled =disable
	

func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func program2text(i):
	var data = programs[i]
	return "%s,%s" % [ second2text(data[1]), second2text(data[2]) ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len( programs)):
		$VBoxContainer/TitleContainer/MenuButton.get_popup().add_item(program2text(i),i)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	totalSecondRemain -= 1 
	if totalSecondRemain <= 0 :
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	updateTimeLabels()


func _on_menu_button_toggled(button_pressed: bool) -> void:
	var sel = $VBoxContainer/TitleContainer/MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	totalSecond =  programs[sel][0]
	walkSecond =  programs[sel][1]
	runSecond =  programs[sel][2]
	resetTime()
	updateTimeLabels()

func resetTime():
	totalSecondRemain = totalSecond
	walkSecondRemain = walkSecond
	runSecondRemain = runSecond


func _on_total_sec_dec_button_pressed() -> void:
	totalSecond -= 60*5
	if totalSecond < 0 :
		totalSecond = 0
	resetTime()
	updateTimeLabels()


func _on_total_sec_inc_button_pressed() -> void:
	totalSecond += 10 # 60*5
	resetTime()
	updateTimeLabels()


func _on_walk_sec_dec_button_pressed() -> void:
	walkSecond -= 30
	if walkSecond < 0 :
		walkSecond = 0
	resetTime()
	updateTimeLabels()


func _on_walk_sec_inc_button_pressed() -> void:
	walkSecond += 30
	resetTime()
	updateTimeLabels()


func _on_run_sec_dec_button_pressed() -> void:
	runSecond -= 30
	if runSecond < 0 :
		runSecond = 0
	resetTime()
	updateTimeLabels()


func _on_run_sec_inc_button_pressed() -> void:
	runSecond += 30
	resetTime()
	updateTimeLabels()


func _on_start_button_toggled(button_pressed: bool) -> void:
	if button_pressed :
		if totalSecondRemain<=0:
			resetTime()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		$Timer.stop()
	buttonsDisable(button_pressed)


