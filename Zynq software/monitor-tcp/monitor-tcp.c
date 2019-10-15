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


//#include "scpi-commands.h"
//#include "common.h"

//#include "scpi/parser.h"
//#include "redpitaya/rp.h"

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) > (Y)) ? (X) : (Y))

#define LISTEN_BACKLOG 50
#define LISTEN_PORT 5000
#define MAX_BUFF_SIZE 1024

static bool app_exit = false;
pid_t parent_pid;
bool bVerbose = false; // this allows enabling lots of debugging messages. currently not available unless the code is recompiled

// Packet formats definitions
#pragma pack(push)
#pragma pack(1)

uint32_t magic_bytes_write_reg = 0xABCD1233;
typedef struct binary_packet_write_reg_t {
	uint32_t magic_bytes;	// 0xABCD1233
	uint32_t write_address;
	uint32_t write_value;

} binary_packet_write_reg_t;

uint32_t magic_bytes_read_reg = 0xABCD1234;
typedef struct binary_packet_read_reg_t {
	uint32_t magic_bytes;	// 0xABCD1234
	uint32_t start_address;
	uint32_t reserved;		// unused
} binary_packet_read_reg_t;

uint32_t magic_bytes_read_buffer = 0xABCD1235;
typedef struct binary_packet_read_buffer_t {
	uint32_t magic_bytes;	// 0xABCD1235
	uint32_t start_address;
	uint32_t number_of_points;	
} binary_packet_read_buffer_t;


uint32_t magic_bytes_flank_servo = 0xABCD1236;
typedef struct binary_packet_flank_servo_t {
	uint32_t magic_bytes;	// 0xABCD1236
	uint16_t iStopAfterZC;
	int16_t ramp_minimum;
	uint32_t number_of_ramps;
	uint32_t number_of_steps;
	uint32_t max_iterations;
	int16_t threshold_int16;
	double ki;

} binary_packet_flank_servo_t;

uint32_t magic_bytes_write_file = 0xABCD1237;
typedef struct binary_packet_write_file_t {
	uint32_t magic_bytes;	// 0xABCD1237
	uint32_t filename_length;
	uint32_t file_size;	
} binary_packet_write_file_t;

uint32_t magic_bytes_shell_command = 0xABCD1238;
typedef struct binary_packet_shell_command_t {
	uint32_t magic_bytes;	// 0xABCD1238
	uint32_t command_length;
	uint32_t reserved;	
} binary_packet_shell_command_t;

uint32_t magic_bytes_reboot_monitor = 0xABCD1239;
typedef struct binary_packet_reboot_monitor_t {
	uint32_t magic_bytes;	// 0xABCD1239
	uint32_t reserved1;
	uint32_t reserved2;	
} binary_packet_reboot_monitor_t;



#pragma pack(pop)


/////////////////////////////////////////////////////
// stuff for writing to the fpga memory
/////////////////////////////////////////////////////

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)
 
//#define MAP_SIZE 4096UL	// TODO: change to the full fpga memory size (1 GB = 2^30 = 1<<30 or 1<<29, not sure)
#define MAP_SIZE (1UL<<29)	// (1 GB = 2^30 = 1<<30, but I couldn't get it to work with 1 GB so I changed to 512 MB instead)
#define MAP_MASK (MAP_SIZE - 1)

uint32_t read_value(uint32_t a_addr);
void write_value(unsigned long a_addr, int a_type, unsigned long a_value);

uint32_t FPGA_MEMORY_START = 0x40000000UL;
void* map_base = (void*)(-1);

int fd_dev_mem = -1;

// Stuff for memory-mapping the XADC, on the GP 0 AXI master bus of the PS:
#define MAP_SIZE_XADC (1UL<<20)	// there are really only a handful of registers in this map (1k addresses I think) (see XADC Wizard v3.2 product guide PG091, table 2-3 for a list, C_BASEADDR = 0x0)
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
		
	// if (addr != 0) {
	// 	if (val_count == 0) {
	// 		read_value(addr);
	// 	}
	// 	else {
	// 		write_values(addr, access_type, val, val_count);
	// 	}
	// }
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
		virt_addr = map_base + (a_addr & MAP_MASK);	// register is in main memory map (0x4000_0000 to 0x6000_0000)
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
		virt_addr = map_base + (a_addr & MAP_MASK);	// register is in main memory map (0x4000_0000 to 0x6000_0000)
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

// Stuff for the data acquisition:
#include "monitor-tcp.h"

// should be equal to 2^ADDRESS_WIDTH generic in ram_data_logger.vhd
#define LOGGER_BUFFER_SIZE (1UL<<15)
#define LOGGER_BASE_ADDR 0x00100000UL
#define LOGGER_DATA_OFFSET  (1UL<<19)
#define LOGGER_START_WRITE_OFFSET  0x1004UL

int16_t data_buffer[LOGGER_BUFFER_SIZE];

