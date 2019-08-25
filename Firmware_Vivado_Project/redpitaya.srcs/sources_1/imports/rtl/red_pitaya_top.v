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
   inout  wire  [ 8-1: 0] exp_p_io           ,
   inout  wire  [ 8-1: 0] exp_n_io           ,
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

wire [1:0] gpio_io_o;
wire ps_gpio_rst;
wire clk_int_or_ext;

// frequency counter on the external clock input
wire clk_ext_bufg;
wire [32-1:0] reg_to_axi1;
wire [32-1:0] reg_to_axi2;
wire [32-1:0] reg_to_axi3;

assign clk_int_or_ext = gpio_io_o[0];
assign ps_gpio_rst    = gpio_io_o[1];

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

  .clk_ext_in(exp_p_in[5]), // 10 MHz-200 MHz external clock input on DIO5_P
  .clk_ext_bufg(clk_ext_bufg), // copy of the exp_p_in[5] signal, after a BUFG
  .clk_to_adc(clk_to_adc),
  .gpio_io_o(gpio_io_o),

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
// channel 4 is AMS
// channel 5 is output multiplexer
// channel 6 is VCO for DAC

// assign sys_rdata[5*32+:32] = 32'h0; 
// assign sys_err  [5       ] =  1'b0;
// assign sys_ack  [5       ] =  1'b1;

// assign sys_rdata[4*32+:32] = 32'h0; 
// assign sys_err  [4       ] =  1'b0;
// assign sys_ack  [4       ] =  1'b1;

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
BUFG bufg_dac_clk_1x (.O (dac_clk_1x), .I (pll_dac_clk_1x));
BUFG bufg_dac_clk_2x (.O (dac_clk_2x), .I (pll_dac_clk_2x));
BUFG bufg_dac_clk_2p (.O (dac_clk_2p), .I (pll_dac_clk_2p));
BUFG bufg_ser_clk    (.O (adc_clk_2x), .I (pll_clk_adc_2x));
//BUFG bufg_pwm_clk    (.O (pwm_clk   ), .I (pll_pwm_clk   ));
assign pwm_clk = adc_clk_2x;

// ADC reset (active low) 
always @(posedge adc_clk)
adc_rstn <=  frstn[0] &  pll_locked;

