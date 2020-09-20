#pragma pack(push)
#pragma pack(1)

#include <stdbool.h>
#include <stdint.h>

typedef struct binary_packet_write_repeat_reg_t {
    uint32_t magic_bytes;   // 0xABCD1232
    uint32_t write_address;
    uint32_t sleep_us; // number of us to sleep in between each write
    uint32_t repeats;
    // packet must contain "repeats" 32-bits words afterwards
} binary_packet_write_repeat_reg_t;

typedef struct binary_packet_write_reg_t {
    uint32_t magic_bytes;   // 0xABCD1233
    uint32_t write_address;
    uint32_t write_value;
} binary_packet_write_reg_t;

typedef struct binary_packet_read_reg_t {
    uint32_t magic_bytes;   // 0xABCD1234
    uint32_t start_address;
    uint32_t reserved;      // unused
} binary_packet_read_reg_t;

typedef struct binary_packet_read_buffer_t {
    uint32_t magic_bytes;   // 0xABCD1235
    uint32_t start_address;
    uint32_t number_of_points;  
} binary_packet_read_buffer_t;

typedef struct binary_packet_flank_servo_t {
    uint32_t magic_bytes;   // 0xABCD1236
    uint16_t iStopAfterZC;
    int16_t ramp_minimum;
    uint32_t number_of_ramps;
    uint32_t number_of_steps;
    uint32_t max_iterations;
    int16_t threshold_int16;
    double ki;
} binary_packet_flank_servo_t;

typedef struct binary_packet_write_file_t {
    uint32_t magic_bytes;   // 0xABCD1237
    uint32_t filename_length;
    uint32_t file_size; 
} binary_packet_write_file_t;

typedef struct binary_packet_shell_command_t {
    uint32_t magic_bytes;   // 0xABCD1238
    uint32_t command_length;
    uint32_t reserved;  
} binary_packet_shell_command_t;

typedef struct binary_packet_reboot_monitor_t {
    uint32_t magic_bytes;   // 0xABCD1239
    uint32_t reserved1;
    uint32_t reserved2; 
} binary_packet_reboot_monitor_t;

// used to repeatedly read from an address, used with ram_data_logger_v2.vhd
typedef struct binary_packet_read_repeat_t {
    uint32_t magic_bytes;   // 0xABCD123A
    uint32_t start_address;
    uint32_t number_of_points;  
} binary_packet_read_repeat_t;


#pragma pack(pop)


bool getMagicBytes(char* const message_buff, size_t msg_end, uint32_t* const magic_bytes);
char * extractStringFromBuffer(char* message_buff, int str_len, size_t offset);
void read_file_from_socket_to_disk(const char * const strFilename, char * message_buff, size_t offset, unsigned int file_size, int connfd);
void send_file_to_socket(const char * const strFilename, int connfd);

bool packet_handler_write_repeat_reg(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_write_reg      (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_read_repeat    (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_reboot         (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_read_reg       (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_read_buffer    (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_shell_command  (char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
bool packet_handler_file_rw_command(char* message_buff, size_t msg_end, size_t* bytes_needed, size_t* bytes_consumed, int connfd);
