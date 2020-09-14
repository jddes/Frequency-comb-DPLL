/**
 * $Id: red_pitaya_top.v 1271 2014-02-25 12:32:34Z matej.oblak $
 *
 * @brief Red Pitaya TOP module. It connects external pins and PS part with 
 *        other application modules. 
 *
 * @Author Matej Oblak
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */


/**
 * GENERAL DESCRIPTION:
 *
 * Top module connects PS part with rest of Red Pitaya applications.  
 *
 *
 *                   /-------\      
 *   PS DDR <------> |  PS   |      AXI <-> custom bus
 *   PS MIO <------> |   /   | <------------+
 *   PS CLK -------> |  ARM  |              |
 *                   \-------/              |
 *                                          |
 *                            /-------\     |
 *                         -> | SCOPE | <---+
 *                         |  \-------/     |
 *                         |                |
 *            /--------\   |   /-----\      |
 *   ADC ---> |        | --+-> |     |      |
 *            | ANALOG |       | PID | <----+
 *   DAC <--- |        | <---- |     |      |
 *            \--------/   ^   \-----/      |
 *                         |                |
 *                         |  /-------\     |
 *                         -- |  ASG  | <---+ 
 *                            \-------/     |
 *                                          |
 *             /--------\                   |
 *    RX ----> |        |                   |
 *   SATA      | DAISY  | <-----------------+
 *    TX <---- |        | 
 *             \--------/ 
 *               |    |
 *               |    |
 *               (FREE)
 *
 *
 * Inside analog module, ADC data is translated from unsigned neg-slope into
 * two's complement. Similar is done on DAC data.
 *
 * Scope module stores data from ADC into RAM, arbitrary signal generator (ASG)
 * sends data from RAM to DAC. MIMO PID uses ADC ADC as input and DAC as its output.
 *
 * Daisy chain connects with other boards with fast serial link. Data which is
 * send and received is at the moment undefined. This is left for the user.
 * 
 */

module red_pitaya_top (
   // PS connections
   inout  wire  [54-1: 0] FIXED_IO_mio       ,
   inout  wire            FIXED_IO_ps_clk    ,
   inout  wire            FIXED_IO_ps_porb   ,
   inout  wire            FIXED_IO_ps_srstb  ,
   inout  wire            FIXED_IO_ddr_vrn   ,
   inout  wire            FIXED_IO_ddr_vrp   ,
   // DDR
   inout  wire  [15-1: 0] DDR_addr           ,
   inout  wire  [ 3-1: 0] DDR_ba             ,
   inout  wire            DDR_cas_n          ,
   inout  wire            DDR_ck_n           ,
   inout  wire            DDR_ck_p           ,
   inout  wire            DDR_cke            ,
   inout  wire            DDR_cs_n           ,
   inout  wire  [ 4-1: 0] DDR_dm             ,
   inout  wire  [32-1: 0] DDR_dq             ,
   inout  wire  [ 4-1: 0] DDR_dqs_n          ,
   inout  wire  [ 4-1: 0] DDR_dqs_p          ,
   inout  wire            DDR_odt            ,
   inout  wire            DDR_ras_n          ,
   inout  wire            DDR_reset_n        ,
   inout  wire            DDR_we_n           ,

   // Red Pitaya periphery
  
   // ADC
   input  wire  [16-1: 2] adc_dat_a_i        ,  // ADC CH1
   input  wire  [16-1: 2] adc_dat_b_i        ,  // ADC CH2
   input  wire            adc_clk_p_i        ,  // ADC data clock
   input  wire            adc_clk_n_i        ,  // ADC data clock
   output wire  [ 2-1: 0] adc_clk_o          ,  // optional ADC clock source
   output wire            adc_cdcs_o         ,  // ADC clock duty cycle stabilizer
   // DAC
   output wire  [14-1: 0] dac_dat_o          ,  // DAC combined data
   output wire            dac_wrt_o          ,  // DAC write
   output wire            dac_sel_o          ,  // DAC channel select
   output wire            dac_clk_o          ,  // DAC clock
   output wire            dac_rst_o          ,  // DAC reset
   // PWM DAC
   output wire  [ 4-1: 0] dac_pwm_o          ,  // serial PWM DAC
   // XADC
   input  wire  [ 5-1: 0] vinp_i             ,  // voltages p
   input  wire  [ 5-1: 0] vinn_i             ,  // voltages n
   // Expansion connector
   output wire            DIO0_P           ,
   output wire            DIO0_N           ,
   output wire            DIO1_P           ,
   output wire            DIO1_N           ,
   output wire            DIO2_P           ,
   output wire            DIO2_N           ,
   output wire            DIO3_P           ,
   output wire            DIO3_N           ,
   output wire            DIO4_P           ,
   output wire            DIO4_N           ,
   input  wire            DIO5_P           ,
   input  wire            DIO5_N           ,
   output wire            DIO6_P           ,
   output wire            DIO6_N           ,
   output wire            DIO7_P           ,
   output wire            DIO7_N           ,

   // SATA connector
   output wire  [ 2-1: 0] daisy_p_o          ,  // line 1 is clock capable
   output wire  [ 2-1: 0] daisy_n_o          ,
   input  wire  [ 2-1: 0] daisy_p_i          ,  // line 1 is clock capable
   input  wire  [ 2-1: 0] daisy_n_i          ,
   // LED
   output wire  [ 8-1: 0] led_o       
);

//---------------------------------------------------------------------------------
//
//  Connections to PS

wire  [  4-1: 0] fclk               ; //[0]-125MHz, [1]-250MHz, [2]-50MHz, [3]-200MHz
wire  [  4-1: 0] frstn              ;

wire             ps_sys_clk         ;
wire             ps_sys_rstn        ;
wire  [ 32-1: 0] ps_sys_addr        ;
wire  [ 32-1: 0] ps_sys_wdata       ;
wire  [  4-1: 0] ps_sys_sel         ;
wire             ps_sys_wen         ;
wire             ps_sys_ren         ;
wire  [ 32-1: 0] ps_sys_rdata       ;
wire             ps_sys_err         ;
wire             ps_sys_ack         ;

// AXI masters
wire             axi1_clk    , axi0_clk    ;
wire             axi1_rstn   , axi0_rstn   ;
wire  [ 32-1: 0] axi1_waddr  , axi0_waddr  ;
wire  [ 64-1: 0] axi1_wdata  , axi0_wdata  ;
wire  [  8-1: 0] axi1_wsel   , axi0_wsel   ;
wire             axi1_wvalid , axi0_wvalid ;
wire  [  4-1: 0] axi1_wlen   , axi0_wlen   ;
wire             axi1_wfixed , axi0_wfixed ;
wire             axi1_werr   , axi0_werr   ;
wire             axi1_wrdy   , axi0_wrdy   ;

wire rd_do_t;
wire wr_do_t;
wire ack_timout_t;
wire ack_combine_t;

