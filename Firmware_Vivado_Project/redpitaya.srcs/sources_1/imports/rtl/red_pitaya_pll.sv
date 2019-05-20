/**
 * @brief Red Pitaya PLL module.
 *
 * @Author Matej Oblak, Iztok Jeras
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */

module red_pitaya_pll (
  // inputs
  input  logic clk       ,  // clock
  input  logic rstn      ,  // reset - active low
  // // 200 MHz clock inputs, will be converted to 125 MHz for clocking the ADC
  // input  logic clk_ext_or_int,   // selects between "clk_int_for_adc" or "clk_ext_for_adc" as the ADC clock sources
  // input  logic clk_int_for_adc,  // 200 MHz clock input, internal from block design
  // input  logic clk_ext_for_adc,  // 200 MHz external clock input on DIO5_P
  // output logic clk_to_adc,       // 125 MHz clock output, goes to two ODDR to drive the ADC clock input (requires a hardware modification on the RP boards)
  // output clocks, all phase-locked to the input "clk"
  output logic clk_adc   ,  // ADC clock
  output logic clk_dac_1x,  // DAC clock
  output logic clk_dac_2x,  // DAC clock
  output logic clk_dac_2p,  // DAC clock
  output logic clk_adc_2x,  // 2x ADC clock
  output logic clk_pwm   ,  // PWM clock
  // status outputs
  output logic pll_locked
);

logic clk_fb;
logic clk_fb_in;

