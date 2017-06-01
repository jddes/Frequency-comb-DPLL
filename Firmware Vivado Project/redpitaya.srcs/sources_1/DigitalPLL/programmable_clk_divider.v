`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:47 02/25/2014 
// Design Name: 
// Module Name:    programmable_clk_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// data_output contains the output of a programmable clock divider, which runs off the x2 clock (200 MHz)
// It has three modes: off, 50% duty cycle square wave, or 1 cycle long pulse
// mode = 2'b00 is off
// mode = 2'b01 is 50% duty cycle square wave
// mode = 2'b10 is single cycle pulse


module programmable_clk_divider(
    input  wire clk,
    input  wire [1:0] clk_divider_mode,
    input  wire [29:0] clk_divider_modulus,
	input  wire [29:0] phase_increment,
    output wire data_output
    );

reg [30-1:0] clk_divider_counter = 30'b0;
reg clk_divider_reg = 1'b0;
reg DOUT2_reg;
reg [30-1:0] reset_value = 30'b0;	// usually 0, but will be used for phase increments.
reg reset_flag = 1'b0;
reg [1:0] phase_increment_state = 2'd0;

assign data_output = DOUT2_reg;

// The counter itself and the output register
always @(posedge clk) begin
	DOUT2_reg <= clk_divider_reg;

	if (clk_divider_mode == 2'b00) begin
		// off mode:
		clk_divider_reg <= 1'b0;
		reset_flag <= 1'b0;
	end
	
	
	else if (clk_divider_mode == 2'b01) begin
		// 50% duty cycle: counts up until the max count, then toggles the output:
		if (clk_divider_counter < clk_divider_modulus) begin
			// count up
			clk_divider_counter <= clk_divider_counter + 30'b1;
			reset_flag <= 1'b0;
		end
		else begin
			clk_divider_reg <= !clk_divider_reg;	// toggle output state
			clk_divider_counter <= reset_value;	// reset counter
			reset_flag <= 1'b1;
		end
	end	
	
	
	else if (clk_divider_mode == 2'b10) begin
		// 1 cycle long pulse every time the counter hits the maximum value:
		if (clk_divider_counter < clk_divider_modulus) begin
			// count up
			clk_divider_counter <= clk_divider_counter + 30'b1;
			clk_divider_reg <= 1'b0;	// output zero the rest of the time
			reset_flag <= 1'b0;
		end
		else begin

			clk_divider_reg <= 1'b1;	// output a pulse
			clk_divider_counter <= reset_value;	// reset counter
			reset_flag <= 1'b1;
		end
	
	end
end

// the process which handles the reset_value:
// this has three modes: waiting for a new phase increment,
// waiting for the counter to take the reset_value we have just given
// waiting for the phase_increment value to go back to 0 so we can go back to the first state.
always @(posedge clk) begin
	if (phase_increment_state == 2'd0) begin
		// waiting for waiting for a new phase increment
		if (phase_increment != 30'd0) begin
			phase_increment_state <= 2'd1;
			reset_value <= phase_increment;
		end
	end
	else if (phase_increment_state == 2'd1) begin
		// an additional wait state
		phase_increment_state <= 2'd2;
	end
	else if (phase_increment_state == 2'd2) begin
		// waiting for the counter to take the reset_value we have just given
		if (reset_flag == 1'b1) begin
			phase_increment_state <= 2'd3;
			reset_value <= 30'd0;
		end
	end
	else if (phase_increment_state == 2'd3) begin
		// waiting for the phase_increment value to go back to 0 so we can go back to the first state.
		if (phase_increment == 30'd0) begin
			phase_increment_state <= 2'd0;
		end
	end
end

endmodule
