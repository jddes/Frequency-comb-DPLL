
`default_nettype none

module fast_arctan #(
)(
    input  wire                clk,
    input  wire                ce,

    input  wire signed [15:0]  input_x,
    input  wire signed [15:0]  input_y,

    output reg  signed [19:0]  angle
);

////////////////////////////////////////////////////////////////
// Coarse rotation
reg signed [16:0] ext_input_x   = {17{1'b0}};
reg signed [16:0] ext_input_y   = {17{1'b0}};
reg        [3:0]  cv            = 4'b0000;
reg signed [16:0] cr_x          = {17{1'b0}};
reg signed [16:0] cr_y          = {17{1'b0}};
reg signed [19:0] base_angle    = 20'h00000;
reg               mirrored      = 1'b0;

always @(*) begin
    ext_input_x <= input_x;
    ext_input_y <= input_y;
    cv[3] <= (ext_input_x >= 0);
    cv[2] <= (ext_input_y >= 0);
    cv[1] <= (ext_input_y >   ext_input_x);
    cv[0] <= (ext_input_y >= -ext_input_x);
    case (cv) 
        4'b1101 : begin cr_x <=  ext_input_x; cr_y <=  ext_input_y; base_angle <= 20'h00000; mirrored <= 1'b0; end 
        4'b1111 : begin cr_x <=  ext_input_y; cr_y <=  ext_input_x; base_angle <= 20'h40000; mirrored <= 1'b1; end 
        4'b0111 : begin cr_x <=  ext_input_y; cr_y <= -ext_input_x; base_angle <= 20'h40000; mirrored <= 1'b0; end 
        4'b0110 : begin cr_x <= -ext_input_x; cr_y <=  ext_input_y; base_angle <= 20'h80000; mirrored <= 1'b1; end 
        4'b0010 : begin cr_x <= -ext_input_x; cr_y <= -ext_input_y; base_angle <= 20'h80000; mirrored <= 1'b0; end 
        4'b0000 : begin cr_x <= -ext_input_y; cr_y <= -ext_input_x; base_angle <= 20'hC0000; mirrored <= 1'b1; end 
        4'b1000 : begin cr_x <= -ext_input_y; cr_y <=  ext_input_x; base_angle <= 20'hC0000; mirrored <= 1'b0; end 
        4'b1001 : begin cr_x <=  ext_input_x; cr_y <= -ext_input_y; base_angle <= 20'h00000; mirrored <= 1'b1; end 
        default : begin cr_x <=  ext_input_x; cr_y <=  ext_input_y; base_angle <= 20'h00000; mirrored <= 1'b0; end 
    endcase 
end

////////////////////////////////////////////////////////////////
// Pipeline registers (level 0)
reg signed [16:0] reg0_cr_x         = {17{1'b0}};
reg signed [16:0] reg0_cr_y         = {17{1'b0}};
reg signed [19:0] reg0_base_angle   = 20'h00000;
reg               reg0_mirrored     = 1'b0;
always @(posedge clk) begin
    if (ce) begin
        reg0_cr_x       <= cr_x;
        reg0_cr_y       <= cr_y;
        reg0_base_angle <= base_angle;
        reg0_mirrored   <= mirrored;
    end
end

////////////////////////////////////////////////////////////////
// Automatic Gain
reg signed [16:0] agc0_x = {17{1'b0}};
reg signed [16:0] agc0_y = {17{1'b0}};
reg signed [16:0] agc1_x = {17{1'b0}};
reg signed [16:0] agc1_y = {17{1'b0}};
reg signed [16:0] agc2_x = {17{1'b0}};
reg signed [16:0] agc2_y = {17{1'b0}};
reg signed [16:0] agc3_x = {17{1'b0}};
reg signed [16:0] agc3_y = {17{1'b0}};
reg signed [16:0] agc4_x = {17{1'b0}};
reg signed [16:0] agc4_y = {17{1'b0}};

always @(*) begin
    // Assign input
    agc0_x <= reg0_cr_x;
    agc0_y <= reg0_cr_y;
    // << 8
    if (agc0_x[16:7] == 10'b0000000000 && agc0_y[16:7] == 10'b0000000000) begin
        agc1_x <= (agc0_x << 8);
        agc1_y <= (agc0_y << 8);
    end else begin
        agc1_x <= agc0_x;
        agc1_y <= agc0_y;
    end
    // << 4
    if (agc1_x[16:11] == 6'b000000 && agc1_y[16:11] == 6'b000000) begin
        agc2_x <= (agc1_x << 4);
        agc2_y <= (agc1_y << 4);
    end else begin
        agc2_x <= agc1_x;
        agc2_y <= agc1_y;
    end
    // << 2
    if (agc2_x[16:13] == 4'b0000 && agc2_y[16:13] == 4'b0000) begin
        agc3_x <= (agc2_x << 2);
        agc3_y <= (agc2_y << 2);
    end else begin
        agc3_x <= agc2_x;
        agc3_y <= agc2_y;
    end
    // << 1
    if (agc3_x[16:14] == 3'b000 && agc3_y[16:14] == 3'b000) begin
        agc4_x <= (agc3_x << 1);
        agc4_y <= (agc3_y << 1);
    end else begin
        agc4_x <= agc3_x;
        agc4_y <= agc3_y;
    end
end

////////////////////////////////////////////////////////////////
// LUT 1

wire [9:0] addr1 = agc4_x[13:4];

// Synch register for the address
reg addr1_msb_delayed = 0;
always @(posedge clk) begin
    if (ce) begin
        addr1_msb_delayed <= ~(agc4_x[14]);
    end
end

// The RAM + an extra last value
localparam [31:0] LUT1_last = 32'h001FFE20;
wire [31:0] LUT1_rdata;
RAM_1W2R #(
    .INIT_FILE  ("fast_arctan_LUT1.mif"),
    .ADDR_BITS  (10                    ),
    .DATA_BITS  (32                    )
) LUT1 (
    .clk        (clk                ),
    .addr_a     (addr1              ),
    .clken_a    (ce                 ),
    .data_o_a   (LUT1_rdata         ),
    .uflag_a    (                   ),
    .wren_a     (1'b0               ),
    .data_i_a   (32'h00000000       ),
    .addr_b     (10'b0000000000     ),
    .clken_b    (1'b0               ),
    .data_o_b   (                   ),
    .uflag_b    (                   )
);

// Unpacking values
reg [22:0] reciprocal = 23'd0;
always @(*) begin
    if (addr1_msb_delayed) begin
        reciprocal <= LUT1_last[22:0];
    end else begin
        reciprocal <= LUT1_rdata[22:0];
    end
end

////////////////////////////////////////////////////////////////
// LUT1 Synch registers (level 1)
reg signed [16:0] reg1_agc4_x       = {17{1'b0}};
reg signed [16:0] reg1_agc4_y       = {17{1'b0}};
reg signed [19:0] reg1_base_angle   = 20'h00000;
reg               reg1_mirrored     = 1'b0;
always @(posedge clk) begin
    if (ce) begin
        reg1_agc4_x     <= agc4_x;
        reg1_agc4_y     <= agc4_y;
        reg1_base_angle <= reg0_base_angle;
        reg1_mirrored   <= reg0_mirrored;
    end
end

////////////////////////////////////////////////////////////////
// Normalization (target: x = 1)

(* use_dsp48 = "yes" *)
reg signed [39:0] norm_x = {40{1'b0}};
(* use_dsp48 = "yes" *)
reg signed [39:0] norm_y = {40{1'b0}};

// always @(*) begin
//     norm_x <= reg1_agc4_x*reciprocal;
//     norm_y <= reg1_agc4_y*reciprocal;
// end
always @(posedge clk) begin
    if (ce) begin
        norm_x <= reg1_agc4_x*reciprocal;
        norm_y <= reg1_agc4_y*reciprocal;
    end
end

////////////////////////////////////////////////////////////////
// Pipeline registers (level 2)

// reg signed [39:0] reg2_norm_x = {40{1'b0}};
// reg signed [39:0] reg2_norm_y = {40{1'b0}};
reg signed [19:0] reg2_base_angle   = 20'h00000;
reg               reg2_mirrored     = 1'b0;
always @(posedge clk) begin
    if (ce) begin
        // reg2_norm_x <= norm_x;
        // reg2_norm_y <= norm_y;
        reg2_base_angle <= reg1_base_angle;
        reg2_mirrored   <= reg1_mirrored;
    end
end

////////////////////////////////////////////////////////////////
// LUT 2
// wire [9:0] addr2 = reg2_norm_y[35:26];
wire [9:0] addr2 = norm_y[35:26];

reg addr2_msb_delayed = 0;
always @(posedge clk) begin
    if (ce) begin
        // addr2_msb_delayed <= reg2_norm_y[36];
        addr2_msb_delayed <= norm_y[36];
    end
end

localparam [31:0] LUT2_last = 32'h51480000;
wire [31:0] LUT2_rdata;
RAM_1W2R #(
    .INIT_FILE  ("fast_arctan_LUT2.mif"),
    .ADDR_BITS  (10                    ),
    .DATA_BITS  (32                    )
) LUT2 (
    .clk        (clk                ),
    .addr_a     (addr2              ),
    .clken_a    (ce                 ),
    .data_o_a   (LUT2_rdata         ),
    .uflag_a    (                   ),
    .wren_a     (1'b0               ),
    .data_i_a   (32'h00000000       ),
    .addr_b     (10'b0000000000     ),
    .clken_b    (1'b0               ),
    .data_o_b   (                   ),
    .uflag_b    (                   )
);

// Unpacking values
reg signed [23:0] relative_angle = 24'd0;
reg signed [6:0] correction_gain_x = 7'd0;
reg signed [6:0] correction_gain_y = 7'd0;
always @(*) begin
    if (addr2_msb_delayed) begin
        relative_angle <= {2'b00, LUT2_last[19:0], 2'b00};
        correction_gain_x <= {1'b0, LUT2_last[25:20]};
        correction_gain_y <= {1'b0, LUT2_last[31:26]};
    end else begin
        relative_angle <= {2'b00, LUT2_rdata[19:0], 2'b00};
        correction_gain_x <= {1'b0, LUT2_rdata[25:20]};
        correction_gain_y <= {1'b0, LUT2_rdata[31:26]};
    end
end

////////////////////////////////////////////////////////////////
// LUT2 synch registers (level 3)

reg signed [39:0] reg3_norm_x = {40{1'b0}};
reg signed [39:0] reg3_norm_y = {40{1'b0}};
reg signed [19:0] reg3_base_angle   = 20'h00000;
reg               reg3_mirrored     = 1'b0;
always @(posedge clk) begin
    if (ce) begin
        // reg3_norm_x     <= reg2_norm_x;
        // reg3_norm_y     <= reg2_norm_y;
        reg3_norm_x     <= norm_x;
        reg3_norm_y     <= norm_y;
        reg3_base_angle <= reg2_base_angle;
        reg3_mirrored   <= reg2_mirrored;
    end
end


////////////////////////////////////////////////////////////////
// Final multiplication

wire signed [6:0] offset_x = -$signed(reg3_norm_x[26:20]);
wire signed [6:0] offset_y = {1'b0, reg3_norm_y[25:20]};

(* use_dsp48 = "yes" *)
reg signed [23:0] correction_x = 24'd0;
(* use_dsp48 = "yes" *)
reg signed [23:0] correction_y = 24'd0;

// always @(*) begin
//     correction_x <= correction_gain_x*offset_x;
//     correction_y <= correction_gain_y*offset_y;
// end

always @(posedge clk) begin
    if (ce) begin
        correction_x <= correction_gain_x*offset_x;
        correction_y <= correction_gain_y*offset_y;
    end
end

////////////////////////////////////////////////////////////////
// Pipeline registers (level 4)

// reg signed [23:0] reg4_correction_x = 24'd0;
// reg signed [23:0] reg4_correction_y = 24'd0;
reg signed [23:0] reg4_relative_angle = 24'd0;
reg signed [19:0] reg4_base_angle   = 20'h00000;
reg               reg4_mirrored     = 1'b0;


// always @(*) begin
//     reg4_correction_x <= correction_x;
//     reg4_correction_y <= correction_y;
// end

always @(posedge clk) begin
    if (ce) begin
        reg4_relative_angle <= relative_angle;
        reg4_base_angle <= reg3_base_angle;
        reg4_mirrored   <= reg3_mirrored;
    end
end


reg signed [23:0] partial_angle = 24'd0;

always @(*) begin
    // partial_angle <= reg4_relative_angle + reg4_correction_x + reg4_correction_y;
    partial_angle <= reg4_relative_angle + correction_x + correction_y;
    if (reg4_mirrored) begin
        angle <= reg4_base_angle - partial_angle[23:4];
    end else begin
        angle <= reg4_base_angle + partial_angle[23:4];
    end
end

endmodule

`default_nettype wire
