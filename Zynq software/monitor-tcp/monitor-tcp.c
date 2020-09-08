/**
 * $Id: $
 *
 * @brief Simple program that listens on a TCP port, then writes values to the FPGA memory based on the received data.
 * packet format is simply: MAGIC_BYTES WRITE_ADDRESS WRITE_VALUE, where magic_bytes = 0xABCD1234, write_address and write_value are 32-bits values
 *
 * @Author Red Pitaya
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include <netinet/in.h>
#include <sys/prctl.h>
#include <errno.h>
#include <arpa/inet.h>
#include <signal.h>
#include <unistd.h>
#include <syslog.h>

// for open
#include <fcntl.h>
// for memory-map
#include <sys/mman.h>
// for usleep
#include <unistd.h>
// for clock_gettime
#include <time.h>

// for multithreading
#include <pthread.h>

// for getpid() and kill()
#include <sys/types.h>
// for waitpid()
#include <sys/wait.h>

#define LISTEN_BACKLOG 50
#define LISTEN_PORT 5000
#define MAX_BUFF_SIZE 1024

static bool app_exit = false;
pid_t parent_pid;
bool bVerbose = false; // this allows enabling lots of debugging messages.

#include "packets.h"
#include "monitor-tcp.h"
#include "memory_interface.h"
#include "common.h"

int16_t  data_buffer[LOGGER_BUFFER_SIZE];
int32_t  data_buffer32[LOGGER_REPEAT_SIZE];


/////////////////////////////////// End of packet handler functions ///////////////////////////////////


/////////////////////////////////////////////////////
// Starting here is the code for the tcp server
/////////////////////////////////////////////////////

static void handleCloseChildEvents()
{
    struct sigaction sigchld_action = {
            .sa_handler = SIG_DFL,
            .sa_flags = SA_NOCLDWAIT
    };
    sigaction(SIGCHLD, &sigchld_action, NULL);
}

static void termSignalHandler(int signum)
{
	printf("Received terminate signal. Exiting...");
    app_exit = true;
    //syslog (LOG_NOTICE, "Received terminate signal. Exiting...");
}


static void installTermSignalHandler()
{
    struct sigaction action;
    memset(&action, 0, sizeof(struct sigaction));
    action.sa_handler = termSignalHandler;
    sigaction(SIGTERM, &action, NULL);
    sigaction(SIGINT, &action, NULL);
}

/**
 * This is main method of every child process. Here communication with client is handled.
 * @param connfd The communication port
 * @return
 */
