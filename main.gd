extends Node2D

#@export var workScene: PackedScene

var workScene = preload("res://work_container.tscn")

var programs = [
	#총시간초,걷기초,달리기초 
	[ ["총시간",60*30], ["걷기", 10*1  ], ["달리기", 10*1  ] ],
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
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ] ],
	[ ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ ["달리기",60*30] ],
]

# tts

var voices = DisplayServer.tts_get_voices_for_language("ko")
var voice_id = voices[0]

func Text2Speech(str):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(str, voice_id)


var Works = []
var subWorkIndex = 1

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
		rtn += "%s(%s)" % [ data[j][0], second2text(data[j][1]) ]
	return rtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len( programs)):
		$VBoxContainer/TitleContainer/MenuButton.get_popup().add_item(program2text(i),i)
	$VBoxContainer/TitleContainer/MenuButton.get_popup().theme = preload("res://menulist_theme.tres")

func makeWorks(n ):
	for i in range(len(Works)):
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(Works[i])
		Works[i].queue_free()
	Works = []
	for i in range(n):
		var work = workScene.instantiate()
		Works.append(work)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(work)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if Works[0].decRemainSec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	if len(Works) > subWorkIndex:
		if Works[subWorkIndex].decRemainSec() != true: # move to next sub work
			Works[subWorkIndex].resetTime()
			var oldWorkStr = Works[subWorkIndex].getLabelText()
			subWorkIndex += 1
			if len(Works) <= subWorkIndex:
				subWorkIndex = 1
			var newWorkStr = Works[subWorkIndex].getLabelText()
			Text2Speech("%s를 끝내고 %s를 시작합니다." %[oldWorkStr,newWorkStr])
	updateTimeLabels()


func _on_menu_button_toggled(button_pressed: bool) -> void:
	var sel = $VBoxContainer/TitleContainer/MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	
	var selData =programs[sel]
	makeWorks(len(selData))
	for i in range(len(selData)):
		Works[i].setLabelTotalSec( selData[i][0],selData[i][1])
	resetTime()
	updateTimeLabels()


func _on_start_button_toggled(button_pressed: bool) -> void:
	if len(Works) == 0 :
		return
	if button_pressed :
		if Works[0].remainSec<=0:
			resetTime()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		Text2Speech("시작합니다.")
#		Text2Speech("start main work")
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		Text2Speech("멈춥니다.")
#		Text2Speech("end main work")
		$Timer.stop()
	buttonsDisable(button_pressed)


