class_name WorkData

extends Object

class SubWork:
	var name :String
	var second :int
	func from_data(rawdata):
		name = rawdata[0]
		second = rawdata[1]
		return self
	func to_data():
		return [name,second]
	func second2text()->String:
		return "%02d:%02d" %[ second/60,second % 60]
	func to_str()->String:
		return "%s(%s)" % [ name, second2text() ]

class Work:
	var title :String
	var sub_work_list :Array[SubWork]
	func from_data(rawdata):
		rawdata = rawdata.duplicate()
		title = rawdata.pop_front()
		for sw in rawdata:
			sub_work_list.append( SubWork.new().from_data(sw) )
		return self
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

var works :Array[Work]
func from_data(rawdata)->WorkData:
	for rd in rawdata:
		works.append(Work.new().from_data(rd))
	return self
func to_data()->Array:
	var rtn = []
	for d in works:
		rtn.append(d.to_data())
	return rtn

func add_new_work(wk :Work):
	works.append(wk)

func del_at(pos):
	works.remove_at(pos)

func get_at(pos)->Work:
	return works[pos]

func len()->int:
	return works.size()

func file_exist(file_name :String)->bool:
	return FileAccess.file_exists(file_name)

func save(file_name :String)-> String:
	var fileobj = FileAccess.open(file_name, FileAccess.WRITE)
	var work_list = to_data()
	var json_string = JSON.stringify(work_list)
	fileobj.store_line(json_string)
	return "%s save" % [file_name]

func load(file_name :String)->String:
	var fileobj = FileAccess.open(file_name, FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			from_data(data_received)
			return "%s loaded" % [file_name]
		else:
			return "Unexpected data %s" % [ error ]
	else:
		return "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]