static int handleConnection(int connfd) {
    int read_size;

    size_t message_len = MAX_BUFF_SIZE;
    char *message_buff = malloc(message_len);
    printf("allocated message_buf to size %u. address = 0x%x\n", (uint)message_len, (uint)message_buff);
    char buffer[MAX_BUFF_SIZE];
    size_t msg_end = 0;
    size_t bytes_consumed = 0;
    bool bHaveMagicBytes = false;


	// contains the packet "header"
	uint32_t message_magic_bytes = 0;

    installTermSignalHandler();

    prctl( 1, SIGTERM );

    initMemoryMap();
    printf("Memory map completed.\n");
    printf("Waiting for first client request.\n");

 //    //////////////////////////////////////////////////////////////////////////////////////////
 //    // Multithreading tests
	// pthread_t thread1;
	// const char *message1 = "Thread 1";
	// int  iret1;

	//  // Create independent threads each of which will execute function 
	// iret1 = pthread_create( &thread1, NULL, second_thread_function, (void*) message1);
	// if(iret1)
	// {
	// 	printf("Error - pthread_create() return code: %d\n",iret1);
	// }
	// //////////////////////////////////////////////////////////////////////////////////////////

 //    // run a FPGA<->PS throughput test:
	// // throughput_test();
	// // run a FPGA<->PS continuous fifo read throughput test:
	// continuous_fifo_read();

    size_t bytes_needed = sizeof(message_magic_bytes);	// to start, we only need 4 bytes before starting to parse out the message.

    // Variables used for handling "write file" messages
    bool bHaveFileWriteHeader = false;
    struct binary_packet_write_file_t * pPacketWriteFile;
    FILE * file_pointer = NULL;
    // Variables for the "shell command" message
    bool bHaveShellCommandHeader = false;
    struct binary_packet_shell_command_t * pPacketShellCommand;
    // Variables for the "reboot" message
    bool bReboot = false;

    

    //Receive a message from client
    while( (read_size = recv(connfd , buffer , MAX_BUFF_SIZE , 0)) > 0 )
    {
        // if (app_exit) {
        //     break;
        // }

        // First make sure that message buffer is large enough
        while (msg_end + read_size >= message_len) {
            message_len *= 2;
            if (msg_end+read_size > message_len)
            {
            	printfv("msg_end+read_size > message_len\n");
            	message_len = msg_end+read_size;
            }
            message_buff = realloc(message_buff, message_len);
            printfv("reallocated message_buf to size %u. new address = 0x%x\n", (uint)message_len, (uint)message_buff);
        }

        // Copy read buffer into message buffer
        memcpy(message_buff + msg_end, buffer, read_size);
        msg_end += read_size;

        while (msg_end >= bytes_needed)
        {
        	//printfv("msg_end=%u, bytes_needed=%u, bHaveMagicBytes=%u", msg_end, bytes_needed, bHaveMagicBytes);
        	if (!bHaveMagicBytes)
        	{
        		if (getMagicBytes(message_buff, msg_end, &message_magic_bytes))
        		{
			        bHaveMagicBytes = true;
			        printfv("message_magic_bytes = 0x%X\n", message_magic_bytes);
			    }
			}
	        if (bHaveMagicBytes)
	        {
	        	// we know which type of packet is coming in:
	        	// parse out the correct type of packet
	        	if (packet_handler_write_reg(message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd)) {
	        		bHaveMagicBytes = false;
	        			
	        	////////////////////////////////////////////////////////////
	        	// Read 32 bits value to specified FPGA register
	        	} else if (message_magic_bytes == magic_bytes_read_reg)
	        	{
	        		bytes_needed = sizeof(binary_packet_read_reg_t);
	        		if (msg_end >= bytes_needed)
	        		{
		        		struct binary_packet_read_reg_t * pPacketReadReg;
		        		pPacketReadReg = (binary_packet_read_reg_t*) message_buff;



		        		printfv("Received a register read packet.\n");
		        		printfv("pPacketReadReg->start_address = 0x%X (hex)\n", pPacketReadReg->start_address);
		        		printfv("pPacketReadReg->reserved = %u (decimal) (currently unused)\n", pPacketReadReg->reserved);

		        		// perform actual memory read, dump 32 bits value into TCP socket.
		        		uint32_t register_value;
		        		register_value = read_value(pPacketReadReg->start_address);

		        		// send it back:
		        		send(connfd, &register_value, sizeof(register_value), 0);
		        		printfv("register sent. addr = 0x%X, value = %u\n", pPacketReadReg->start_address, register_value);

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_read_reg_t);
		        		bHaveMagicBytes = false;
		        		bytes_needed = sizeof(message_magic_bytes);

		        	} else {
		        		printfv("Received a register read packet, but we have not received the full packet yet.\n");

		        	}
	        	////////////////////////////////////////////////////////////
	        	// Read a buffer of continuous value from an ADC input
	        	} else if (message_magic_bytes == magic_bytes_read_buffer) {

	        		bytes_needed = sizeof(binary_packet_read_buffer_t);
	        		if (msg_end >= bytes_needed) {
		        		
		        		struct binary_packet_read_buffer_t * pPacketReadBuffer;
		        		pPacketReadBuffer = (binary_packet_read_buffer_t*) message_buff;



		        		printfv("Received a buffer read packet.\n");
		        		printfv("pPacketReadBuffer->start_address = 0x%X (hex) (currently unused)\n", pPacketReadBuffer->start_address);
		        		printfv("pPacketReadBuffer->number_of_points = %u (decimal)\n", pPacketReadBuffer->number_of_points);

					    struct timespec time_start, time_end;
					    // clock_gettime(CLOCK_REALTIME, &time_start);

		        		// this should contain the actual data, note that the writing has surely wrapped and the start/end of the data run will be random in the dataset
		        		// TODO: sync with the end of the acquisition in the buffer.
		        		clock_gettime(CLOCK_REALTIME, &time_start);
		        		uint32_t acq_size = MIN(LOGGER_BUFFER_SIZE, pPacketReadBuffer->number_of_points);
		        		readBuffer(&acq_size, data_buffer);
					    clock_gettime(CLOCK_REALTIME, &time_end);
					    printfv("getdata elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));

		        		// dump this into the TCP socket:
		        		printfv("before socket send()\n");
		        		clock_gettime(CLOCK_REALTIME, &time_start);
		        		send(connfd, data_buffer, (size_t)acq_size*sizeof(int16_t), 0);
					    clock_gettime(CLOCK_REALTIME, &time_end);
					    printfv("send() elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));
		        		printfv("socket send() complete\n");


		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_read_buffer_t);
		        		bHaveMagicBytes = false;
		        		bytes_needed = sizeof(message_magic_bytes);
	        		} else {
	        			printfv("Received a buffer read packet, but we have not received the full packet yet.\n");

	        		}

	        	////////////////////////////////////////////////////////////
	        	// Read a buffer (intended to be used with registers_read.vhd)
	        	} else if (packet_handler_read_repeat(message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd))
	        	{
	        		bHaveMagicBytes = false;

	        	////////////////////////////////////////////////////////////
	        	// Read/Write a file to the filesystem
	        	} else if (message_magic_bytes == magic_bytes_write_file || message_magic_bytes == magic_bytes_read_file)
	        	{
	        		printfv("magic bytes are read/write file\n");
	        		// we need at least the first two 32 bits value before we can figure out the size of this message.
	        		if (!bHaveFileWriteHeader)
	        		{
	        			bytes_needed = sizeof(binary_packet_write_file_t);
	        			if (msg_end >= bytes_needed) {
	        				bHaveFileWriteHeader = true;
	        				printfv("Received complete file read/write header.\n");
			        		
			        		pPacketWriteFile = (binary_packet_write_file_t*) message_buff;
			        		printfv("address of message_buff = 0x%x, address of pPacketWriteFile = 0x%x\n", (uint) message_buff, (uint) pPacketWriteFile);
			        		printfv("pPacketWriteFile->filename_length = %u\n", pPacketWriteFile->filename_length);
			        		printfv("pPacketWriteFile->file_size       = %u\n", pPacketWriteFile->file_size);
			        		bytes_needed = sizeof(binary_packet_write_file_t) + pPacketWriteFile->filename_length + pPacketWriteFile->file_size;
			        		printfv("bytes_needed                    = %u\n", bytes_needed);


	        			}
	        		}
	        		if (bHaveFileWriteHeader) {
	        			// we know how long the total message needs to be, so we just wait to have received everything.
	        			if (msg_end >= bytes_needed)
	        			{
	        				printfv("Complete file read/write message received.\n");
	        				printfv("msg_end = %u, bytes_needed = %u\n", msg_end, bytes_needed);

							// first copy the filename to a string
							pPacketWriteFile = (binary_packet_write_file_t*) message_buff;	// we need to update our packet pointer because message_buf might have changed its location if it has been reallocated since last time pPacketWriteFile was set
							char * strNewFileName = (char*) malloc((pPacketWriteFile->filename_length+1)*sizeof(char));	// the +1 is for the \0 character
							if (!strNewFileName)
							{
								printfv("malloc failed to allocate a string of size: %u\n", pPacketWriteFile->filename_length+1);
							} else
							{
								printfv("address of strNewFileName = 0x%x, address of pPacketWriteFile = 0x%x\n", (uint) strNewFileName, (uint) pPacketWriteFile);
								printfv("malloc succeeded to allocate a string of size: %u\n", pPacketWriteFile->filename_length+1);
								printfv("pPacketWriteFile->filename_length = %u\n", pPacketWriteFile->filename_length);
								printfv("pPacketWriteFile->file_size       = %u\n", pPacketWriteFile->file_size);
								memcpy((void*) strNewFileName, (void*)(message_buff+sizeof(binary_packet_write_file_t)), pPacketWriteFile->filename_length);
								printfv("memcpy succeeded\n");
								// add \0 termination
								strNewFileName[pPacketWriteFile->filename_length] = '\0';

								printfv("filename: %s\n", strNewFileName);

								if (message_magic_bytes == magic_bytes_write_file)
								{
									// then we should call fopen with the filename, then fwrite with the right pointer.
									file_pointer = fopen(strNewFileName, "wb");
									if (!file_pointer)
									{
										printfv("Error opening file %s. No contents written.\n", strNewFileName);
									} else {
										// write file contents
										fwrite((void*)(message_buff+sizeof(binary_packet_write_file_t)+pPacketWriteFile->filename_length) , 1, pPacketWriteFile->file_size, file_pointer);
										fclose(file_pointer);
										file_pointer = NULL;
									}
								} else {
									// file read: send file size first
									// Format is: file_valid, file_size, <file bytes>
					        		uint32_t file_valid;
					        		uint32_t file_size;

					        		// send it back:
					        		

									file_pointer = fopen(strNewFileName, "rb");
									if (!file_pointer)
									{
										file_valid = 0; // -1 means that the file does not exist
										send(connfd, &file_valid, sizeof(file_valid), 0); // file valid?
										file_size = 0;
										send(connfd, &file_size, sizeof(file_size), 0); // file size
										printfv("Error opening file %s. No contents read.\n", strNewFileName);
									} else {
										file_valid = 1;
										send(connfd, &file_valid, sizeof(file_valid), 0); // file valid?
										fseek(file_pointer, 0, SEEK_END);
										file_size = ftell(file_pointer);
										rewind(file_pointer);

										uint8_t *file_contents = malloc(file_size);
										if (!file_contents)
										{
											// allocation error, send back an empty file:
											printfv("Error allocating memory for file %s. Will send back an empty file instead.\n", strNewFileName);
											file_size = 0;
											send(connfd, &file_size, sizeof(file_size), 0); // file size, clamped to 0
										} else {
											size_t retval = fread(file_contents, 1, file_size, file_pointer);
											if (retval != file_size)
												printfv("fread returned %u instead of %u\n", retval, file_size);
											printfv("Sending file %s, %u bytes.\n", strNewFileName, file_size);
											send(connfd, &file_size, sizeof(file_size), 0); // file size
											send(connfd, file_contents, file_size, 0);
										}
										// read and send file contents
										// fwrite((void*)(message_buff+sizeof(binary_packet_write_file_t)+pPacketWriteFile->filename_length) , 1, pPacketWriteFile->file_size, file_pointer);
										fclose(file_pointer);
										file_pointer = NULL;
									}
								}

		        				free(strNewFileName);

		        				//kill(parent_pid, SIGTERM);
		        				//kill(parent_pid, SIGTERM);

	        				}

			        		// reset our message parsing state variables
			        		bHaveFileWriteHeader = false;
			        		bytes_consumed = bytes_needed;
			        		bHaveMagicBytes = false;
			        		bytes_needed = sizeof(message_magic_bytes);
	        			}
	        		}



	        	}	// else if (message_magic_bytes == magic_bytes_write_file) 


	        	////////////////////////////////////////////////////////////
	        	// Send a command string to the shell
	        	else if (message_magic_bytes == magic_bytes_shell_command)
	        	{
	        		// we need at least the first two 32 bits values before we can figure out the size of this message.
	        		if (!bHaveShellCommandHeader)
	        		{
	        			bytes_needed = sizeof(binary_packet_shell_command_t);
	        			if (msg_end >= bytes_needed) {
	        				bHaveShellCommandHeader = true;
	        				printfv("Received complete shell command header.\n");
			        		
			        		pPacketShellCommand = (binary_packet_shell_command_t*) message_buff;

			        		printfv("pPacketShellCommand->command_length = %u\n", pPacketShellCommand->command_length);
			        		bytes_needed = sizeof(binary_packet_write_file_t) + pPacketShellCommand->command_length;
			        		printfv("bytes_needed                    = %u\n", bytes_needed);


	        			}
	        		}
	        		if (bHaveShellCommandHeader) {
	        			// we know how long the total message needs to be, so we just wait to have received everything.
	        			if (msg_end >= bytes_needed) {
	        				printfv("Complete shell command message received.\n");
	        				printfv("msg_end = %u, bytes_needed = %u\n", msg_end, bytes_needed);

							// first copy the filename to a string
							pPacketShellCommand = (binary_packet_shell_command_t*) message_buff;	// we need to update our packet pointer because message_buf might have changed its location if it has been reallocated since last time pPacketWriteFile was set
							char * strCommand = (char*) malloc((pPacketShellCommand->command_length+1)*sizeof(char));	// the +1 is for the \0 character
							if (!strCommand)
							{
								printfv("malloc failed to allocate a string of size: %u\n", pPacketShellCommand->command_length+1);
							}
							else 
							{
								memcpy((void*) strCommand, (void*)(message_buff+sizeof(binary_packet_write_file_t)), pPacketShellCommand->command_length);
								// add \0 termination
								strCommand[pPacketShellCommand->command_length] = '\0';
								printfv("shell command: '%s'\n", strCommand);
								// send command to shell using system()
								system(strCommand);

								free(strCommand);

		        				
		        				//kill(parent_pid, SIGTERM);

	        				}

			        		// reset our message parsing state variables
			        		bHaveShellCommandHeader = false;
			        		bytes_consumed = bytes_needed;
			        		bHaveMagicBytes = false;
			        		bytes_needed = sizeof(message_magic_bytes);
	        			}
	        		}



	        	} // else if (message_magic_bytes == magic_bytes_shell_command)

	        	////////////////////////////////////////////////////////////
	        	// Reboot this program (monitor-tcp).
	        	// To do this, we first need to kill our parent process, then we exit the loop and run a system() call which launches ourselves again.
	        	else if (message_magic_bytes == magic_bytes_reboot_monitor)
	        	{
	        		bytes_needed = sizeof(binary_packet_reboot_monitor_t);
		        	if (msg_end >= bytes_needed) {
		        		// there is no other information in this type of packet.

		        		// kill returns 0 if no error, so we wait until the process is gone
		        		while (kill(parent_pid, SIGTERM) == 0)
		        		{
		        			usleep(10000);	// 10 ms
		        		}

		        		printfv("exiting message parsing loop.\n");
		        		bReboot = true;
		        		//goto loop_exit;	// we need to exit two nested while loops

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_reboot_monitor_t);
		        		bHaveMagicBytes = false;
		        		bytes_needed = sizeof(message_magic_bytes);
		        	}


		        } // else if (message_magic_bytes == magic_bytes_reboot_monitor)

	        	else {	// magic bytes didn't match any known packet type

	        		printfv("magic bytes do not match any known packet type. got: 0x%0x, msg_end = %u\n", message_magic_bytes, msg_end);
	        		printfv("This will probably mean that the whole protocol is de-synced and erronous values will be read/written\n");
	        		bytes_consumed = sizeof(message_magic_bytes);
	        		bHaveMagicBytes = false;
	        		return 0;
	        	}

	        } // if (bHaveMagicBytes)




	    	// move the rest of the message to the beginning of the buffer
	    	if (bytes_consumed > 0)
	    	{
	    		if (msg_end < bytes_consumed)
	    		{
	    			bytes_consumed = 0;
	    			printfv("Assert error: msg_end < bytes_consumed, msg_end = %u, bytes_consumed = %u\n", (uint32_t)msg_end, (uint32_t)bytes_consumed);
	    		} else {
	        		printfv("consumed %u bytes from the buffer. msg_end before=%u", (uint32_t)bytes_consumed, msg_end);
		        	msg_end -= bytes_consumed;
		        	char *m = message_buff + bytes_consumed;
			        if (message_buff != m && msg_end > 0) {
			            memmove(message_buff, m, msg_end);
			        }
			        bytes_consumed = 0;
	        		printfv(", msg_end after=%u\n", msg_end);

		    	}
			}

		} // while (msg_end >= bytes_needed)
        
		// debug:
		//printf("at the end of the recv loop: msg_end = %u, bHaveMagicBytes = %d\n", (uint32_t)msg_end, bHaveMagicBytes);
		// if (msg_end > 0)
		// {
		// 	printf("dumping messagebuf contents: ");
		// 	for (int k=0;k<msg_end; k++)
		// 		printf("0x%X,", message_buff[k]);
		// }
    }