// this can be as long as we want (as long as it fits in the Zynq's RAM)
// currently sizeof(uint32_t)*(1UL<<20) = 4 MB
#define NO_FIFO_LOGGER_BUFFER_SIZE (1U<<20)
uint32_t data_buffer_no_fifo[NO_FIFO_LOGGER_BUFFER_SIZE];

// 16e6 samples (64 MB)
#define FIFO_LOGGER_BUFFER_SIZE (1U<<24)
uint32_t data_buffer_with_fifo[FIFO_LOGGER_BUFFER_SIZE];

void acq_LoggerStartWrite()
{
	// writing anything to this register triggers the writing in ram_data_logger.vhd
	write_value(LOGGER_BASE_ADDR + LOGGER_START_WRITE_OFFSET, 'w', 0);
}


void acq_GetDataFromLogger(uint32_t* size, int16_t* buffer_in)
{
    *size = MIN(*size, LOGGER_BUFFER_SIZE);

    const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + LOGGER_BASE_ADDR + LOGGER_DATA_OFFSET);
    //const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + OSC_CHB_OFFSET);

    if (bVerbose)
    	printf("acq_GetDataFromLogger: reading %u points, starting from address 0x%lX\n", *size, LOGGER_BASE_ADDR + LOGGER_DATA_OFFSET);

    for (uint32_t i = 0; i < (*size); ++i) {
        buffer_in[i] = (raw_buffer[i % LOGGER_BUFFER_SIZE]);
    }
    if (bVerbose)
    	printf("buffer_in[0] = %hd\n", buffer_in[0]);
}


// based off acq_GetDataRawV2 in file acq_handler.c
#define ADC_BUFFER_SIZE             (16*1024)

//int16_t data_buffer2[ADC_BUFFER_SIZE];

void acq_GetDataRawV2_CHA(uint32_t pos, uint32_t* size, int16_t* buffer_in)
{
    *size = MIN(*size, ADC_BUFFER_SIZE);

    const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + OSC_CHA_OFFSET);
    //const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + OSC_CHB_OFFSET);

    for (uint32_t i = 0; i < (*size); ++i) {
        buffer_in[i] = (raw_buffer[(pos + i) % ADC_BUFFER_SIZE]);
    }

}

void acq_GetDataRawV2_CHB(uint32_t pos, uint32_t* size, int16_t* buffer)
{
    *size = MIN(*size, ADC_BUFFER_SIZE);

    //const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + OSC_CHA_OFFSET);
    const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + OSC_CHB_OFFSET);

    for (uint32_t i = 0; i < (*size); ++i) {
        buffer[i] = (raw_buffer[(pos + i) % ADC_BUFFER_SIZE]);
    }
    
}

void acq_MinimumSetup()
{
	// start an acquisition with the minimum amount of setup:
	osc_control_t *osc_control = (osc_control_t*)((char*)map_base + OSC_BASE_ADDR);

	// send a "write pointer reset" command: (it looks like it gets stuck after one acquisition otherwise, but I can't figure out why by reading the fpga code)
	osc_control->conf = 2;
	
	// set trigger source to software:
	osc_control->trig_source = 1;
	// send an "arm" command:
	osc_control->conf = 1;
	// send a software trigger (I think that this second write is necessary but I am not sure):
	//usleep(1000);
	osc_control->trig_source = 1;

	// wait for the ram to fill (this could be done much better by probing a write pointer or some other register...):
	osc_control->trigger_delay = 16*1024;	// I think that this is essentially the number of samples to write after receiving the trigger.
	usleep(1000);
	//usleep(10000);

	// set arm = 0 so that the FPGA stops writing to the RAM while we read it out
	//osc_control->conf = 0;

	// data should be ready to be read out

}

void read_write_loop_minimum()
{
	double buf;
	const volatile uint32_t* virt_addr_read = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + 0x00094);
	void* virt_addr_write = (void*)((char*)map_base + 0x500000);
	//volatile uint32_t* raw_buffer_write = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + 0x00094);

    struct timespec time_start, time_end;
    clock_gettime(CLOCK_REALTIME, &time_start);
    // stuff to be timed would go here

    //unsigned short a_value = 1;

	double val_min, val_max;
	val_min = 16e3*10.;
	val_max = -val_min;

    printf("entering read_write_loop_minimum()\n");

	for (int k=0; k<100000; k++)
	{
		buf = (double) (int16_t) (*virt_addr_read & 0xFFFF);	// the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
		if (buf < val_min)
			val_min = buf;
		if (buf > val_max)
			val_max = buf;
		if (buf > 1e3)
			*((unsigned long *) virt_addr_write) = (long int) (int16_t) -2e3;
		else
			*((unsigned long *) virt_addr_write) = (long int) (int16_t) 2e3;
		//*((unsigned long *) virt_addr_write) = (long int) (int16_t) -1.0 * buf;	// for now this is just a pass-through
	}

    clock_gettime(CLOCK_REALTIME, &time_end);
    printf("read_write_loop_minimum(), elapsed = %d seconds + %ld ms\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec)/1000000);

    printf("val_min = %f, val_max = %f", val_min, val_max);
}


