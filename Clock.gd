extends Control

var Hour
var Minute
var Second
var music = AudioStreamPlayer.new()
var lasthour = float(OS.get_time().hour)
var lastsecond = float(OS.get_time().second)
var fps = ProjectSettings.get_setting("physics/common/physics_fps")
var ms = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Hour = get_node("Hour")
	Minute = get_node("Minute")
	Second = get_node("Second")
	add_child(music)
	#Ding(3)

func _physics_process(_delta):
	var timeDict = SNTP.datetime
	var hour = float(timeDict["hour"])
	var minutes = float(timeDict["minute"])
	var second = float(timeDict["second"])
	ms = SNTP.ms
	if hour > 11:
		hour -= 12
	Hour.rotation_degrees = float((360.0/12.0)*hour) + (float((360.0/60.0/12)*minutes) - 180.0)
	Minute.rotation_degrees = float((360/60)*minutes)
	Second.rotation_degrees = float((360/60)*(second)) + float((360/60.0/1000.0)*ms)
	
	if timeDict.hour != lasthour:
		lasthour = timeDict.hour
		if hour == 0:
			print(hour)
			Ding(12)
		else:
			print(hour)
			Ding(hour)
	
func Ding(n):
	var stream = load("res://Clock/Clock.wav")
	music.set_stream(stream)
	music.volume_db = 1
	music.pitch_scale = 1
	for i in n-1:
		music.play()
		yield(get_tree().create_timer(2.90), "timeout")
	music.stop()
	stream = load("res://Clock/Clock_End.wav")
	music.set_stream(stream)
	music.play()
	yield(get_tree().create_timer(2.90), "timeout")
