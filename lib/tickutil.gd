extends Object
class_name TickLib

static func tick2dict(tick:float)->Dictionary:
	var ms = clampi( (tick - int(tick))*100, 0,99)
	var sec = tick as int % 60
	var min = tick as int / 60
	var hour = min / 60
	min -= hour * 60
	return {
		hour = hour,
		min = min,
		sec = sec,
		ms = ms,
	}

static func tickdict2str(td :Dictionary)->String:
	if td.hour == 0:
		return "%02d:%02d.%02d" % [td.min, td.sec, td.ms]
	return "%d:%02d:%02d.%02d" % [td.hour, td.min, td.sec, td.ms]

static func tick2str(tick :float)->String:
	return TickLib.tickdict2str(TickLib.tick2dict(tick))

static func tickdict2stri(td :Dictionary)->String:
	if td.hour == 0:
		return "%02d:%02d" % [td.min, td.sec]
	return "%d:%02d:%02d" % [td.hour, td.min, td.sec]

static func tick2stri(tick :float)->String:
	return TickLib.tickdict2stri(TickLib.tick2dict(tick))

