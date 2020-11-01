import socket
import select
import time

# def send_str(s, strMessage):
#     s.send(strMessage.encode('ascii'))
#     print(strMessage.rstrip())

# # adapted from https://stackoverflow.com/questions/29023885/python-socket-readline-without-socket-makefile
# # this is probably super-inefficient, but we don't care since we are only reading very small text lines
# def read_line(s):
#     buf = list()
#     while True:
#         new_char = s.recv(1)
#         buf.append(new_char) # wow...
#         if new_char == b'\n':
#             break
#     buf = b"".join(buf) # convert from a list to bytes
#     print(buf.decode('ascii'))
#     return buf.decode('ascii').rstrip() # convert from bytes to a string

# # from https://stackoverflow.com/questions/1097974/how-to-empty-a-socket-in-python
# def empty_socket(sock):
#     """remove the data present on the socket"""
#     while 1:
#         inputready, o, e = select.select([sock],[],[], 0.0)
#         if len(inputready)==0: break
#         for s in inputready: s.recv(1)

# # from https://stackoverflow.com/questions/17667903/python-socket-receive-large-amount-of-data
# def recvall(sock, n):
#     # Helper function to recv n bytes or return None if EOF is hit
#     data = b''
#     while len(data) < n:
#         packet = sock.recv(n - len(data))
#         if not packet:
#             return None
#         data += packet
#     return data

# This class simply adds a few small convenience functions to a raw socket object
# None of these are optimized so they are probably horribly inefficient
# (which doesn't matter for the use case that the class was written in the first place)
class EasySocket(socket.socket):
    def __init__(self, *args, **kwargs):
        self.bVerbose = False
        super().__init__(*args, **kwargs)

    def send_str(self, strMessage):
        self.send(strMessage.encode('ascii'))
        if self.bVerbose:
            print(strMessage.rstrip())


    # adapted from https://stackoverflow.com/questions/29023885/python-socket-readline-without-socket-makefile
    # this is probably super-inefficient, but we don't care since we are only reading very small text lines
    def read_line(self):
        timeout = self.gettimeout()
        start_time = time.clock()
        buf = list()
        elapsed = 0
        while True and elapsed < timeout:
            new_char = self.recv(1)
            buf.append(new_char) # wow...
            if new_char == b'\n':
                break
            elapsed = time.clock() - start_time
        buf = b"".join(buf) # convert from a list to bytes
        if self.bVerbose:
            print(buf.decode('ascii').rstrip())
        return buf.decode('ascii').rstrip() # convert from bytes to a string

    # from https://stackoverflow.com/questions/1097974/how-to-empty-a-socket-in-python
    def empty_socket(self):
        """remove the data present on the socket"""
        while 1:
            inputready, o, e = select.select([self],[],[], 0.0)
            if len(inputready)==0: break
            for s in inputready: s.recv(1)

    # from https://stackoverflow.com/questions/17667903/python-socket-receive-large-amount-of-data
    def recvall(self, n):
        # Helper function to recv n bytes or return None if EOF is hit
        data = b''
        while len(data) < n:
            packet = self.recv(n - len(data))
            if not packet:
                return None
            data += packet
        return data