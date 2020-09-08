/////////////////////////////////////////////////////
// stuff for reading/writing to the fpga memory
/////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h> // for strerror()
#include <stdint.h>
#include <errno.h>

#include <fcntl.h> // for open
#include <sys/mman.h> // for memory-map
#include <unistd.h> // for close()

#include "memory_interface.h"
#include "common.h"
extern bool bVerbose; // this allows enabling lots of debugging messages.

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)
 
//#define MAP_SIZE 4096UL   // TODO: change to the full fpga memory size (1 GB = 2^30 = 1<<30 or 1<<29, not sure)
#define MAP_SIZE (1UL<<29)  // (1 GB = 2^30 = 1<<30, but I couldn't get it to work with 1 GB so I changed to 512 MB instead)
#define MAP_MASK (MAP_SIZE - 1)



uint32_t FPGA_MEMORY_START = 0x40000000UL;
void* map_base = (void*)(-1);

int fd_dev_mem = -1;

// Stuff for memory-mapping the XADC, on the GP 0 AXI master bus of the PS:
#define MAP_SIZE_XADC (1UL<<20) // there are really only a handful of registers in this map (1k addresses I think) (see XADC Wizard v3.2 product guide PG091, table 2-3 for a list, C_BASEADDR = 0x0)
#define MAP_MASK_XADC (MAP_SIZE_XADC - 1)
uint32_t FPGA_MEMORY_START_XADC = 0x80000000UL;
void* map_base_xadc = (void*)(-1);

void initMemoryMap()
{
    printf("MAP_SIZE = %lu\n", MAP_SIZE);
    if((fd_dev_mem = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
    map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd_dev_mem, FPGA_MEMORY_START & ~MAP_MASK);
    if(map_base == (void *) -1) FATAL;

    // open XADC memory map:
    map_base_xadc = mmap(0, MAP_SIZE_XADC, PROT_READ | PROT_WRITE, MAP_SHARED, fd_dev_mem, FPGA_MEMORY_START_XADC & ~MAP_MASK_XADC);
    if(map_base_xadc == (void *) -1) FATAL;
}

void closeMemoryMap()
{
    // close main memory map to 0x4000_0000 to 0x6000_0000
    if (map_base != (void*)(-1)) {
        if(munmap(map_base, MAP_SIZE) == -1) FATAL;
        map_base = (void*)(-1);
    }
    // close XADC memory map to 0x8000_0000 to ...
    if (map_base != (void*)(-1)) {
        if(munmap(map_base, MAP_SIZE) == -1) FATAL;
        map_base = (void*)(-1);
    }
    close(fd_dev_mem);
}

uint32_t read_value(uint32_t a_addr) {
    void* virt_addr;
    if (a_addr < FPGA_MEMORY_START_XADC)
        virt_addr = map_base + (a_addr & MAP_MASK); // register is in main memory map (0x4000_0000 to 0x6000_0000)
    else
        virt_addr = map_base_xadc + (a_addr & MAP_MASK_XADC); // register is in XADC memory map (0x8XXX_XXXX)
    uint32_t read_result = 0;
    read_result = *((uint32_t *) virt_addr);
    //printf("0x%08x\n", read_result);
    //fflush(stdout);
    return read_result;
}

void write_value(unsigned long a_addr, int a_type, unsigned long a_value) {
    void* virt_addr;
    if (a_addr < FPGA_MEMORY_START_XADC)
        virt_addr = map_base + (a_addr & MAP_MASK); // register is in main memory map (0x4000_0000 to 0x6000_0000)
    else
        virt_addr = map_base_xadc + (a_addr & MAP_MASK_XADC); // register is in XADC memory map (0x8XXX_XXXX)
    
    //printf("writing at addr = 0x%08lx, ", (a_addr & MAP_MASK));
    //printf("map_base = 0x%08lx, ", (unsigned long)(map_base));
    //printf("virt_addr = 0x%08lx\n", (unsigned long)(virt_addr));

    switch(a_type) {
        case 'b':
            *((unsigned char *) virt_addr) = a_value;
            break;
        case 'h':
            *((unsigned short *) virt_addr) = a_value;
            break;
        case 'w':
            *((unsigned long *) virt_addr) = a_value;
            break;
    }

}

void readBuffer(uint32_t* size, int16_t* buffer_in)
{
    *size = MIN(*size, LOGGER_BUFFER_SIZE);

    const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + LOGGER_BASE_ADDR + LOGGER_DATA_OFFSET);

    printfv("readBuffer: reading %u points, starting from address 0x%lX\n", *size, LOGGER_BASE_ADDR + LOGGER_DATA_OFFSET);

    for (uint32_t i = 0; i < (*size); ++i) {
        buffer_in[i] = (raw_buffer[i % LOGGER_BUFFER_SIZE]);
    }
    printfv("buffer_in[0] = %hd\n", buffer_in[0]);
}

void readRepeat(uint32_t start_address, uint32_t* size, int32_t* buffer_in)
{
    *size = MIN(*size, LOGGER_REPEAT_SIZE);

    const volatile uint32_t* raw_buffer = (uint32_t*)(map_base + (start_address & MAP_MASK));

    printfv("readRepeat: reading %u points, starting from address 0x%X\n", *size, start_address);

    for (uint32_t i = 0; i < (*size); ++i) {
        buffer_in[i] = *raw_buffer;
    }

    // printfv("buffer_in[0] = %d\n", buffer_in[0]);
}
