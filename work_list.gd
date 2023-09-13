class_name WorkList

extends Object

class SubWork:
	var errmsg :String
	func has_error()->bool:
		return not errmsg.is_empty()
	var name :String
	var second :int
	func _init(rawdata) -> void:
		if rawdata.size() != 2 :
			errmsg = "invalid subwork %s" % [rawdata]
			return
		name = rawdata[0]
		second = rawdata[1]
	func to_data():
		return [name,second]
	func second2text()->String:
		return "%02d:%02d" %[ second/60,second % 60]
	func to_str()->String:
		return "%s(%s)" % [ name, second2text() ]

class Work:
	var errmsg :String
	func has_error()->bool:
		return not errmsg.is_empty()
	var title :String
	var sub_work_list :Array[SubWork]
	func _init(rawdata)->void:
		rawdata = rawdata.duplicate()
		title = rawdata.pop_front()
		for sw in rawdata:
			var s = SubWork.new(sw)
			if s.has_error():
				errmsg = s.errmsg
				return
			sub_work_list.append( s )
	func to_data():
		var swl = [title]
		for d in sub_work_list:
			swl.append(d.to_data())
		return swl
	func to_str():
		var rtn = "%s:" % [ title ]
		for j in sub_work_list:
			rtn += j.to_str()
		return rtn

var errmsg :String
func has_error()->bool:
	return not errmsg.is_empty()
var works :Array[Work]
func _init(rawdata)->void:
	for rd in rawdata:
		var w = Work.new(rd)
		if w.has_error():
			errmsg = w.errmsg
			return
		works.append(w)

func to_data()->Array:
	var rtn = []
	for d in works:
		rtn.append(d.to_data())
	return rtn

# return added work index
func add_new_work(wk :Work):
	works.append(wk)
	return works.size()-1

func del_at(pos):
	works.remove_at(pos)

func get_at(pos)->Work:
	return works[pos]

func size()->int:
	return works.size()

func file_exist(file_name :String)->bool:
	return FileAccess.file_exists(file_name)

func save(file_name :String)-> String:
	var fileobj = FileAccess.open(file_name, FileAccess.WRITE)
	var work_list = to_data()
	var json_string = JSON.stringify(work_list)
	fileobj.store_line(json_string)
	return "save %s" % [file_name]

func load_new(file_name :String)->WorkList:
	var fileobj = FileAccess.open(file_name, FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		return WorkList.new(data_received)
	else:
		var neww = WorkList.new([])
		neww.errmsg = "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]
		return neww