void absorption_flank_servo(int connfd, uint16_t iStopAfterZC, int16_t ramp_minimum, uint32_t number_of_ramps, uint32_t number_of_steps,
							uint32_t max_iterations, int16_t threshold_int16, double ki)
{
	printf("absorption_flank_servo(): iStopAfterZC = %u, ramp_minimum = %d, number_of_ramps = %u, number_of_steps = %u,\nmax_iterations = %u, threshold_int16 = %d, ki = %f\n", 
		iStopAfterZC, ramp_minimum, number_of_ramps, number_of_steps,
		max_iterations, threshold_int16, ki
		);
	fflush(stdout);

	const volatile uint32_t* virt_addr_read = (uint32_t*)((char*)map_base + OSC_BASE_ADDR + 0x00094);
	unsigned long* virt_addr_write = (unsigned long*)((char*)map_base + 0x500000);

	printf("sizeof(unsigned long int) = %u\n", sizeof(unsigned long int));
	printf("sizeof(unsigned int) = %u\n", sizeof(unsigned int));
	printf("sizeof(double) = %u\n", sizeof(double));


	int16_t * RAM_buffer = calloc((number_of_ramps*number_of_steps+max_iterations)*2, sizeof(int16_t));
	if (!RAM_buffer)
	{
		printf("Error, unable to allocate %u bytes for the ram buffer. exiting...\n", (number_of_ramps*number_of_steps+max_iterations)*2*sizeof(int16_t));
		return;
	}

	uint32_t k, k2, kOut = 0;
	int16_t ramp_output = 0;
	int16_t dac_output, adc_input;
	uint32_t current_sign, last_sign;


	for (k =0; k< number_of_ramps; k++)
	{
		// this inner loop does a single ramp
		// current_sign = 1;
		// last_sign = 1;
		ramp_output = ramp_minimum;
		dac_output = ramp_output;
		// set dac
		//*((unsigned long *) virt_addr_write) = (long int) (int16_t) dac_output;
		*virt_addr_write = (long int) (int16_t) dac_output;
		// wait for output to settle
		printf("start of ramp\n");
		fflush(stdout);
		usleep(1000);	// argument is in microseconds
		for (k2 =0; k2<number_of_steps; k2++)
		{
			// read adc
			//printf("before adc read\n");
			adc_input = (int16_t) (*virt_addr_read & 0xFFFF);	// the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
			//printf("after adc read\n");
			// set dac
			//*((unsigned long *) virt_addr_write) = (long int) (int16_t) dac_output;
			dac_output = ramp_output;
			*virt_addr_write = (long int) (int16_t) dac_output;
			// increment ramp output for next step
			ramp_output++;
			
			// put both values in RAM to be sent to the PC
			RAM_buffer[kOut++] = adc_input;
			RAM_buffer[kOut++] = dac_output;
			//printf("end of loop\n");
			// check threshold crossing
			current_sign = (adc_input > threshold_int16 ? 1 : 0);
			if (k2 == 0) last_sign = current_sign;
			if (current_sign != last_sign)
			{
				// we just crossed threshold, either positive or negative crossing AND we are at the last ramp
				if (iStopAfterZC && k == number_of_ramps-1)
					goto run_control_loop;
			}

			last_sign = current_sign;

		}
	}

	// if we get here, that means that we didn't find the zero crossing condition or weren't told to look for it (iStopAfterZC == 0)
	if (iStopAfterZC)
		printf("finished looping without finding zero crossing.\n");
	else
		printf("finished looping, skipping control loop since iStopAfterZC = 0\n");
	goto skip_control_loop;

run_control_loop:
	printf("Running control loop for %u iterations (0 means infinite).\n", max_iterations);

	uint32_t kIterations = 0;
	double current_error = 0., integrator_state = 0., delta_t = 1.0;
	while (kIterations < max_iterations || max_iterations==0)
	{
		// read adc value
		adc_input = (int16_t) (*virt_addr_read & 0xFFFF);	// the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
		// compute error
		current_error = (double) (threshold_int16 - adc_input);
		// compute output value (integrate)
		delta_t = 1.0;	// TODO: get actual timer value to compute delta_t
		integrator_state += ki * current_error * delta_t;
		// saturate integrator state, TODO: should change to anti-windup behavior (and saturate at the dac_output instead of at the integrator state)
		if (integrator_state > 8191.)
			integrator_state = 8191.;
		if (integrator_state < -8192.)
			integrator_state = -8192.;
		// set dac value
		dac_output = integrator_state + ramp_output;
		*virt_addr_write = (long int) (int16_t) dac_output;

		// put both values in RAM to be sent to the PC later
		if (max_iterations != 0)
		{
			RAM_buffer[kOut++] = adc_input;
			RAM_buffer[kOut++] = dac_output;
		}

		if (app_exit)
		{
			printf("quit signal detected. quitting loop.\n");
			fflush(stdout);
			break;
		}
		kIterations++;
	}
skip_control_loop:


	// send contents of the ram buffer through the tcp connection:
	printf("Sending RAM buffer...\n");
	//int16_t * RAM_buffer = calloc(number_of_ramps*number_of_steps*2, sizeof(int16_t));
	if (!app_exit)
		send(connfd, RAM_buffer, (size_t)(number_of_ramps*number_of_steps+max_iterations)*2*sizeof(int16_t), 0);
	printf("after send()\n");
	// for now: dump out the RAM_buffer:
	// printf("Dumping RAM buffer...\n");
	// kOut = 0;
	// for (k =0; k< number_of_ramps; k++)
	// {
	// 	for (k2 =0; k2<number_of_steps; k2++)
	// 	{
	// 		printf("%d, %d, ", RAM_buffer[kOut], RAM_buffer[kOut+1]);
	// 		kOut++;
	// 		kOut++;
	// 	}

	// }
	// printf("\n");


}


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


