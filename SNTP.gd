extends Node2D
const NTP_HOST = "0.nettime.pool.ntp.org"
const NTP_PORT = 123
var o_peer_udp: PacketPeerUDP = PacketPeerUDP.new()

func _ready():
	pass

func synchronize():
	
	var send_packet = PoolByteArray()
	send_packet.append_array([0x1B])
	var s = OS.get_unix_time() + 2208988800	# Convert unix time (32 bit) to NTP (64 bit), add epoch offset.
	print("unix: ", OS.get_unix_time())
	print("sys: ",OS.get_system_time_secs())
	print("sys ms : ",OS.get_system_time_msecs())
	var ms = OS.get_system_time_msecs()
	print((float(ms/1000.0) - int(ms/1000)))
	var Ms = int(round((float(ms/1000.0) - int(ms/1000))*1000.0))
	print("MS2: ", Ms)
	var msstr = String(ms)
	print(ms)
	var us = int(msstr.substr(len(msstr)-3,len(msstr)-1) + "000")
	us = (us<<32)/1000000
	for n in range(39):
		send_packet.append_array([0x00])
	send_packet.append_array([(( s >> 24) & 0xff),(( s >> 16) & 0xff),(( s >> 8) & 0xff),(( s >> 0) & 0xff),(( us >> 24) & 0xff),(( us >> 16) & 0xff),(( us >> 8) & 0xff),(( us >> 0) & 0xff)])	
	o_peer_udp.set_dest_address(NTP_HOST, NTP_PORT)
	o_peer_udp.put_packet(send_packet)

func _process(delta):
	var recv_packet = o_peer_udp.get_packet()
	if recv_packet.size() > 0:
#		for m in range(12):
#			print(
#				"%02X %02X %02X %02X" % [
#					recv_packet[(4 * m) + 0],
#					recv_packet[(4 * m) + 1],
#					recv_packet[(4 * m) + 2],
#					recv_packet[(4 * m) + 3]
#					]
#				)
		print("leng: ", recv_packet.size())
