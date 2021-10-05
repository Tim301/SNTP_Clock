extends Button

func _on_sync_time_pressed():
	SNTP.synchronize()
