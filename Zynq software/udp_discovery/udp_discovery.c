#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <time.h> 

#define PORT_NUMBER 1952

#define RECV_BUF_SIZE 1
#define MAC_BUF_SIZE (6*2+5)

int main(int argc, char *argv[])
{
    int listenfd = 0;
    int connfd = 0;
    struct sockaddr_in serv_addr; 
    struct sockaddr_in * client_addr_in;
    struct sockaddr client_addr;
    size_t client_addr_size = sizeof(client_addr);
    static int enable = 1;

    //char sendBuf[SEND_BUF_SIZE];
    char recvBuf[RECV_BUF_SIZE];

    // First: read our mac address (we send this in the response packet as a form of serial-number identification)
    FILE* f_mac = fopen("/sys/class/net/eth0/address", "r");
    char mac_address[MAC_BUF_SIZE];
    memset(mac_address, 0, MAC_BUF_SIZE);

    if (!f_mac)
    {
        printf("error: could not open /sys/class/net/eth0/address for reading.");
    } else {
        // read the mac address:
        fread(mac_address, 1, MAC_BUF_SIZE, f_mac);
        printf("mac address: " );
        for (uint32_t i=0;i<MAC_BUF_SIZE;i++)
            printf("%c", mac_address[i]);
        printf("\n");
        fclose(f_mac);
    }
    



    //memset(sendBuf, '0', sizeof(sendBuf));
    //sendBuf[0] = '1';
    //sendBuf[1] = '\0';

    listenfd = socket(AF_INET, SOCK_DGRAM, 0);

    // Form the broadcast address:
    memset(&serv_addr, '0', sizeof(serv_addr));
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(PORT_NUMBER); 

    // setsockopt() allows other applications to listen to this port
    if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable)) < 0)
    {
    	//printf("error in setsockopt()\n");
    	perror("error in setsockopt()\n");
    }
    if (bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0)
    {
    	//printf("error in bind()\n");
    	perror("error in bind()\n");
    }

    // Create the 'client' socket which will be used to answer back to the discovery packet
	connfd = socket(AF_INET, SOCK_DGRAM, 0);


    //listen(listenfd, 10); 

    while(1)
    {	
    	recvfrom(listenfd, recvBuf, sizeof(recvBuf[0])*RECV_BUF_SIZE, 0, &client_addr, &client_addr_size);
    	printf("received.\n");
    	//printf("family = %u", client_addr.sa_family);
    	if (client_addr.sa_family == AF_INET)
    	{
    		//printf("AF_INET\n");
    		client_addr_in = (struct sockaddr_in *) &client_addr;
    		printf("family = %d, port = %u\n", client_addr_in->sin_family, client_addr_in->sin_port);
    		printf("sin_addr = %x\n", client_addr_in->sin_addr.s_addr);

    	}
    	// change the reply port to the same port that we are using in reception + 1
    	client_addr_in->sin_port = htons(PORT_NUMBER+1);

    	//sendto(connfd, sendBuf, sizeof(sendBuf[0])*SEND_BUF_SIZE, 0, &client_addr, client_addr_size);
        sendto(connfd, mac_address, sizeof(mac_address[0])*MAC_BUF_SIZE, 0, &client_addr, client_addr_size);

        // connfd = accept(listenfd, (struct sockaddr*)NULL, NULL); 

        // ticks = time(NULL);
        // snprintf(sendBuff, sizeof(sendBuff), "%.24s\r\n", ctime(&ticks));
        // write(connfd, sendBuff, strlen(sendBuff)); 

        // close(connfd);
        // sleep(1);
     }

     close(connfd);
     close(listenfd);
}

