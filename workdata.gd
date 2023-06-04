class_name WorkData

extends Object

var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/workdata.json"

var workData = [
	# 이름,총시간초,걷기초,달리기초 
	[ "테스트", ["총시간",60*1 ], ["걷기", 10*1  ], ["달리기", 10*1  ], ["걷기", 10*1  ], ["달리기", 10*1 ] ],
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
	[ "23일차", ["총시간",60*30], ["걷기", 60*2  ], ["달리기", 60*13 ], ["걷기", 60*2  ], ["달리기", 60*15 ] ],
	[ "25일차", ["총시간",60*30], ["걷기", 60*3  ], ["달리기", 60*5  ], ["걷기", 60*2  ], ["달리기", 60*20 ] ],
	[ "27일차", ["총시간",60*30], ["걷기", 60*2.5], ["달리기", 60*25 ], ["걷기", 60*2.5] ],
	[ "29일차", ["달리기",60*30] ],
]

func FileExist():
	return FileAccess.file_exists(file_name)

func Save()-> String:
	var fileobj = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(workData)
	fileobj.store_line(json_string)
	return "%s save" % [file_name]
	
func Load()->String:
	var fileobj = FileAccess.open(file_name, FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			workData = data_received
			return "%s loaded" % [file_name]
		else:
			return "Unexpected data %s" % [ error ]
	else:
		return "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]
