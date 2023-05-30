extends Node2D

#@export var workScene: PackedScene

var workScene = preload("res://work_container.tscn")

var programs = [
	# 이름,총시간초,걷기초,달리기초 
	[ "테스트", ["총시간",30*1 ], ["걷기", 10*1  ], ["달리기", 10*1  ] ],
	[ "1일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1  ] ],
	[ "3일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1.5] ],
	[ "5일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*2  ] ],
	[ "7일차",  ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*2  ] ],
	[ "9일차",  ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*3  ] ],
	[ "11일차", ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*3  ] ],
	[ "13일차", ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*4  ] ],
	[ "15일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*5  ] ],
	[ "17일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*7  ] ],
	[ "19일차", ["총시간",60*30], ["걷기", 60*4  ], ["달리기", 60*10 ] ],
	[ "21일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ] ],
	[ "23일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ "25일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ] ],
	[ "27일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ "29일차", ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ "30일차", ["달리기",60*30] ],
]


var voices = DisplayServer.tts_get_voices_for_language("ko")
var voice_id = voices[0]

func Text2Speech(s):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voice_id)


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
	var data = programs[i].duplicate()
	var rtn = "%s:" % [ data.pop_front() ]
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
	if button_pressed: # list opened
		return
	var sel = $VBoxContainer/TitleContainer/MenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	
	var selData = programs[sel].duplicate()
	var title=selData.pop_front()
	$VBoxContainer/TitleContainer/MenuButton.text = title
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
		Text2Speech("%s를 시작합니다." % [ $VBoxContainer/TitleContainer/MenuButton.text ])
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		Text2Speech("%s를 멈춥니다." % [ $VBoxContainer/TitleContainer/MenuButton.text ])
		$Timer.stop()
	buttonsDisable(button_pressed)


