extends Label

func _process(delta):
	var datetime = OS.get_datetime()
	var unix_time = float(OS.get_system_time_msecs()/1000.0)
	var ms = float(unix_time - int(unix_time))*1000
	text = "Local time: " +  str(datetime["hour"]) + " : " + str(datetime["minute"]) + " : " +  str(datetime["second"]+(ms/1000.0))
