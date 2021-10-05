extends Node2D
#const NTP_HOST = "0.nettime.pool.ntp.org"
const NTP_HOST = "193.190.198.10"
const NTP_PORT = 123
var o_peer_udp: PacketPeerUDP = PacketPeerUDP.new()
var delay = 0.0
var offset= 0.0
var datetime: Dictionary
var ms: float
var tz_bias: int
var tz_name: String
var last_sync


func _ready():
	datetime = OS.get_datetime()
	datetime["milis"] = float(OS.get_system_time_msecs()/1000.0)
	tz_bias = OS.get_time_zone_info()["bias"]*60
	tz_name = OS.get_time_zone_info()["name"]
	var timer = Timer.new()
	timer.set_autostart(true)
	timer.set_one_shot(false)
	timer.set_wait_time(15)
	timer.connect("timeout",self,"synchronize")
	add_child(timer) #to process
	timer.start() #to start

func synchronize():
	print("Start synchronisation")
	var send_packet = PoolByteArray()
	send_packet.append_array([0x1B])
	print("   send: ", OS.get_system_time_secs())
	var ntp_time = OS.get_system_time_secs() + 2208988800	# Convert unix time to NTP time, add epoch offset.
	var ntp_us = (int(OS.get_system_time_msecs() - stepify(OS.get_system_time_msecs(), 1000))<<32)/1000  # ntp_us = (unix_us<<32)/1000000
	for n in range(39):
		send_packet.append_array([0x00])
	send_packet.append_array([(( ntp_time >> 24) & 0xff),(( ntp_time >> 16) & 0xff),(( ntp_time >> 8) & 0xff),(( ntp_time >> 0) & 0xff)])
	send_packet.append_array([(( ntp_us >> 24) & 0xff),(( ntp_us >> 16) & 0xff),(( ntp_us >> 8) & 0xff),(( ntp_us >> 0) & 0xff)])
	o_peer_udp.set_dest_address(NTP_HOST, NTP_PORT)
	o_peer_udp.put_packet(send_packet)

func _process(delta):
	var recv_packet = o_peer_udp.get_packet()
	if recv_packet.size() > 0:
		var t1 =  packet2timefloat(recv_packet.subarray(24,31))
		var t2 = packet2timefloat(recv_packet.subarray(32,39))
		var t3 = packet2timefloat(recv_packet.subarray(40,47))
		var t4 = float(OS.get_system_time_msecs()/1000.0)
		delay = (t4-t1)-(t3-t2)
		offset = ((t2-t1)+(t3-t4))/2.0
#		print("t1: ", t1)
#		print("t2: ", t2)
#		print("t3: ", t3)
#		print("t4: ", t4)
#
#		print("t2: ", timeformat(t2))
#		print("t3: ", timeformat(t3))
#		print("t4: ", timeformat(t4))
#		print("offset: ", offset)
	var unix_time = float(OS.get_system_time_msecs()/1000.0) + offset + tz_bias
	datetime = OS.get_datetime_from_unix_time(unix_time)
	ms = float(unix_time - int(unix_time))*1000
	last_sync = datetime
#	print("time: ", unix_time )
#	print("ms: ", ms)
#	print("delay: ", delay)
#	print("offset: ", offset)

func timeformat(floattime: float) -> String:
	var timetoprint = OS.get_datetime_from_unix_time(floattime)
	var text = str(timetoprint["hour"]) + " : " + str(timetoprint["minute"]) + " : " +  str(timetoprint["second"]) + "." + str(ms)
	var mstoprint = float(floattime - int(floattime))*1000
	return text

func packet2timefloat(ntp_time: PoolByteArray) -> float:
	var time_s = float(ntp_time[0] << 24) + (ntp_time[1] << 16) + (ntp_time[2]<< 8) + (ntp_time[3] << 0) - 2208988800
	var time_us = float(((ntp_time[4] << 24) + (ntp_time[5] << 16) + (ntp_time[6] << 8) + (ntp_time[7] << 0))*1000000000 >> 32)/1000000000.0
	return  time_s + time_us
