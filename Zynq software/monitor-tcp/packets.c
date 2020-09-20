#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <time.h> // for clock_gettime

#include <sys/types.h> // for getpid()
#include <sys/socket.h>
#include <unistd.h> // for usleep
#include <signal.h> // for kill()

#include "packets.h"
#include "memory_interface.h"
#include "common.h"

const uint32_t magic_bytes_write_repeat_reg = 0xABCD1232;
const uint32_t magic_bytes_write_reg      = 0xABCD1233;
const uint32_t magic_bytes_read_reg       = 0xABCD1234;
const uint32_t magic_bytes_read_buffer    = 0xABCD1235;
const uint32_t magic_bytes_flank_servo    = 0xABCD1236;
const uint32_t magic_bytes_write_file     = 0xABCD1237;
const uint32_t magic_bytes_shell_command  = 0xABCD1238;
const uint32_t magic_bytes_reboot_monitor = 0xABCD1239;
const uint32_t magic_bytes_read_repeat    = 0xABCD123A;
const uint32_t magic_bytes_read_file      = 0xABCD123B; // this packet uses the same header as binary_packet_write_file_t

const size_t BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY = sizeof(magic_bytes_write_reg); // default size needed

extern bool bVerbose; // this allows enabling lots of debugging messages.
extern int16_t  data_buffer[LOGGER_BUFFER_SIZE];
extern int32_t  data_buffer32[LOGGER_REPEAT_SIZE];
extern pid_t parent_pid;
extern bool bReboot; // signals to the main loop that it needs to close

// Returns true if we had enough data to parse out the magic bytes
bool getMagicBytes(char* const message_buff, size_t msg_end, uint32_t* const magic_bytes)
{
    if (msg_end < BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY) // early exit if we haven't received enough bytes yet
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
        *bytes_needed = BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY; // default size needed
        *bytes_consumed = struct_size;
        return true;
    } else {
        *bytes_needed = struct_size;
        *bytes_consumed = 0;
        return false;
    }
}

// copy a string from the message buffer of the given length.
// str_len should be the actual string length, without the /0 terminator.
// The output is placed in the return value and includes the /0 terminator.
// The calling function is responsible for freeing the allocated memory
// returns a null pointer on failure
char * extractStringFromBuffer(char* message_buff, int str_len, size_t offset)
{
    char * strOutput = (char*) malloc((str_len+1)*sizeof(char));   // the +1 is for the \0 character
    if (strOutput)
    {
        memcpy((void*) strOutput, (void*)(message_buff+offset), str_len);
        // add \0 termination
        strOutput[str_len] = '\0';
    } else {
        printfv("malloc failed to allocate a string of size: %u\n", str_len+1);
        return false;
    }
    return strOutput;
}

/////////////////////////////////// Packet handler functions: ///////////////////////////////////
// All of these functions return true if packet was handled by this function

// // use this template to create a new handler:
// bool packet_handler_template(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
// {
//     if (!magicBytesMatch(message_buff, msg_end, magic_bytes_template))
//         return false;

//     struct binary_packet_template* pPacket = (binary_packet_template*) message_buff;
//     if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
//         return false;

//     // do stuff here!

//     return true;
// }

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

// Write multiple 32 bits values to specified FPGA register
bool packet_handler_write_repeat_reg(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_write_repeat_reg))
        return false;

    struct binary_packet_write_repeat_reg_t* pPacket = (binary_packet_write_repeat_reg_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    *bytes_consumed = 0; // set this back to 0 since we have more rules to apply before we can parse out this message completely
    if (pPacket->repeats > 10000)
    {
        return false; // avoid waiting for a ridiculous number of words
    }
    *bytes_needed = sizeof(*pPacket) + sizeof(uint32_t)*(pPacket->repeats);

    // we know how long the total message needs to be, so we just wait to have received everything.
    if (msg_end < *bytes_needed)
        return false;

    printfv("Received a register write repeat packet.\n");
    printfv("*bytes_needed  = %u, msg_end=%u\n",   *bytes_needed, (uint)msg_end);
    printfv("address = 0x%X (hex)\n",              pPacket->write_address);
    printfv("sleep time between writes = %u us\n", pPacket->sleep_us);
    printfv("number of repeats = %u (decimal)\n",  pPacket->repeats);

    *bytes_consumed = *bytes_needed;
    *bytes_needed = BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY; // set this back to default

    // perform the actual memory writes:
    uint32_t *value_ptr = &(pPacket->repeats) + 1;
    for (uint32_t k=0; k<pPacket->repeats; k++)
    {
        write_value(pPacket->write_address, 'w', *value_ptr);
        usleep(pPacket->sleep_us);
        value_ptr++;
    }

    return true;
}

