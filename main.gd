extends Node2D

var work_scene = preload("res://work_container.tscn")

var voices = DisplayServer.tts_get_voices_for_language("ko")
func text2speech(s):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voices[0])

@onready var WorkDataMenuButton = $VBoxContainer/TitleContainer/WorkDataMenuButton
@onready var CmdMenuButton = $VBoxContainer/TitleContainer/CmdMenuButton

var work_data :WorkData
var work_nodes = []
var sub_work_index = 1

func update_time_labels():
	for o in work_nodes:
		o.update_time_labels()

func reset_time():
	for o in work_nodes:
		o.reset_time()

func disable_buttons(disable :bool):
	WorkDataMenuButton.disabled =disable
	for o in work_nodes:
		o.disable_buttons(disable)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkDataMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	reset_work_data()
	work_data2work_data_menu()

func work_data2work_data_menu():
	WorkDataMenuButton.get_popup().clear()
	for i in work_data.works.size():
		WorkDataMenuButton.get_popup().add_item(work_data.get_at(i).to_str(),i)

func _on_timer_timeout() -> void:
	if work_nodes[0].dec_remain_sec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	elif len(work_nodes) > sub_work_index:
		if work_nodes[sub_work_index].dec_remain_sec() != true: # move to next sub work
			work_nodes[sub_work_index].reset_time()
			var oldWorkStr = work_nodes[sub_work_index].get_label_text()
			sub_work_index += 1
			if len(work_nodes) <= sub_work_index:
				sub_work_index = 1
			var newWorkStr = work_nodes[sub_work_index].get_label_text()
			text2speech("%s를 끝내고 %s를 시작합니다." %[oldWorkStr,newWorkStr])
			work_nodes[sub_work_index].grab_focus()
	update_time_labels()

func _on_work_data_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = WorkDataMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return

	var sel_wd = work_data.get_at(sel)
	WorkDataMenuButton.text = sel_wd.title
	text2speech("%s로 설정합니다." % sel_wd.title)
	make_works(sel_wd)
	reset_time()
	update_time_labels()

func make_works(wk :WorkData.Work):
	# clear
	for i in work_nodes.size():
		if i == 0:
			continue
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(work_nodes[i])
		work_nodes[i].queue_free()
	work_nodes = [
		$VBoxContainer/MainWorkContainer
	]
	for i in wk.sub_work_list.size()-1:
		var wn = work_scene.instantiate()
		wn.focus_mode = Control.FOCUS_ALL
		work_nodes.append(wn)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(wn)
	for i in work_nodes.size():
		var sw = wk.sub_work_list[i]
		work_nodes[i].set_label_total_sec( sw.name, sw.second)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if work_nodes.size() == 0 :
		return
	if button_pressed :
		if work_nodes[0].remainSec<=0:
			reset_time()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		text2speech("%s를 시작합니다." % [ WorkDataMenuButton.text ])
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		text2speech("%s를 멈춥니다." % [ WorkDataMenuButton.text ])
		$Timer.stop()
	disable_buttons(button_pressed)

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
			reset_work_data()
		3: # 새작업추가하기
			add_new_work()
		_: # unknown
			print_debug("unknown", sel)

func reset_work_data():
	var new_wd = WorkData.new(work_rawdata)
	if not new_wd.errmsg.is_empty():
#		print_debug(new_wd.errmsg)
		$TimedMessage.show_message(new_wd.errmsg)
		return
	work_data = new_wd
#	print_debug(work_data.to_data())
	work_data2work_data_menu()
	$TimedMessage.show_message("초기화합니다.")

func load_work_data():
	var new_wd =  work_data.load_new(file_name)
	if not new_wd.errmsg.is_empty():
		$TimedMessage.show_message(new_wd.errmsg)
		return
	work_data = new_wd
	work_data2work_data_menu()
	$TimedMessage.show_message("load %s" % [file_name])

func save_work_data():
	var msg = work_data.save(file_name)
	$TimedMessage.show_message(msg)

func add_new_work():
	var wk = ["새워크", ["총시간",60*30], ["운동", 60*3], ["휴식", 60*1] ]
	work_data.add_new_work( work_data.Work.new(wk) )
	work_data2work_data_menu()
	$TimedMessage.show_message("새워크를추가합니다.")

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