// loop_exit:
    free(message_buff);

    //
    printf("Closing memory map...\n");
    closeMemoryMap();

    printf("Closing client connection...\n");



    if(read_size == 0)
    {
        printf("Client is disconnected\n");
        if (bReboot)
        	return -1;	// -1 tells the previous function to restart the program
       	else
        	return 0;	// this is a normal close
    }
    else if(read_size == -1)
    {
        printf("Receive message failed (%s)\n", strerror(errno));
        perror("Receive message failed");
        return 1;
    }
    return 0;
}




/**
 * Main daemon entrance point. Opens a socket and listens for any incoming connection.
 * When client connects, if forks the conversation into a new socket and the daemon (parent process)
 * waits for another connection. It can handle multiple connections simultaneously.
 * @param argc  not used
 * @param argv  not used
 * @return
 */
int main(int argc, char *argv[])
{

	printf("monitor-tcp server started, V1.0, built at " __TIME__ " on " __DATE__ "\n");

	if (argc>=2)
	{
		if (strcmp(argv[1], "-v") == 0)
		{
			bVerbose = true;
		}
	}

	// first some simple tests to figure out size of certain types:
	printfv("sizeof(char) = %d, sizeof(short) = %d, sizeof(int) = %d, sizeof(long int) = %d, sizeof(long long int) = %d\n", (int)sizeof(char), (int)sizeof(short), (int)sizeof(int), (int)sizeof(long int), (int)sizeof(long long int));
	printfv("sizeof(char*) = %d, sizeof(void*) = %d\n", (int)sizeof(char*), (int)sizeof(void*));
	// results from Zynq: "sizeof(short) = 2, sizeof(int) = 4, sizeof(long int) = 4, sizeof(long long int) = 8"
	// "sizeof(char*) = 4, sizeof(void*) = 4"

	int result = 0;

    // Open logging into "/var/log/messages" or /var/log/syslog" or other configured...
    //setlogmask (LOG_UPTO (LOG_INFO));
    //openlog ("scpi-server", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);

    

    installTermSignalHandler();

    int listenfd = 0, connfd = 0;
    struct sockaddr_in serv_addr;

    // Handle close child events
    handleCloseChildEvents();
    parent_pid = getpid();


    // Create a socket
    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if (listenfd == -1)
    {
        printf("Failed to create a socket (%s)\n", strerror(errno));
        perror("Failed to create a socket");
        return (EXIT_FAILURE);
    }

    memset(&serv_addr, '0', sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(LISTEN_PORT);

    bool bBindSuccess = false;
    uint iRetries = 0;

    while (!bBindSuccess && iRetries < 200 && !app_exit)
    {
	    if (bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
	    {
	        printf("Failed to bind the socket (%s), retrying in 1000 ms...\n", strerror(errno));
	        perror("Failed to bind the socket");
	        usleep(1000000);	// 1 sec
	        iRetries++;
	        //return (EXIT_FAILURE);
	    } else {
	    	bBindSuccess = true;
	    }
    }
    if (app_exit)
    {
    	return EXIT_FAILURE;
    }
    if (!bBindSuccess)	// we didn't succeed after 20 retries...
    {
    	printf("failed to bind after 200 tries... exiting.\n");
    	return EXIT_FAILURE;
    }

    if (listen(listenfd, LISTEN_BACKLOG) == -1)
    {
        printf("Failed to listen on the socket (%s)\n", strerror(errno));
        perror("Failed to listen on the socket");
        return (EXIT_FAILURE);
    }

    printf("Server is listening on port %d\n", LISTEN_PORT);

    // Socket is opened and listening on port. Now we can accept connections
    while(1)
    {
        struct sockaddr_in cliaddr;
        socklen_t clilen;
        clilen = sizeof(cliaddr);

        connfd = accept(listenfd, (struct sockaddr *)&cliaddr, &clilen);

        if (app_exit == true) {
            break;
        }

        if (connfd == -1) {
            printf("Failed to accept connection (%s)\n", strerror(errno));
            perror("Failed to accept connection\n");
            return (EXIT_FAILURE);
        }

        // Fork a child process, which will talk to the client
        if (!fork()) {

            printf("Connection with client ip %s established.\n", inet_ntoa(cliaddr.sin_addr));

            // this is the child process
            close(listenfd); // child doesn't need the listener

            //scpi_context.user_context = &connfd;



            result = handleConnection(connfd);

            printf("calling close(connfd)...\n");
            close(connfd);

            printf("Closing connection with client ip %s.\n", inet_ntoa(cliaddr.sin_addr));

            if (result == -1)	// -1 means to reboot the program
            {
		    	printf("rebooting monitor-tcp... sleep 1 sec\n");
		    	usleep(100000);
		    	printf("rebooting monitor-tcp... done sleeping, calling monitor-tcp again\n");
		    	system("/opt/monitor-tcp");
		    	return (EXIT_SUCCESS);
	    	}


            if (result == 0) {
                return(EXIT_SUCCESS);
            }
            else {
                return(EXIT_FAILURE);
            }
        }

        printf("calling close(connfd)...\n");
        close(connfd);
    }

    printf("calling close(listenfd)...\n");
    close(listenfd);


    printf("monitor-tcp server stopped.\n");


    return (EXIT_SUCCESS);
}