wire [2:0] gpio_io_o;
wire ps_gpio_rst;
wire clk_int_or_ext_desired;
wire clk_int_or_ext_actual;
wire [10-1:0] to_uart;

// frequency counter on the external clock input
wire clk_ext_bufg;
wire [32-1:0] reg_to_axi1;
wire [32-1:0] reg_to_axi2;
wire [32-1:0] reg_to_axi3;

assign clk_int_or_ext_desired = gpio_io_o[0];
assign ps_gpio_rst    = gpio_io_o[1];

// these settings should be good enough to detect presence of a 10 MHz clock, at 125 MHz stable clk rate
wire [16-1:0] minimum_cycles_of_clk_under_test = 16'd1;
wire [16-1:0] cycles_of_clk_stable = 16'd80;
wire clk_ext_good;


red_pitaya_ps i_ps (
  .FIXED_IO_mio       (  FIXED_IO_mio                ),
  .FIXED_IO_ps_clk    (  FIXED_IO_ps_clk             ),
  .FIXED_IO_ps_porb   (  FIXED_IO_ps_porb            ),
  .FIXED_IO_ps_srstb  (  FIXED_IO_ps_srstb           ),
  .FIXED_IO_ddr_vrn   (  FIXED_IO_ddr_vrn            ),
  .FIXED_IO_ddr_vrp   (  FIXED_IO_ddr_vrp            ),
  // DDR
  .DDR_addr      (DDR_addr    ),
  .DDR_ba        (DDR_ba      ),
  .DDR_cas_n     (DDR_cas_n   ),
  .DDR_ck_n      (DDR_ck_n    ),
  .DDR_ck_p      (DDR_ck_p    ),
  .DDR_cke       (DDR_cke     ),
  .DDR_cs_n      (DDR_cs_n    ),
  .DDR_dm        (DDR_dm      ),
  .DDR_dq        (DDR_dq      ),
  .DDR_dqs_n     (DDR_dqs_n   ),
  .DDR_dqs_p     (DDR_dqs_p   ),
  .DDR_odt       (DDR_odt     ),
  .DDR_ras_n     (DDR_ras_n   ),
  .DDR_reset_n   (DDR_reset_n ),
  .DDR_we_n      (DDR_we_n    ),

  .fclk_clk_o    (fclk        ),
  .fclk_rstn_o   (frstn       ),
  // ADC analog inputs
  .vinp_i        (vinp_i      ),  // voltages p
  .vinn_i        (vinn_i      ),  // voltages n
   // system read/write channel
  .sys_clk_o     (ps_sys_clk  ),  // system clock
  .sys_rstn_o    (ps_sys_rstn ),  // system reset - active low
  .sys_addr_o    (ps_sys_addr ),  // system read/write address
  .sys_wdata_o   (ps_sys_wdata),  // system write data
  .sys_sel_o     (ps_sys_sel  ),  // system write byte select
  .sys_wen_o     (ps_sys_wen  ),  // system write enable
  .sys_ren_o     (ps_sys_ren  ),  // system read enable
  .sys_rdata_i   (ps_sys_rdata),  // system read data
  .sys_err_i     (ps_sys_err  ),  // system error indicator
  .sys_ack_i     (ps_sys_ack  ),  // system acknowledge signal
  // AXI masters
  .axi1_clk_i    (axi1_clk    ),  .axi0_clk_i    (axi0_clk    ),  // global clock
  .axi1_rstn_i   (axi1_rstn   ),  .axi0_rstn_i   (axi0_rstn   ),  // global reset
  .axi1_waddr_i  (axi1_waddr  ),  .axi0_waddr_i  (axi0_waddr  ),  // system write address
  .axi1_wdata_i  (axi1_wdata  ),  .axi0_wdata_i  (axi0_wdata  ),  // system write data
  .axi1_wsel_i   (axi1_wsel   ),  .axi0_wsel_i   (axi0_wsel   ),  // system write byte select
  .axi1_wvalid_i (axi1_wvalid ),  .axi0_wvalid_i (axi0_wvalid ),  // system write data valid
  .axi1_wlen_i   (axi1_wlen   ),  .axi0_wlen_i   (axi0_wlen   ),  // system write burst length
  .axi1_wfixed_i (axi1_wfixed ),  .axi0_wfixed_i (axi0_wfixed ),  // system write burst type (fixed / incremental)
  .axi1_werr_o   (axi1_werr   ),  .axi0_werr_o   (axi0_werr   ),  // system write error
  .axi1_wrdy_o   (axi1_wrdy   ),  .axi0_wrdy_o   (axi0_wrdy   ),  // system write ready
  .rd_do_o       (rd_do_t      ),
  .wr_do_o       (wr_do_t      ),
  .ack_timout_o  (ack_timout_t ),
  .ack_combine_o (ack_combine_t),

  .clk_ext_in(clk_ext_bufg), // exp_p_in[5]), after a bufg // 10 MHz-200 MHz external clock input on DIO5_P/DIO5_N
  .clk_to_adc(clk_to_adc),
  .gpio_io_o(gpio_io_o),
  .to_uart(to_uart), // 10 bits to uart uC: 1 bit pwr/enable, 1 bit send strobe signal, 8 bits data

  .reg_to_axi1(reg_to_axi1),
  .reg_to_axi2(reg_to_axi2),
  .reg_to_axi3(reg_to_axi3)

);

////////////////////////////////////////////////////////////////////////////////
// counts the frequency of the external clock on exp_p_in[5] against fclk[3] (200 MHz)
////////////////////////////////////////////////////////////////////////////////
digital_clock_freq_counter # (
    .N_gate_time(32'd200000000) // fixed for clk_ref = 200 MHz, 1 sec gate time
) digital_clock_freq_counter_inst (
    .clk_ref          (fclk[3]),
    .clk_target       (clk_ext_bufg),
    .output_clk_enable(), // could use these if we had to use the results
    .freq_count_out   (), // could use these if we had to use the results
    .out_reg_to_axi1  (reg_to_axi1), // see inside this module for the data format in those three registers
    .out_reg_to_axi2  (reg_to_axi2), // see inside this module for the data format in those three registers
    .out_reg_to_axi3  (reg_to_axi3) // see inside this module for the data format in those three registers
);

