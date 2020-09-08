////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is just a bunch of dead code that I didn't really want to delete
// in case I want to use it as a reference later
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// this can be as long as we want (as long as it fits in the Zynq's RAM)
// currently sizeof(uint32_t)*(1UL<<20) = 4 MB
#define NO_FIFO_LOGGER_BUFFER_SIZE (1U<<20)
uint32_t data_buffer_no_fifo[NO_FIFO_LOGGER_BUFFER_SIZE];

// 16e6 samples (64 MB)
#define FIFO_LOGGER_BUFFER_SIZE (1U<<24)
uint32_t data_buffer_with_fifo[FIFO_LOGGER_BUFFER_SIZE];


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
        buf = (double) (int16_t) (*virt_addr_read & 0xFFFF);    // the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
        if (buf < val_min)
            val_min = buf;
        if (buf > val_max)
            val_max = buf;
        if (buf > 1e3)
            *((unsigned long *) virt_addr_write) = (long int) (int16_t) -2e3;
        else
            *((unsigned long *) virt_addr_write) = (long int) (int16_t) 2e3;
        //*((unsigned long *) virt_addr_write) = (long int) (int16_t) -1.0 * buf;   // for now this is just a pass-through
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
        usleep(1000);   // argument is in microseconds
        for (k2 =0; k2<number_of_steps; k2++)
        {
            // read adc
            //printf("before adc read\n");
            adc_input = (int16_t) (*virt_addr_read & 0xFFFF);   // the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
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
        adc_input = (int16_t) (*virt_addr_read & 0xFFFF);   // the 16 LSBs contain channel A, while the LSBs contain channel B, both sign-extended from 14 bits to 16 bits
        // compute error
        current_error = (double) (threshold_int16 - adc_input);
        // compute output value (integrate)
        delta_t = 1.0;  // TODO: get actual timer value to compute delta_t
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
    //  for (k2 =0; k2<number_of_steps; k2++)
    //  {
    //      printf("%d, %d, ", RAM_buffer[kOut], RAM_buffer[kOut+1]);
    //      kOut++;
    //      kOut++;
    //  }

    // }
    // printf("\n");


}

void continuous_fifo_read(  )
{
    uint32_t iChunk, iOut;
    const volatile uint32_t* fifo_buffer = (uint32_t*)((char*)map_base + 4*0x00039U);

    // start the reading process by setting a few registers:
    write_value(FPGA_MEMORY_START + 0x42*4, 'w', 1);    //    assert fifo synchronous reset (and also resets max_fifo_count)
    write_value(FPGA_MEMORY_START + 0x42*4, 'w', 0);    // de-assert fifo synchronous reset
    write_value(FPGA_MEMORY_START + 0x41*4, 'w', 1);    // bWritesEnabled = 1


    // Read the fifo as quickly as we can
    iOut = 0;
    while (iOut < FIFO_LOGGER_BUFFER_SIZE) {
        // wait until fifo is not empty
        while (read_value(FPGA_MEMORY_START + 0x38*4)) ;
        // "not empty" in this case means at least 10 samples in the fifo
        for (iChunk=0; iChunk<10; iChunk++)
            data_buffer_with_fifo[iOut++] = (*fifo_buffer);
    }
    write_value(FPGA_MEMORY_START + 0x41*4, 'w', 1);    // bWritesEnabled = 0

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

    min_delta_counter = 0x7fffffff; // hex(2^31-1)
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
