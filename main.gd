extends Node2D

var workScene = preload("res://work_container.tscn")
var voices = DisplayServer.tts_get_voices_for_language("ko")
var voice_id = voices[0]

func Text2Speech(s):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voice_id)

@onready var WorkDataMenuButton = $VBoxContainer/TitleContainer/WorkDataMenuButton
@onready var CmdMenuButton = $VBoxContainer/TitleContainer/CmdMenuButton

var workData :WorkData
var Works = []
var subWorkIndex = 1

func updateTimeLabels():
	for o in Works:
		o.updateTimeLabels()

func resetTime():
	for o in Works:
		o.resetTime()

func buttonsDisable(disable :bool):
	WorkDataMenuButton.disabled =disable
	for o in Works:
		o.buttonsDisable(disable)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkDataMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")

	reset_workd_data()
	work_data2work_data_menu()


func work_data2work_data_menu():
	WorkDataMenuButton.get_popup().clear()
	for i in workData.works.size():
		WorkDataMenuButton.get_popup().add_item(workData.get_at(i).to_str(),i)

func _on_timer_timeout() -> void:
	if Works[0].decRemainSec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	elif len(Works) > subWorkIndex:
		if Works[subWorkIndex].decRemainSec() != true: # move to next sub work
			Works[subWorkIndex].resetTime()
			var oldWorkStr = Works[subWorkIndex].getLabelText()
			subWorkIndex += 1
			if len(Works) <= subWorkIndex:
				subWorkIndex = 1
			var newWorkStr = Works[subWorkIndex].getLabelText()
			Text2Speech("%s를 끝내고 %s를 시작합니다." %[oldWorkStr,newWorkStr])
			Works[subWorkIndex].grab_focus()
	updateTimeLabels()

func _on_work_data_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = WorkDataMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return

	var selData = workData.get_at(sel)
	var title=selData.title
	WorkDataMenuButton.text = title
	Text2Speech("%s로 설정합니다." % title)
	makeWorks(selData)
	resetTime()
	updateTimeLabels()

func makeWorks(work :WorkData.Work):
	# clear
	for i in range(len(Works)):
		if i == 0:
			continue
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(Works[i])
		Works[i].queue_free()
	Works = [
		$VBoxContainer/MainWorkContainer
	]
	for wd in work.sub_work_list:
		var wk = workScene.instantiate()
		wk.focus_mode = Control.FOCUS_ALL
		wk.setLabelTotalSec( wd.name, wd.second)
		Works.append(wk)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(wk)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if len(Works) == 0 :
		return
	if button_pressed :
		if Works[0].remainSec<=0:
			resetTime()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		Text2Speech("%s를 시작합니다." % [ WorkDataMenuButton.text ])
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		Text2Speech("%s를 멈춥니다." % [ WorkDataMenuButton.text ])
		$Timer.stop()
	buttonsDisable(button_pressed)

func _on_cmd_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = CmdMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	match sel :
		0: # 읽어오기
			load_work_data()
		1: # 저장하기
			save_work_data()
		2: # 초기화하기
			reset_workd_data()
		3: # 새작업추가하기
			add_new_work()
		_: # unknown
			print_debug("unknown", sel)

func reset_workd_data():
	workData = WorkData.new().from_data(work_rawdata)
	print_debug(workData.to_data())
	work_data2work_data_menu()
	show_message("초기화합니다.")

func load_work_data():
	var msg =  workData.load(file_name)
	work_data2work_data_menu()
	show_message(msg)

func save_work_data():
	var msg = workData.save(file_name)
	show_message(msg)

func add_new_work():
	var wk = ["새워크", ["총시간",60*30], ["운동", 60*3], ["휴식", 60*1] ]
	workData.add_new_work( workData.Work.new().from_data(wk) )
	work_data2work_data_menu()
	show_message("새워크를추가합니다.")

func show_message(msg):
	$MessageLabel.text = msg
	$MessageLabel.visible = true
	$MessageTimer.start(3.0)

func _on_message_timer_timeout() -> void:
	$MessageLabel.visible = false

# raw data
var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/gd4timer_workdata.json"
var work_rawdata = [
	# 이름,총시간초,work1 sec, work2 sec, etc
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
	[ "23일차", ["총시간",60*32], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ "25일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ "27일차", ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ "29일차", ["총시간",60*35], ["걷기", 60*2.5], ["달리기", 60*30 ], ["걷기", 60*2.5] ],
]
