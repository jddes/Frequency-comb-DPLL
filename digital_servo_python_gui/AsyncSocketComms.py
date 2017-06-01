# -*- coding: utf-8 -*-
"""
Created on Tue Feb 18 13:03:46 2014

@author: jnd
"""

import socket
import select
import time

class AsyncSocketServer():
    
    def __init__(self, port_number=50000):
        self.port_number = port_number
        self.sock_conn = None
        self.sock_server = None
        self.read_buffer = ''
        
        self.bVerbose = False
        
        self.startListening()
        
    def startListening(self):
        # Initialization part: starts listening on the two ports
        print('Creating server socket...')
        HOST = ''       # means local host

        self.sock_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock_server.setblocking(0)
        self.sock_server.bind((HOST, self.port_number))
        self.sock_server.listen(5)

    def run(self):
        # First: check if there is any connection pending:
        # Check if there is a connection pending:
        # note the [0] at the end which selects only the first output of the select()
        if self.bVerbose:
            print('First')
        ready_to_read = select.select([self.sock_server], [], [], 0)[0]
        
        if ready_to_read:
            (sock_conn, addr) = self.sock_server.accept()
            sock_conn.setblocking(0)
            self.sock_conn = sock_conn
            self.conn_addr = addr
            if self.bVerbose:
                print('Accepted connection from %s' % str(addr))
        
        # Second: try to read from the socket:
        # We need a try/catch around these lines as the socket could have been closed in the meantime (or any number of possible errors):
        if self.bVerbose:
            print('Second')
        if self.sock_conn:
            try:
                (read_buffer, bSocketOpen) = self.readdata_async(self.sock_conn, self.read_buffer)
                self.read_buffer = read_buffer
                
                if not bSocketOpen:
                    # socket has been closed on the other side:
                    if self.bVerbose:
                        print('Socket closed detected.')
                    self.sock_conn = None
            except:
                # probably better to just close the socket if we get here:
                print('Read generated an exception')
#                self.sock_conn.close() # this can also throw an exception:
                self.sock_conn = None
#                raise
            
        # parse the receive buffer:
        delim='\n'
        line = None
        while self.read_buffer.find(delim) != -1:
            line, self.read_buffer = self.read_buffer.split('\n', 1)
        
        
        # if we have a valid line, this is what we output:
        return line
        
    def readdata_async(self, sock, read_buffer):
        if self.bVerbose:
            print('readdata_async: entering')
        recv_buffer=4096
        data = True
        while data:
            # Check if there is data:
            # note the [0] at the end which selects only the first output of the select()
            ready_to_read = select.select([sock], [], [], 0)[0]
                
            if ready_to_read:
                data = sock.recv(recv_buffer)
                
                if not data:
                    # This means that the other end has closed the socket:
                    if self.bVerbose:
                        print('socket close detected')
                        print('readdata_async: exiting')
                    return (read_buffer, False)
                    
                read_buffer += data
#                print('read buffer: %s' % read_buffer)
            else:
                break
            
        if self.bVerbose:
            print('readdata_async: exiting')
        return (read_buffer, True)

class AsyncSocketClient():
    
    def __init__(self, PORT=50000):
        HOST = 'localhost'    # means local host
        self.PORT = PORT
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((HOST, self.PORT))
        
    def send_text(self, txt_to_send):
        self.sock.sendall(txt_to_send)