// DAC reset (active high)
always @(posedge dac_clk_1x)
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
ODDR i_adc_clk_p ( .Q(adc_clk_o[0]), .D1(1'b1), .D2(1'b0), .C(clk_to_adc), .CE(1'b1), .R(1'b0), .S(1'b0));
ODDR i_adc_clk_n ( .Q(adc_clk_o[1]), .D1(1'b0), .D2(1'b1), .C(clk_to_adc), .CE(1'b1), .R(1'b0), .S(1'b0));

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
always @(posedge dac_clk_1x)
begin
  dac_dat_a <= {dac_a[14-1], ~dac_a[14-2:0]};
  dac_dat_b <= {dac_b[14-1], ~dac_b[14-2:0]};
end

// DDR outputs
ODDR oddr_dac_clk          (.Q(dac_clk_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2p), .CE(1'b1), .R(1'b0   ), .S(1'b0));
ODDR oddr_dac_wrt          (.Q(dac_wrt_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2x), .CE(1'b1), .R(1'b0   ), .S(1'b0));
ODDR oddr_dac_sel          (.Q(dac_sel_o), .D1(1'b1     ), .D2(1'b0     ), .C(dac_clk_1x), .CE(1'b1), .R(dac_rst), .S(1'b0));
ODDR oddr_dac_rst          (.Q(dac_rst_o), .D1(dac_rst  ), .D2(dac_rst  ), .C(dac_clk_1x), .CE(1'b1), .R(1'b0   ), .S(1'b0));
ODDR oddr_dac_dat [14-1:0] (.Q(dac_dat_o), .D1(dac_dat_b), .D2(dac_dat_a), .C(dac_clk_1x), .CE(1'b1), .R(dac_rst), .S(1'b0));



//---------------------------------------------------------------------------------
//  Digital-PLL module (2 inputs, 2 outputs)
wire signed [15:0] ADCraw0, ADCraw1;
wire signed [15:0] DACout0, DACout1;
wire        [15:0] DACout2;
wire [16-1:0] LoggerData;
wire LoggerData_clk_enable;
wire LoggerIsWriting;

reg dpll_output_selector;

wire osc_output;  // for testing a switching regulator

wire [ 32-1:0] dpll_output;
wire dpll_ack;
wire [ 32-1:0] addr_packed_output;
wire addr_packed_ack;

reg selected_ack;
reg [32-1:0] selected_output;

wire fifo_empty;
wire fifo_full;


wire debug_out_1;
wire debug_out_2;
wire debug_out_3;
wire debug_out_4;

reg [26-1:0] led_counter;

assign ADCraw0 = {adc_a, 2'b0};
assign ADCraw1 = {adc_b, 2'b0};
// assign dac_a = DACout0[16-1:2];   // converts 16 bits DACout to 14 bits for dac_a
// assign dac_b = DACout1[16-1:2];   // converts 16 bits DACout to 14 bits for dac_b

wire dpll_rst = 1'b0; // I don't know if we can use the RedPitaya's reset because I don't know if it is clock-synchronous or not. In any case, it does not matter because we have the sys_bus driven resets.

dpll_wrapper dpll_wrapper_inst (
  
  .clk1                    (  adc_clk                    ), // global clock, designed for 100 MHz clock rate
  .clk1_timesN             (  adc_clk_2x                 ), // this should be N times the clock, phase-locked to clk1, N matching what was input in the FIR compiler for fir_compiler_minimumphase_N_times_clk
  .rst                     (  dpll_rst                   ), // currently only use the resets driven by the system bus

  // analog data input/output interface
  .ADCraw0                 (  ADCraw0                    ),
  .ADCraw1                 (  ADCraw1                    ),
  .DACout0                 (  DACout0                    ),
  .DACout1                 (  DACout1                    ),
  .DACout2                 (  DACout2                    ),

  .osc_output(osc_output),
  //.clk_ext_or_int(clk_ext_or_int), // clock select register. 1 = internal, 0 = external

  // Data logger port:
  .LoggerData              (  LoggerData                 ),
  .LoggerData_clk_enable   (  LoggerData_clk_enable      ),
  .LoggerIsWriting         (  LoggerIsWriting            ),

  // System bus
  .sys_addr                (  sys_addr                   ),  // address
  .sys_wdata               (  sys_wdata                  ),  // write data
  .sys_sel                 (  sys_sel                    ),  // write byte select
  .sys_wen                 (  sys_wen[0]                 ),  // write enable
  .sys_ren                 (  sys_ren[0]                 ),  // read enable
  .sys_rdata               (  sys_rdata[ 0*32+31: 0*32]  ),  // read data                     -- sys_rdata[ 0*32+31: 0*32]
  .sys_err                 (  sys_err[0]                 ),  // error indicator
  .sys_ack                 (  sys_ack[0]                 )   // acknowledge signal            -- sys_ack[0]
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

assign led_o = {fifo_empty, fifo_full, led_counter[25], clk_int_or_ext, 4'b0};

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

// // always @(posedge adc_clk) begin
// //   if (adc_rstn == 1'b0) begin
// //     led_counter <= 26'h0;
// //   end
// //   else begin
// //     led_counter <= led_counter + 26'h1;
// //   end
// // end


// assign exp_n_out[8-1:0] = {5'b10000000};
// assign exp_p_out[8-1:0] = {8'b00000000};

// Set the direction of each IO pins:
assign exp_n_dir[8-1:0] = {8'b00111111};  // pins 0-5 set as outputs, the rest as inputs
assign exp_p_dir[8-1:0] = {8'b00001001};  // pin 0 and 3 set as output, the rest as inputs

assign exp_n_out[2] = osc_output;
assign exp_n_out[5] = 1'b0;   // unused GPIO set as output with 0V for the moment
assign exp_n_out[3] = 1'b0;   // unused GPIO set as output with 0V for the moment
// assign exp_n_out[5] = exp_p_in[5];  // loopback from buffered input to output
//assign exp_p_out[3] = exp_p_in[2];  // loopback from buffered input to output

// // 125 MHz generated from 200 MHz, either internal or external clocks
ODDR oddr_exp_p_out3 ( .Q(exp_p_out[3]), .D1(1'b1), .D2(1'b0), .C(clk_to_adc), .CE(1'b1), .R(1'b0), .S(1'b0));

// Use this to map the digital IO to the house keeping module:
// IOBUF i_iobufp [8-1:0] (.O(exp_p_in), .IO(exp_p_io), .I(exp_p_out_hk), .T(~exp_p_dir) );
// IOBUF i_iobufn [8-1:0] (.O(exp_n_in), .IO(exp_n_io), .I(exp_n_out_hk), .T(~exp_n_dir) );
// Use this to use the digital IO connectors differently:
// Drive "exp_p_out" and "exp_n_out" and set "exp_n_dir" and "exp_p_dir" accordingly
IOBUF i_iobufp [8-1:0] (.O(exp_p_in), .IO(exp_p_io), .I(exp_p_out), .T(~exp_p_dir) );
IOBUF i_iobufn [8-1:0] (.O(exp_n_in), .IO(exp_n_io), .I(exp_n_out), .T(~exp_n_dir) );

//---------------------------------------------------------------------------------
// VCO and output mux
// Channel 5

wire signed [14-1 : 0] to_DAC0;
wire signed [14-1 : 0] to_DAC1;

mux_internal_vco mux_vco (
  .clk            ( adc_clk                   ), // clock
  .DACin0         ( DACout0                   ), // output of the DPLL channel a
  .DACin1         ( DACout1                   ), // output of the DPLL channel b
  // internal configuration bus
  .sys_addr       ( sys_addr                  ), // address
  .sys_wdata      ( sys_wdata                 ), // write data
  .sys_sel        ( sys_sel                   ), // write byte select
  // communication bus for the vco
  .sys_wen_vco    (sys_wen[6]                 ), // write enable for the vco
  .sys_ren_vco    (sys_ren[6]                 ), // read enable for the vco
  .sys_rdata_vco  (sys_rdata[ 6*32+31: 6*32]  ), // read data for the vco
  .sys_err_vco    (sys_err[6]                 ), // error indicator for the vco
  .sys_ack_vco    (sys_ack[6]                 ), // acknowledge signal for the vco
  // communication bus for the mux
  .sys_wen_mux    (sys_wen[5]                 ), // write enable for the mux
  .sys_ren_mux    (sys_ren[5]                 ), // read enable for the mux
  .sys_rdata_mux  (sys_rdata[ 5*32+31: 5*32]  ), // read data for the mux
  .sys_err_mux    (sys_err[5]                 ), // error indicator for the mux
  .sys_ack_mux    (sys_ack[5]                 ), // acknowledge signal for the mux
  // output
  .DACa_out       ( to_DAC0                  ), // output to the dac (from vco or directly from dpll)
  .DACb_out       ( to_DAC1                  )  // output to the dac (from vco or directly from dpll)
  );

assign dac_a = to_DAC0;
assign dac_b = to_DAC1;


// ---------------------------------------------------------------------------------
// // output mux (select between different configurations)
// // Channel 5

// wire signed [14-1:0] signal_mux0;
// wire signed [14-1:0] signal_mux1;

// output_multiplexer muxDAC (
//   // system signals
//   .clk             (  adc_clk                    ),  // clock
// //  .rstn_i          (  adc_rstn                   ),  // reset - active low

//    // System bus
//   .sys_addr        (  sys_addr                   ),  // address
//   .sys_wdata       (  sys_wdata                  ),  // write data
//   .sys_sel         (  sys_sel                    ),  // write byte select
//   .sys_wen         (  sys_wen[5]                 ),  // write enable
//   .sys_ren         (  sys_ren[5]                 ),  // read enable
//   .sys_rdata       (  sys_rdata[ 5*32+31: 5*32]  ),  // read data
//   .sys_err         (  sys_err[5]                 ),  // error indicator
//   .sys_ack         (  sys_ack[5]                 ),  // acknowledge signal
//   .in0_0_mux       (  DACout0[16-1:2]            ),  // 
//   .in1_0_mux       (  vco0_cosine_out[16-1:2]     ),  //
//   .out_0_mux       (  signal_mux0                ),
//   .in0_1_mux       (  DACout1[16-1:2]            ),  // 
//   .in1_1_mux       (  vco1_cosine_out[16-1:2]     ),  //
//   .out_1_mux       (  signal_mux1                )
// );

// assign dac_a = signal_mux0;
// assign dac_b = signal_mux1;


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

red_pitaya_pwm pwm [4-1:0] (
 // system signals
 .clk   (pwm_clk ),
 .rstn  (pwm_rstn),
 // configuration
 .cfg   ({pwm_cfg_d, pwm_cfg_c, pwm_cfg_b, pwm_cfg_a}),
 // PWM outputs
 .pwm_o (dac_pwm_o),
 .pwm_s ()
);

//---------------------------------------------------------------------------------
//  Daisy chain
//  simple communication module

reg [3-1:0] daisy_counter;

wire clk_out_10;

always @(posedge adc_clk) begin
  if (adc_rstn == 1'b0) begin
    daisy_counter <= 3'h0;
  end
  else begin
    daisy_counter <= daisy_counter + 3'h1;
  end
end

// clk_10MHz_sync 
// (// Clock in ports
//   .clk_in1    ( adc_clk   ),
//   // Clock out ports
//   .clk_out1   (clk_out_10 ),
//   // Status and control signals
//   .locked     (           )
//  );


assign daisy_p_o = {clk_out_10, 1'bz};  //Important : if you want to use only one of the signals (p or n), terminate the other one with a 50 Ohm. To do so
assign daisy_n_o = {~clk_out_10, 1'bz};   // we built a SATA connector with 2 SMA connector at the end (one for the "p" and one for the "n" signal).


//---------------------------------------------------------------------------------
//  SPI communication with a MAX5541 16-bits, SPI DAC.

  reg [16-1:0] dac_ramp_test;
  wire data_loaded_clk_enable;
  wire max5541_scl;
  wire max5541_sda;
  wire max5541_csb;
  wire opamp_30V_enable = 1'b1;

  // // we simply play a ramp in a loop for now:
  // always @(posedge adc_clk) begin
  //   if (data_loaded_clk_enable == 1'b1) begin
  //     dac_ramp_test <= dac_ramp_test + 16'd1;
  //   end
  // end

  max5541_spi_dac_interface max5541_spi_dac_interface_inst
  (
    .clk(adc_clk),
    .data_in(DACout2),
    .data_loaded_clk_enable(data_loaded_clk_enable),
    .scl(max5541_scl),
    .sda(max5541_sda),
    .csb(max5541_csb)
  );
  // Map the SPI port to specific IO pins:
  assign exp_p_out[0] = max5541_csb; // before 2018-06-29: max5541_scl
  assign exp_n_out[0] = max5541_scl; // before 2018-06-29: max5541_sda
  assign exp_n_out[1] = max5541_sda; 
  assign exp_p_out[1] = 0; // before 2018-06-29: max5541_csb, now is just an input (unused, but wired in parallel with an output on one of the boards

  assign exp_n_out[3] = opamp_30V_enable; // this turns ON Q1 in the schematic, which turns on Q2, which activates 15 mA of bias current into the non-inverting pin in order to put the opamp inside it's common-mode input range
endmodule

