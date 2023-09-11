class_name WorkData

extends Object

class SubWork:
	var name :String
	var second :int

class Work:
	var title :String
	var sub_work_list :Array[SubWork]

var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/gd4timer_workdata.json"

var work_list = [
	# 이름,총시간초,work1 sec, work2 sec, etc
	[ "1일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1  ] ],
	[ "3일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*1.5] ],
	[ "5일차",  ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*2  ] ],
	[ "7일차",  ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*2  ] ],
	[ "9일차",  ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*3  ] ],
	[ "11일차", ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*3  ] ],
	[ "13일차", ["총시간",60*30], ["걷기", 60*1  ], ["달리기", 60*4  ] ],
	[ "15일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*5  ] ],
	[ "17일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*7  ] ],
	[ "19일차", ["총시간",60*30], ["걷기", 60*4  ], ["달리기", 60*10 ] ],
	[ "21일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ] ],
	[ "23일차", ["총시간",60*32], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ "25일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ "27일차", ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ "29일차", ["총시간",60*35], ["걷기", 60*2.5], ["달리기", 60*30 ], ["걷기", 60*2.5] ],
]


func second2text(sec :int):
	return "%02d:%02d" %[ sec/60,sec % 60]

func work2text(i):
	var data = work_list[i].duplicate()
	var rtn = "%s:" % [ data.pop_front() ]
	for j in range(len(data)):
		rtn += "%s(%s)" % [ data[j][0], second2text(data[j][1]) ]
	return rtn

func add_new_work(title, subWorkList):
	var adddata = [title]
	adddata.append_array(subWorkList)
	work_list.append(adddata)

func del_at(pos):
	work_list.remove_at(pos)

func get_at(pos):
	return work_list[pos]

func file_exist():
	return FileAccess.file_exists(file_name)

func len()->int:
	return len(work_list)

func save()-> String:
	var fileobj = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(work_list)
	fileobj.store_line(json_string)
	return "%s save" % [file_name]

func load()->String:
	var fileobj = FileAccess.open(file_name, FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			work_list = data_received
			return "%s loaded" % [file_name]
		else:
			return "Unexpected data %s" % [ error ]
	else:
		return "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]
