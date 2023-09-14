extends Node2D

var work_scene = preload("res://work_container.tscn")

var voices = DisplayServer.tts_get_voices_for_language("ko")
func text2speech(s):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voices[0])

@onready var WorkListMenuButton = $VBoxContainer/TitleContainer/WorkListMenuButton
@onready var CmdMenuButton = $VBoxContainer/TitleContainer/CmdMenuButton

var work_list :WorkList
var work_nodes = []
var current_work_index = -1
var sub_work_index = 1

func update_time_labels()->void:
	for o in work_nodes:
		o.update_time_labels()

func reset_time()->void:
	for o in work_nodes:
		o.reset_time()

func disable_buttons(disable :bool)->void:
	WorkListMenuButton.disabled =disable
	for o in work_nodes:
		o.disable_buttons(disable)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkListMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	reset_work_list()
	work_list2work_list_menu()

func work_list2work_list_menu()->void:
	WorkListMenuButton.get_popup().clear()
	for i in work_list.works.size():
		WorkListMenuButton.get_popup().add_item(work_list.get_at(i).to_str(),i)
	clear_work_nodes()

func _on_timer_timeout() -> void:
	if work_nodes[0].dec_remain_sec() != true: # fail to dec
		$VBoxContainer/TitleContainer/StartButton.button_pressed = false
	elif work_nodes.size() > sub_work_index:
		if work_nodes[sub_work_index].dec_remain_sec() != true: # move to next sub work
			work_nodes[sub_work_index].reset_time()
			var oldWorkStr = work_nodes[sub_work_index].get_label_text()
			sub_work_index += 1
			if work_nodes.size() <= sub_work_index:
				sub_work_index = 1
			var newWorkStr = work_nodes[sub_work_index].get_label_text()
			text2speech("%s를 끝내고 %s를 시작합니다." %[oldWorkStr,newWorkStr])
			work_nodes[sub_work_index].grab_focus()
	update_time_labels()

func _on_work_list_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = WorkListMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	current_work_index = sel
	select_work(sel)

func select_work(work_index)->void:
	var sel_wd = work_list.get_at(work_index)
	text2speech("%s로 설정합니다." % sel_wd.get_title())
	clear_work_nodes()
	make_work_nodes(sel_wd)
	reset_time()
	update_time_labels()

func clear_work_nodes()->void:
	# clear
	for i in work_nodes.size():
		if i == 0:
			continue
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(work_nodes[i])
		work_nodes[i].queue_free()
	work_nodes = [
		$VBoxContainer/MainWorkContainer
	]

func make_work_nodes(wk :WorkList.Work)->void:
	for i in wk.sub_work_list.size()-1:
		var wn = work_scene.instantiate()
		wn.focus_mode = Control.FOCUS_ALL
		wn.add_sub_work.connect(_on_work_container_add_sub_work)
		wn.del_sub_work.connect(_on_work_container_del_sub_work)
		work_nodes.append(wn)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(wn)
	for i in work_nodes.size():
		var sw = wk.sub_work_list[i]
		work_nodes[i].set_sub_work(i,sw)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if work_nodes.size() == 0 :
		return
	var sel_wd = work_list.get_at(current_work_index)
	if button_pressed :
		if work_nodes[0].remainSec<=0:
			reset_time()
		$VBoxContainer/TitleContainer/StartButton.text = "멈추기"
		text2speech("%s를 시작합니다." % [ sel_wd.get_title() ])
		$Timer.start()
	else:
		$VBoxContainer/TitleContainer/StartButton.text = "시작하기"
		text2speech("%s를 멈춥니다." % [ sel_wd.get_title() ])
		$Timer.stop()
	disable_buttons(button_pressed)

func _on_cmd_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = CmdMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	match sel :
		0: # 워크목록읽어오기
			load_work_list()
		1: # 워크목록저장하기
			save_work_list()
		2: # 워크목록초기화하기
			reset_work_list()
		3: # 새워크추가하기
			add_new_work()
		4: # 현재워크삭제하기
			del_current_work()
		_: # unknown
			print_debug("unknown", sel)

func reset_work_list()->void:
	var new_wl = WorkList.new(work_rawdata)
	if new_wl.has_error():
#		print_debug(new_wl.errmsg)
		$TimedMessage.show_message(new_wl.errmsg)
		return
	work_list = new_wl
#	print_debug(work_list.to_data())
	work_list2work_list_menu()
	$TimedMessage.show_message("초기화합니다.")

func load_work_list()->void:
	var new_wl =  work_list.load_new(file_name)
	if new_wl.has_error():
		$TimedMessage.show_message(new_wl.errmsg)
		return
	work_list = new_wl
	work_list2work_list_menu()
	$TimedMessage.show_message("load %s" % [file_name])

func save_work_list()->void:
	var msg = work_list.save(file_name)
	$TimedMessage.show_message(msg)

func add_new_work()->void:
	var wk = [ ["새워크", 60*30], ["운동", 60*3], ["휴식", 60*1] ]
	var new_work = work_list.Work.new(wk)
	if new_work.has_error():
		$TimedMessage.show_message(new_work.errmsg)
		return
	var new_work_index = work_list.add_new_work( new_work )
	work_list2work_list_menu()
	$TimedMessage.show_message("새워크를추가합니다.")
	select_work( new_work_index )

func del_current_work()->void:
	var errmsg = work_list.del_at(current_work_index)
	if not errmsg.is_empty() :
		$TimedMessage.show_message(errmsg)
		return
	work_list2work_list_menu()

func _on_work_container_del_sub_work(index :int, sw :WorkList.SubWork)->void:
	pass

func _on_work_container_add_sub_work(index :int, sw :WorkList.SubWork)->void:
	pass


# raw data
var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/gd4timer_workdata.json"
var work_rawdata = [
	# 워크이름 총시간 sec, subwork1 sec, subwork2 sec, etc
	[ ["1일차",  60*30], ["걷기", 60*3  ], ["달리기", 60*1  ] ],
	[ ["3일차",  60*30], ["걷기", 60*3  ], ["달리기", 60*1.5] ],
	[ ["5일차",  60*30], ["걷기", 60*3  ], ["달리기", 60*2  ] ],
	[ ["7일차",  60*30], ["걷기", 60*2  ], ["달리기", 60*2  ] ],
	[ ["9일차",  60*30], ["걷기", 60*2  ], ["달리기", 60*3  ] ],
	[ ["11일차", 60*30], ["걷기", 60*1  ], ["달리기", 60*3  ] ],
	[ ["13일차", 60*30], ["걷기", 60*1  ], ["달리기", 60*4  ] ],
	[ ["15일차", 60*30], ["걷기", 60*2  ], ["달리기", 60*5  ] ],
	[ ["17일차", 60*30], ["걷기", 60*3  ], ["달리기", 60*7  ] ],
	[ ["19일차", 60*30], ["걷기", 60*4  ], ["달리기", 60*10 ] ],
	[ ["21일차", 60*30], ["걷기", 60*2  ], ["달리기", 60*13 ] ],
	[ ["23일차", 60*32], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ ["25일차", 60*30], ["걷기", 60*3  ], ["달리기", 60*5  ], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ ["27일차", 60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ ["29일차", 60*35], ["걷기", 60*2.5], ["달리기", 60*30 ], ["걷기", 60*2.5] ],
]