void continuous_fifo_read(  )
{
	uint32_t iChunk, iOut;
    const volatile uint32_t* fifo_buffer = (uint32_t*)((char*)map_base + 4*0x00039U);

    // start the reading process by setting a few registers:
    write_value(FPGA_MEMORY_START + 0x42*4, 'w', 1);	//    assert fifo synchronous reset (and also resets max_fifo_count)
    write_value(FPGA_MEMORY_START + 0x42*4, 'w', 0);	// de-assert fifo synchronous reset
    write_value(FPGA_MEMORY_START + 0x41*4, 'w', 1);	// bWritesEnabled = 1


    // Read the fifo as quickly as we can
    iOut = 0;
    while (iOut < FIFO_LOGGER_BUFFER_SIZE) {
    	// wait until fifo is not empty
    	while (read_value(FPGA_MEMORY_START + 0x38*4)) ;
    	// "not empty" in this case means at least 10 samples in the fifo
    	for (iChunk=0; iChunk<10; iChunk++)
        	data_buffer_with_fifo[iOut++] = (*fifo_buffer);
    }
    write_value(FPGA_MEMORY_START + 0x41*4, 'w', 1);	// bWritesEnabled = 0

    // what is max data count for fifo?
    uint32_t max_fifo_count = read_value(FPGA_MEMORY_START + 0x40*4);

    // show results, first few points of the buffer:
    for (iOut=0; iOut<50; iOut++)
    	printf("%u, ", data_buffer_with_fifo[iOut]);
    printf("\n");

    printf("max_fifo_count = %u\n", max_fifo_count);

	return;
}

void throughput_test(  )
{
	int32_t current_delta;
    int32_t min_delta_counter, max_delta_counter, total_delta_counter;
    uint32_t number_of_counts_above_threshold = 0;

    min_delta_counter = 0x7fffffff;	// hex(2^31-1)
    max_delta_counter = 0;
    printf("throughput_test\n");
    printf("min_delta_counter at start = %d, max_delta_counter = %d\n", min_delta_counter, max_delta_counter);


    const volatile uint32_t* raw_buffer = (uint32_t*)((char*)map_base + 4*0x00037U);

    // Read a buffer as quickly as we can
    uint32_t i;
    for (i = 0; i < NO_FIFO_LOGGER_BUFFER_SIZE; ++i) {
        data_buffer_no_fifo[i] = (*raw_buffer);
    }
    
    // count min, max and average counter steps:
	for (i = 1; i < NO_FIFO_LOGGER_BUFFER_SIZE; ++i)
	{
		// compute delta
		current_delta = (int32_t)data_buffer_no_fifo[i] - (int32_t)data_buffer_no_fifo[i-1];

		// show first 50 pts:
		if (i<250)
			printf("%d, ", current_delta);


		// how many above a certain threshold? set at 2* mean
		if (current_delta > 40)
			number_of_counts_above_threshold++;

		// running min
		if (current_delta < min_delta_counter)
			min_delta_counter = current_delta;
		// running max
		if (current_delta > max_delta_counter)
			max_delta_counter = current_delta;
	}
	total_delta_counter = (int32_t)data_buffer_no_fifo[NO_FIFO_LOGGER_BUFFER_SIZE-1] - (int32_t)data_buffer_no_fifo[0];

	printf("\n");
	printf("total delta = %d counts, avg = %d counts\n", total_delta_counter, total_delta_counter / NO_FIFO_LOGGER_BUFFER_SIZE);
	printf("min_delta_counter = %d counts, max_delta_counter = %d counts\n", min_delta_counter, max_delta_counter);
	printf("number_of_counts_above_threshold = %d\n", number_of_counts_above_threshold);

	return;
}


