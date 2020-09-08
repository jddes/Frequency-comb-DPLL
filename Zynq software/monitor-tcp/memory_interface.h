#include <stdint.h>

// should be equal to 2^ADDRESS_WIDTH generic in ram_data_logger.vhd
#define LOGGER_BUFFER_SIZE (1UL<<15)
// should be equal to 2^ADDRESS_WIDTH generic in ram_data_logger_v2.vhd
#define LOGGER_REPEAT_SIZE (1UL<<13)
#define LOGGER_BASE_ADDR 0x00100000UL
#define LOGGER_DATA_OFFSET  (1UL<<19)
#define LOGGER_START_WRITE_OFFSET  0x1004UL


void initMemoryMap();
void closeMemoryMap();
void readBuffer(uint32_t* size, int16_t* buffer_in);
void readRepeat(uint32_t start_address, uint32_t* size, int32_t* buffer_in);
uint32_t read_value(uint32_t a_addr);
void write_value(unsigned long a_addr, int a_type, unsigned long a_value);
