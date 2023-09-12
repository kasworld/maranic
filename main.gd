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
var work_nodes = []
var subWorkIndex = 1

func updateTimeLabels():
	for o in work_nodes:
		o.updateTimeLabels()

func resetTime():
	for o in work_nodes:
		o.resetTime()

func buttonsDisable(disable :bool):
	WorkDataMenuButton.disabled =disable
	for o in work_nodes:
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
	if work_nodes[0].decRemainSec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	elif len(work_nodes) > subWorkIndex:
		if work_nodes[subWorkIndex].decRemainSec() != true: # move to next sub work
			work_nodes[subWorkIndex].resetTime()
			var oldWorkStr = work_nodes[subWorkIndex].getLabelText()
			subWorkIndex += 1
			if len(work_nodes) <= subWorkIndex:
				subWorkIndex = 1
			var newWorkStr = work_nodes[subWorkIndex].getLabelText()
			Text2Speech("%s를 끝내고 %s를 시작합니다." %[oldWorkStr,newWorkStr])
			work_nodes[subWorkIndex].grab_focus()
	updateTimeLabels()

func _on_work_data_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = WorkDataMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return

	var selData = workData.get_at(sel)
	WorkDataMenuButton.text = selData.title
	Text2Speech("%s로 설정합니다." % selData.title)
	makeWorks(selData)
	resetTime()
	updateTimeLabels()

func makeWorks(work :WorkData.Work):
	# clear
	for i in work_nodes.size():
		if i == 0:
			continue
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(work_nodes[i])
		work_nodes[i].queue_free()
	work_nodes = [
		$VBoxContainer/MainWorkContainer
	]
	for wd in work.sub_work_list.size()-1:
		var wk = workScene.instantiate()
		wk.focus_mode = Control.FOCUS_ALL
		work_nodes.append(wk)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(wk)
	for i in work_nodes.size():
		var wd = work.sub_work_list[i]
		work_nodes[i].setLabelTotalSec( wd.name, wd.second)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if work_nodes.size() == 0 :
		return
	if button_pressed :
		if work_nodes[0].remainSec<=0:
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
	var neww = WorkData.new(work_rawdata)
	if not neww.errmsg.is_empty():
#		print_debug(neww.errmsg)
		show_message(neww.errmsg)
		return
	workData = neww
#	print_debug(workData.to_data())
	work_data2work_data_menu()
	show_message("초기화합니다.")

func load_work_data():
	var neww =  workData.load_new(file_name)
	if not neww.errmsg.is_empty():
		show_message(neww.errmsg)
		return
	workData = neww
	work_data2work_data_menu()
	show_message("load %s" % [file_name])

func save_work_data():
	var msg = workData.save(file_name)
	show_message(msg)

func add_new_work():
	var wk = ["새워크", ["총시간",60*30], ["운동", 60*3], ["휴식", 60*1] ]
	workData.add_new_work( workData.Work.new(wk) )
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
