#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <time.h> // for clock_gettime

#include <sys/types.h>
#include <sys/socket.h>

#include "packets.h"
#include "memory_interface.h"
#include "common.h"

const uint32_t magic_bytes_write_reg      = 0xABCD1233;
const uint32_t magic_bytes_read_reg       = 0xABCD1234;
const uint32_t magic_bytes_read_buffer    = 0xABCD1235;
const uint32_t magic_bytes_flank_servo    = 0xABCD1236;
const uint32_t magic_bytes_write_file     = 0xABCD1237;
const uint32_t magic_bytes_shell_command  = 0xABCD1238;
const uint32_t magic_bytes_reboot_monitor = 0xABCD1239;
const uint32_t magic_bytes_read_repeat    = 0xABCD123A;
const uint32_t magic_bytes_read_file      = 0xABCD123B; // this packet uses the same header as binary_packet_write_file_t


extern bool bVerbose; // this allows enabling lots of debugging messages.
extern int16_t  data_buffer[LOGGER_BUFFER_SIZE];
extern int32_t  data_buffer32[LOGGER_REPEAT_SIZE];

// Returns true if we had enough data to parse out the magic bytes
bool getMagicBytes(char* const message_buff, size_t msg_end, uint32_t* const magic_bytes)
{
    if (msg_end < sizeof(*magic_bytes)) // early exit if we haven't received enough bytes yet
        return false;

    *magic_bytes = *((uint32_t*)&message_buff[0]);
    return true;
}

// Returns true if magic bytes match start of message
bool magicBytesMatch(char* message_buff, size_t msg_end, uint32_t magic_bytes)
{
    uint32_t message_magic_bytes;
    if (!getMagicBytes(message_buff, msg_end, &message_magic_bytes))
        return false; // early exit if we haven't received enough bytes yet

    return (message_magic_bytes == magic_bytes);
}

// Returns true if mapping a struct of size struct_size to the given buffer is possible, false otherwise.
// Also sets the values of *bytes_needed and *bytes_consumed accordingly
bool canConsumeStructFromBuffer(size_t struct_size,
                                char* message_buff, size_t msg_end,
                                size_t* bytes_needed, size_t* bytes_consumed)
{
    if (msg_end >= struct_size)
    {
        *bytes_consumed = struct_size;
        return true;
    } else {
        *bytes_needed = struct_size;
        *bytes_consumed = 0;
        return false;
    }
}

/////////////////////////////////// Packet handler functions: ///////////////////////////////////
// All of these functions return true if packet was handled by this function


// Write 32 bits value to specified FPGA register
bool packet_handler_write_reg(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_write_reg))
        return false;

    struct binary_packet_write_reg_t* pPacket = (binary_packet_write_reg_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    printfv("Received a register write packet.\n");
    printfv("message_write_address = 0x%X (hex)\n", pPacket->write_address);
    printfv("message_write_value = %u (decimal)\n", pPacket->write_value);
    fflush(stdout);

    // perform the actual memory write:
    write_value(pPacket->write_address, 'w', pPacket->write_value);

    return true;
}

// Read a buffer by reading repeatedly at the same address (intended to be used with registers_read.vhd)
bool packet_handler_read_repeat(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_read_repeat))
        return false;

    struct binary_packet_read_repeat_t* pPacket = (binary_packet_read_repeat_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    printfv("Received a read repeat packet.\n");
    printfv("pPacket->start_address = 0x%X (hex)\n", pPacket->start_address);
    printfv("pPacket->number_of_points = %u (decimal)\n", pPacket->number_of_points);

    struct timespec time_start, time_end;
    clock_gettime(CLOCK_REALTIME, &time_start);
    uint32_t acq_size = MIN(LOGGER_REPEAT_SIZE, pPacket->number_of_points);
    readRepeat(pPacket->start_address, &acq_size, data_buffer32);
    clock_gettime(CLOCK_REALTIME, &time_end);
    printfv("readRepeat elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));

    // dump this into the TCP socket:
    printfv("before socket send()\n");
    clock_gettime(CLOCK_REALTIME, &time_start);
    send(connfd, data_buffer32, (size_t)acq_size*sizeof(int32_t), 0);
    clock_gettime(CLOCK_REALTIME, &time_end);
    printfv("send() elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));
    printfv("socket send() complete\n");
    
    return true;
}
