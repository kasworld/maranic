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

	var wl = WorkData.WorkList.new().from_data(workData.work_list)
	print_debug(wl.to_data())

func work_data2work_data_menu():
	WorkDataMenuButton.get_popup().clear()
	for i in range(workData.len()):
		WorkDataMenuButton.get_popup().add_item(workData.work2text(i),i)

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

	var selData = workData.get_at(sel).duplicate()
	var title=selData.pop_front()
	WorkDataMenuButton.text = title
	Text2Speech("%s로 설정합니다." % title)
	makeWorks(len(selData))
	for i in range(len(selData)):
		Works[i].setLabelTotalSec( selData[i][0],selData[i][1])
	resetTime()
	updateTimeLabels()

func makeWorks(n ):
	for i in range(len(Works)):
		if i == 0:
			continue
		$VBoxContainer/ScrollContainer/WorksContainer.remove_child(Works[i])
		Works[i].queue_free()
	Works = [
		$VBoxContainer/MainWorkContainer
	]
	for i in range(n-1):
		var work = workScene.instantiate()
		work.focus_mode = Control.FOCUS_ALL
		Works.append(work)
		$VBoxContainer/ScrollContainer/WorksContainer.add_child(work)

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
	workData = WorkData.new()
	work_data2work_data_menu()
	show_message("초기화합니다.")

func load_work_data():
	var msg =  workData.load()
	work_data2work_data_menu()
	show_message(msg)

func save_work_data():
	var msg = workData.save()
	show_message(msg)

func add_new_work():
	workData.add_new_work("새워크",[ ["총시간",60*30], ["운동", 60*3], ["휴식", 60*1] ] )
	work_data2work_data_menu()
	show_message("새워크를추가합니다.")

func show_message(msg):
	$MessageLabel.text = msg
	$MessageLabel.visible = true
	$MessageTimer.start(3.0)

func _on_message_timer_timeout() -> void:
	$MessageLabel.visible = false
