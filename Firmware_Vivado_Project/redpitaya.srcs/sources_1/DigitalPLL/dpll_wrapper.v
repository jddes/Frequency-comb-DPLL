// Digital-PLL wrapper
// JDD 2016

`default_nettype none   // This disables implicit variable declaration, which I really don't like as a feature as it lets bugs go unreported

module dpll_wrapper(

    
    input  wire               clk1,         // global clock, designed for 100 MHz clock rate
    input  wire               clk1_timesN,  // this should be N times the clock, phase-locked to clk1, N matching what was input in the FIR compiler for fir_compiler_minimumphase_N_times_clk
    input  wire               rst,

    // analog data input/output interface
    input  wire signed [15:0] ADCraw0,
    input  wire signed [15:0] ADCraw1,
    output wire signed [15:0] DACout0,
    output wire signed [15:0] DACout1,
    output wire signed [15:0] DACout2,

    output wire osc_output,
    output wire clk_ext_or_int, // clock select register. 1 = internal, 0 = external

    // Data logger port:
    output wire [16-1:0]      LoggerData,
    output wire               LoggerData_clk_enable,
    input  wire               LoggerIsWriting,

    // System bus
    input  wire [ 32-1:0]     sys_addr   ,  // bus address
    input  wire [ 32-1:0]     sys_wdata  ,  // bus write data
    input  wire [  4-1:0]     sys_sel    ,  // bus write byte select
    input  wire               sys_wen    ,  // bus write enable
    input  wire               sys_ren    ,  // bus read enable
    output wire [ 32-1:0]     sys_rdata  ,  // bus read data
    output wire               sys_err    ,  // bus error indicator
    output wire               sys_ack       // bus acknowledge signal

);

// Parameters
localparam SIGNAL_SIZE = 16;


///////////////////////////////////////////////////////////////////////////////
// Replacement for the Opal Kelly "Triggers"

// 2015-01-27 Modification by Hugo Bergeron: added wire in for resetting the fifo
// wire [15:0] WireIn00, WireIn01, WireIn02, WireIn03, WireIn04_Clock_source_select, WireIn05_fifo_reset;
// wire [15:0] WireOut20, WireOut21, WireOut22, WireOut23, WireOut24, WireOut25StatusFlags;
// wire [15:0] TrigIn40;

// new style triggers:
// each "trigger" is actually the update_flag signal of an empty register:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h0040)
)
parallel_bus_register_ok_reset (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(), 
     .update_flag(ok_reset)
     );

parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h0042)
)
parallel_bus_register_trigger_identification (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(), 
     .update_flag(trigger_identification)
     );

// trig 0x0043 would be the crash monitor, which is currently not implemented

parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h0044)
)
parallel_bus_register_phase_ok_reset_frontend (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(), 
     .update_flag(ok_reset_frontend)
     );




///////////////////////////////////////////////////////////////////////////////
// Wires for the configuration bus
wire [15:0]          cmd_addr;
wire [15:0]          cmd_data1in, cmd_data2in;
wire                 cmd_trig;

// conversion from Zynq-style parallel bus to the legacy Opal-Kelly-style bus:
assign cmd_trig    = sys_wen;
assign cmd_addr    = sys_addr [16-1+2:2];   // note that we divide the Zynq addresses by 4 when mapping to the DPLL addresses.  This is because the Zynq cannot address memory locations that are not on 32-bits boundaries, but the legacy bus didn't have this restriction.
assign cmd_data1in = sys_wdata[16-1  :0];
assign cmd_data2in = sys_wdata[32-1  :16];


///////////////////////////////////////////////////////////////////////////////
// For testing a switching supply
wire osc_enable, osc_polarity;
wire [24-1:0] oscillator_modulus;
wire [24-1:0] oscillator_modulus_active;

    variable_duty_cycle_oscillator variable_duty_cycle_oscillator_inst
    (
        .clk(clk1),
        .benable(osc_enable),
        .bpolarity(osc_polarity),
        .modulus(oscillator_modulus),                  // sets the period
        .modulus_active(oscillator_modulus_active),    // controls the duty cycle: output < '1' when modulus < modulus_active (if polarity='1' and enable = '1')
        .output_square_wave(osc_output)
    );

parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(26),
    .REGISTER_DEFAULT_VALUE(26'b11000000000000001001110001),    // polarity=1, enable=1, modulus = 625
    .ADDRESS(16'h0046)
)
parallel_bus_register_oscillator (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output({osc_polarity, osc_enable, oscillator_modulus}), 
     .update_flag()
     );

parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(24),
    .REGISTER_DEFAULT_VALUE(24'd62), // modulus_active = 62 (9.9% duty cyle)
    .ADDRESS(16'h0048)
)
parallel_bus_register_oscillator_duty (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(oscillator_modulus_active), 
     .update_flag()
     );

///////////////////////////////////////////////////////////////////////////////
// clock select register. 1 = internal, 0 = external

parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(1'b1), // internal clock mode by default
    .ADDRESS(16'h0049)
)
parallel_bus_register_clk_select (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(clk_ext_or_int), 
     .update_flag()
     );


///////////////////////////////////////////////////////////////////////////////
// LEDs



// //////////////////////////////////////////////////////////////////////
// // Programmable clock divider, which runs off the x2 clock (200 MHz)
// //////////////////////////////////////////////////////////////////////
// // DOUT[2] contains the output of a programmable clock divider, which runs off the x2 clock (200 MHz)
// // It has three modes: off, 50% duty cycle square wave, or 1 cycle long pulse
// // mode = 2'b00 is off
// // mode = 2'b01 is 50% duty cycle square wave
// // mode = 2'b10 is single cycle pulse
// reg [30-1:0] clk_divider_modulus;
// reg [30-1:0] clk_divider_phase_increment;
// reg [1:0] clk_divider_mode;
// wire programmable_clk_divider_output;

// //assign                   DOUT[1] = clk_divider_mode[0];

// parallel_bus_register_32bits_or_less # (
//  .REGISTER_SIZE(32),
//  .REGISTER_DEFAULT_VALUE(32'b0),
//  .ADDRESS(16'h8500)
// )
// parallel_bus_register_clk_divider (
//     .clk(clk1), 
//     .bus_strobe(cmd_trig), 
//     .bus_address(cmd_addr), 
//     .bus_data({cmd_data2in, cmd_data1in}), 
//     .register_output({clk_divider_mode, clk_divider_modulus}), 
//     .update_flag()
//     );
     
// parallel_bus_register_32bits_or_less # (
//  .REGISTER_SIZE(30),
//  .REGISTER_DEFAULT_VALUE(30'b0),
//  .ADDRESS(16'h8503)
// )
// parallel_bus_register_clk_divider_phase_increment (
//     .clk(clk1), 
//     .bus_strobe(cmd_trig), 
//     .bus_address(cmd_addr), 
//     .bus_data({cmd_data2in, cmd_data1in}), 
//     .register_output(clk_divider_phase_increment), 
//     .update_flag()
//     );

// programmable_clk_divider programmable_clk_divider_2x (
//     .clk(clk2x), 
//     .clk_divider_mode(clk_divider_mode), 
//     .clk_divider_modulus(clk_divider_modulus),
//   .phase_increment(clk_divider_phase_increment),
//     .data_output(programmable_clk_divider_output)
//     );
     


//////////////////////////////////////////////////////////////////////
// The module which drives the front panel LEDs:
// These LEDs don't map directly to LEDs on the RedPitaya, but they still show up in the Python PC GUI so we left them there.
// they could eventually be mapped to some of the LEDs on the RP, although we don't have the nice Reg/Green LEDS anymore.
wire  LED_G0, LED_G1;
wire  LED_R0, LED_R1;

assign LED_G0 = 1'b1;


Status_LED_driver # (
    .N_BITS_COUNTER(23) // 100 MHz/2**23 = 12 Hz
) Status_LED_driver0 (
    .clk(clk1), 
    .lock_on(pll0_lock), 
    .residuals_above_threshold(residuals0_are_above_threshold), 
    .railed((dac0_railed_negative | dac0_railed_positive)), 
    .red_LED(LED_R0), 
    .green_LED() // LED_G0
    );
     
Status_LED_driver # (
    .N_BITS_COUNTER(23) // 100 MHz/2**23 = 12 Hz
) Status_LED_driver1 (
    .clk(clk1), 
    .lock_on(pll1_lock), 
    .residuals_above_threshold(residuals1_are_above_threshold), 
    .railed((dac1_railed_negative | dac1_railed_positive)), 
    .red_LED(LED_R1), 
    .green_LED(LED_G1)
    );
     

// This module outputs high if the abs value of the phase residuals is above a certain threshold
// the output of this module triggers the crash monitor
wire [31:0] phase_residuals0, phase_residuals0_threshold;
wire [9:0] freq_residuals0, freq_residuals0_threshold;
wire residuals0_are_above_threshold_phase, residuals0_are_above_threshold_freq;
reg residuals0_are_above_threshold;

// sets the phase residuals threshold for DAC0:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8400)
)
parallel_bus_register_phase_residuals0_threshold (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(phase_residuals0_threshold), 
     .update_flag()
     );
     
residuals_monitor # (
    .N_BITS_DATA(32)
)
residuals_monitor_inst0 (
     .clk(clk1), 
     .phase_residuals(phase_residuals0), 
     .residuals_threshold(phase_residuals0_threshold), 
     .residuals_are_above_threshold(residuals0_are_above_threshold_phase)
     );
 
// sets the frequency residuals threshold for DAC0:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(10),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8410)
)
parallel_bus_register_freq_residuals0_threshold (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(freq_residuals0_threshold), 
     .update_flag()
     );
     
residuals_monitor # (
    .N_BITS_DATA(10)
)
residuals_monitor_inst0_freq (
     .clk(clk1), 
     .phase_residuals(inst_frequency0), 
     .residuals_threshold(freq_residuals0_threshold), 
     .residuals_are_above_threshold(residuals0_are_above_threshold_freq)
     );
 
// The two trigger conditions are ORed together:
always @(posedge clk1) residuals0_are_above_threshold <= residuals0_are_above_threshold_phase | residuals0_are_above_threshold_freq;
 
wire [31:0] phase_residuals1, phase_residuals1_threshold;
wire residuals1_are_above_threshold;
     
// sets the phase residuals threshold for DAC1:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8401)
)
parallel_bus_register_phase_residuals1_threshold (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(phase_residuals1_threshold), 
     .update_flag()
     );
     
residuals_monitor # (
    .N_BITS_DATA(32)
)
residuals_monitor_inst1 (
     .clk(clk1), 
     .phase_residuals(phase_residuals1), 
     .residuals_threshold(phase_residuals1_threshold), 
     .residuals_are_above_threshold(residuals1_are_above_threshold)
     );


    

///////////////////////////////////////////////////////////////////////////////
// Reset signals
wire bus_rst;

wire ok_reset;
wire ok_reset_frontend;

reg rst_peripherals, rst_peripherals_output1, rst_peripherals_output2, rst_peripherals_internal, rst_peripherals_output1_internal, rst_peripherals_output2_internal;    // we split the reset signal in a tree to try help with the fanout, and hope that xst won't combine our register
reg rst_frontend0, rst_frontend1, rst_frontend0_internal, rst_frontend1_internal;

reg [15:0] reset_counter = 16'b1111111111111111;    // 2**16 cycles * 10 ns/cycle = 655 us of maximum reset time
reg [15:0] reset_counter_frontend = 16'b1111111111111111;   // 2**16 cycles * 10 ns/cycle = 655 us of maximum reset time


//assign DOUT[2] = rst_frontend0;
always @(posedge clk1) begin
    
    if (rst == 1'b1 | bus_rst == 1'b1) begin
        reset_counter <= 16'b1111111111111111;
    end
    else begin
        if (reset_counter > 0) begin
            reset_counter <= reset_counter - 1'b1;
        end
        
        // The different reset groups are compared each to a different value,
        // to make sure that Xilinx doesn't combine the registers into a single reset signal driving a very large fanout
        rst_peripherals_internal         <= ((reset_counter > 3) ? 1'b1 : 1'b0);
        rst_peripherals_output1_internal <= ((reset_counter > 4) ? 1'b1 : 1'b0);
        rst_peripherals_output2_internal <= ((reset_counter > 5) ? 1'b1 : 1'b0);
        
        // An extra register stage to help with routing
        rst_peripherals <= rst_peripherals_internal;
        rst_peripherals_output1 <= rst_peripherals_output1_internal;
        rst_peripherals_output2 <= rst_peripherals_output2_internal;
        
    end
end

always @(posedge clk1) begin
    
    if ((ok_reset == 1'b1) || (ok_reset_frontend == 1'b1)) begin
        reset_counter_frontend <= 16'b1111111111111111;
    end
    else begin
        if (reset_counter_frontend > 0) begin
            reset_counter_frontend <= reset_counter_frontend - 1'b1;
        end
        
        // The different reset groups are compared each to a different value,
        // to make sure that Xilinx doesn't combine the registers into a single reset signal driving a very large fanout
        rst_frontend0_internal              <= ((reset_counter_frontend > 1) ? 1'b1 : 1'b0);
        rst_frontend1_internal              <= ((reset_counter_frontend > 2) ? 1'b1 : 1'b0);
        
        // An extra register stage to help with routing
        rst_frontend0 <= rst_frontend0_internal;
        rst_frontend1 <= rst_frontend1_internal;
        
    end
end


///////////////////////////////////////////////////////////////////////////////
// Multiplexer which selects the desired input for the Data logger (formerly DDR2 logger)
///////////////////////////////////////////////////////////////////////////////
wire    [15:0]         selector;

// counter connected to a free input on the multiplexer, helps for debugging
reg     [31:0]  debugging_counter;
always @(posedge clk1) debugging_counter <= debugging_counter + 1'b1;


multiplexer_NbitsxMsignals_to_Nbits 
    # (
        .N_bits_per_signal(17)  // 16 bits per signal + clock enable in MSB : simply put a static 1'b1 if signal is always valid
    )
    multiplexer_NbitsxMsignals_to_Nbits_inst
    (
    .clk(clk1), 
    .in0({1'b1, ADC0_multiplexed}), 
    .in1({1'b1, ADC1_multiplexed}), 
    .in2({1'b1, {4{inst_frequency0[9]}}, inst_frequency0, 2'b0}), // Inst freq after DDC 0, sign extended to 16 bits
    .in3({1'b1, {4{inst_frequency1[9]}}, inst_frequency1, 2'b0}), // Inst freq after DDC 1, sign extended to 16 bits
    .in4({VNA_output_to_logger_clk_enable, VNA_output_to_logger}), // VNA output
    .in5({1'b1, debugging_counter[15:0]}),  // counter, simply for debugging the DDR2 Logger/USB link
    .in6({1'b1, DACout0}), 
    .in7({1'b1, DACout1}), 
    .in8({1'b1, DACout2}),
    //.in9({crash_monitor_output_to_logger_clk_enable, crash_monitor_output_to_logger}),
    .in9({0'b0, 8'b0}),
    .selector(selector[4:0]), 
    .selected_output({LoggerData_clk_enable, LoggerData})
    );

    // register which selects the correct multiplexer input
    parallel_bus_register_32bits_or_less # (
        .REGISTER_SIZE(16),
        .REGISTER_DEFAULT_VALUE(1'b0),
        .ADDRESS(16'h3)
    )
    parallel_bus_register_logger_mux_select (
         .clk(clk1), 
         .bus_strobe(cmd_trig), 
         .bus_address(cmd_addr), 
         .bus_data({cmd_data2in, cmd_data1in}), 
         .register_output(selector), 
         .update_flag()
         );


///////////////////////////////////////////////////////////////////////////////
// Another multiplexer.  This one is more specialized, as it monitors the state of the DDR2 logger and adds auxilary data to the start of the data stream.
///////////////////////////////////////////////////////////////////////////////
// it also adds a 16-bits magic word to help diagnose bus sync issues
// Collection of wires used to add auxilary data to the stream going to the Data logguer.
// Currently all we do is add one sample of the DDC reference tone near the start of the data packet when the ADC is selected.
wire [15:0]         ref_cosine_0, ref_sine_0, ref_cosine_1, ref_sine_1;
wire [15:0]         ADC0_multiplexed, ADC1_multiplexed;
aux_data_mux aux_data_mux_inst (
    .clk(clk1), 
    .write_mode(LoggerIsWriting), 
    .ADC0(ADCraw0), 
    .ADC1(ADCraw1), 
    .ref_cosine_0(ref_cosine_0), 
    .ref_sine_0(ref_sine_0), 
    .ref_cosine_1(ref_cosine_1), 
    .ref_sine_1(ref_sine_1), 
    .ADC0_multiplexed(ADC0_multiplexed), 
    .ADC1_multiplexed(ADC1_multiplexed)
    );


// ///////////////////////////////////////////////////////////////////////////////
// // "Crash monitor": Monitors the lock state, and starts logging the data if the beat unlocks.  Logs everything to its internal RAMs, then dumps the results to the DDR2 logger
// ///////////////////////////////////////////////////////////////////////////////
// wire crash_monitor_trigger;
// //always @(posedge clk1) crash_monitor_trigger <= ((selector[4:3] == 2'b10) ? 1'b1 : 1'b0);

// assign crash_monitor_trigger = TrigIn40[3];


// reg [15:0] ADC0_buffed, ADC1_buffed, DAC0_buffed, DAC1_buffed, DAC2_buffed;
// always @(posedge clk1) ADC0_buffed <= ADCraw0;
// always @(posedge clk1) ADC1_buffed <= ADCraw1;
// always @(posedge clk1) DAC0_buffed <= DACout0[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// always @(posedge clk1) DAC1_buffed <= DACout1[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// always @(posedge clk1) DAC2_buffed <= DACout[2][SIGNAL_SIZE-1:SIGNAL_SIZE-16];


// wire [15:0] crash_monitor_output_to_logger;
// wire crash_monitor_output_to_logger_clk_enable, crash_monitor_has_data;

// crash_monitor_v1 #
// (
//  .N_BITS_DATA(16),
//  .ADDRESS_BITS(13)
// )
// crash_monitor_v1_inst (
//     .clk(clk1), 
//     .input1(ADC1_buffed), 
//   .input2(DAC1_buffed), 
//   .input3(DAC2_buffed), 
//     .trigger_input(residuals1_are_above_threshold), 
//     .ready_for_dump(crash_monitor_trigger), 
//   .has_data(crash_monitor_has_data),
//     .pretrigger_samples(14'd4096), 
//     .output_to_logger(crash_monitor_output_to_logger), 
//     .output_to_logger_clk_enable(crash_monitor_output_to_logger_clk_enable)
//     );




///////////////////////////////////////////////////////////////////////////////
// Direct-digital converter (brings a signal to baseband, low-pass filters it, and outputs the phase and frequency) for ADC 0
///////////////////////////////////////////////////////////////////////////////
wire        [11:0]  boxcar_filter_size = 12'd20;    // Filter with a notch at 5 MHz: 100MHz/5MHz = 20 samples
wire        [47:0]  reference_frequency0;// = 48'b110011001100 11001100110011001100110011001100;    // 5 MHz reference frequency, should be move to a configurable value from the PC eventually
wire        [9:0]       wrapped_phase0;     // phi/(2*pi) * 2**10
wire        [9:0]       inst_frequency0;        // diff(phi)/(2*pi) * 2**10
wire [10-1+12:0]    inst_frequency0_filtered;       // this is the output of a boxcar filter on the inst_frequency signal, before sending to the DDR2 logger
wire [10-1+2:0] inst_frequency0_filtered_small; // overall filter gain is only equal to its length (4) so we don't really need all the bits
wire [1:0] ddc0_filter_select, ddc1_filter_select;
wire select_phase_or_freq0, select_phase_or_freq1;
wire [3:0] angleSelect_0, angleSelect_1;

   parallel_bus_register_64_bits_or_less # (
        .REGISTER_SIZE(48),
        .ADDRESS(16'h8000)
    ) parallel_bus_register_64_bits_or_less_freq0 (
         .clk(clk1), 
         .bus_strobe(cmd_trig), 
         .bus_address(cmd_addr), 
         .bus_data({cmd_data2in, cmd_data1in}), 
         .register_output(reference_frequency0), 
         .update_flag()
    );
    
   parallel_bus_register_32bits_or_less # (
        .REGISTER_SIZE(8),
        .REGISTER_DEFAULT_VALUE(8'b0),
        .ADDRESS(16'h8004)
    ) parallel_bus_register_64_bits_or_less_angleSelect (
         .clk(clk1), 
         .bus_strobe(cmd_trig), 
         .bus_address(cmd_addr), 
         .bus_data({cmd_data2in, cmd_data1in}), 
         .register_output({angleSelect_1,angleSelect_0}), 
         .update_flag()
    );
    

    parallel_bus_register_32bits_or_less # (
        .REGISTER_SIZE(6),
        .REGISTER_DEFAULT_VALUE(32'b0),
        .ADDRESS(16'h8002)
    )
    parallel_bus_register_ddc_filter_select (
         .clk(clk1), 
         .bus_strobe(cmd_trig), 
         .bus_address(cmd_addr), 
         .bus_data({cmd_data2in, cmd_data1in}), 
         .register_output({select_phase_or_freq1, select_phase_or_freq0, ddc1_filter_select, ddc0_filter_select}), 
         .update_flag()
         );
     
// The actual DDC:
DDC_wideband_filters DDC0_inst (
    .rst(rst_frontend0), 
    .clk(clk1), 
    .clk_times_N(clk1_timesN),
    .data_input(ADCraw0),     // 
     
     // Configuration
     .boxcar_filter_size(boxcar_filter_size),
    .reference_frequency(reference_frequency0), 
     .ddc_filter_select(ddc0_filter_select),
     
    // Reference tone output:
    .ref_cosine_out(ref_cosine_0),
    .ref_sine_out(ref_sine_0),
    
    // Used for nulling the lock phase offset:
    .lock(pll0_lock),
    .angleSelect(angleSelect_0),
     
     // Output
    .amplitude(), 
    .wrapped_phase(wrapped_phase0), 
    .inst_frequency(inst_frequency0)
    );
     
///////////////////////////////////////////////////////////////////////////////
// Counts the frequency with no dead-time using a short bandlimiting filter  + an integrate and dump.
// Output rate will be fs/2^LOG2_N_CYCLES_INTEGRATION ~ 100e6/8e6 ~ 12.5 Hz
// Results are sent to a FIFO which goes to an Opal Kelly PipeOut
///////////////////////////////////////////////////////////////////////////////
wire [64-1:0] counter0_out;
wire counter0_out_clk_enable, counter0_out_clk_enable_faster;
wire triangular_mode;   // triangular_mode='1' means a triangular averaging of the frequency, triangular_mode='0' means rectangular averaging of the frequency

//zero_deadtime_counter #
//(
//  .N_INPUT_BITS(10),
//  .LOG2_N_CYCLES_INTEGRATION(23)
//)
//zero_deadtime_counter_inst0 (
//       .rst(rst_frontend0),
//       .clk(clk1),
//       .data_in(inst_frequency0),
//       .data_out(counter0_out),
//       .output_clk_enable(counter0_out_clk_enable)
//    );
      
dual_type_frequency_counter dual_type_frequency_counter_inst0 (
    .rst(rst_frontend0),
    .clk(clk1), 
    .data_input(inst_frequency0), 
    .N_gate_time(32'd125000000), 
    .N_times_faster_gate_time(32'd125000000), 
    .triangular_mode(triangular_mode), 
    .output_clk_enable_N_times_faster(counter0_out_clk_enable_faster), 
    .data_output(counter0_out), 
    .output_clk_enable(counter0_out_clk_enable)
    );

    // Register which controls the counter mode (triangular or rectangular averaging)
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(12'b1),
    .ADDRESS(16'h8501)
)
parallel_bus_register_counter_mode (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(triangular_mode), 
    .update_flag()
    );

      
    // ///////////////////////////////////////////////////////////////////////////////
    // // pwm_level
    // ///////////////////////////////////////////////////////////////////////////////

    // wire [8:0] pwm_level;

    // parallel_bus_register_32bits_or_less # (
    //     .REGISTER_SIZE(9),
    //     .REGISTER_DEFAULT_VALUE(9'b00000000),
    //     .ADDRESS(16'h6621)
    // )
    // parallel_bus_register_pwm_level (
    //     .clk(clk1), 
    //     .bus_strobe(cmd_trig), 
    //     .bus_address(cmd_addr), 
    //     .bus_data({cmd_data2in, cmd_data1in}), 
    //     .register_output(pwm_level), 
    //     .update_flag()
    // );
    
    // PWM_generator # (
    //     .NUMBER_OF_BITS(8)
    // )
    // PWM_generator_inst (
    //     .clk(clk1),
    //     .level(pwm_level),
    //     .dout(DOUT[0])
    // );


///////////////////////////////////////////////////////////////////////////////
// Direct-digital converter (brings a signal to baseband, low-pass filters it, and outputs the phase and frequency) for ADC 1
///////////////////////////////////////////////////////////////////////////////
//wire      [11:0]  boxcar_filter_size = 12'd20;    // Filter with a notch at 5 MHz: 100MHz/5MHz = 20 samples
wire       [47:0]  reference_frequency1, nominal_reference_frequency1, new_reference_frequency1;
wire     [80-1:0]  dfr_phase_modulus, dfr_phase_adjust, delta_fr;
wire               goto_new_freq_at_next_zerocrossing, force_nominal_freq;
wire        [9:0]  wrapped_phase1;     // phi/(2*pi) * 2**10
wire        [9:0]  inst_frequency1;        // diff(phi)/(2*pi) * 2**10 //now output from the mux that select between DDC1_output, inst_frequency0 or pll0_output
wire  [10-1+12:0]  inst_frequency1_filtered;       // this is the output of a boxcar filter on the inst_frequency signal, before sending to the DDR2 logger
wire   [10-1+2:0]  inst_frequency1_filtered_small; // overall filter gain is only equal to its length (4) so we don't really need all the bits

wire        [10-1:0]    DDC1_output;            // diff(phi)/(2*pi) * 2**10


   parallel_bus_register_64_bits_or_less # (
        .REGISTER_SIZE(48),
        .ADDRESS(16'h8010)
    ) parallel_bus_register_64_bits_or_less_freq1 (
         .clk(clk1), 
         .bus_strobe(cmd_trig), 
         .bus_address(cmd_addr), 
         .bus_data({cmd_data2in, cmd_data1in}), 
         .register_output(reference_frequency1), 
         .update_flag()
    );

     
// The actual DDC:
DDC_wideband_filters DDC1_inst (
    .rst(rst_frontend1), 
    .clk(clk1), 
    .clk_times_N(clk1_timesN),
    .data_input(ADCraw1),
     //.data_input(ADCraw0),  // FOR DEBUGGING< REMOVE ME PLEASE
     
     // Configuration
     .boxcar_filter_size(boxcar_filter_size),
    .reference_frequency(reference_frequency1), 
     .ddc_filter_select(ddc1_filter_select),
     
    // Reference tone output:
    .ref_cosine_out(ref_cosine_1),
    .ref_sine_out(ref_sine_1),
    
    // Used to null out the phase offset
    .lock(pll1_lock),
    .angleSelect(angleSelect_1),
     
     // Output
    .amplitude(), 
    .wrapped_phase(wrapped_phase1), 
    .inst_frequency(DDC1_output) //we changed the output name from inst_frequency1 to DDC1_output to be able to select the input of the Loop Filter with a multiplexer
    );




wire [2-1:0] loop_filter_1_mux_selector;
// Registers which controls the multiplexer for the PLL1 input:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(2),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h9000)
)
parallel_bus_register_mux_pll1  (
 .clk                           (clk1                       ), 
 .bus_strobe                    (cmd_trig                   ), 
 .bus_address                   (cmd_addr                   ), 
 .bus_data                      ({cmd_data2in, cmd_data1in} ), 
 .register_output               (loop_filter_1_mux_selector ), 
 .update_flag                   (                           )
);

multiplexer_3to1_async loop_filters_1_mux (
 .clk                               (clk1                       ),
 .selector_mux                      (loop_filter_1_mux_selector ),
 .in0_mux                           (DDC1_output                ), 
 .in1_mux                           (inst_frequency0            ),
 .in2_mux                           (pll0_output >> 5           ), //pll0_output is 15 bits and in2_mux is 10 bits
 .out_mux                           (inst_frequency1            )
);


     
///////////////////////////////////////////////////////////////////////////////
// Counts the frequency with no dead-time using a short bandlimiting filter  + an integrate and dump.
// Output rate will be fs/2^LOG2_N_CYCLES_INTEGRATION ~ 12.5 Hz
// Results are sent to a FIFO which goes to an Opal Kelly PipeOut
///////////////////////////////////////////////////////////////////////////////
wire [64-1:0] counter1_out;
wire counter1_out_clk_enable;

//zero_deadtime_counter #
//(
//  .N_INPUT_BITS(10),
//  .LOG2_N_CYCLES_INTEGRATION(23)
//)
//zero_deadtime_counter_inst1 (
//       .rst(rst_frontend1),
//       .clk(clk1),
//       .data_in(inst_frequency1),
////         .data_in(inst_frequency0), // For debugging, please remove me!!!
//       .data_out(counter1_out),
//       .output_clk_enable(counter1_out_clk_enable)
//    );
     
     
dual_type_frequency_counter dual_type_frequency_counter_inst1 (
    .rst(rst_frontend0),    // the 0 here is not a typo: we want the two counters to stay synchronized even during a reset
    .clk(clk1), 
    .data_input(inst_frequency1), 
    .N_gate_time(32'd125000000), 
    .N_times_faster_gate_time(32'd125000000), 
    .triangular_mode(triangular_mode), 
    .output_clk_enable_N_times_faster(), 
    .data_output(counter1_out), 
    .output_clk_enable(counter1_out_clk_enable)
    );
     
     // NOT USED ANYMORE:
// Short filter applied to the inst_frequency output of the ddc before sending the data to the logger
// Simply to remove a little bit of noise at higher frequencies before decimation
// Length is fixed at 4 samples. (first null at 25 MHz)
adjustable_boxcar_filter 
    # (
    .MAXIMUM_SIZE(6),
    .DATA_WIDTH(10)
    )
    adjustable_boxcar_filter_freq1 (
    .rst(rst_frontend1), 
    .clk(clk1), 
    .input_clk_enable(1'b1), 
    .input_data(inst_frequency1), 
    .filter_size(12'd4), 
    .output_clk_enable(), 
    .output_data(inst_frequency1_filtered)
    );
assign inst_frequency1_filtered_small = inst_frequency1_filtered[10-1+2:0];



///////////////////////////////////////////////////////////////////////////////
// Loop filters for DAC 0:
wire pll0_lock, pll0_gain_changedp, pll0_gain_changedi, pll0_gain_changedii, pll0_gain_changedd, pll0_coef_changedd;
wire pll0_gain_changed;
wire [32-1:0] pll0_gainp, pll0_gaini, pll0_gainii, pll0_gaind, pll0_coefdfilter;
wire [15:0] pll0_output;

// Then the registers which controls the gain and locked/unlocked behavior of the filters:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7000)
)
parallel_bus_register_pll0_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_lock), 
    .update_flag()
    );
     
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7001)
)
parallel_bus_register_pll0_gainp (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gainp), 
    .update_flag(pll0_gain_changedp)
    );
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7002)
)
parallel_bus_register_pll0_gaini (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gaini), 
    .update_flag(pll0_gain_changedi)
    );
     
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7003)
)
parallel_bus_register_pll0_gainii (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gainii), 
    .update_flag(pll0_gain_changedii)
    );
     
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7004)
)
parallel_bus_register_pll0_gaind (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gaind), 
    .update_flag(pll0_gain_changedd)
    );
    
    
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(18),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7005)
)
parallel_bus_register_pll0_coefdfilter (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_coefdfilter), 
    .update_flag(pll0_coef_changedd)
    );
     
// This is used for bumpless change of the gain settings (TODO, most probably in the output summing block)
assign pll0_gain_changed = pll0_gain_changedp | pll0_gain_changedi | pll0_gain_changedii | pll0_gain_changedd | pll0_coef_changedd;
     
// Finally the PLL itself:
PLL_loop_filters_with_saturation # (
    .N_DIVIDE_P(24-11),  // changed 2017-05-02 by JDD from 24 to 24-11 to recenter gain for RedPitaya connected to a laser with 8e8 Hz/V of VCO gain and 20 kHz of 1st order cutoff
    .N_DIVIDE_I(24), 
    .N_DIVIDE_II(35),
    .N_DIVIDE_D(0),
    .N_OUTPUT(16)
)
PLL0_loop_filters (
    .clk(clk1), 
    .lock(pll0_lock), 
    .gain_changed(pll0_gain_changed), 
    .data_in(inst_frequency0), 
    .gain_p(pll0_gainp), 
    .gain_i(pll0_gaini), 
    .gain_ii(pll0_gainii),
    .gain_d(pll0_gaind),
    .coef_d_filter(pll0_coefdfilter),
    .phase_residuals(phase_residuals0),
    .data_out(pll0_output),
    .saturated_low(),
    .saturated_high()
    );

///////////////////////////////////////////////////////////////////////////////
// Loop filters for DAC 1:
wire pll1_lock, pll1_gain_changedp, pll1_gain_changedi, pll1_gain_changedii, pll1_gain_changedd, pll1_coef_changedd;
wire pll1_gain_changed;
wire [32-1:0] pll1_gainp, pll1_gaini, pll1_gainii, pll1_gaind, pll1_coefdfilter;
wire [15:0] pll1_output;

// Then the registers which controls the gain and locked/unlocked behavior of the FLL:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7010)
)
parallel_bus_register_pll1_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_lock), 
    .update_flag()
    );
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7011)
)
parallel_bus_register_pll1_gainp (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gainp), 
    .update_flag(pll1_gain_changedp)
    );
     
//  // For debugging: we serialize the value of this register because there seems to be a problem with it (we can't use the full range).
//  serialize_register_value # (
//      .N_BITS_INPUT(32),
//      .WAIT_COUNTER_BITS(23)
//  )
//  serialize_register_value_gainp (
//      .clk(clk1),
//      .register_in(pll1_gainp),
//      .serial_out(DOUT_f[2])
//  );
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7012)
)
parallel_bus_register_pll1_gaini (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gaini), 
    .update_flag(pll1_gain_changedi)
    );
     

     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7013)
)
parallel_bus_register_pll1_gainii (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gainii), 
    .update_flag(pll1_gain_changedii)
    );
     
     
     
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7014)
)
parallel_bus_register_pll1_gaind (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gaind), 
    .update_flag(pll1_gain_changedd)
    );
    
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(18),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7015)
)
parallel_bus_register_pll1_coefdfilter (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_coefdfilter), 
    .update_flag(pll1_coef_changedd)
    );
     
// This is used for bumpless change of the gain settings (TODO, most probably in the output summing block)
assign pll1_gain_changed = pll1_gain_changedp | pll1_gain_changedi | pll1_gain_changedii | pll1_coef_changedd;
     
// Finally the PLL itself:
PLL_loop_filters_with_saturation # (
    .N_DIVIDE_P(11),
    .N_DIVIDE_I(18),
    .N_DIVIDE_II(29),
    .N_DIVIDE_D(0),
    .N_OUTPUT(16)
)
PLL1_loop_filters (
    .clk(clk1), 
    .lock(pll1_lock), 
    .gain_changed(pll1_gain_changed), 
    .data_in(inst_frequency1),              // TODO: Change this for inst_frequency2 when we finally add the second DDC core
    .gain_p(pll1_gainp), 
    .gain_i(pll1_gaini), 
    .gain_ii(pll1_gainii),
    .gain_d(pll1_gaind),
    .coef_d_filter(pll1_coefdfilter),
    .phase_residuals(phase_residuals1),
    .data_out(pll1_output),
    .saturated_low(),
    .saturated_high()
    );


///////////////////////////////////////////////////////////////////////////////
// Loop filters for DAC 2:

///////////////////////////////////////////////////////////////////////////////
// Simple gain-selectable integrators for DAC 2:
///////////////////////////////////////////////////////////////////////////////
// Integrator from the instantenous frequency to the DAC 2 output
wire dac2_integrate_frequency, dac2_integrator1_flipsign, dac2_int1_hold;
wire [4:0] dac2_freq_integrator_gain_left_shift_in_bits, dac2_freq_integrator_gain_right_shift_in_bits;
// Integrator from the DAC 1 output to the DAC 2 output
wire dac2_integrate_dac1_output, dac2_integrator2_flipsign, dac2_int2_hold;
wire [4:0] dac2_dac1_integrator_gain_left_shift_in_bits, dac2_dac1_integrator_gain_right_shift_in_bits;

// The registers which controls the gain and locked/unlocked behavior of the frequency integrator:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(13),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7020)
)
parallel_bus_register_int2_1_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({dac2_int1_hold, dac2_integrator1_flipsign, dac2_integrate_frequency, dac2_freq_integrator_gain_left_shift_in_bits, dac2_freq_integrator_gain_right_shift_in_bits}), 
    .update_flag()
    );
     
// The registers which controls the gain and locked/unlocked behavior of the dac1 output integrator:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(13),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h7021)
)
parallel_bus_register_int2_2_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({dac2_int2_hold, dac2_integrator2_flipsign, dac2_integrate_dac1_output, dac2_dac1_integrator_gain_left_shift_in_bits, dac2_dac1_integrator_gain_right_shift_in_bits}), 
    .update_flag()
    );
     
// Finally the integrators themselves:
wire [17-1:0] dac2_output1, dac2_output2;

// Integrator from the instantenous frequency to the DAC 2 output
// This block is only used to optionaly flip the error sign
wire [11-1:0] inst_frequency1_potentially_flipped;
dac2_error_computation # (
    .N_BITS_DAC1(10)
)
dac2_error_computation_inst (
    .clk(clk1),
    .dac1_minimum(16'b0),       // these put the setpoint at 0
    .dac1_maximum(16'b0),       // these put the setpoint at 0
    .dac1_current(inst_frequency1),
    .flip_error_sign(dac2_integrator1_flipsign),
    .dac1_error(inst_frequency1_potentially_flipped)
);
//
acquisition_FLL # (
    .FREQUENCY_WIDTH(11),
    .OUTPUT_WIDTH(17)
)
acquisition_FLL_dac2_1 (
    .rst(rst_frontend1), 
    .clk(clk1), 
     .hold(dac2_int1_hold),
    .lock(dac2_integrate_frequency), 
    .frequency_input(inst_frequency1_potentially_flipped), 
    .gain_right_shift_in_bits(dac2_freq_integrator_gain_right_shift_in_bits), 
    .gain_left_shift_in_bits(dac2_freq_integrator_gain_left_shift_in_bits), 
    .data_output(dac2_output1), 
    .output_railed()
    );
     
// Integrator from the DAC 1 output to the DAC 2 output
// We first have to generate an error signal which is the offset between the desired dac1 output (half-way between the min and max value) and the current value:
// Even though it's fairly simple, we compute the error in a VHDL module since we are much comfortable doing precise arithmetic and make sure nothing wraps.
wire [17-1:0] dac1_current_error;
dac2_error_computation # (
    .N_BITS_DAC1(16)
)
dac2_error_computation_inst2 (
    .clk(clk1),
    .dac1_minimum(negative_limit_dac1),
    .dac1_maximum(positive_limit_dac1),
    .dac1_current(DACout1),
    .flip_error_sign(dac2_integrator2_flipsign),
    .dac1_error(dac1_current_error)
);

acquisition_FLL # (
    .FREQUENCY_WIDTH(17),   // equal to the number of DAC1 bits + 1 (due to the error computation bit growth)
    .OUTPUT_WIDTH(17)
)
acquisition_FLL_dac2_2 (
    .rst(rst_frontend1), 
    .clk(clk1), 
     .hold(dac2_int2_hold),
    .lock(dac2_integrate_dac1_output), 
    .frequency_input(dac1_current_error), 
    .gain_right_shift_in_bits(dac2_dac1_integrator_gain_right_shift_in_bits), 
    .gain_left_shift_in_bits(dac2_dac1_integrator_gain_left_shift_in_bits), 
    .data_output(dac2_output2), 
    .output_railed()
    );


///////////////////////////////////////////////////////////////////////////////
// Output combiners before sending the results to the DACs:
wire [15:0] manual_offset_dac0, positive_limit_dac0, negative_limit_dac0;
wire dac0_railed_negative, dac0_railed_positive;

wire [15:0] manual_offset_dac1, positive_limit_dac1, negative_limit_dac1;
wire dac1_railed_negative, dac1_railed_positive;

wire [15:0] manual_offset_dac2, positive_limit_dac2, negative_limit_dac2;
wire dac2_railed_negative, dac2_railed_positive;



// DAC0 limits
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE({16'd32767, 16'd0}),
    .ADDRESS(16'h6101)
)
parallel_bus_register_dac0_limits (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({positive_limit_dac0, negative_limit_dac0}), 
    .update_flag()
    );
     
// DAC1 limits
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE({16'd32767, 16'd0}),
    .ADDRESS(16'h6102)
)
parallel_bus_register_dac1_limits (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({positive_limit_dac1, negative_limit_dac1}), 
    .update_flag()
    );

// DAC2 limits, note that DAC2 is 16-bits _unsigned_
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE({16'd65535, 16'd0}),
    .ADDRESS(16'h6103)
)
parallel_bus_register_dac2_limits (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({positive_limit_dac2, negative_limit_dac2}), 
    .update_flag()
    );
     
     
// Register which adds a manual offset to the dac0 output:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h6000)
)
parallel_bus_register_manual_offset_dac0 (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(manual_offset_dac0), 
    .update_flag()
    );

// Register which adds a manual offset to the dac1 output:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h6001)
)
parallel_bus_register_manual_offset_dac1 (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(manual_offset_dac1), 
    .update_flag()
    );
     
// Register which adds a manual offset to the dac2 output:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h6002)
)
parallel_bus_register_manual_offset_dac2 (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(manual_offset_dac2), 
    .update_flag()
    );

// Output summing and limiting, DAC0
output_summing # (
    .INPUT_SIZE       (16),
    .OUTPUT_SIZE      (16)
)
output_summing_dac0
(
    .clk              (  clk1                       ), 
    .in0              (  modulation_output_to_dac0  ), 
    .in1              (                             ), 
    .in2              (  pll0_output                ), 
    .in3              (  manual_offset_dac0         ), 
    .data_output      (  DACout0                    ), 
    .positive_limit   (  positive_limit_dac0        ),
    .negative_limit   (  negative_limit_dac0        ),
    .railed_positive  (  dac0_railed_positive       ),
    .railed_negative  (  dac0_railed_negative       )
    );



// Output summing and limiting, DAC1
wire [16-1:0] data_to_dac1_notch_filter;

output_summing # (
    .INPUT_SIZE       (16),
    .OUTPUT_SIZE      (16)
)
output_summing_dac1
(  
    .clk              (  clk1                       ), 
    .in0              (  modulation_output_to_dac1  ), 
    .in1              (                             ), 
    .in2              (  pll1_output                ), 
    .in3              (  manual_offset_dac1         ), 
    .data_output      (  DACout1                    ), 
    .positive_limit   (  positive_limit_dac1        ),
    .negative_limit   (  negative_limit_dac1        ),
    .railed_positive  (  dac1_railed_positive       ),
    .railed_negative  (  dac1_railed_negative       )
    );

// this is a bit weird since the output_summing module does signed arithmetic, while DAC2 is 16-bits _unsigned_
// thus we do the calculations at 17 bits in this module, then do the signed->unsigned conversion afterwards.
wire [17-1:0] DACout2_17bitssigned;

output_summing # (
    .INPUT_SIZE(17),
    .OUTPUT_SIZE(17)
)
output_summing_dac2 (
    .clk(clk1), 
    // note the sign-extension from 16 bits to 17 bits
    .in0({modulation_output_to_dac2[15], modulation_output_to_dac2}), // Note that the VNA output has been multiplied by 2**4 to enable the highest output amplitude to use the full DAC range.  This multiplication is implemented by bit shifting at the summing block which generates this signal
    .in1({dac2_output1[15], dac2_output1}),     // Integrator from the instantenous frequency to the DAC 2 output
    .in2({dac2_output2[15], dac2_output2}),     // Integrator from the DAC 1 output to the DAC 2 output
    .in3({1'd0, manual_offset_dac2}), // this is already in 16-bits unsigned, so no sign-extension is necessary
    .data_output(DACout2_17bitssigned), // 17 bits signed
    .positive_limit({1'd0, positive_limit_dac2}),  // this is already in 16-bits unsigned, so no sign-extension is necessary
    .negative_limit({1'd0, negative_limit_dac2}),  // this is already in 16-bits unsigned, so no sign-extension is necessary
    .railed_positive(dac2_railed_positive),
    .railed_negative(dac2_railed_negative)
    );
     
    // convert from 17-bits signed to 16-bits unsigned.
    // the 17-bits values only use the positive range
    assign DACout2 = DACout2_17bitssigned[15:0];
    //assign DACout2 = positive_limit_dac2;//manual_offset_dac2;

///////////////////////////////////////////////////////////////////////////////
// Vector Network Analyzer (VNA) which performs transfer function measurements
// Also includes its own input and output multiplexers
///////////////////////////////////////////////////////////////////////////////
wire [15:0] vna_output_to_dac0, vna_output_to_dac1, vna_output_to_dac2;
wire trigger_identification;
wire [15:0] VNA_output_to_logger;
wire VNA_output_to_logger_clk_enable;

//assign trigger_identification = TrigIn40[2];


system_identification_vna_with_dither_wrapper system_identification_vna_inst (
    .rst(rst_frontend0), 
    .clk(clk1), 
    // Cmd bus to program the different variables, addresses start at 0x5000 up to 0x5005
    .cmd_addr(cmd_addr), 
    .cmd_data1(cmd_data1in), 
    .cmd_data2(cmd_data2in), 
    .cmd_trig(cmd_trig), 

    // -- A rising edge here triggers the identification process
    .trigger_identification(trigger_identification), 

    // -- Data inputs from the output of the systems to be identified
    .data_in1(ADCraw0),
    .data_in2(ADCraw1), 
    .data_in3({{6{inst_frequency0[9]}}, inst_frequency0}),  // the output of the DDC, sign-extended to 16 bits
    .data_in4({{6{inst_frequency1[9]}}, inst_frequency1}),

    // -- Modulation outputs to dacs
    .modulation_output_to_dac0(vna_output_to_dac0), 
    .modulation_output_to_dac1(vna_output_to_dac1), 
    .modulation_output_to_dac2(vna_output_to_dac2),

    // -- Output port which goes to the data logger which contains the identification results
    .output_to_logger(VNA_output_to_logger), 
    .output_to_logger_clk_enable(VNA_output_to_logger_clk_enable)
    );
     

///////////////////////////////////////////////////////////////////////////////
// Dither generator + lock-in, which serves to measure the DC gain and sign of the loop
///////////////////////////////////////////////////////////////////////////////
wire            [15:0]              dither_output_to_dac0, dither_output_to_dac1;
wire            [19:0]              dither_output_to_dac2;
wire signed     [16*3-1:0]          dither0_lockin_output_to_wires, dither1_lockin_output_to_wires, dither2_lockin_output_to_wires;
wire                                dither0_lockin_output_clk_enable, dither1_lockin_output_clk_enable, dither2_lockin_output_clk_enable;

dither_lockin_wrapper #
(
    .BASE_ADDRESS(16'h8100),
    .CMD_BUS_BITS(16),
    .N_BITS_INPUT(10),
    .N_BITS_OUTPUT(16),
    .COUNTER_BITS(27),              // 27 bits gives ~ 134 Millions clock cycles, or 1.34 seconds at 100 MHz clock rate
    .SYNC_DELAY(60),                    // should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
    .INTEGRATORS_BITS(16*3) // should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
            // but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
            // initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
            // so we'll go for 3 Wires, or a total of 48 bits for each integrator.
) dither_lockin_wrapper0 (
    .clk                 (  clk1  ),
    .data_input          (  inst_frequency0  ),

    .cmd_trig            (  cmd_trig  ),
    .cmd_addr            (  cmd_addr  ),
    .cmd_data1           (  cmd_data1in  ),
    .cmd_data2           (  cmd_data2in  ),

    .output_to_dac       (  dither_output_to_dac0  ),
    .results_output_I    (  dither0_lockin_output_to_wires  ),
    .results_output_Q    (                                  ),
    .output_clk_enable   (  dither0_lockin_output_clk_enable  )
);

dither_lockin_wrapper #
(
    .BASE_ADDRESS(16'h8200),
    .CMD_BUS_BITS(16),
    .N_BITS_INPUT(10),
    .N_BITS_OUTPUT(16),
    .COUNTER_BITS(27),              // 27 bits gives ~ 134 Millions clock cycles, or 1.34 seconds at 100 MHz clock rate
    .SYNC_DELAY(60),                    // should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
    .INTEGRATORS_BITS(16*3) // should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
            // but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
            // initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
            // so we'll go for 3 Wires, or a total of 48 bits for each integrator.
) dither_lockin_wrapper1 (
    .clk                 (  clk1  ),
    .data_input          (  inst_frequency1  ),

    .cmd_trig            (  cmd_trig  ),
    .cmd_addr            (  cmd_addr  ),
    .cmd_data1           (  cmd_data1in  ),
    .cmd_data2           (  cmd_data2in  ),

    .output_to_dac       (  dither_output_to_dac1  ),
    .results_output_I    (  dither1_lockin_output_to_wires  ),
    .results_output_Q    (                                  ),
    .output_clk_enable   (  dither1_lockin_output_clk_enable  )
);

// for debug: output a fixed value:
//assign dither_lockin_output_to_wires = {48'b110000000000000000000000000000000000000000000001, 48'b001101100000000000000000000000000000000000001110};

///////////////////////////////////////////////////////////////////////////////
// Sums the output of the VNA and the dither modules
///////////////////////////////////////////////////////////////////////////////
wire            [15:0]              modulation_output_to_dac0, modulation_output_to_dac1;
wire            [15:0]              modulation_output_to_dac2;

output_summing # (
    .INPUT_SIZE(16),
    .OUTPUT_SIZE(16)
)
output_summing_dac0_auxilary (
    .clk(clk1), 
    .in0(dither_output_to_dac0), 
    .in1(vna_output_to_dac0), 
    .in2(), 
    .in3(), 
    .data_output(modulation_output_to_dac0), 
     .positive_limit($signed(2**15-1)),
     .negative_limit($signed(-2**15)),
    .railed_positive(), //dac0_railed_positive
    .railed_negative()  //dac0_railed_negative
    );
     
output_summing # (
    .INPUT_SIZE(16),
    .OUTPUT_SIZE(16)
)
output_summing_dac1_auxilary (
    .clk(clk1), 
    .in0(dither_output_to_dac1), 
    .in1(vna_output_to_dac1), 
    .in2(), 
    .in3(), 
    .data_output(modulation_output_to_dac1), 
     .positive_limit($signed(2**15-1)),
     .negative_limit($signed(-2**15)),
    .railed_positive(), //dac0_railed_positive
    .railed_negative()  //dac0_railed_negative
    );
     
//// for now: just pass through the vna outputs:
//assign modulation_output_to_dac1 = vna_output_to_dac1;
assign modulation_output_to_dac2 = vna_output_to_dac2;  // we didn't bother adding dither to DAC2.


// ///////////////////////////////////////////////////////////////////////////////
// // Lock residuals streaming
// ///////////////////////////////////////////////////////////////////////////////
// // Uses a trigger input (DIN[2]), has a programmable delay on the trigger.
// // has a programmable length lowpass filter (max 31 samples) on the phase inputs.
// // the phase input is 32 bits, bit only the 27 LSBs are used (which shouldn't matter when the lock is on, because the residuals are way lower than the wrapping limit of that number).
// wire [32-1:0]   residuals_streaming_data1, residuals_streaming_data2;
// wire                residuals_streaming_write1, residuals_streaming_write2;
// wire                residuals_trigger_input;
// // programmable registers
// wire                rst_residuals_streaming;
// wire [5-1:0]    residuals_boxcar_filter_size;
// wire [10-1:0]   residuals_trigger_delay;
// wire [8-1:0]    residuals_data_delay;

// assign residuals_trigger_input = DIN[2];
// //assign DOUT[1] = residuals_streaming_write1;

// parallel_bus_register_32bits_or_less # (
//     .REGISTER_SIZE(24),
//     .REGISTER_DEFAULT_VALUE(12'b0),
//     .ADDRESS(16'h8502)
// )
// parallel_bus_register_residuals_streaming (
//     .clk(clk1), 
//     .bus_strobe(cmd_trig), 
//     .bus_address(cmd_addr), 
//     .bus_data({cmd_data2in, cmd_data1in}), 
//     .register_output({residuals_data_delay, residuals_trigger_delay, residuals_boxcar_filter_size, rst_residuals_streaming}), 
//     .update_flag()
//     );

// residuals_streaming # (
//     .N_BITS_DATA(32),
//     .N_SAMPLES_HOLDOFF(3333)    // set at 100e6/3e3 * 0.1, which means 10 % of the nominal IGM period
// ) residuals_streaming1 (
//     .clk(clk1), 
//     .rst(rst_residuals_streaming), 
//     .trigger_input(residuals_trigger_input), 
//     .trigger_delay({22'd0, residuals_trigger_delay}), 
//      .data_delay(residuals_data_delay),
//     .boxcar_filter_size(residuals_boxcar_filter_size), 
//     .phase_residuals(phase_residuals0), 
//      .select_phase_or_freq(select_phase_or_freq0),
//      .freq_residuals(inst_frequency0),
//     .data_output_to_fifo(residuals_streaming_data1), 
//     .output_clk_enable(residuals_streaming_write1)
//     );
     
// residuals_streaming # (
//     .N_BITS_DATA(32),
//     .N_SAMPLES_HOLDOFF(3333)    // set at 100e6/3e3 * 0.1, which means 10 % of the nominal IGM period
// ) residuals_streaming2 (
//     .clk(clk1), 
//     .rst(rst_residuals_streaming), 
//     .trigger_input(residuals_trigger_input), 
//     .trigger_delay({22'd0, residuals_trigger_delay}), 
//      .data_delay(residuals_data_delay),
//     .boxcar_filter_size(residuals_boxcar_filter_size), 
//     .phase_residuals(phase_residuals1), 
// //   .phase_residuals(32'd10), 
//      .select_phase_or_freq(select_phase_or_freq1),
//      .freq_residuals(inst_frequency1),
     
//     .data_output_to_fifo(residuals_streaming_data2),  // For debugging: put a constant value in data2:
// //   .data_output_to_fifo(), 
//     .output_clk_enable(residuals_streaming_write2)
//     );

//     // For debugging: put a constant value in data2:
// //  assign residuals_streaming_data2 = 32'hABCD_1234;



///////////////////////////////////////////////////////////////////////////////
// Opal Kelly interface
///////////////////////////////////////////////////////////////////////////////


reg [32-1:0]    zdtc_samples_number_counter;
wire [32-1:0]   status_flags;
// two legacy flags that made sense when the counters were sent to a fifo... should be removed eventually
wire            counter0_fifo_has_too_little_samples;   // Frequency counter 0 (1 Hz writes)
wire            counter1_fifo_has_too_little_samples;   // Frequency counter 1 (1 Hz writes)


always @(posedge clk1) begin
    zdtc_samples_number_counter <= (counter0_out_clk_enable_faster == 1'b1 ? zdtc_samples_number_counter + 1'b1 : zdtc_samples_number_counter);
    // slow_pipe_dac_data <= {zdtc_samples_number_counter[11:0], DACout[2][SIGNAL_SIZE-1:SIGNAL_SIZE-20], DACout1[SIGNAL_SIZE-1:SIGNAL_SIZE-16], DACout0[SIGNAL_SIZE-1:SIGNAL_SIZE-16]};
//  slow_pipe_data_in1 <= {DACout[2][SIGNAL_SIZE-1:SIGNAL_SIZE-9], DACout1[SIGNAL_SIZE-1:SIGNAL_SIZE-16], counter1_out};
    // fifo_dac_write_enable <= counter0_out_clk_enable_faster;
end

assign status_flags[0]  = counter0_fifo_has_too_little_samples;
assign status_flags[1]  = counter1_fifo_has_too_little_samples;
assign status_flags[2]  = 1'b0; // PipeOutA1Empty;
assign status_flags[3]  = 1'b0; // crash_monitor_has_data;
assign status_flags[4]  = LED_G0;
assign status_flags[5]  = LED_R0;
assign status_flags[6]  = LED_G1;
assign status_flags[7]  = LED_R1;
assign status_flags[8]  = 1'b0; // LED_G[2]
assign status_flags[9]  = 1'b0; // LED_R[2]
assign status_flags[10] = 1'b0; // residuals_ceo_fifo_has_too_little_samples;
assign status_flags[11] = 1'b0; // residuals_optical_fifo_has_too_little_samples;
assign status_flags[31:12] = 20'b0;


// this module implements all of the register/status readout to the Zynq
registers_read registers_read_inst
(
    .clk(clk1),
    

    // Registers inputs (to be read)
    .status_flags(status_flags),
    // these get sampled internally together even though they go through multiple reads by the CPU
    .dither0_lockin_output({  {16{dither0_lockin_output_to_wires[47]}} , dither0_lockin_output_to_wires}),  // manual sign extension from 48 to 64 bits
    // these get sampled internally together even though they go through multiple reads by the CPU
    .dither1_lockin_output({  {16{dither1_lockin_output_to_wires[47]}} , dither1_lockin_output_to_wires}),  // manual sign extension from 48 to 64 bits

    // these get sampled internally together even though they go through multiple reads by the CPU
    .zdtc_samples_number_counter(zdtc_samples_number_counter),
    .counter0_out(counter0_out),
    .counter1_out(counter1_out),
    .DAC0_out({  {16{DACout0[15]}} , DACout0}),   // manual sign extension from 16 to 32 bits
    .DAC1_out({  {16{DACout1[15]}} , DACout1}),
    .DAC2_out({  {16{DACout2[15]}} , DACout2}),


    // internal configuration bus
    .sys_addr        (  { 2'b0, sys_addr[32-1:2]}      ),  // address, note the divide by 4 again to map between zynq addresses and the legacy DPLL addresses
    .sys_wdata       (  sys_wdata                      ),  // write data
    .sys_sel         (  sys_sel                        ),  // write byte select
    .sys_wen         (  sys_wen                        ),  // write enable
    .sys_ren         (  sys_ren                        ),  // read enable
    .sys_rdata       (  sys_rdata                      ),  // read data
    .sys_err         (  sys_err                        ),  // error indicator
    .sys_ack         (  sys_ack                        )   // acknowledge signal

);






// okWireOut   ep25 (.ok1(ok1), .ok2(ok2x[ 5*17 +: 17 ]), .ep_addr(8'h25), .ep_datain(WireOut25StatusFlags));  // ENDPOINT_STATUS_FLAGS_OUT, needs to be ported to a register read
// okTriggerIn ep40 (.ok1(ok1),                           .ep_addr(8'h40), .ep_clk(clk1), .ep_trigger(TrigIn40));  // ENDPOINT_CMD_TRIG, this is also important, needs to be ported to a 'trigger' register



// // FIFO and pipe out for reading data from the RAM
// wire             PipeOutA1Read, PipeOutA1Empty;
// wire [15:0]      PipeOutA1DataOut;
// fifo_w64_512_r16_2048 okPipeOut_fifo (
//     .rst(PipeOutA1Reset | external_fifo_reset),
//     .wr_clk(PipeOutA1WriteClock),
//     .wr_en(PipeOutA1Write),
//     .din(PipeOutA1DataIn), // Bus [63 : 0] 
//     .rd_clk(ti_clk),
//     .rd_en(PipeOutA1Read),
//     .dout(PipeOutA1DataOut), // Bus [15 : 0] 
//     .empty(PipeOutA1Empty),
//     .wr_data_count(PipeOutA1Count) // Bus [8 : 0]
// ); 
// okPipeOut epA1 (.ok1(ok1), .ok2(ok2x[ 7*17 +: 17 ]), .ep_addr(8'hA1), .ep_read(PipeOutA1Read),   .ep_datain(PipeOutA1DataOut));






// // Frequency counter 0 (1 Hz writes)
// wire            PipeOutA2Read;
// wire [15:0]     PipeOutA2DataOut;

// // Frequency counter 1 (1 Hz writes)
// wire            PipeOutA3Read;
// wire [15:0]     PipeOutA3DataOut;


// // Slow DACs monitoring FIFO (10 Hz writes, locked with counter 0 and counter 1)
// wire            PipeOutA4Read;
// wire [15:0]     PipeOutA4DataOut;








// Current bit assignments for pipe at address 0xA2:
// 64 bits: counter_out0

// Current bit assignments for pipe at address 0xA3:
// 64 bits: counter_out1

// Current bit assignments for pipe at address 0xA4:
// 16 bits: DAC0 value
// 16 bits: DAC1 value
// 20 bits: DAC1 value
// 12 bits: zdtc_samples_number_counter (modulo 2**12)
// reg [64-1:0]        slow_pipe_dac_data;
// reg fifo_dac_write_enable;




// fifo_pipeout_counter fifo_pipeout_counter0_inst (
//   .rst(rst_frontend0), // input rst
//   .wr_clk(clk1), // input wr_clk
//   .rd_clk(ti_clk), // input rd_clk
//   .din(counter0_out), // Currently: 64 bits data per sample.
//   .wr_en(counter0_out_clk_enable), // input wr_en
//   .rd_en(PipeOutA2Read), // input rd_en
//   .dout(PipeOutA2DataOut), // output [63 : 0] dout
//   .full(), // output full
//   .empty(), // output empty
//   .prog_empty(counter0_fifo_has_too_little_samples) // output prog_empty
// );

// fifo_pipeout_counter fifo_pipeout_counter1_inst (
//   .rst(rst_frontend1), // input rst
//   .wr_clk(clk1), // input wr_clk
//   .rd_clk(ti_clk), // input rd_clk
//   .din(counter1_out), // Currently: 64 bits data per sample.
//   .wr_en(counter1_out_clk_enable), // input wr_en
//   .rd_en(PipeOutA3Read), // input rd_en
//   .dout(PipeOutA3DataOut), // output [63 : 0] dout
//   .full(), // output full
//   .empty(), // output empty
//   .prog_empty(counter1_fifo_has_too_little_samples) // output prog_empty
// );

// fifo_pipeout_counter fifo_pipeout_dacs_inst (
//   .rst(rst_frontend1), // input rst
//   .wr_clk(clk1), // input wr_clk
//   .rd_clk(ti_clk), // input rd_clk
//   .din(slow_pipe_dac_data), // Currently: 64 bits data per sample.
//   .wr_en(fifo_dac_write_enable), // input wr_en
//   .rd_en(PipeOutA4Read), // input rd_en
//   .dout(PipeOutA4DataOut), // output [63 : 0] dout
//   .full(), // output full
//   .empty(), // output empty
//   .prog_empty() // output prog_empty
// );



// okPipeOut epA2 (.ok1(ok1), .ok2(ok2x[ 8*17 +: 17 ]), .ep_addr(8'hA2), .ep_read(PipeOutA2Read),   .ep_datain(PipeOutA2DataOut)); // Frequency counter 0 (1 Hz writes)
// okPipeOut epA3 (.ok1(ok1), .ok2(ok2x[ 9*17 +: 17 ]), .ep_addr(8'hA3), .ep_read(PipeOutA3Read),   .ep_datain(PipeOutA3DataOut)); // Frequency counter 1 (1 Hz writes)

// okPipeOut epA4 (.ok1(ok1), .ok2(ok2x[ 13*17 +: 17 ]), .ep_addr(8'hA4), .ep_read(PipeOutA4Read),   .ep_datain(PipeOutA4DataOut));    // Slow DAC monitors
// // okPipeOut epA5 (.ok1(ok1), .ok2(ok2x[ 14*17 +: 17 ]), .ep_addr(8'hA5), .ep_read(PipeOutA5Read),   .ep_datain(PipeOutA5DataOut)); // CEO residuals monitor
// // okPipeOut epA6 (.ok1(ok1), .ok2(ok2x[ 15*17 +: 17 ]), .ep_addr(8'hA6), .ep_read(PipeOutA6Read),   .ep_datain(PipeOutA6DataOut)); // Optical residuals monitor



// // DAC0 dither lock-in wires outputs
// // I integrator results
// okWireOut   ep26 (.ok1(ok1), .ok2(ok2x[ 10*17 +: 17 ]), .ep_addr(8'h26), .ep_datain(dither0_lockin_output_to_wires[ 0*16 +: 16 ]));
// okWireOut   ep27 (.ok1(ok1), .ok2(ok2x[ 11*17 +: 17 ]), .ep_addr(8'h27), .ep_datain(dither0_lockin_output_to_wires[ 1*16 +: 16 ]));
// okWireOut   ep28 (.ok1(ok1), .ok2(ok2x[ 12*17 +: 17 ]), .ep_addr(8'h28), .ep_datain(dither0_lockin_output_to_wires[ 2*16 +: 16 ]));


// // DAC1 dither lock-in wires outputs
// // I integrator results
// okWireOut   ep29 (.ok1(ok1), .ok2(ok2x[ 16*17 +: 17 ]), .ep_addr(8'h29), .ep_datain(dither1_lockin_output_to_wires[ 0*16 +: 16 ]));
// okWireOut   ep2a (.ok1(ok1), .ok2(ok2x[ 17*17 +: 17 ]), .ep_addr(8'h2a), .ep_datain(dither1_lockin_output_to_wires[ 1*16 +: 16 ]));
// okWireOut   ep2b (.ok1(ok1), .ok2(ok2x[ 18*17 +: 17 ]), .ep_addr(8'h2b), .ep_datain(dither1_lockin_output_to_wires[ 2*16 +: 16 ]));





// Dead code:
//////////////////////////////////////////////////////////////////////////////




// wire            ti_clk;

// wire [30:0]     ok1;
// wire [16:0]     ok2;
// wire [17*(23)-1:0] ok2x;             // Change this to [17*N_OUTPUTS-10:0] when changing the number of output modules! Note that this also includes the pipes output.
// okWireOR # (.N(23)) wireOR (.ok2(ok2), .ok2s(ok2x)); // Change this to .N(N_OUTPUTS) when changing the number of output modules!

// okHost okHI(
//  .hi_in(hi_in),
//  .hi_out(hi_out),
//  .hi_inout(hi_inout),
//  .hi_aa(hi_aa),
//  .ti_clk(ti_clk),
//  .ok1(ok1),
//  .ok2(ok2)
// );

// These were not used (or the ones that were, were not necessary)
// okWireIn    ep00 (.ok1(ok1),                           .ep_addr(8'h00), .ep_dataout(WireIn00));  // assign cmd_addr = WireIn00[15:0];
// okWireIn    ep01 (.ok1(ok1),                           .ep_addr(8'h01), .ep_dataout(WireIn01));  // assign cmd_data1in = WireIn01;
// okWireIn    ep02 (.ok1(ok1),                           .ep_addr(8'h02), .ep_dataout(WireIn02));  // assign cmd_data2in = WireIn02;
// okWireIn    ep03 (.ok1(ok1),                           .ep_addr(8'h03), .ep_dataout(WireIn03));  // assign selector = WireIn03;
// okWireIn    ep04 (.ok1(ok1),                           .ep_addr(8'h04), .ep_dataout(WireIn04_Clock_source_select));

// // 2015-01-27: Modification by Hugo Bergeron: added wire for resetting fifo
// okWireIn    ep05 (.ok1(ok1),                           .ep_addr(8'h05), .ep_dataout(WireIn05_fifo_reset));


// okWireOut   ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(WireOut20));  // WireOut20 = cmd_dataout_M25P32_CONFIG;
// okWireOut   ep21 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(WireOut21));  // WireOut21 = cmd_dataout_AD9783;
// okWireOut   ep22 (.ok1(ok1), .ok2(ok2x[ 2*17 +: 17 ]), .ep_addr(8'h22), .ep_datain(WireOut22));  // WireOut22 = cmd_dataout_LTC2195_0;
// okWireOut   ep23 (.ok1(ok1), .ok2(ok2x[ 3*17 +: 17 ]), .ep_addr(8'h23), .ep_datain(WireOut23));  // WireOut23 = cmd_dataout_LTC2195_1;
// okWireOut   ep24 (.ok1(ok1), .ok2(ok2x[ 4*17 +: 17 ]), .ep_addr(8'h24), .ep_datain(WireOut24));  // WireOut24 = cmd_dataout_LTC2195_2;




// // CEO residuals fifo (writes @ Delta_Fr when activated - nominally 3 kHz)
// wire             PipeOutA5Read;
// wire [15:0]      PipeOutA5DataOut;
// wire             residuals_ceo_fifo_has_too_little_samples;

// // Optical residuals fifo (writes @ Delta_Fr when activated - nominally 3 kHz)
// wire             PipeOutA6Read;
// wire [15:0]      PipeOutA6DataOut;
// wire         residuals_optical_fifo_has_too_little_samples;


// fifo_pipeout_residuals fifo_pipeout_CEO_residuals (
//   .rst(rst_residuals_streaming), // input rst
//   .wr_clk(clk1), // input wr_clk
//   .rd_clk(ti_clk), // input rd_clk
//   .din(residuals_streaming_data1), // input [31 : 0] din
//   .wr_en(residuals_streaming_write1), // input wr_en
//   .rd_en(PipeOutA5Read), // input rd_en
//   .dout(PipeOutA5DataOut), // output [15 : 0] dout
//   .full(), // output full
//   .empty(), // output empty
//   .prog_empty(residuals_ceo_fifo_has_too_little_samples) // output prog_empty
// );

// // Prog Empty flag goes high when there are less than 2000
// // words on the read side of the FIFO.
// // This means that at 3 kHz IGM rate, the input rate is 3 kHz * 2 words/write = 6 kWords/sec on the output.
// // the prog_empty flag will thus go low after 2000 words/(6kWords/sec) = 0.3 sec worth of data on the input
// // This fifo holds 4095 input samples, or 8192 output samples, so 1.36 seconds worth of data.
// fifo_pipeout_residuals fifo_pipeout_optical_residuals (
//   .rst(rst_residuals_streaming), // input rst
//   .wr_clk(clk1), // input wr_clk
//   .rd_clk(ti_clk), // input rd_clk
//   .din(residuals_streaming_data2), // input [31 : 0] din
//   .wr_en(residuals_streaming_write2), // input wr_en
//   .rd_en(PipeOutA6Read), // input rd_en
//   .dout(PipeOutA6DataOut), // output [15 : 0] dout
//   .full(), // output full
//   .empty(), // output empty
//   .prog_empty(residuals_optical_fifo_has_too_little_samples) // output prog_empty
// );




// // DAC2 dither lock-in wires outputs
// // I integrator results
// okWireOut   ep2c (.ok1(ok1), .ok2(ok2x[ 19*17 +: 17 ]), .ep_addr(8'h2c), .ep_datain(dither2_lockin_output_to_wires[ 0*16 +: 16 ]));
// okWireOut   ep2d (.ok1(ok1), .ok2(ok2x[ 20*17 +: 17 ]), .ep_addr(8'h2d), .ep_datain(dither2_lockin_output_to_wires[ 1*16 +: 16 ]));
// okWireOut   ep2e (.ok1(ok1), .ok2(ok2x[ 21*17 +: 17 ]), .ep_addr(8'h2e), .ep_datain(dither2_lockin_output_to_wires[ 2*16 +: 16 ]));


// wire [15:0] WireOut2fDebugging;
// assign WireOut2fDebugging = {8'b11111111, residuals_data_delay};

// okWireOut   ep2f (.ok1(ok1), .ok2(ok2x[ 22*17 +: 17 ]), .ep_addr(8'h2f), .ep_datain(WireOut2fDebugging));


//// DAC0 Q integrator results
//okWireOut   ep29 (.ok1(ok1), .ok2(ok2x[ 13*17 +: 17 ]), .ep_addr(8'h29), .ep_datain(dither0_lockin_output_to_wires[ 3*16 +: 16 ]));
//okWireOut   ep2a (.ok1(ok1), .ok2(ok2x[ 14*17 +: 17 ]), .ep_addr(8'h2a), .ep_datain(dither0_lockin_output_to_wires[ 4*16 +: 16 ]));
//okWireOut   ep2b (.ok1(ok1), .ok2(ok2x[ 15*17 +: 17 ]), .ep_addr(8'h2b), .ep_datain(dither0_lockin_output_to_wires[ 5*16 +: 16 ]));
//// DAC1 Q integrator results
//okWireOut   ep2f (.ok1(ok1), .ok2(ok2x[ 19*17 +: 17 ]), .ep_addr(8'h2f), .ep_datain(dither1_lockin_output_to_wires[ 3*16 +: 16 ]));
//okWireOut   ep30 (.ok1(ok1), .ok2(ok2x[ 20*17 +: 17 ]), .ep_addr(8'h30), .ep_datain(dither1_lockin_output_to_wires[ 4*16 +: 16 ]));
//okWireOut   ep31 (.ok1(ok1), .ok2(ok2x[ 21*17 +: 17 ]), .ep_addr(8'h31), .ep_datain(dither1_lockin_output_to_wires[ 5*16 +: 16 ]));
//// DAC2 Q integrator results
//okWireOut   ep35 (.ok1(ok1), .ok2(ok2x[ 25*17 +: 17 ]), .ep_addr(8'h35), .ep_datain(dither2_lockin_output_to_wires[ 3*16 +: 16 ]));
//okWireOut   ep36 (.ok1(ok1), .ok2(ok2x[ 26*17 +: 17 ]), .ep_addr(8'h36), .ep_datain(dither2_lockin_output_to_wires[ 4*16 +: 16 ]));
//okWireOut   ep37 (.ok1(ok1), .ok2(ok2x[ 27*17 +: 17 ]), .ep_addr(8'h37), .ep_datain(dither2_lockin_output_to_wires[ 5*16 +: 16 ]));

endmodule
