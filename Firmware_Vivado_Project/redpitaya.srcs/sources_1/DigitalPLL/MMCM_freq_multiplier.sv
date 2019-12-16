
module MMCM_freq_multiplier (

    // Clock to be multiplied
    input logic clk_in,
    // Output clock signal.
    // This is the output of an ODDR and thus needs to be connected directly to a top-level pin.
    // Will have frequency equal to N times the frequency of clk_in
    output logic clk_out_oddr,



    // Bus signals:
    input logic clk_bus,
    input logic bus_strobe,
    input logic bus_address,
    input logic bus_data

);

logic clk_fb;
logic clk_fb_in;
logic clk_out_before_oddr;

    // Registers used to access the dynamic reconfiguration port (DRP):
    wire [7-1:0] DADDR;
    wire DEN;
    wire [16-1:0] DI;
    wire DWE;
    wire rst;
    wire update_flag;

    parallel_bus_register_32bits_or_less # (
        .REGISTER_SIZE(16+7),
        .REGISTER_DEFAULT_VALUE(0),
        .ADDRESS(16'h8701)
    )
    parallel_bus_register_data  (
     .clk                           (clk_bus                    ), 
     .bus_strobe                    (bus_strobe                 ), 
     .bus_address                   (bus_address                ), 
     .bus_data                      (bus_data                   ), 
     .register_output               ({DADDR, DI}                ), 
     .update_flag                   (update_flag                )
    );
    assign DWE = update_flag;
    assign DEN = update_flag;

    parallel_bus_register_32bits_or_less # (
        .REGISTER_SIZE(1),
        .REGISTER_DEFAULT_VALUE(0),
        .ADDRESS(16'h8700)
    )
    parallel_bus_register_rst  (
     .clk                           (clk_bus                    ), 
     .bus_strobe                    (bus_strobe                 ), 
     .bus_address                   (bus_address                ), 
     .bus_data                      (bus_data                   ), 
     .register_output               (rst                        ), 
     .update_flag                   ()
    );


    PLLE2_ADV #(
    .BANDWIDTH            ("HIGH"     ),
    .COMPENSATION         ("ZHOLD"    ),
    .DIVCLK_DIVIDE        ( 1         ),
    .CLKFBOUT_MULT        ( 30        ), // 30*40MHz = 1200 MHz VCO freq, VCO is speced 800-1600 MHz according to the datasheet
    .CLKFBOUT_PHASE       ( 0.000     ),
    .CLKOUT0_DIVIDE       ( 7         ), // 40 MHz*30/10 = 120 MHz
    .CLKOUT0_PHASE        ( 0.000     ),
    .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
    .CLKOUT1_DIVIDE       ( 7         ),
    .CLKOUT1_PHASE        ( 0.000     ),
    .CLKOUT1_DUTY_CYCLE   ( 0.5       ),
    .CLKOUT2_DIVIDE       ( 7         ),
    .CLKOUT2_PHASE        ( 0.000     ),
    .CLKOUT2_DUTY_CYCLE   ( 0.5       ),
    .CLKOUT3_DIVIDE       ( 7         ),
    .CLKOUT3_PHASE        ( 0.000     ),
    .CLKOUT3_DUTY_CYCLE   ( 0.5       ),
    .CLKOUT4_DIVIDE       ( 7         ),
    .CLKOUT4_PHASE        ( 0.000     ),
    .CLKOUT4_DUTY_CYCLE   ( 0.5       ),
    .CLKOUT5_DIVIDE       ( 7         ),
    .CLKOUT5_PHASE        ( 0.000     ),
    .CLKOUT5_DUTY_CYCLE   ( 0.5       ),
    .CLKIN1_PERIOD        (25.000     ),
    .REF_JITTER1          ( 0.010     )
    ) pll (
    // Output clocks
    .CLKFBOUT     (clk_fb    ),
    .CLKOUT0      (clk_out_before_oddr ),
    .CLKOUT1      (),
    .CLKOUT2      (),
    .CLKOUT3      (),
    .CLKOUT4      (),
    .CLKOUT5      (),
    // Input clock control
    .CLKFBIN      (clk_fb    ),
    .CLKIN1       (clk_in    ),
    .CLKIN2       (1'b0      ),
    // Tied to always select the primary input clock
    .CLKINSEL     (1'b1 ),
    // Ports for dynamic reconfiguration
    .DADDR        (7'h0 ),
    .DCLK         (clk_bus),
    .DEN          (1'b0 ),
    .DI           (16'h0),
    .DO           (     ),
    .DRDY         (     ),
    .DWE          (1'b0 ),
    // Other control and status signals
    .LOCKED       (),
    .PWRDWN       (1'b0),
    .RST          (rst)
    );





    ODDR multiplied_clock_oddr ( .Q(clk_out_oddr), .D1(1'b1), .D2(1'b0), .C(clk_out_before_oddr), .CE(1'b1), .R(1'b0), .S(1'b0));

endmodule: MMCM_freq_multiplier
