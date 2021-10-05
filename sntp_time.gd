extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if SNTP.offset != 0.0:
		var datetime = SNTP.datetime
		var ms = int(SNTP.ms)
		text = "SNTP time: " + str(datetime["hour"]) + " : " + str(datetime["minute"]) + " : " +  str(datetime["second"]+ (ms/1000.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
