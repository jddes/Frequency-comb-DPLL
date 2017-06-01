
import struct
import socket

class TCP_client:
	
	# from http://stupidpythonideas.blogspot.ca/2013/05/sockets-are-byte-streams-not-message.html
	def recvall(self, count):
	    buf = b''
	    
	    while count:
	        newbuf = self.sock.recv(count)
	        if not newbuf: return None
	        buf += newbuf
	        count -= len(newbuf)
	        
	    return buf


	def OpenTCPConnection(self, HOST, PORT):
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.sock.setblocking(1)
		self.sock.connect(('192.168.2.8', 5000))

	def send_packet()