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

func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func program2text(i):
	var data = workData.workList[i].duplicate()
	var rtn = "%s:" % [ data.pop_front() ]
	for j in range(len(data)):
		rtn += "%s(%s)" % [ data[j][0], second2text(data[j][1]) ]
	return rtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorkDataMenuButton.get_popup().theme = preload("res://menulist_theme.tres")
	CmdMenuButton.get_popup().theme = preload("res://menulist_theme.tres")

	resetWorkdData()
	workData2menu()

func workData2menu():
	for i in range(len( workData.workList)):
		WorkDataMenuButton.get_popup().add_item(program2text(i),i)

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

	var selData = workData.workList[sel].duplicate()
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
			loadWorkData()
		1: # 저장하기
			saveWorkData()
		2: # 초기화하기
			resetWorkdData()
		3: # 새작업추가하기
			pass
		_: # known
			print_debug("known", sel)

func resetWorkdData():
	workData = WorkData.new()
	showMessage("초기화합니다.")

func loadWorkData():
	var msg =  workData.Load()
	showMessage(msg)

func saveWorkData():
	var msg = workData.Save()
	showMessage(msg)

func showMessage(msg):
	$MessageLabel.text = msg
	$MessageLabel.visible = true
	$MessageTimer.start(3.0)

func _on_message_timer_timeout() -> void:
	$MessageLabel.visible = false
