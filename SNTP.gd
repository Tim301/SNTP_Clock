extends Node2D
#const NTP_HOST = "0.nettime.pool.ntp.org"
const NTP_HOST = "193.190.198.10"
const NTP_PORT = 123
var o_peer_udp: PacketPeerUDP = PacketPeerUDP.new()

func _ready():
	pass

func synchronize():
	
	var send_packet = PoolByteArray()
	send_packet.append_array([0x1B])
	print("   send: ", OS.get_system_time_secs())
	var ntp_s = OS.get_system_time_secs() + 2208988800	# Convert unix time to NTP time, add epoch offset.
	var ntp_us = (int(OS.get_system_time_msecs() - stepify(OS.get_system_time_msecs(), 1000))<<32)/1000  # ntp_us = (unix_us<<32)/1000000
	#print("ms: ",OS.get_system_time_msecs())
	for n in range(39):
		send_packet.append_array([0x00])
	send_packet.append_array([(( ntp_s >> 24) & 0xff),(( ntp_s >> 16) & 0xff),(( ntp_s >> 8) & 0xff),(( ntp_s >> 0) & 0xff),(( ntp_us >> 24) & 0xff),(( ntp_us >> 16) & 0xff),(( ntp_us >> 8) & 0xff),(( ntp_us >> 0) & 0xff)])	
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
		var t4 = float(recv_packet[40] << 24) + (recv_packet[41] << 16) + (recv_packet[42] << 8) + (recv_packet[43] << 0) - 2208988800
		var tu = (recv_packet[44] << 24) + (recv_packet[45] << 16) + (recv_packet[46] << 8) + (recv_packet[47] << 0)
		var tu2 = float(((recv_packet[44] << 24) + (recv_packet[45] << 16) + (recv_packet[46] << 8) + (recv_packet[47] << 0))*1000 >> 32)/1000
		print(float(tu*1000>>32)/1000)
		print(t4+(float(tu*1000>>32)/1000))
		print("Receive: ", t4)
		
