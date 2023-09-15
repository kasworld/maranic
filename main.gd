extends Node2D

var work_scene = preload("res://subwork_node.tscn")

var voices = DisplayServer.tts_get_voices_for_language(OS.get_locale_language())
func text2speech(s :String):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voices[0])

@onready var WorkListMenuButton = $VBoxContainer/TitleContainer/WorkListMenuButton
@onready var CmdMenuButton = $VBoxContainer/TitleContainer/CmdMenuButton
@onready var StartButton = $VBoxContainer/TitleContainer/StartButton
@onready var FirstSubWorkNode = $VBoxContainer/FirstSubWorkNode
@onready var SubWorkNodesContainer = $VBoxContainer/ScrollContainer/SubWorkNodesContainer

var work_list :WorkList
var current_work_index = -1
var subwork_nodes = []
var subwork_index = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkListMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	reset_work_list()
	work_list2work_list_menu()
	FirstSubWorkNode.disable_buttons(true)
	FirstSubWorkNode.add_subwork.connect(_on_work_container_add_subwork)
	FirstSubWorkNode.del_subwork.connect(_on_work_container_del_subwork)

# work list ########################################################################################

func work_list2work_list_menu()->void:
	WorkListMenuButton.get_popup().clear()
	for i in work_list.works.size():
		WorkListMenuButton.get_popup().add_item(work_list.get_at(i).to_str(),i)
	clear_subwork_nodes()

func _on_work_list_menu_button_toggled(button_pressed: bool) -> void:
	if button_pressed: # list opened
		return
	var sel = WorkListMenuButton.get_popup().get_focused_item()
	if sel ==-1 :
		return
	current_work_index = sel
	select_work(sel)

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
	$TimedMessage.show_message(tr("목록을 초기화합니다."))

func load_work_list()->void:
	var new_wl =  work_list.load_new(file_name)
	if new_wl.has_error():
		$TimedMessage.show_message(new_wl.errmsg)
		return
	work_list = new_wl
	work_list2work_list_menu()
	$TimedMessage.show_message(tr("목록파일을 읽었습니다. %s") % [file_name] )

func save_work_list()->void:
	var msg = work_list.save(file_name)
	if msg.is_empty() :
		$TimedMessage.show_message("목록파일을 저장했습니다. %s" %[file_name] )
	else:
		$TimedMessage.show_message(msg)

func add_new_work()->void:
	var wk = [ ["새워크", 60*30], ["운동", 60*3], ["휴식", 60*1] ]
	var new_work = work_list.Work.new(wk)
	if new_work.has_error():
		$TimedMessage.show_message(new_work.errmsg)
		return
	current_work_index = work_list.add_new_work( new_work )
	work_list2work_list_menu()
	$TimedMessage.show_message(tr("목록에 새 워크를 추가합니다."))
	select_work( current_work_index )

func del_current_work()->void:
	var errmsg = work_list.del_at(current_work_index)
	if not errmsg.is_empty() :
		$TimedMessage.show_message(errmsg)
		return
	work_list2work_list_menu()

# subwork ##########################################################################################

func select_work(work_index :int)->void:
	var sel_wd = work_list.get_at(work_index)
	text2speech(tr("%s로 설정합니다.") % sel_wd.get_title())
	clear_subwork_nodes()
	make_subwork_nodes(sel_wd)
	reset_time()
	update_time_labels()

func clear_subwork_nodes()->void:
	# clear
	for i in subwork_nodes.size():
		if i == 0:
			continue
		SubWorkNodesContainer.remove_child(subwork_nodes[i])
		subwork_nodes[i].queue_free()
	subwork_nodes = [
		FirstSubWorkNode
	]
	FirstSubWorkNode.disable_buttons(true)
	FirstSubWorkNode.reset()

func make_subwork_nodes(wk :WorkList.Work)->void:
	FirstSubWorkNode.disable_buttons(false)
	for i in wk.subwork_list.size()-1:
		var wn = work_scene.instantiate()
		wn.focus_mode = Control.FOCUS_ALL
		wn.add_subwork.connect(_on_work_container_add_subwork)
		wn.del_subwork.connect(_on_work_container_del_subwork)
		subwork_nodes.append(wn)
		SubWorkNodesContainer.add_child(wn)
	for i in subwork_nodes.size():
		var sw = wk.subwork_list[i]
		subwork_nodes[i].set_subwork(i,sw)

func _on_work_container_del_subwork(index :int, sw :WorkList.SubWork)->void:
	var wk = work_list.get_at(current_work_index)
	if wk.size() <= 1:
		$TimedMessage.show_message(tr("빈 워크가 되어 지울 수 없습니다."))
		return
	wk.del_at(index)
	work_list2work_list_menu()
	select_work(current_work_index)

func _on_work_container_add_subwork(index :int, sw :WorkList.SubWork)->void:
	var wk = work_list.get_at(current_work_index)
	wk.add_new_subwork( WorkList.SubWork.new(["운동", 60*3]) )
	work_list2work_list_menu()
	select_work(current_work_index)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if subwork_nodes.size() == 0 :
		return
	var sel_wd = work_list.get_at(current_work_index)
	if button_pressed :
		if subwork_nodes[0].remainSec<=0:
			reset_time()
		StartButton.text = tr("멈추기")
		text2speech(tr("%s를 시작합니다.") % [ sel_wd.get_title() ])
		$Timer.start()
	else:
		StartButton.text = tr("시작하기")
		text2speech(tr("%s를 멈춥니다.") % [ sel_wd.get_title() ])
		$Timer.stop()
	disable_buttons(button_pressed)

func _on_timer_timeout() -> void:
	if subwork_nodes[0].dec_remain_sec() != true: # fail to dec
		StartButton.button_pressed = false
	elif subwork_nodes.size() > subwork_index:
		if subwork_nodes[subwork_index].dec_remain_sec() != true: # move to next sub work
			subwork_nodes[subwork_index].reset_time()
			var oldWorkStr = subwork_nodes[subwork_index].get_label_text()
			subwork_index += 1
			if subwork_nodes.size() <= subwork_index:
				subwork_index = 1
			var newWorkStr = subwork_nodes[subwork_index].get_label_text()
			text2speech(tr("%s를 끝내고 %s를 시작합니다.") %[oldWorkStr,newWorkStr])
			subwork_nodes[subwork_index].grab_focus()
	update_time_labels()

func update_time_labels()->void:
	for o in subwork_nodes:
		o.update_time_labels()

func reset_time()->void:
	for o in subwork_nodes:
		o.reset_time()

func disable_buttons(disable :bool)->void:
	WorkListMenuButton.disabled =disable
	for o in subwork_nodes:
		o.disable_buttons(disable)

# raw data #########################################################################################

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


