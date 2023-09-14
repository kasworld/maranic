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
	func to_data()->Array:
		return [name,second]
	func second2text(s :int)->String:
		return "%02d:%02d" %[ s/60,s % 60]
	func to_str()->String:
		return "%s(%s)" % [ name, second2text(second) ]

class Work:
	var errmsg :String
	func has_error()->bool:
		return not errmsg.is_empty()
	var subwork_list :Array[SubWork]
	func _init(rawdata :Array)->void:
		if rawdata.size() < 1 :
			errmsg = "no sub work"
			return
		for sw in rawdata:
			var s = SubWork.new(sw)
			if s.has_error():
				errmsg = s.errmsg
				return
			subwork_list.append( s )
	func get_title()->String:
		if subwork_list.size() < 1 :
			return "no sub work"
		return subwork_list[0].name
	func to_data()->Array:
		var swl = []
		for d in subwork_list:
			swl.append(d.to_data())
		return swl
	func to_str()->String:
		var rtn = ""
		for j in subwork_list:
			rtn += j.to_str()
		return rtn
	func del_at(i :int)->String:
		if i < 0 or i >= subwork_list.size():
			return "invalid index"
		subwork_list.remove_at(i)
		return ""
	func add_new_subwork(sw :SubWork)->int:
		subwork_list.append(sw)
		return subwork_list.size()-1
	func size()->int:
		return subwork_list.size()

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
func add_new_work(wk :Work)->int:
	works.append(wk)
	return works.size()-1

func del_at(pos)->String:
	if pos < 0 or pos >= works.size() :
		return "invalid index"
	works.remove_at(pos)
	return ""

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


