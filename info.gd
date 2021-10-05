extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	text = "Delay: " + str(SNTP.delay) + ", Offset:  " +  str(SNTP.offset) + "\nTime zone: " + SNTP.tz_name + ", " + str(SNTP.tz_bias/3600) +"h"