void *second_thread_function( void *ptr )
{
	// we want to run for ~10 seconds:
	// a loop of: reading an FPGA register, sleeping for 1 us, counting the time taken
	// compute and show min max time over this 10 secs period.
    struct timespec time_start, time_start_of_all, time_end;
    
    long int min_in_ns, max_in_ns, current_in_ns;

    min_in_ns = 1000000000;
    max_in_ns = 0;

	uint32_t cumul = 0;

	clock_gettime(CLOCK_REALTIME, &time_start_of_all);

	printf("hi, we are starting thread 2, time = %ld", (long int) time_start_of_all.tv_sec);

	int k = 0;

	while (1)
	{
		clock_gettime(CLOCK_REALTIME, &time_start);
		// todo: read fpga register.
		cumul = cumul + read_value(0x40000000);
		//usleep(1); // argument is in microseconds
		clock_gettime(CLOCK_REALTIME, &time_end);
		current_in_ns = 1000000000L * (long int)(time_end.tv_sec-time_start.tv_sec) + (long int)(time_end.tv_nsec-time_start.tv_nsec);
		if (current_in_ns < min_in_ns)
			min_in_ns = current_in_ns;
		if (current_in_ns > max_in_ns)
			max_in_ns = current_in_ns;
		if (time_end.tv_sec - time_start_of_all.tv_sec >= 10)
			break;
		//printf("in loop, %ld = ", (long int) time_start.tv_sec);
		if (k >= 1000000)
			break;
		k++;
	}

	printf("cumul = %d\n", cumul);
	printf("min_in_ns = %ld ns, max_in_ns = %ld\n", min_in_ns, max_in_ns);

	return NULL;
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

    printf("Waiting for first client request.\n");

    initMemoryMap();
    printf("Memory map completed.\n");

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

    size_t iRequiredBytes = sizeof(message_magic_bytes);	// to start, we only need 4 bytes before starting to parse out the message.

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
            	printf("msg_end+read_size > message_len\n");
            	message_len = msg_end+read_size;
            }
            message_buff = realloc(message_buff, message_len);
            printf("reallocated message_buf to size %u. new address = 0x%x\n", (uint)message_len, (uint)message_buff);
        }

        // Copy read buffer into message buffer
        memcpy(message_buff + msg_end, buffer, read_size);
        msg_end += read_size;
        //printf("msg_end = %u\n", (uint32_t)msg_end);

        while (msg_end >= iRequiredBytes)
        {

	        if (~bHaveMagicBytes)
	        {
	        	if (msg_end >= sizeof(message_magic_bytes))
	        	{
					// we can read the packet 'header', or magic bytes:
					if (bVerbose)
						printf("buffer is long enough to parse out magic bytes at least.\n");
		        	// check the packet "header"
		        	message_magic_bytes = *((uint32_t*)&message_buff[0]);
		        	if (bVerbose)
		        		printf("message_magic_bytes = 0x%X\n", message_magic_bytes);
		        	bHaveMagicBytes = true;
	        	}
	        }
	        if (bHaveMagicBytes)
	        {
	        	// we know which type of packet is coming in:
	        	// parse out the correct type of packet

	        	////////////////////////////////////////////////////////////
	        	// Write 32 bits value to specified FPGA register
	        	if (message_magic_bytes == magic_bytes_write_reg)
	        	{
	        		iRequiredBytes = sizeof(binary_packet_write_reg_t);
	        		if (msg_end >= iRequiredBytes){
		        		struct binary_packet_write_reg_t * pPacketWriteReg;
		        		pPacketWriteReg = (binary_packet_write_reg_t*) message_buff;


		        		if (bVerbose)
		        			printf("Received a register write packet.\n");
		        		if (bVerbose)
		        			printf("message_write_address = 0x%X (hex)\n", pPacketWriteReg->write_address);
		        		if (bVerbose)
		        			printf("message_write_value = %u (decimal)\n", pPacketWriteReg->write_value);
		        		fflush(stdout);

		        		// perform the actual memory write:
		        		write_value(pPacketWriteReg->write_address, 'w', pPacketWriteReg->write_value);

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_write_reg_t);
		        		bHaveMagicBytes = false;
		        		iRequiredBytes = sizeof(message_magic_bytes);
	        		} else {
	        			if (bVerbose)
	        				printf("Received a register write packet, but we have not received the full packet yet.\n");

	        		}
	        	////////////////////////////////////////////////////////////
	        	// Read 32 bits value to specified FPGA register
	        	} else if (message_magic_bytes == magic_bytes_read_reg)
	        	{
	        		iRequiredBytes = sizeof(binary_packet_read_reg_t);
	        		if (msg_end >= iRequiredBytes)
	        		{
		        		struct binary_packet_read_reg_t * pPacketReadReg;
		        		pPacketReadReg = (binary_packet_read_reg_t*) message_buff;



		        		if (bVerbose)
		        			printf("Received a register read packet.\n");
		        		if (bVerbose)
		        			printf("pPacketReadReg->start_address = 0x%X (hex)\n", pPacketReadReg->start_address);
		        		if (bVerbose)
		        			printf("pPacketReadReg->reserved = %u (decimal) (currently unused)\n", pPacketReadReg->reserved);

		        		// perform actual memory read, dump 32 bits value into TCP socket.
		        		uint32_t register_value;
		        		register_value = read_value(pPacketReadReg->start_address);

		        		// send it back:
		        		send(connfd, &register_value, sizeof(register_value), 0);
		        		if (bVerbose)
		        			printf("register sent. addr = 0x%X, value = %u\n", pPacketReadReg->start_address, register_value);

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_read_reg_t);
		        		bHaveMagicBytes = false;
		        		iRequiredBytes = sizeof(message_magic_bytes);

		        	} else {
		        		if (bVerbose)
		        			printf("Received a register read packet, but we have not received the full packet yet.\n");

		        	}
	        	////////////////////////////////////////////////////////////
	        	// Read a buffer of continuous value from an ADC input
	        	} else if (message_magic_bytes == magic_bytes_read_buffer) {

	        		iRequiredBytes = sizeof(binary_packet_read_buffer_t);
	        		if (msg_end >= iRequiredBytes) {
		        		
		        		struct binary_packet_read_buffer_t * pPacketReadBuffer;
		        		pPacketReadBuffer = (binary_packet_read_buffer_t*) message_buff;



		        		if (bVerbose)
		        			printf("Received a buffer read packet.\n");
		        		if (bVerbose)
		        			printf("pPacketReadBuffer->start_address = 0x%X (hex) (currently unused)\n", pPacketReadBuffer->start_address);
		        		if (bVerbose)
		        			printf("pPacketReadBuffer->number_of_points = %u (decimal)\n", pPacketReadBuffer->number_of_points);

		        		// do an acquisition
		        		if (bVerbose)// 
		        			printf("running acquisition...\n");
					    struct timespec time_start, time_end;
					    // clock_gettime(CLOCK_REALTIME, &time_start);
					    // stuff to be timed would go here

		        		//acq_MinimumSetup();
		        		//acq_LoggerStartWrite();
					    // clock_gettime(CLOCK_REALTIME, &time_end);
					    if (bVerbose)// 
					    	printf("acq_MinimumSetup(), elapsed = %d seconds + %ld ms\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec)/1000000);

		        		// this should contain the actual data, note that the writing has surely wrapped and the start/end of the data run will be random in the dataset
		        		// TODO: sync with the end of the acquisition in the buffer.
		        		clock_gettime(CLOCK_REALTIME, &time_start);
		        		uint32_t acq_size = MIN(LOGGER_BUFFER_SIZE, pPacketReadBuffer->number_of_points);
		        		if (bVerbose)// 
		        			printf("acquisition completed, grabbing %u points....\n", acq_size);
		        		//acq_GetDataRawV2_CHA(0, &acq_size, data_buffer);
		        		acq_GetDataFromLogger(&acq_size, data_buffer);
					    clock_gettime(CLOCK_REALTIME, &time_end);
					    if (bVerbose)
					    	printf("getdata elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));
		        		// for (int k=100; k<140; k++)

		        		// dump this into the TCP socket:
		        		if (bVerbose)// 
		        			printf("before socket send()\n");
		        		clock_gettime(CLOCK_REALTIME, &time_start);
		        		send(connfd, data_buffer, (size_t)acq_size*sizeof(int16_t), 0);
					    clock_gettime(CLOCK_REALTIME, &time_end);
					    if (bVerbose)
					    	printf("send() elapsed = %d seconds + %ld ns\n", (int)(time_end.tv_sec-time_start.tv_sec), (long int)(time_end.tv_nsec-time_start.tv_nsec));
		        		if (bVerbose)
		        			printf("socket send() complete\n");


		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_read_buffer_t);
		        		bHaveMagicBytes = false;
		        		iRequiredBytes = sizeof(message_magic_bytes);
	        		} else {
	        			if (bVerbose)
	        				printf("Received a buffer read packet, but we have not received the full packet yet.\n");

	        		}

	        	////////////////////////////////////////////////////////////
	        	// Run a software control loop (integrator only) to lock a laser on the flank of an absorption line
	        	} else if (message_magic_bytes == magic_bytes_flank_servo)
	        	{
	        		iRequiredBytes = sizeof(binary_packet_flank_servo_t);
		        	if (msg_end >= iRequiredBytes) {

		        		struct binary_packet_flank_servo_t * pPacketFlankServo;
		        		pPacketFlankServo = (binary_packet_flank_servo_t*) message_buff;



		        		absorption_flank_servo(	connfd,
		        								pPacketFlankServo->iStopAfterZC, 
		        								pPacketFlankServo->ramp_minimum, 
		        								pPacketFlankServo->number_of_ramps, 
		        								pPacketFlankServo->number_of_steps,
		        								pPacketFlankServo->max_iterations,
		        								pPacketFlankServo->threshold_int16,
		        								pPacketFlankServo->ki );

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_flank_servo_t);
		        		bHaveMagicBytes = false;
		        		iRequiredBytes = sizeof(message_magic_bytes);
		        	} else {
		        		if (bVerbose)
		        			printf("Received a 'start flank servo' packet, but we have not received the full packet yet.\n");
		        	}

	        	////////////////////////////////////////////////////////////
	        	// Write a file to the filesystem
	        	} else if (message_magic_bytes == magic_bytes_write_file)
	        	{
	        		// we need at least the first two 32 bits value before we can figure out the size of this message.
	        		

	        		if (!bHaveFileWriteHeader)
	        		{
	        			iRequiredBytes = sizeof(binary_packet_write_file_t);
	        			if (msg_end >= iRequiredBytes) {
	        				bHaveFileWriteHeader = true;
	        				if (bVerbose)
	        					printf("Received complete file write header.\n");
			        		
			        		pPacketWriteFile = (binary_packet_write_file_t*) message_buff;
			        		if (bVerbose)
			        			printf("address of message_buff = 0x%x, address of pPacketWriteFile = 0x%x\n", (uint) message_buff, (uint) pPacketWriteFile);

			        		if (bVerbose)
			        			printf("pPacketWriteFile->filename_length = %u\n", pPacketWriteFile->filename_length);
			        		if (bVerbose)
			        			printf("pPacketWriteFile->file_size       = %u\n", pPacketWriteFile->file_size);
			        		iRequiredBytes = sizeof(binary_packet_write_file_t) + pPacketWriteFile->filename_length + pPacketWriteFile->file_size;
			        		if (bVerbose)
			        			printf("iRequiredBytes                    = %u\n", iRequiredBytes);


	        			}
	        		}
	        		if (bHaveFileWriteHeader) {
	        			// we know how long the total message needs to be, so we just wait to have received everything.
	        			if (msg_end >= iRequiredBytes) {
	        				if (bVerbose)
	        					printf("Complete file write message received.\n");
	        				if (bVerbose)
	        					printf("msg_end = %u, iRequiredBytes = %u\n", msg_end, iRequiredBytes);

							// first copy the filename to a string
							pPacketWriteFile = (binary_packet_write_file_t*) message_buff;	// we need to update our packet pointer because message_buf might have changed its location if it has been reallocated since last time pPacketWriteFile was set
							char * strNewFileName = (char*) malloc((pPacketWriteFile->filename_length+1)*sizeof(char));	// the +1 is for the \0 character
							if (!strNewFileName)
							{
								if (bVerbose)
									printf("malloc failed to allocate a string of size: %u\n", pPacketWriteFile->filename_length+1);
							} else {
								if (bVerbose)
									printf("address of strNewFileName = 0x%x, address of pPacketWriteFile = 0x%x\n", (uint) strNewFileName, (uint) pPacketWriteFile);
								if (bVerbose)
									printf("malloc succeeded to allocate a string of size: %u\n", pPacketWriteFile->filename_length+1);
								if (bVerbose)
									printf("pPacketWriteFile->filename_length = %u\n", pPacketWriteFile->filename_length);
								if (bVerbose)
									printf("pPacketWriteFile->file_size       = %u\n", pPacketWriteFile->file_size);
								memcpy((void*) strNewFileName, (void*)(message_buff+sizeof(binary_packet_write_file_t)), pPacketWriteFile->filename_length);
								if (bVerbose)
									printf("memcpy succeeded\n");
								if (bVerbose)
									printf("pPacketWriteFile->filename_length = %u\n", pPacketWriteFile->filename_length);
								if (bVerbose)
									printf("pPacketWriteFile->file_size       = %u\n", pPacketWriteFile->file_size);
								// add \0 termination
								strNewFileName[pPacketWriteFile->filename_length] = '\0';

								if (bVerbose)
									printf("filename: %s\n", strNewFileName);


								// then we should call fopen with the filename, then fwrite with the right pointer.
								file_pointer = fopen(strNewFileName, "wb");
								if (!file_pointer)
								{
									if (bVerbose)
										printf("Error opening file %s. No contents written.", strNewFileName);
								} else {
									// write file contents
									fwrite((void*)(message_buff+sizeof(binary_packet_write_file_t)+pPacketWriteFile->filename_length) , 1, pPacketWriteFile->file_size, file_pointer);
									fclose(file_pointer);
									file_pointer = NULL;
								}


		        				free(strNewFileName);

		        				//kill(parent_pid, SIGTERM);
		        				//kill(parent_pid, SIGTERM);

	        				}

			        		// reset our message parsing state variables
			        		bHaveFileWriteHeader = false;
			        		bytes_consumed = iRequiredBytes;
			        		bHaveMagicBytes = false;
			        		iRequiredBytes = sizeof(message_magic_bytes);
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
	        			iRequiredBytes = sizeof(binary_packet_shell_command_t);
	        			if (msg_end >= iRequiredBytes) {
	        				bHaveShellCommandHeader = true;
	        				if (bVerbose)
	        					printf("Received complete file write header.\n");
			        		
			        		pPacketShellCommand = (binary_packet_shell_command_t*) message_buff;

			        		if (bVerbose)
			        			printf("pPacketShellCommand->command_length = %u\n", pPacketShellCommand->command_length);
			        		iRequiredBytes = sizeof(binary_packet_write_file_t) + pPacketShellCommand->command_length;
			        		if (bVerbose)
			        			printf("iRequiredBytes                    = %u\n", iRequiredBytes);


	        			}
	        		}
	        		if (bHaveShellCommandHeader) {
	        			// we know how long the total message needs to be, so we just wait to have received everything.
	        			if (msg_end >= iRequiredBytes) {
	        				if (bVerbose)
	        					printf("Complete shell command message received.\n");
	        				if (bVerbose)
	        					printf("msg_end = %u, iRequiredBytes = %u\n", msg_end, iRequiredBytes);

							// first copy the filename to a string
							pPacketShellCommand = (binary_packet_shell_command_t*) message_buff;	// we need to update our packet pointer because message_buf might have changed its location if it has been reallocated since last time pPacketWriteFile was set
							char * strCommand = (char*) malloc((pPacketShellCommand->command_length+1)*sizeof(char));	// the +1 is for the \0 character
							if (!strCommand)
							{
								if (bVerbose)
									printf("malloc failed to allocate a string of size: %u\n", pPacketShellCommand->command_length+1);
							}
							else 
							{
								memcpy((void*) strCommand, (void*)(message_buff+sizeof(binary_packet_write_file_t)), pPacketShellCommand->command_length);
								// add \0 termination
								strCommand[pPacketShellCommand->command_length] = '\0';

								if (bVerbose)
									printf("shell command: '%s'\n", strCommand);

								// send command to shell using system()
								system(strCommand);

								free(strCommand);

		        				
		        				//kill(parent_pid, SIGTERM);

	        				}

			        		// reset our message parsing state variables
			        		bHaveShellCommandHeader = false;
			        		bytes_consumed = iRequiredBytes;
			        		bHaveMagicBytes = false;
			        		iRequiredBytes = sizeof(message_magic_bytes);
	        			}
	        		}



	        	} // else if (message_magic_bytes == magic_bytes_shell_command)

	        	////////////////////////////////////////////////////////////
	        	// Reboot this program (monitor-tcp).
	        	// To do this, we first need to kill our parent process, then we exit the loop and run a system() call which launches ourselves again.
	        	else if (message_magic_bytes == magic_bytes_reboot_monitor)
	        	{
	        		iRequiredBytes = sizeof(binary_packet_reboot_monitor_t);
		        	if (msg_end >= iRequiredBytes) {
		        		// there is no other information in this type of packet.

		        		// kill returns 0 if no error, so we wait until the process is gone
		        		while (kill(parent_pid, SIGTERM) == 0)
		        		{
		        			usleep(10000);	// 10 ms
		        		}


		        		if (bVerbose)
		        			printf("exiting message parsing loop.\n");
		        		bReboot = true;
		        		//goto loop_exit;	// we need to exit two nested while loops

		        		// reset our message parsing state variables
		        		bytes_consumed = sizeof(binary_packet_reboot_monitor_t);
		        		bHaveMagicBytes = false;
		        		iRequiredBytes = sizeof(message_magic_bytes);
		        	}


		        } // else if (message_magic_bytes == magic_bytes_reboot_monitor)

	        	else {	// magic bytes didn't match any known packet type

	        		if (bVerbose)
	        			printf("magic bytes do not match. got: 0x%0x, msg_end = %u\n", message_magic_bytes, msg_end);
	        		if (bVerbose)
	        			printf("This will probably mean that the whole protocol is de-synced and erronous values will be read/written\n");
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
	    			if (bVerbose)
	    				printf("Assert error: msg_end < bytes_consumed, msg_end = %u, bytes_consumed = %u\n", (uint32_t)msg_end, (uint32_t)bytes_consumed);
	    		} else {
	        		if (bVerbose)
	        			printf("consumed %u bytes from the buffer.\n", (uint32_t)bytes_consumed);
		        	msg_end -= bytes_consumed;
		        	char *m = message_buff + bytes_consumed;
			        if (message_buff != m && msg_end > 0) {
			            memmove(message_buff, m, msg_end);
			        }
			        bytes_consumed = 0;
		    	}
			}

		} // while (msg_end >= iRequiredBytes)
        
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

	// first some simple tests to figure out size of certain types:
	printf("sizeof(char) = %d, sizeof(short) = %d, sizeof(int) = %d, sizeof(long int) = %d, sizeof(long long int) = %d\n", (int)sizeof(char), (int)sizeof(short), (int)sizeof(int), (int)sizeof(long int), (int)sizeof(long long int));
	printf("sizeof(char*) = %d, sizeof(void*) = %d\n", (int)sizeof(char*), (int)sizeof(void*));
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