// Read 32 bits value to specified FPGA register
bool packet_handler_read_reg(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_read_reg))
        return false;

    struct binary_packet_read_reg_t* pPacket = (binary_packet_read_reg_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    printfv("read_reg(0x%X)\n", pPacket->start_address);

    // perform actual memory read, dump 32 bits value into TCP socket.
    uint32_t register_value;
    register_value = read_value(pPacket->start_address);

    // send it back:
    send(connfd, &register_value, sizeof(register_value), 0);
    printfv("register sent. addr = 0x%X, value = %u\n", pPacket->start_address, register_value);

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

// Read a buffer of continuous value from an ADC input
bool packet_handler_read_buffer(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_read_buffer))
        return false;

    struct binary_packet_read_buffer_t* pPacket = (binary_packet_read_buffer_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    printfv("Buffer read packet, number_of_points=%u\n", pPacket->number_of_points);

    struct timespec time_start, time_end;
    // clock_gettime(CLOCK_REALTIME, &time_start);

    // this should contain the actual data, note that the writing has surely wrapped and the start/end of the data run will be random in the dataset
    // TODO: sync with the end of the acquisition in the buffer.
    clock_gettime(CLOCK_REALTIME, &time_start);
    uint32_t acq_size = MIN(LOGGER_BUFFER_SIZE, pPacket->number_of_points);
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
    
    return true;
}

// Reboot this program (monitor-tcp).
// To do this, we first need to kill our parent process, then we exit the loop and run a system() call which launches ourselves again.
bool packet_handler_reboot(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_reboot_monitor))
        return false;

    struct binary_packet_reboot_monitor_t* pPacket = (binary_packet_reboot_monitor_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    // there is no other information in this type of packet.
    while (kill(parent_pid, SIGTERM) == 0) // kill returns 0 if no error, so this waits until the process is gone
    {
        usleep(10000);  // 10 ms
    }

    printfv("exiting message parsing loop.\n");
    bReboot = true;

    return true;
}

