extends Node2D

var work_scene = preload("res://subwork_node.tscn")

var voices = DisplayServer.tts_get_voices_for_language(OS.get_locale_language())
func text2speech(s :String):
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(s, voices[0])

@onready var WorkListMenuButton = $VBoxContainer/TitleContainer/WorkListMenuButton
@onready var CmdMenuButton = $VBoxContainer/TitleContainer/CmdMenuButton
@onready var StartButton = $VBoxContainer/TitleContainer/StartButton
@onready var MasterWorkNode = $VBoxContainer/MasterWorkNode
@onready var SubWorkNodesContainer = $VBoxContainer/ScrollContainer/SubWorkNodesContainer

var work_list :WorkList
var work_index = -1 # inxex to worklist

var subwork_index :int = 1 # index to SubWorkNodesContainer +1
var is_running :bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vp_rect = get_viewport_rect()
	var msgrect = Rect2( vp_rect.size.x * 0.1 ,vp_rect.size.y * 0.3 , vp_rect.size.x * 0.8 , vp_rect.size.y * 0.3 )
	$TimedMessage.init(100, msgrect, tr("인터벌 타이머 9.3.0"))
	WorkListMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	WorkListMenuButton.get_popup().index_pressed.connect(_on_work_list_menu_index_pressed)
	CmdMenuButton.get_popup().index_pressed.connect(_on_cmd_menu_index_pressed)
	reset_work_list()
	work_list2work_list_menu()
	MasterWorkNode.init()
	MasterWorkNode.disable_buttons(true)
	subwork_connect(MasterWorkNode)

# subwork ##########################################################################################
func subwork_connect(wn :SubWorkNode)->void:
	wn.add_subwork.connect(_on_work_container_add_subwork)
	wn.del_subwork.connect(_on_work_container_del_subwork)
	wn.time_reached.connect(_on_work_time_reached)

func reset_time_all()->void:
	MasterWorkNode.reset_time()
	for o in SubWorkNodesContainer.get_children():
		o.reset_time()

func pause_all()->void:
	MasterWorkNode.pause()
	for o in SubWorkNodesContainer.get_children():
		o.pause()

func disable_buttons(b :bool)->void:
	WorkListMenuButton.disabled = b
	MasterWorkNode.disable_buttons(b)
	for o in SubWorkNodesContainer.get_children():
		o.disable_buttons(b)

func clear_subwork_node_list()->void:
	# clear
	for o in SubWorkNodesContainer.get_children():
		SubWorkNodesContainer.remove_child(o)
	MasterWorkNode.disable_buttons(true)
	MasterWorkNode.clear()
	CmdMenuButton.get_popup().set_item_disabled(4,true)
	StartButton.disabled = true

func make_subwork_node_list(wk :WorkList.Work)->void:
	MasterWorkNode.disable_buttons(false)
	for i in wk.subwork_list.size()-1:
		var wn = work_scene.instantiate()
		wn.focus_mode = Control.FOCUS_ALL
		subwork_connect(wn)
		SubWorkNodesContainer.add_child(wn)
	MasterWorkNode.set_subwork(0,wk.subwork_list[0])
	for i in SubWorkNodesContainer.get_child_count():
		var sw = wk.subwork_list[i+1]
		SubWorkNodesContainer.get_child(i).init()
		SubWorkNodesContainer.get_child(i).set_subwork(i+1,sw)
	if SubWorkNodesContainer.get_child_count() == 0 :
		MasterWorkNode.disable_menu(1,true)

# v : overrun value (<=0)
func _on_work_time_reached(idx :int, v :float)->void:
	if idx == 0: # masterwork
		StartButton.button_pressed = false
		pause_master()
	else:
		subwork_index = idx
		var old_sn = SubWorkNodesContainer.get_child(subwork_index-1)
		old_sn.reset_time()
		subwork_index += 1
		if SubWorkNodesContainer.get_child_count() <= subwork_index-1:
			subwork_index = 1
		if is_running:
			var new_sn = SubWorkNodesContainer.get_child(subwork_index-1)
			new_sn.start(-v)
			text2speech(tr("%s를 끝내고 %s를 시작합니다.") %[old_sn.get_label_text(),new_sn.get_label_text()])
			new_sn.grab_focus()

# start and resume
func start_master()->void:
	if not is_running:
		is_running = true
		MasterWorkNode.start()
		SubWorkNodesContainer.get_child(subwork_index-1).start()
		var sel_wd = work_list.get_at(work_index)
		StartButton.text = tr("멈추기")
		text2speech(tr("%s를 시작합니다.") % [ sel_wd.get_title() ])

# stop and pause
func pause_master()->void:
	if is_running:
		is_running = false
		pause_all()
		var sel_wd = work_list.get_at(work_index)
		StartButton.text = tr("시작하기")
		text2speech(tr("%s를 멈춥니다.") % [ sel_wd.get_title() ])

func _on_work_container_del_subwork(index :int, sw :WorkList.SubWork)->void:
	var wk = work_list.get_at(work_index)
	if wk.size() <= 1:
		$TimedMessage.show_message(tr("빈 워크가 되어 지울 수 없습니다."))
		return
	wk.del_at(index)
	work_list2work_list_menu()
	select_work(work_index)

func _on_work_container_add_subwork(index :int, sw :WorkList.SubWork)->void:
	var wk = work_list.get_at(work_index)
	wk.add_new_subwork( WorkList.SubWork.new(["운동", 60*3]) )
	work_list2work_list_menu()
	select_work(work_index)
	MasterWorkNode.disable_menu(1,false)

func _on_start_button_toggled(button_pressed: bool) -> void:
	if button_pressed : # start current work
		start_master()
	else:
		pause_master()

# work list ########################################################################################

func select_work(wi :int)->void:
	var sel_wd = work_list.get_at(wi)
	text2speech(tr("%s로 설정합니다.") % sel_wd.get_title())
	clear_subwork_node_list()
	make_subwork_node_list(sel_wd)
	reset_time_all()
	CmdMenuButton.get_popup().set_item_disabled(4,false)
	StartButton.disabled = false

func work_list2work_list_menu()->void:
	WorkListMenuButton.get_popup().clear()
	for i in work_list.works.size():
		WorkListMenuButton.get_popup().add_item(work_list.get_at(i).to_str(),i)
	clear_subwork_node_list()

func _on_work_list_menu_index_pressed(sel :int)->void:
	work_index = sel
	select_work(sel)

func _on_cmd_menu_index_pressed(sel :int)->void:
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
		$TimedMessage.show_message(tr("목록파일을 저장했습니다. %s") %[file_name] )
	else:
		$TimedMessage.show_message(msg)

func add_new_work()->void:
	var wk = [ ["새워크", 60*30], ["운동", 60*3], ["휴식", 60*1] ]
	var new_work = work_list.Work.new(wk)
	if new_work.has_error():
		$TimedMessage.show_message(new_work.errmsg)
		return
	work_index = work_list.add_new_work( new_work )
	work_list2work_list_menu()
	$TimedMessage.show_message(tr("목록에 새 워크를 추가합니다."))
	select_work( work_index )

func del_current_work()->void:
	var errmsg = work_list.del_at(work_index)
	if not errmsg.is_empty() :
		$TimedMessage.show_message(errmsg)
		return
	work_list2work_list_menu()

# work raw data #########################################################################################

var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/gd4timer_workdata.json"
var work_rawdata = [
	# 워크이름 총시간 sec, subwork1 sec, subwork2 sec, etc
	[ ["test",  60*1], ["걷기", 20*1  ], ["달리기", 20*1  ] ],
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