PLLE2_ADV #(
   .BANDWIDTH            ("OPTIMIZED"),
   .COMPENSATION         ("ZHOLD"    ),
   .DIVCLK_DIVIDE        ( 1         ),
   .CLKFBOUT_MULT        ( 8         ),
   .CLKFBOUT_PHASE       ( 0.000     ),
   .CLKOUT0_DIVIDE       ( 8         ),
   .CLKOUT0_PHASE        ( 0.000     ),
   .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT1_DIVIDE       ( 8         ),
   .CLKOUT1_PHASE        ( 0.000     ),
   .CLKOUT1_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT2_DIVIDE       ( 4         ),
   .CLKOUT2_PHASE        ( 0.000     ),
   .CLKOUT2_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT3_DIVIDE       ( 4         ),
   .CLKOUT3_PHASE        (-45.000    ),
   .CLKOUT3_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT4_DIVIDE       ( 4         ),  // 125MHz*8/4=250MHz, 125MHz*8/2=500MHz
   .CLKOUT4_PHASE        ( 0.000     ),
   .CLKOUT4_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT5_DIVIDE       ( 4         ),
   .CLKOUT5_PHASE        ( 0.000     ),
   .CLKOUT5_DUTY_CYCLE   ( 0.5       ),
   .CLKIN1_PERIOD        ( 8.000     ),
   .REF_JITTER1          ( 0.010     )
) pll (
   // Output clocks
   .CLKFBOUT     (clk_fb    ),
   .CLKOUT0      (clk_adc   ),
   .CLKOUT1      (clk_dac_1x),
   .CLKOUT2      (clk_dac_2x),
   .CLKOUT3      (clk_dac_2p),
   .CLKOUT4      (clk_adc_2x),
   .CLKOUT5      (clk_pwm   ),
   // Input clock control
   .CLKFBIN      (clk_fb_in ),
   .CLKIN1       (clk       ),
   .CLKIN2       (1'b0      ),
   // Tied to always select the primary input clock
   .CLKINSEL     (1'b1 ),
   // Ports for dynamic reconfiguration
   .DADDR        (7'h0 ),
   .DCLK         (1'b0 ),
   .DEN          (1'b0 ),
   .DI           (16'h0),
   .DO           (     ),
   .DRDY         (     ),
   .DWE          (1'b0 ),
   // Other control and status signals
   .LOCKED       (pll_locked),
   .PWRDWN       (1'b0      ),
   .RST          (!rstn     )
);

// JDD 2018-06-23: Adding a bufg in the feedback loop to remove the associated phase offset of the input bufg
// this is to try to help the hold time violation on the ADC data inputs
   BUFG BUFG_inst (
      .O(clk_fb_in), // 1-bit output: Clock output
      .I(clk_fb)  // 1-bit input: Clock input
   );

// JDD 2019-05-19: this functionality is now moved to the block design.
// the PLL is instantiated in clk_wiz_0, which we can control through the AXI bus
// this axi bus is clocked on the internal clock always, so there is no issue
// with losing the clock for the configuration bus if there is no external clock input
// ///////////////////////////////////////////////////////////////////////
// // 200 MHz input clocks, converted to 125 MHz for clocking the ADC.
// // the VCO should run at 200 MHz*CLKFBOUT_MULT = 1 GHz, which yields F_VCO/CLKOUT0_DIVIDE = 125 MHz output.
// wire clk_fb2;
// wire clk_to_adc_before_bufg;
 
// PLLE2_ADV #(
//    .BANDWIDTH            ("OPTIMIZED"),
//    .COMPENSATION         ("ZHOLD"    ),
//    .DIVCLK_DIVIDE        ( 1         ),
//    .CLKFBOUT_MULT        ( 62        ), // 10 MHz*62 = 620 MHz VCO frequency (valid range is 600-1600 MHz according to the datasheet (DS181))
//    .CLKFBOUT_PHASE       ( 0.000     ),
//    .CLKOUT0_DIVIDE       ( 5         ), // 10 MHz*62/5 = 124 MHz (instead of the usual 125 MHz).
//    .CLKOUT0_PHASE        ( 0.000     ),
//    .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
//    .CLKOUT1_DIVIDE       ( 8         ),
//    .CLKOUT1_PHASE        ( 0.000     ),
//    .CLKOUT1_DUTY_CYCLE   ( 0.5       ),
//    .CLKOUT2_DIVIDE       ( 4         ),
//    .CLKOUT2_PHASE        ( 0.000     ),
//    .CLKOUT2_DUTY_CYCLE   ( 0.5       ),
//    .CLKOUT3_DIVIDE       ( 4         ),
//    .CLKOUT3_PHASE        (-45.000    ),
//    .CLKOUT3_DUTY_CYCLE   ( 0.5       ),
//    .CLKOUT4_DIVIDE       ( 4         ),
//    .CLKOUT4_PHASE        ( 0.000     ),
//    .CLKOUT4_DUTY_CYCLE   ( 0.5       ),
//    .CLKOUT5_DIVIDE       ( 4         ),
//    .CLKOUT5_PHASE        ( 0.000     ),
//    .CLKOUT5_DUTY_CYCLE   ( 0.5       ),
//    .CLKIN1_PERIOD        ( 100.0     ),
//    .CLKIN2_PERIOD        ( 100.0     ),
//    .REF_JITTER1          ( 0.010     ),
//    .REF_JITTER2          ( 0.010     )
// ) pll2 (
//    // Output clocks
//    .CLKFBOUT     (clk_fb2   ),
//    .CLKOUT0      (clk_to_adc_before_bufg),
//    .CLKOUT1      (),
//    .CLKOUT2      (),
//    .CLKOUT3      (),
//    .CLKOUT4      (),
//    .CLKOUT5      (),
//    // Input clock control
//    .CLKFBIN      (clk_fb2 ),
//    .CLKIN1       (clk_int_for_adc   ),
//    .CLKIN2       (clk_ext_for_adc   ),
//    .CLKINSEL     (clk_ext_or_int),
//    // Ports for dynamic reconfiguration
//    .DADDR        (7'h0 ),
//    .DCLK         (1'b0 ),
//    .DEN          (1'b0 ),
//    .DI           (16'h0),
//    .DO           (     ),
//    .DRDY         (     ),
//    .DWE          (1'b0 ),
//    // Other control and status signals
//    .LOCKED       (),
//    .PWRDWN       (1'b0      ),
//    .RST          (!rstn     )
// );



//    BUFG BUFG_inst2 (
//       .O(clk_to_adc), // 1-bit output: Clock output
//       .I(clk_to_adc_before_bufg)  // 1-bit input: Clock input
//    );

endmodule: red_pitaya_pll
