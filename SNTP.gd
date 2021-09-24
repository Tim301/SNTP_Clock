extends Node2D

var NTP_SERVER = "0.nettime.pool.ntp.org" 
var senderUDP = PacketPeerUDP.new() # UDP sender
var receiverPort: int # UDP sender port. Needed for listening NTP server answer.

func _ready():
	init()
	#synchronize() # Use button signal to call synchronize() instead.

# Send UDP message to himself (receiverUDP) to get UDP sender port (senderUDP)
func init():
	senderUDP.set_dest_address("127.0.0.1", 5000) # Setting  UDP Request to localhost, port 5000
	var receiverUDP = PacketPeerUDP.new() #  UDP Listener
	if (receiverUDP.listen(5000) != OK): 	# Listening at port 5000
		print("Error listening on port: " , 5000) 
	else:
		print("Listening on port: " , 5000)
	var stg = "hi server!"
	var pac = stg.to_ascii() 
	senderUDP.put_packet(pac) # Send UDP packet with "hi server!" message.
	receiverUDP.wait() # Waiting until receive something.
	var array_bytes = receiverUDP.get_packet() # Extract received message.
	if array_bytes.get_string_from_ascii() == "hi server!" : # Check if same message. Just in case.
		receiverPort = receiverUDP.get_packet_port()  # Get port used by senderUDP while sending message.
		print("UDP packet send from port:", receiverPort) 
		receiverUDP.close()

# Send NTP Request and get time form answer. Call by a signal button
# Same working as init() but used for NTP
func synchronize():
	senderUDP.set_dest_address(NTP_SERVER, 123) #Setting NTP Request to NTP server, port 123
	var receiverUDP = PacketPeerUDP.new() #UDP Listener
	if (receiverUDP.listen(receiverPort) != OK): # Listening at port used by senderUDP. The NTP server answer on the same port of the request.
		printt("Error listening on port: " + str(receiverPort))
	else:
		printt("Listening on port: " + str(receiverPort))
	var data = ""
	var pac = data.to_ascii()
	#var numb = 4294967293
	var numb = OS.get_unix_time() + 2208988800# ToDo: Convert unix time (32 bit) to NTP (64 bit), add epoch offset.
	var ms = OS.get_system_time_msecs()
	var msstr = String(ms)
	print(ms)
	var us = int(msstr.substr(len(msstr)-3,len(msstr)-1) + "000")
	us = (us<<32)/1000000
	print((us<<32)/1000000)
	print("left: ",( numb >> 24) & 0xff)
	print("left: ",( numb >> 16) & 0xff)
	print("left: ",( numb >> 8) & 0xff)
	print("left: ",( numb >> 0) & 0xff)
	var test = var2bytes(numb)
	print(Array(var2bytes(numb,true)))
	#print(timestamp.to_ascii)
	# https://stackoverflow.com/questions/29112071/how-to-convert-ntp-time-to-unix-epoch-time-in-c-language-linux
	pac.append_array([27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,(( numb >> 24) & 0xff),(( numb >> 16) & 0xff),(( numb >> 8) & 0xff),(( numb >> 0) & 0xff),(( us >> 24) & 0xff),(( us >> 16) & 0xff),(( us >> 8) & 0xff),(( us >> 0) & 0xff)]) # Create  NTP packet. ToDO: Inclucde timestamp on 8 lastest bytes
	senderUDP.put_packet(pac) # Send NTP packet
	#receiverUDP.wait() # Wait NTP  server response
	# ---->>> Infinite waiting because wait() is blocking. <<<----
	# ---->>> Why there is no incomming packet even though I can see the anwser on Wireshark???. <<<----
	var array_bytes = receiverUDP.get_packet() # Get NTP data from packet
	print(array_bytes.get_string_from_ascii()) # Print Answer. To Do: Extract NTP (64 bit) and convert to unix time (32 bit)
	print("Received NTP message")
