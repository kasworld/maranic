extends PanelContainer

class_name TimeRecorder

signal started(n:int) # emit when 1st start
signal overrun(v :float) # emit when count down over 0 with overrun value(<0)

var initial_sec :float
var start_tick :float
var sum_tick :float
var is_paused :bool
var is_inuse :bool
var index :int
var is_downward :bool # count down timer

var formater :Callable = default_formater
func default_formater(v:float)->String:
	return "%02.02f" % v

func init(idx :int, fsize :int, fmt :Callable=default_formater)->void:
	index = idx
	formater = fmt
	theme.default_font_size = fsize

# set initial sec and count donw timer
func set_initial_sec(t :float)->void:
	initial_sec = t
	is_downward = true
	reset()

func reset() -> void:
	is_paused = true
	is_inuse = false
	sum_tick = 0

func start1st()->void:
	is_inuse = true
	started.emit(index)
	resume()

func start()->void:
	if is_inuse:
		resume()
	else:
		start1st()

func pause()->void:
	is_paused = true
	sum_tick += get_last_dur()

func resume()->void:
	is_paused = false
	start_tick = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur :float
	if is_downward:
		dur = get_remain_sec()
		if dur < 0 :
			overrun.emit(dur)
	else:
		dur = get_progress_sec()
	$ButtonSec.text = formater.call(dur)

func get_last_dur()->float:
	return Time.get_unix_time_from_system() - start_tick

func get_progress_sec()->float:
	if is_inuse :
		var dur :float = sum_tick
		if not is_paused:
			dur += get_last_dur()
		return dur
	else:
		return 0.0

func get_remain_sec()->float:
	return initial_sec - get_progress_sec()

var button_down_tick :float
func _on_button_sec_button_down() -> void:
	button_down_tick = Time.get_unix_time_from_system()
	$Timer.start(1.0)

func _on_button_sec_button_up() -> void:
	$Timer.stop()
	# check long press
	if Time.get_unix_time_from_system() - button_down_tick > 1.0:
		reset()
	else:
		if not is_inuse:
			start1st()
		else:
			if is_paused:
				resume()
			else:
				pause()
	button_down_tick = 0

func _on_timer_timeout() -> void:
	reset()