////////////////////////////////////////////////////////////////////////////////
// Handles the decision for switching between internal and external clock according to both the user request AND the presence or not of the external clock
////////////////////////////////////////////////////////////////////////////////
clk_manager clk_manager_inst (
    .clk_stable                      (fclk[0]),
    .clk_ext                         (clk_ext_bufg),
    .clk_int_or_ext_desired          (clk_int_or_ext_desired),
    .minimum_cycles_of_clk_under_test(minimum_cycles_of_clk_under_test),
    .cycles_of_clk_stable            (cycles_of_clk_stable),
    .clk_ext_good                    (clk_ext_good),
    .clk_int_or_ext_actual           (clk_int_or_ext_actual)
);


  // implements the actual switching between the two clock sources
   BUFGCTRL #(
      .INIT_OUT(0),           // Initial value of BUFGCTRL output ($VALUES;)
      .PRESELECT_I0("TRUE"), // BUFGCTRL output uses I0 input ($VALUES;)
      .PRESELECT_I1("FALSE")  // BUFGCTRL output uses I1 input ($VALUES;)
   )
   BUFGCTRL_inst (
      .O(clk_to_adc_muxed),             // 1-bit output: Clock output
      .CE0(1'b1),         // 1-bit input: Clock enable input for I0
      .CE1(1'b1),         // 1-bit input: Clock enable input for I1
      .I0(fclk[0]),      // 1-bit input: Primary clock
      .I1(clk_to_adc),   // 1-bit input: Secondary clock
      .IGNORE0(1'b1), // 1-bit input: Clock ignore input for I0
      .IGNORE1(1'b1), // 1-bit input: Clock ignore input for I1
      .S0(clk_int_or_ext_actual),           // 1-bit input: Clock select for I0
      .S1(~clk_int_or_ext_actual)           // 1-bit input: Clock select for I1
   );

   // clock-domain crossing synchronizers for S1:
   (* ASYNC_REG = "TRUE" *) reg clk_int_or_ext_actual_reg1;
   (* ASYNC_REG = "TRUE" *) reg clk_int_or_ext_actual_reg2;
   always @(posedge adc_clk)
   begin
      clk_int_or_ext_actual_reg1 <= clk_int_or_ext_actual;
      clk_int_or_ext_actual_reg2 <= clk_int_or_ext_actual_reg1;
   end

////////////////////////////////////////////////////////////////////////////////
// system bus decoder & multiplexer (it breaks memory addresses into 8 regions)
////////////////////////////////////////////////////////////////////////////////

wire              sys_clk   = ps_sys_clk  ;
wire              sys_rstn  = ps_sys_rstn ;
wire  [  32-1: 0] sys_addr  = ps_sys_addr ;
wire  [  32-1: 0] sys_wdata = ps_sys_wdata;
wire  [   4-1: 0] sys_sel   = ps_sys_sel  ;
wire  [8   -1: 0] sys_wen   ;
wire  [8   -1: 0] sys_ren   ;
wire  [8*32-1: 0] sys_rdata ;
wire  [8* 1-1: 0] sys_err   ;
wire  [8* 1-1: 0] sys_ack   ;
wire  [8   -1: 0] sys_cs    ;

assign sys_cs = 8'h01 << sys_addr[22:20];

assign sys_wen = sys_cs & {8{ps_sys_wen}};
assign sys_ren = sys_cs & {8{ps_sys_ren}};

assign ps_sys_rdata = sys_rdata[sys_addr[22:20]*32+:32];

assign ps_sys_err   = |(sys_cs & sys_err);
assign ps_sys_ack   = |(sys_cs & sys_ack);

// unused system bus slave ports
// channel 0 is DPLL
// channel 1 is BRAM-based data logger
// channel 2 is to read data in the RAM for addr_packed
// channel 3 is "Housekeeping"
// channel 4 is AMS (handles the XADC)
// channel 5 is empty
// channel 6 is empty
// channel 7 is empty

assign sys_rdata[5*32+:32] = 32'h0; 
assign sys_err  [5       ] =  1'b0;
assign sys_ack  [5       ] =  1'b1;

assign sys_rdata[6*32+:32] = 32'h0; 
assign sys_err  [6       ] =  1'b0;
assign sys_ack  [6       ] =  1'b1;

assign sys_rdata[7*32+:32] = 32'h0; 
assign sys_err  [7       ] =  1'b0;
assign sys_ack  [7       ] =  1'b1;

////////////////////////////////////////////////////////////////////////////////
// local signals
////////////////////////////////////////////////////////////////////////////////

// PLL signals
wire                  adc_clk_in;
wire                  pll_adc_clk;
wire                  pll_dac_clk_1x;
wire                  pll_dac_clk_2x;
wire                  pll_dac_clk_2p;
wire                  pll_clk_adc_2x;
wire                  pll_pwm_clk;
wire                  pll_locked;

// fast serial signals
wire                  ser_clk ;

// PWM clock and reset
wire                  pwm_clk ;
reg                   pwm_rstn;

// ADC signals
wire                  adc_clk, adc_clk_2x;
reg                   adc_rstn;
reg          [14-1:0] adc_dat_a, adc_dat_b;
wire  signed [14-1:0] adc_a    , adc_b    ;

// DAC signals
wire                  dac_clk_1x;
wire                  dac_clk_2x;
wire                  dac_clk_2p;
reg                   dac_rst;
reg          [14-1:0] dac_dat_a, dac_dat_b;
wire         [14-1:0] dac_a    , dac_b    ;
wire  signed [15-1:0] dac_a_sum, dac_b_sum;

// ASG
wire  signed [14-1:0] asg_a    , asg_b    ;

// PID
wire  signed [14-1:0] pid_a    , pid_b    ;

// configuration
wire                  digital_loop;

////////////////////////////////////////////////////////////////////////////////
// PLL (clock and reaset)
////////////////////////////////////////////////////////////////////////////////
wire clk_to_adc;
wire clk_to_adc_muxed;
//wire clk_ext_or_int;


// diferential clock input
IBUFDS i_clk (.I (adc_clk_p_i), .IB (adc_clk_n_i), .O (adc_clk_in));  // differential clock input

red_pitaya_pll pll (
  // inputs
  .clk            (adc_clk_in),  // clock
  .rstn           (frstn[0] | (~ps_gpio_rst) ),  // reset - active low
  // 200 MHz clock inputs, will be converted to 125 MHz for clocking the ADC
  //.clk_ext_or_int (clk_ext_or_int), // selects between "clk_int_for_adc" or "clk_ext_for_adc" as the ADC clock sources
  //.clk_int_for_adc(fclk[3]),        // 200 MHz clock input, internal from block design
  //.clk_ext_for_adc(exp_p_in[5]),    // 200 MHz external clock input on DIO5_P
  //.clk_to_adc     (clk_to_adc),     // 125 MHz clock output, goes to two ODDR to drive the ADC clock input (requires a hardware modification on the RP boards)
  // output clocks
  .clk_adc        (pll_adc_clk   ),  // ADC clock
  .clk_dac_1x     (pll_dac_clk_1x),  // DAC clock 125MHz
  .clk_dac_2x     (pll_dac_clk_2x),  // DAC clock 250MHz
  .clk_dac_2p     (pll_dac_clk_2p),  // DAC clock 250MHz -45DGR
  .clk_adc_2x     (pll_clk_adc_2x),  // fast serial clock
  .clk_pwm        (pll_pwm_clk   ),  // PWM clock
  // status outputs
  .pll_locked     (pll_locked)
);

BUFG bufg_adc_clk    (.O (adc_clk   ), .I (pll_adc_clk   ));
//BUFG bufg_dac_clk_1x (.O (dac_clk_1x), .I (pll_dac_clk_1x)); // don't need this, since this is exactly the same as the adc_clk..
BUFG bufg_dac_clk_2x (.O (dac_clk_2x), .I (pll_dac_clk_2x));
BUFG bufg_dac_clk_2p (.O (dac_clk_2p), .I (pll_dac_clk_2p));
BUFG bufg_ser_clk    (.O (adc_clk_2x), .I (pll_clk_adc_2x));
//BUFG bufg_pwm_clk    (.O (pwm_clk   ), .I (pll_pwm_clk   ));
assign pwm_clk = adc_clk_2x;

// ADC reset (active low) 
always @(posedge adc_clk)
adc_rstn <=  frstn[0] &  pll_locked;

// DAC reset (active high)
always @(posedge adc_clk)
dac_rst  <= ~frstn[0] | ~pll_locked;

// PWM reset (active low)
always @(posedge pwm_clk)
pwm_rstn <=  frstn[0] &  pll_locked;

////////////////////////////////////////////////////////////////////////////////
// ADC IO
////////////////////////////////////////////////////////////////////////////////

// // generating ADC clock is disabled
// assign adc_clk_o = 2'b10;
// //ODDR i_adc_clk_p ( .Q(adc_clk_o[0]), .D1(1'b1), .D2(1'b0), .C(fclk[0]), .CE(1'b1), .R(1'b0), .S(1'b0));
// //ODDR i_adc_clk_n ( .Q(adc_clk_o[1]), .D1(1'b0), .D2(1'b1), .C(fclk[0]), .CE(1'b1), .R(1'b0), .S(1'b0));

// JDD 2019-01-09: Enabling generating ADC clock from the FPGA (so that we can switch between internal and external clock modes)
// assign adc_clk_o = 2'b10;
ODDR i_adc_clk_p ( .Q(adc_clk_o[0]), .D1(1'b1), .D2(1'b0), .C(clk_to_adc_muxed), .CE(1'b1), .R(1'b0), .S(1'b0));
ODDR i_adc_clk_n ( .Q(adc_clk_o[1]), .D1(1'b0), .D2(1'b1), .C(clk_to_adc_muxed), .CE(1'b1), .R(1'b0), .S(1'b0));

// ADC clock duty cycle stabilizer is enabled
assign adc_cdcs_o = 1'b1 ;

// IO block registers should be used here
// lowest 2 bits reserved for 16bit ADC
always @(posedge adc_clk)
begin
  adc_dat_a <= adc_dat_a_i[16-1:2];
  adc_dat_b <= adc_dat_b_i[16-1:2];
end
    
// transform into 2's complement (negative slope)
assign adc_a = digital_loop ? dac_a : {adc_dat_a[14-1], ~adc_dat_a[14-2:0]};
assign adc_b = digital_loop ? dac_b : {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};

////////////////////////////////////////////////////////////////////////////////
// DAC IO
////////////////////////////////////////////////////////////////////////////////

// // JD: Added a manual offset register for the dac outputs, at addresses 0x4050_0000 and 0x4050_0004:
// // manual output registers which add to the dac output value:
// reg signed [16-1:0] manual_dac_register_a, manual_dac_register_b;

// always @(posedge adc_clk)
// begin
//     if (sys_wen[5]) begin
//         if (sys_addr[19:0] == 20'h0) manual_dac_register_a <= sys_wdata[ 16-1:0 ];
//         if (sys_addr[19:0] == 20'h4) manual_dac_register_b <= sys_wdata[ 16-1:0 ];
//     end
// end

// // Sumation of ASG and PID signal perform saturation before sending to DAC 
// assign dac_a_sum = vco_cosine_out[16-1:1] + pid_a + manual_dac_register_a;
// assign dac_b_sum = pid_b + manual_dac_register_b;

// // saturation
// assign dac_a = (^dac_a_sum[15-1:15-2]) ? {dac_a_sum[15-1], {13{~dac_a_sum[15-1]}}} : dac_a_sum[14-1:0];
// assign dac_b = (^dac_b_sum[15-1:15-2]) ? {dac_b_sum[15-1], {13{~dac_b_sum[15-1]}}} : dac_b_sum[14-1:0];


// output registers + signed to unsigned (also to negative slope)
always @(posedge adc_clk)
begin
  dac_dat_a <= {dac_a[14-1], ~dac_a[14-2:0]};
  dac_dat_b <= {dac_b[14-1], ~dac_b[14-2:0]};
end

// // DDR outputs
// ODDR oddr_dac_clk          (.Q(dac_clk_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2p), .CE(1'b1), .R(1'b0   ), .S(1'b0));
// ODDR oddr_dac_wrt          (.Q(dac_wrt_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2x), .CE(1'b1), .R(1'b0   ), .S(1'b0));
// ODDR oddr_dac_sel          (.Q(dac_sel_o), .D1(1'b1     ), .D2(1'b0     ), .C(adc_clk   ), .CE(1'b1), .R(dac_rst), .S(1'b0));
// ODDR oddr_dac_rst          (.Q(dac_rst_o), .D1(dac_rst  ), .D2(dac_rst  ), .C(adc_clk   ), .CE(1'b1), .R(1'b0   ), .S(1'b0));
// ODDR oddr_dac_dat [14-1:0] (.Q(dac_dat_o), .D1(dac_dat_b), .D2(dac_dat_a), .C(adc_clk   ), .CE(1'b1), .R(dac_rst), .S(1'b0));



//---------------------------------------------------------------------------------
//  Digital-PLL module (2 inputs, 2 outputs)
wire signed [15:0] DACout0, DACout1;
wire        [15:0] DACout2;
wire [16-1:0] LoggerData;
wire LoggerData_clk_enable;
wire LoggerIsWriting;

reg dpll_output_selector;

wire [ 32-1:0] dpll_output;
wire dpll_ack;
wire [ 32-1:0] addr_packed_output;
wire addr_packed_ack;

reg selected_ack;
reg [32-1:0] selected_output;

wire fifo_empty;
wire fifo_full;

reg [26-1:0] led_counter;

wire DDS_clk_enable;
wire [48-1:0] DDSout1;
wire [48-1:0] DDSout2;
wire [48-1:0] DDSout3;
wire [48-1:0] DDSout4;

wire [16-1:0] DDS_SPI_enables; // this can be used to gate out various SPI signals going to the DDS board, mostly for diagnosing crosstalk issues

wire AD9912_register_write;
wire [13-1:0] AD9912_register_address1;
wire [13-1:0] AD9912_register_address2;
wire [13-1:0] AD9912_register_address3;
wire [13-1:0] AD9912_register_address4;
wire [ 8-1:0] AD9912_register_value;

assign dac_a = DACout0[16-1:2];   // converts 16 bits DACout to 14 bits for dac_a
// assign dac_b = DACout1[16-1:2];   // converts 16 bits DACout to 14 bits for dac_b

multichannel_freq_counter_top multichannel_freq_counter_top_inst (
    .clk                      (adc_clk),
    .clk_times_N              (adc_clk_2x),
    .data1_in                 (adc_a),
    .data2_in                 (adc_b),
    .LoggerData_clk_enable    (LoggerData_clk_enable),
    .LoggerData               (LoggerData),
    .LoggerIsWriting          (LoggerIsWriting),
    .AD9912_register_write    (AD9912_register_write),
    .AD9912_register_address1 (AD9912_register_address1),
    .AD9912_register_address2 (AD9912_register_address2),
    .AD9912_register_address3 (AD9912_register_address3),
    .AD9912_register_address4 (AD9912_register_address4),
    .AD9912_register_value    (AD9912_register_value),
    .DDS_SPI_enables          (DDS_SPI_enables),
    .clk_int_or_ext_actual    (clk_int_or_ext_actual),
    .clk_int_or_ext_desired   (clk_int_or_ext_desired),
    .clk_ext_good             (clk_ext_good),
    .DACout1                  (DACout0),
    .DACout2                  (DACout1),
    .DDS_clk_enable           (DDS_clk_enable),
    .DDSout1                  (DDSout1),
    .DDSout2                  (DDSout2),
    .DDSout3                  (DDSout3),
    .DDSout4                  (DDSout4),
    .sys_addr                 (sys_addr                   ),  // address
    .sys_wdata                (sys_wdata                  ),  // write data
    .sys_wen                  (sys_wen[0]                 ),  // write enable
    .sys_ren                  (sys_ren[0]                 ),  // read enable
    .sys_rdata                (sys_rdata[ 0*32+31: 0*32]  ),  // read data                     -- sys_rdata[ 0*32+31: 0*32]
    .sys_err                  (sys_err[0]                 ),  // error indicator
    .sys_ack                  (sys_ack[0]                 )   // acknowledge signal            -- sys_ack[0]
);

addr_packed addr_packed_inst (
  .clk                    ( adc_clk                   ),
  .rst                    ( adc_rstn                  ),
  .sys_addr               ( sys_addr                  ),
  .sys_wdata              ( sys_wdata                 ),
  .sys_wen                ( sys_wen[0]                ),
  .sys_ren                ( sys_ren[2]                ),
  .sys_rdata              ( sys_rdata[ 2*32+31: 2*32] ),
  .sys_err                ( sys_err[2]                ),
  .sys_ack                ( sys_ack[2]                ),
  .out_empty              ( fifo_empty                ),
  .out_full               ( fifo_full                 )
);


// assign  = selected_output;

// always @(posedge adc_clk)
// begin
//   if (sys_wen[0] || sys_ren[0]) begin
//     if ((20'h00025 <= sys_addr) && (sys_addr <= 20'h00040)) begin
//         dpll_output_selector <= 1;
//     end
//     else begin
//         dpll_output_selector <= 0;
//     end
//     end
// end

// always @*
// begin
//     if (dpll_output_selector == 1) begin
//         selected_output <= dpll_output;
//     end
//     else begin
//         selected_output <= addr_packed_output;
//     end
// end

// assign sys_rdata[ 0*32+31: 0*32] = dpll_output;
// assign sys_ack[0] = addr_packed_ack; // || dpll_ack;

always @(posedge adc_clk) begin
  if (adc_rstn == 1'b0) begin
    led_counter <= 26'h0;
  end
  else begin
    led_counter <= led_counter + 26'h1;
  end
end

assign led_o = {5'b0, led_counter[25], clk_ext_good, clk_int_or_ext_actual};

// // ---------------------------------------------------------------------------------
// // For testing the N-times clk FIR filter:
// reg signed [16-1:0] fir_test_data;

// N_times_clk_FIR_wrapper N_times_clk_FIR_wrapper_inst (
//   // these two clocks need to be phase-locked to have a common edge (0 phase difference at the rising edges of clk_times_1)
//   .clk_times_1    (  adc_clk        ),
//   .clk_times_N    (  adc_clk_2x     ),
  
//   // these two signals are on the clk_times_1 clock domain
//   .data_in        (  fir_test_data  ),
//   .data_out       (  LoggerData     )

//   );
// assign LoggerData_clk_enable = 1'b1;

// always @(posedge adc_clk)
// begin
//   if (LoggerIsWriting) begin
//     fir_test_data <= 16'd1000;
//   end
//   else begin
//     fir_test_data <= 16'd0;
//   end
// end

//---------------------------------------------------------------------------------
// BRAM-based data logger, replaces the Red Pitaya oscilloscope application, but has much simpler behavior:
// The write port is directly controlled by the DPLL module, while the reads happen through the Zynq sys_bus

// // for testing independently of the DPLL module:
// assign LoggerData = adc_a;
// assign LoggerData_clk_enable = 1'b1;

ram_data_logger ram_data_logger_i (
  .clk                  (  adc_clk                    ),
  
  // data input interface
  .data_in              (  LoggerData                 ),
  .data_in_clk_enable   (  LoggerData_clk_enable      ),
  // control interface
  .is_writing           (  LoggerIsWriting            ),
  
  // CPU interface
  .sys_addr             (  sys_addr                   ),  // address
  .sys_wdata            (  sys_wdata                  ),  // write data
  .sys_sel              (  sys_sel                    ),  // write byte select
  .sys_wen              (  sys_wen[1]                 ),  // write enable
  .sys_ren              (  sys_ren[1]                 ),  // read enable
  .sys_rdata            (  sys_rdata[ 1*32+31: 1*32]  ),  // read data
  .sys_err              (  sys_err[1]                 ),  // error indicator
  .sys_ack              (  sys_ack[1]                 )   // acknowledge signal
  );


//---------------------------------------------------------------------------------
// //  Internal VCO channel a
// wire signed [16-1:0] vco0_cosine_out;
// wire signed [16-1:0] vco0_sine_out;
// reg  signed [48-1:0] vco0_frequency;

// always @(posedge adc_clk)
// begin
//     // gain was determined to mimick ~3e8 Hz/V of VCO gain, using:
//     // log2(3e8/(125e6/2^48 * 2^15/1))
//     // offset is equal to dec2bin(20e6/100e6 * 2^48, 48)
//     //vco_frequency <= ($signed(DACout0)<<<34) + $signed(48'b001100110011001100110011001100110011001100110011);
    
//     // This alternative gain setting is set to be able to address the full 0-Nyquist frequency range with the 16-bits control signal out of the DPLL block.
//     // offset is equal to dec2bin(20e6/100e6 * 2^48, 48)
//     vco0_frequency <= ($signed(DACout0)<<<(48-16-1)) + $signed(48'b0100000000000000000000000000000_00000000000000000);
    
//     // this value is equal to dec2bin(31.25e6/125e6 * 2^48, 48) (MATLAB)
//     //vco_frequency <= $signed(48'b000101101000011100101011000000100000110001001001);
// end

// internal_vco internal_vco_0 (

//  .clk             (  adc_clk                    ),

//  // frequency in counts: analog frequency is equal to: frequency/2^48*clock frequency (currently 125 MHz)
//  .frequency       (  vco0_frequency              ),

//   // System bus, address starts at 0x4X20_0000
//  .sys_addr        (  sys_addr                   ),  // address
//  .sys_wdata       (  sys_wdata                  ),  // write data
//  .sys_sel         (  sys_sel                    ),  // write byte select
//  .sys_wen         (  sys_wen[2]                 ),  // write enable
//  .sys_ren         (  sys_ren[2]                 ),  // read enable
//  .sys_rdata       (  sys_rdata[ 2*32+31: 2*32]  ),  // read data
//  .sys_err         (  sys_err[2]                 ),  // error indicator
//  .sys_ack         (  sys_ack[2]                 ),  // acknowledge signal


//  .cosine_out      (  vco0_cosine_out             ),
//  .sine_out        (  vco0_sine_out               )

//  );
// //assign dac_b = vco0_cosine_out[16-1:2];

// //---------------------------------------------------------------------------------
// //  Internal VCO channel b
// wire signed [16-1:0] vco1_cosine_out;
// wire signed [16-1:0] vco1_sine_out;
// reg  signed [48-1:0] vco1_frequency;

// always @(posedge adc_clk)
// begin
//     // gain was determined to mimick ~3e8 Hz/V of VCO gain, using:
//     // log2(3e8/(125e6/2^48 * 2^15/1))
//     // offset is equal to dec2bin(20e6/100e6 * 2^48, 48)
//     //vco_frequency <= ($signed(DACout0)<<<34) + $signed(48'b001100110011001100110011001100110011001100110011);
    
//     // This alternative gain setting is set to be able to address the full 0-Nyquist frequency range with the 16-bits control signal out of the DPLL block.
//     // offset is equal to dec2bin(31.25e6/125e6 * 2^48, 48)
//     vco1_frequency <= ($signed(DACout1)<<<(48-16-1)) + $signed(48'b0100000000000000000000000000000_00000000000000000);
    
//     // this value is equal to dec2bin(31.25e6/125e6 * 2^48, 48) (MATLAB)
//     //vco_frequency <= $signed(48'b000101101000011100101011000000100000110001001001);
// end

// internal_vco internal_vco_1 (

//  .clk             (  adc_clk                    ),

//  // frequency in counts: analog frequency is equal to: frequency/2^48*clock frequency (currently 125 MHz)
//  .frequency       (  vco1_frequency              ),

//   // System bus, address starts at 0x4X20_0000
//  .sys_addr        (  sys_addr                   ),  // address
//  .sys_wdata       (  sys_wdata                  ),  // write data
//  .sys_sel         (  sys_sel                    ),  // write byte select
//  .sys_wen         (  sys_wen[4]                 ),  // write enable
//  .sys_ren         (  sys_ren[4]                 ),  // read enable
//  .sys_rdata       (  sys_rdata[ 4*32+31: 4*32]  ),  // read data
//  .sys_err         (  sys_err[4]                 ),  // error indicator
//  .sys_ack         (  sys_ack[4]                 ),  // acknowledge signal


//  .cosine_out      (  vco1_cosine_out             ),
//  .sine_out        (  vco1_sine_out               )

//  );
// //assign dac_b = vco0_cosine_out[16-1:2];

    // soft DDS for testing purposes until we get the real hardware
    wire [32-1:0] lo_dds_m_axis_data_tdata;
    LO_DDS LO_DDS_inst
    (
        .aclk(adc_clk),
        .s_axis_phase_tvalid(1'b1),
        .s_axis_phase_tdata(DDSout1),
        .m_axis_data_tvalid(),
        .m_axis_data_tdata(lo_dds_m_axis_data_tdata)
    );
    assign dac_b = lo_dds_m_axis_data_tdata[16-1:2];

//---------------------------------------------------------------------------------
//  House Keeping

wire  [  8-1: 0] exp_p_in , exp_n_in ;
wire  [  8-1: 0] exp_p_out, exp_n_out;
wire  [  8-1: 0] exp_p_dir, exp_n_dir;

wire  [  8-1: 0] exp_p_in_hk , exp_n_in_hk ;
wire  [  8-1: 0] exp_p_out_hk, exp_n_out_hk;
wire  [  8-1: 0] exp_p_dir_hk, exp_n_dir_hk;

wire  [ 8-1: 0] led_o_hk;

wire            digital_loop_hk;

red_pitaya_hk i_hk (
  // system signals
  .clk_i           (  adc_clk                    ),  // clock
  .rstn_i          (  adc_rstn                   ),  // reset - active low
  // LED
  .led_o           (  led_o_hk                   ),  // LED output
  // global configuration
  .digital_loop    (  digital_loop_hk            ),
  // Expansion connector (disabled)
  // .exp_p_dat_i     (  exp_p_in_hk                ),  // input data
  // .exp_p_dat_o     (  exp_p_out_hk               ),  // output data
  // .exp_p_dir_o     (  exp_p_dir_hk               ),  // 1-output enable
  // .exp_n_dat_i     (  exp_n_in_hk                ),
  // .exp_n_dat_o     (  exp_n_out_hk               ),
  // .exp_n_dir_o     (  exp_n_dir_hk               ),
  .exp_p_dat_i     (  ),  // input data
  .exp_p_dat_o     (  ),  // output data
  .exp_p_dir_o     (  ),  // 1-output enable
  .exp_n_dat_i     (  ),
  .exp_n_dat_o     (  ),
  .exp_n_dir_o     (  ),
   // System bus
  .sys_addr        (  sys_addr                   ),  // address
  .sys_wdata       (  sys_wdata                  ),  // write data
  .sys_sel         (  sys_sel                    ),  // write byte select
  .sys_wen         (  sys_wen[3]                 ),  // write enable
  .sys_ren         (  sys_ren[3]                 ),  // read enable
  .sys_rdata       (  sys_rdata[ 3*32+31: 3*32]  ),  // read data
  .sys_err         (  sys_err[3]                 ),  // error indicator
  .sys_ack         (  sys_ack[3]                 )   // acknowledge signal
);


wire uart_serial_out;

uart_tx # (
    .CLK_DIVIDER  (1736), // 200 MHz clock/1736 ~ 115200 baud
    .COUNTER_WIDTH(16),
    .BITS_PER_WORD(8)
) uart_tx_inst (
    .clk            (fclk[3]), // 200 MHz clock
    .send_clk_enable(to_uart[8]),
    .data_to_send   (to_uart[7:0]),
    .serial_out     (uart_serial_out)
);


// ---------------------------------------------------------------------------------
//  Oscilloscope application
// JDD: I kept this here just because it seems like we need to keep the axi0 and axi1 modules,
// otherwise the Zynq PS hangs up everytime we try to access the FPGA's address space.
// Eventually I should figure out how to properly remove them without this lock-up problem.
// It could simply be related to the fact that axi0_clk and axi1_clk are in fact connected to adc_clk inside this module,
// but it could also be that we need to 'ack' transactions in some manner which is implemented by the axi-fifos inside...

wire trig_asg_out ;

red_pitaya_scope i_scope (
  // ADC
  // .adc_a_i         (  adc_a                      ),  // CH 1
  // .adc_b_i         (  adc_b                      ),  // CH 2
  .adc_clk_i       (  adc_clk                    ),  // clock
  .adc_rstn_i      (  adc_rstn                   ),  // reset - active low
  // .trig_ext_i      (  exp_p_in[0]                ),  // external trigger
  // .trig_asg_i      (  trig_asg_out               ),  // ASG trigger
  // AXI0 master                 // AXI1 master
  .axi0_clk_o    (axi0_clk   ),  .axi1_clk_o    (axi1_clk   ),
  .axi0_rstn_o   (axi0_rstn  ),  .axi1_rstn_o   (axi1_rstn  ),
  .axi0_waddr_o  (axi0_waddr ),  .axi1_waddr_o  (axi1_waddr ),
  .axi0_wdata_o  (axi0_wdata ),  .axi1_wdata_o  (axi1_wdata ),
  .axi0_wsel_o   (axi0_wsel  ),  .axi1_wsel_o   (axi1_wsel  ),
  .axi0_wvalid_o (axi0_wvalid),  .axi1_wvalid_o (axi1_wvalid),
  .axi0_wlen_o   (axi0_wlen  ),  .axi1_wlen_o   (axi1_wlen  ),
  .axi0_wfixed_o (axi0_wfixed),  .axi1_wfixed_o (axi1_wfixed),
  .axi0_werr_i   (axi0_werr  ),  .axi1_werr_i   (axi1_werr  ),
  .axi0_wrdy_i   (axi0_wrdy  ),  .axi1_wrdy_i   (axi1_wrdy  )
  // // System bus
  // .sys_addr        (  sys_addr                   ),  // address
  // .sys_wdata       (  sys_wdata                  ),  // write data
  // .sys_sel         (  sys_sel                    ),  // write byte select
  // .sys_wen         (  sys_wen[1]                 ),  // write enable
  // .sys_ren         (  sys_ren[1]                 ),  // read enable
  // .sys_rdata       (  sys_rdata[ 1*32+31: 1*32]  ),  // read data
  // .sys_err         (  sys_err[1]                 ),  // error indicator
  // .sys_ack         (  sys_ack[1]                 )   // acknowledge signal
);


////---------------------------------------------------------------------------------
////  DAC arbitrary signal generator

//red_pitaya_asg i_asg (
//   // DAC
//  .dac_a_o         (  asg_a                      ),  // CH 1
//  .dac_b_o         (  asg_b                      ),  // CH 2
//  .dac_clk_i       (  adc_clk                    ),  // clock
//  .dac_rstn_i      (  adc_rstn                   ),  // reset - active low
//  .trig_a_i        (  exp_p_in[0]                ),
//  .trig_b_i        (  exp_p_in[0]                ),
//  .trig_out_o      (  trig_asg_out               ),
//  // System bus
//  .sys_addr        (  sys_addr                   ),  // address
//  .sys_wdata       (  sys_wdata                  ),  // write data
//  .sys_sel         (  sys_sel                    ),  // write byte select
//  .sys_wen         (  sys_wen[2]                 ),  // write enable
//  .sys_ren         (  sys_ren[2]                 ),  // read enable
//  .sys_rdata       (  sys_rdata[ 2*32+31: 2*32]  ),  // read data
//  .sys_err         (  sys_err[2]                 ),  // error indicator
//  .sys_ack         (  sys_ack[2]                 )   // acknowledge signal
//);

////---------------------------------------------------------------------------------
////  MIMO PID controller

//red_pitaya_pid i_pid (
//   // signals
//  .clk_i           (  adc_clk                    ),  // clock
//  .rstn_i          (  adc_rstn                   ),  // reset - active low
//  .dat_a_i         (  adc_a                      ),  // in 1
//  .dat_b_i         (  adc_b                      ),  // in 2
//  .dat_a_o         (  pid_a                      ),  // out 1
//  .dat_b_o         (  pid_b                      ),  // out 2
//  // System bus
//  .sys_addr        (  sys_addr                   ),  // address
//  .sys_wdata       (  sys_wdata                  ),  // write data
//  .sys_sel         (  sys_sel                    ),  // write byte select
//  .sys_wen         (  sys_wen[3]                 ),  // write enable
//  .sys_ren         (  sys_ren[3]                 ),  // read enable
//  .sys_rdata       (  sys_rdata[ 3*32+31: 3*32]  ),  // read data
//  .sys_err         (  sys_err[3]                 ),  // error indicator
//  .sys_ack         (  sys_ack[3]                 )   // acknowledge signal
//);

//---------------------------------------------------------------------------------
//  Analog mixed signals
//  XADC and slow PWM DAC control

wire  [ 24-1: 0] pwm_cfg_a;
wire  [ 24-1: 0] pwm_cfg_b;
wire  [ 24-1: 0] pwm_cfg_c;
wire  [ 24-1: 0] pwm_cfg_d;

red_pitaya_ams i_ams (
  // power test
 .clk_i           (  adc_clk                    ),  // clock
 .rstn_i          (  adc_rstn                   ),  // reset - active low
 // PWM configuration
 .dac_a_o         (  pwm_cfg_a                  ),
 .dac_b_o         (  pwm_cfg_b                  ),
 .dac_c_o         (  pwm_cfg_c                  ),
 .dac_d_o         (  pwm_cfg_d                  ),
  // System bus
 .sys_addr        (  sys_addr                   ),  // address
 .sys_wdata       (  sys_wdata                  ),  // write data
 .sys_sel         (  sys_sel                    ),  // write byte select
 .sys_wen         (  sys_wen[4]                 ),  // write enable
 .sys_ren         (  sys_ren[4]                 ),  // read enable
 .sys_rdata       (  sys_rdata[ 4*32+31: 4*32]  ),  // read data
 .sys_err         (  sys_err[4]                 ),  // error indicator
 .sys_ack         (  sys_ack[4]                 )   // acknowledge signal
);

  //---------------------------------------------------------------------------------
  //  SPI communication with a AD9912 1 GHz DDS, 48 bits frequency word
  // now try pushing the SPI clock rate to what we'll actually be using
  // the AD9912 has 50 MHz as its maximum SPI clock in the specs, but our clock rate is 125 MHz,
  // so we can only do 125 MHz/4 = 31.25 MHz
  // since we are limited to even number of cycles per clock periods with the current implementation
  reg [15:0] clk_div              = 16'd4; // 125 MHz/4 = 31.25 MHz
  wire AD9912_SPI_SCLK;
  wire AD9912_SPI_SCLK_P;
  wire AD9912_SPI_SCLK_N;
  wire AD9912_SPI_SDIO1, AD9912_SPI_SDIO2, AD9912_SPI_SDIO3, AD9912_SPI_SDIO4;
  wire AD9912_SPI_CSB;


  AD9912_DDS_controller # () AD9912_DDS_controller_inst1 (
      .clk                     (adc_clk),
      .freq_word               (DDSout1),
      .freq_word_delay_only    (),
      .update_freq             (DDS_clk_enable),

        // this is used to update AD9912 registers directly
      .register_write          (AD9912_register_write),
      .register_address        (AD9912_register_address1),
      .register_value          (AD9912_register_value),

      .current_dds_freq        (),
      .timestamp_in            (),
      .timestamp_at_freq_update(),
      .clk_div                 (clk_div),
      .SPI_SCLK                (AD9912_SPI_SCLK),
      .SPI_SDIO                (AD9912_SPI_SDIO1),
      .SPI_CSB                 (AD9912_SPI_CSB)
  );
  AD9912_DDS_controller # () AD9912_DDS_controller_inst2 (
      .clk                     (adc_clk),
      .freq_word               (DDSout2),
      .freq_word_delay_only    (),
      .update_freq             (DDS_clk_enable),

        // this is used to update AD9912 registers directly
      .register_write          (AD9912_register_write),
      .register_address        (AD9912_register_address2),
      .register_value          (AD9912_register_value),

      .current_dds_freq        (),
      .timestamp_in            (),
      .timestamp_at_freq_update(),
      .clk_div                 (clk_div),
      .SPI_SCLK                (),
      .SPI_SDIO                (AD9912_SPI_SDIO2),
      .SPI_CSB                 ()
  );
  AD9912_DDS_controller # () AD9912_DDS_controller_inst3 (
      .clk                     (adc_clk),
      .freq_word               (DDSout3),
      .freq_word_delay_only    (),
      .update_freq             (DDS_clk_enable),

        // this is used to update AD9912 registers directly
      .register_write          (AD9912_register_write),
      .register_address        (AD9912_register_address3),
      .register_value          (AD9912_register_value),

      .current_dds_freq        (),
      .timestamp_in            (),
      .timestamp_at_freq_update(),
      .clk_div                 (clk_div),
      .SPI_SCLK                (),
      .SPI_SDIO                (AD9912_SPI_SDIO3),
      .SPI_CSB                 ()
  );
  AD9912_DDS_controller # () AD9912_DDS_controller_inst4 (
      .clk                     (adc_clk),
      .freq_word               (DDSout4),
      .freq_word_delay_only    (),
      .update_freq             (DDS_clk_enable),

        // this is used to update AD9912 registers directly
      .register_write          (AD9912_register_write),
      .register_address        (AD9912_register_address4),
      .register_value          (AD9912_register_value),

      .current_dds_freq        (),
      .timestamp_in            (),
      .timestamp_at_freq_update(),
      .clk_div                 (clk_div),
      .SPI_SCLK                (),
      .SPI_SDIO                (AD9912_SPI_SDIO4),
      .SPI_CSB                 ()
  );

  assign AD9912_SPI_SCLK_P = AD9912_SPI_SCLK;
  assign AD9912_SPI_SCLK_N = ~AD9912_SPI_SCLK;

  // map all the required signals to the expansion connector E1
   // reading this from the DDS board's schematic
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst0_P   (.O(DIO0_P), .I(AD9912_SPI_SDIO2  & DDS_SPI_enables[1]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst0_N   (.O(DIO0_N), .I(AD9912_SPI_SDIO1  & DDS_SPI_enables[2]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst1_P   (.O(DIO1_P), .I(AD9912_SPI_CSB    & DDS_SPI_enables[3]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst1_N   (.O(DIO1_N), .I(AD9912_SPI_SCLK_P & DDS_SPI_enables[4]));

   // Ideally we would have used the differential output buffers, but we also need 3.3V outputs, for which there are no available standards
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst2_P   (.O(DIO2_P), .I(AD9912_SPI_SCLK_P & DDS_SPI_enables[5]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst2_N   (.O(DIO2_N), .I(AD9912_SPI_SCLK_N & DDS_SPI_enables[6]));

   // uart bus to uC, talks to a bunch of ADF4351
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst3_P   (.O(DIO3_P), .I(uart_serial_out & to_uart[9])); // uart serial data
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst3_N   (.O(DIO3_N), .I(to_uart[9])); // uart uC pwr/enable
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst4_P   (.O(DIO4_P), .I(AD9912_SPI_SDIO3  & DDS_SPI_enables[7]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst4_N   (.O(DIO4_N), .I(AD9912_SPI_CSB    & DDS_SPI_enables[8]));
  // external clock input, goes to an MMCM inside the block design
   // IBUFGDS #(.IOSTANDARD("DIFF_HSTL_II"), .DIFF_TERM("FALSE"),.IBUF_LOW_PWR("FALSE"))
   //                                                                IBUFGDS_inst   (.I(DIO5_P),
   //                                                                               .IB(DIO5_N), .O(clk_ext_bufg) );
   IBUFGDS #(.IOSTANDARD("LVDS_25"),    .DIFF_TERM("FALSE"),.IBUF_LOW_PWR("FALSE"))
                                                                  IBUFGDS_inst   (.I(DIO5_P),
                                                                                 .IB(DIO5_N), .O(clk_ext_bufg) );

   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst6_P   (.O(DIO6_P), .I(AD9912_SPI_SCLK_P & DDS_SPI_enables[9]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst6_N   (.O(DIO6_N), .I(AD9912_SPI_SCLK_N & DDS_SPI_enables[10]));

   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst7_P   (.O(DIO7_P), .I(AD9912_SPI_SDIO4  & DDS_SPI_enables[11]));
   OBUF   #(.IOSTANDARD("LVCMOS33"),    .SLEW("SLOW"), .DRIVE(4)) OBUF_inst7_N   (.O(DIO7_N), .I(AD9912_SPI_CSB    & DDS_SPI_enables[12]));


// //////////////////////// test loss of clock event
//   wire [24-1:0] minimum_cycles_of_clk_under_test = 24'd5;
//   wire [24-1:0] cycles_of_clk_stable = 24'd200;
// (* mark_debug = "true" *) wire clk_good_ext_bufg;
// (* mark_debug = "true" *) wire clk_good_to_adc;

//   clock_presence_detector # (
//       .COUNTER_WIDTH(24)
//   ) clock_presence_detector_inst (
//       .clk_stable                      (fclk[3]),
//       .clk_under_test                  (clk_ext_bufg),
//       .minimum_cycles_of_clk_under_test(minimum_cycles_of_clk_under_test),
//       .cycles_of_clk_stable            (cycles_of_clk_stable),
//       .clk_good                        (clk_good_ext_bufg)
//   );

//   clock_presence_detector # (
//       .COUNTER_WIDTH(24)
//   ) clock_presence_detector_inst2 (
//       .clk_stable                      (fclk[3]),
//       .clk_under_test                  (clk_to_adc),
//       .minimum_cycles_of_clk_under_test(minimum_cycles_of_clk_under_test),
//       .cycles_of_clk_stable            (cycles_of_clk_stable),
//       .clk_good                        (clk_good_to_adc)
//   );

endmodule