// Send a command string to the shell
bool packet_handler_shell_command(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    if (!magicBytesMatch(message_buff, msg_end, magic_bytes_shell_command))
        return false;

    struct binary_packet_shell_command_t* pPacket = (binary_packet_shell_command_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    *bytes_consumed = 0; // set this back to 0 since we have more rules to apply before we can parse out this message completely

    // we need at least the first two 32 bits values before we can figure out the size of this message.
    printfv("Received shell command header.\n");
    printfv("command_length = %u\n", pPacket->command_length);
    *bytes_needed = sizeof(*pPacket) + pPacket->command_length;
    printfv("*bytes_needed  = %u, msg_end=%u\n", *bytes_needed, (uint)msg_end);

    // we know how long the total message needs to be, so we just wait to have received everything.
    if (msg_end < *bytes_needed)
        return false;

    *bytes_consumed = *bytes_needed;
    *bytes_needed = BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY; // set this back to default

    printfv("Complete shell command message received.\n");
    printfv("msg_end = %zu, bytes_needed = %zu, *bytes_consumed = %zu\n", msg_end, *bytes_needed, *bytes_consumed);

    // first copy the filename to a string
    char * strCommand = extractStringFromBuffer(message_buff, pPacket->command_length, sizeof(*pPacket));
    if (!strCommand)
    {
        return true; // str was a null pointer
    }
    else 
    {
        printfv("shell command: 0x%x, %s\n", (uint)strCommand, strCommand);
        // send command to shell using system()
        system(strCommand);
        free(strCommand);
        printfv("shell command: success!\n");
    }
    return true;
}



// Read/Write a file to/from the filesystem
bool packet_handler_file_rw_command(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd)
{
    bool bIsFileWrite = magicBytesMatch(message_buff, msg_end, magic_bytes_write_file);
    bool bIsFileRead  = magicBytesMatch(message_buff, msg_end, magic_bytes_read_file);
    if (!bIsFileWrite && !bIsFileRead)
        return false;
    printfv("magic bytes are read/write file\n");

    struct binary_packet_write_file_t* pPacket = (binary_packet_write_file_t*) message_buff;
    if (!canConsumeStructFromBuffer(sizeof(*pPacket), message_buff, msg_end, bytes_needed, bytes_consumed))
        return false;

    printfv("Received file read/write header.\n");
    
    printfv("address of message_buff = 0x%x, address of pPacket = 0x%x\n", (uint) message_buff, (uint) pPacket);
    printfv("pPacket->filename_length = %u\n", pPacket->filename_length);
    printfv("pPacket->file_size       = %u\n", pPacket->file_size);
    *bytes_needed = sizeof(*pPacket) + pPacket->filename_length + pPacket->file_size;
    *bytes_consumed = 0; // set this back to 0 since we have more rules to apply before we can parse out this message completely
    printfv("*bytes_needed            = %u\n", *bytes_needed);

    // we know how long the total message needs to be, so we just wait to have received everything.
    if (msg_end < *bytes_needed)
        return false;

    *bytes_consumed = *bytes_needed;
    *bytes_needed = BYTES_NEEDED_FOR_MAGIC_BYTES_ONLY; // set this back to default

    printfv("Complete file read/write message received.\n");
    printfv("msg_end = %zu, bytes_needed = %zu, *bytes_consumed = %zu\n", msg_end, *bytes_needed, *bytes_consumed);

    // first copy the filename to a string
    char * strFilename = extractStringFromBuffer(message_buff, pPacket->filename_length, sizeof(*pPacket));
    if (!strFilename)
        return true; // str was a null pointer

    
    if (bIsFileWrite)
    {
        printfv("file write: %s\n", strFilename);
        size_t offset = sizeof(binary_packet_write_file_t)+pPacket->filename_length;
        read_file_from_socket_to_disk(strFilename, message_buff, offset, pPacket->file_size, connfd);
    } else if (bIsFileRead)
    {
        printfv("file read: %s\n", strFilename);
        send_file_to_socket(strFilename, connfd);
    }

    free(strFilename);
    printfv("file r/w command done\n");

    return true;
}

void read_file_from_socket_to_disk(const char * const strFilename, char * message_buff, size_t offset, unsigned int file_size, int connfd)
{
    FILE * file_pointer = fopen(strFilename, "wb");
    if (!file_pointer)
    {
        printfv("Error opening file %s. No contents written.\n", strFilename);
    } else {
        // write file contents
        fwrite((void*)(message_buff+offset) , 1, file_size, file_pointer);
        fclose(file_pointer);
    }
}

// read and send file contents to socket
void send_file_to_socket(const char * const strFilename, int connfd)
{
    // file read: send file size first
    // Format is: file_valid, file_size, <file bytes>
    uint32_t file_valid;
    uint32_t file_size;

    // send it back:
    FILE * file_pointer = fopen(strFilename, "rb");
    if (!file_pointer)
    {
        file_valid = 0; // -1 means that the file does not exist
        send(connfd, &file_valid, sizeof(file_valid), 0); // file valid?
        file_size = 0;
        send(connfd, &file_size, sizeof(file_size), 0); // file size
        printfv("Error opening file %s. No contents read.\n", strFilename);
        return;
    }

    file_valid = 1;
    send(connfd, &file_valid, sizeof(file_valid), 0); // file valid?
    fseek(file_pointer, 0, SEEK_END);
    file_size = ftell(file_pointer);
    rewind(file_pointer);

    uint8_t *file_contents = malloc(file_size);
    if (!file_contents)
    {
        // allocation error, send back an empty file:
        printfv("Error allocating memory for file %s. Will send back an empty file instead.\n", strFilename);
        file_size = 0;
        send(connfd, &file_size, sizeof(file_size), 0); // file size, clamped to 0
    } else {
        size_t retval = fread(file_contents, 1, file_size, file_pointer);
        if (retval != file_size)
            printfv("fread returned %u instead of %u\n", retval, file_size);
        printfv("Sending file %s, %u bytes.\n", strFilename, file_size);
        send(connfd, &file_size, sizeof(file_size), 0); // file size
        send(connfd, file_contents, file_size, 0);
    }
    fclose(file_pointer);
}

