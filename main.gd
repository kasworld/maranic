extends Node2D

@export var workScene: PackedScene

var programs = [
	#총시간초,걷기초,달리기초 
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1  ] ],
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1.5] ],
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*2  ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*2  ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*3  ] ],
	[ ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*3  ] ],
	[ ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*4  ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*5  ] ],
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*7  ] ],
	[ ["총시간",60*30], ["걷기", 60*4  ], ["달리기", 60*10 ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ] ],
	[ ["총시간",60*30], ["걷기", 60*0  ], ["달리기", 60*30 ] ],
]

var Works = []

func updateTimeLabels():
	for o in Works:
		o.updateTimeLabels()

func resetTime():
	for o in Works:
		o.resetTime()

func buttonsDisable(disable :bool):
	$VBoxContainer/TitleContainer/MenuButton.disabled =disable
	for o in Works:
		o.buttonsDisable(disable)
	

func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func program2text(i):
	var data = programs[i]
	var rtn = ""
	for j in range(len(data)):
		rtn += "%s(%s)" % [  data[j][0],  second2text(data[j][1]) ]
	return rtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len( programs)):
		$VBoxContainer/TitleContainer/MenuButton.get_popup().add_item(program2text(i),i)
	Works = [
		$VBoxContainer/TotalWork,
		$VBoxContainer/WalkWork,
		$VBoxContainer/RunWork,
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if Works[0].decRemainSec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	updateTimeLabels()


func _on_menu_button_toggled(button_pressed: bool) -> void:
	var sel = $VBoxContainer/TitleContainer/MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	
	var selData =programs[sel]
	for i in range(len(selData)):
		Works[i].setLabelTotalSec( selData[i][0],selData[i][1])
	resetTime()
	updateTimeLabels()


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


