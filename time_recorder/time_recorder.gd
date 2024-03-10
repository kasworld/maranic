extends Container

class_name TimeRecorder

signal started(n:int)

var initial_sec :float
var start_tick :float
var sum_tick :float
var is_paused :bool
var is_inuse :bool
var index :int

func init(swsize :Vector2, idx :int)->void:
	size = swsize
	custom_minimum_size = swsize
	index = idx
	$ButtonSec.theme.default_font_size = size.x/4.2

func set_initial_sec(t :float)->void:
	initial_sec = t
	reset()

func reset() -> void:
	is_paused = true
	is_inuse = false
	sum_tick = 0

func start1st()->void:
	is_inuse = true
	started.emit(index)
	resume()

func pause()->void:
	is_paused = true
	sum_tick += get_last_dur()

func resume()->void:
	is_paused = false
	start_tick = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur = get_remain_sec()
	$ButtonSec.text = TickLib.tick2str(dur)

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
		if is_paused:
			resume()
		else:
			pause()
	button_down_tick = 0

func _on_timer_timeout() -> void:
	reset()
