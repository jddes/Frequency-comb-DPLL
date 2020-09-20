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
bool bReboot = false; // Variables for the "reboot" message

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
        		bHaveMagicBytes = getMagicBytes(message_buff, msg_end, &message_magic_bytes);

        		if (bHaveMagicBytes)
			        printfv("message_magic_bytes = 0x%X\n", message_magic_bytes);
			}
			if (!bHaveMagicBytes)
				continue;

        	// we have received enough data to know which packet type it is at least
        	bool bPacketHandled = false;
			bPacketHandled = bPacketHandled || packet_handler_write_repeat_reg (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
            bPacketHandled = bPacketHandled || packet_handler_write_reg      (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_read_reg       (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_read_buffer    (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_read_repeat    (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_file_rw_command(message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_shell_command  (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);
			bPacketHandled = bPacketHandled || packet_handler_reboot         (message_buff, msg_end, &bytes_needed, &bytes_consumed, connfd);

	        if (!bPacketHandled)
	        {
	        	// this can mean either:
	        	// magic bytes didn't match any known packet type, OR
	        	// one of the packet parser needs more bytes before it can parse the message
	        	if (bytes_needed == sizeof(message_magic_bytes))
	        	{
	        		// magic bytes didn't match any known packet type
	        		printfv("magic bytes do not match any known packet type. got: 0x%0x, msg_end = %u\n", message_magic_bytes, msg_end);
	        		printfv("This will probably mean that the whole protocol is de-synced and erronous values will be read/written\n");
	        		bytes_consumed = sizeof(message_magic_bytes);
	        		bHaveMagicBytes = false;
	        		return 0;
        		}
        	}

        	// trap a potential error condition:
        	if (bytes_needed < sizeof(message_magic_bytes))
        	{
        		printf("Assert error: bytes_needed < sizeof(message_magic_bytes): %u < %zu.  This probably means that there is a bug in one of the packet handlers in packets.c\n", bytes_needed, sizeof(message_magic_bytes));
        		printf("Will attempt to work around it\n");
        		bytes_needed = sizeof(message_magic_bytes);
        	}



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
        int fork_retval = fork();
        if (fork_retval == 0) {
            // this is the child process
            printf("Connection with client ip %s established.\n", inet_ntoa(cliaddr.sin_addr));
            close(listenfd); // child doesn't need the listener
            result = handleConnection(connfd);
            printf("calling close(connfd)...\n");
            close(connfd);
            printf("Closing connection with client ip %s.\n", inet_ntoa(cliaddr.sin_addr));

            if (result == -1)	// -1 means to reboot the program
            {
		    	printf("rebooting monitor-tcp... sleep 0.1 sec. pid=%u\n", getpid());
		    	usleep(100000);
		    	printf("rebooting monitor-tcp... done sleeping, calling monitor-tcp again. pid=%u\n", getpid());
		    	system("/opt/monitor-tcp"); // this is a blocking call, but that's not a real issue, since this calling process won't be doing anything
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
