/**
 * @brief Red Pitaya PWM module
 *
 * @Author Matej Oblak
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */

module red_pitaya_pwm #(
  int unsigned CCW = 24,  // configuration counter width (resolution)
  bit  [8-1:0] FULL = 8'd156 // 100% value
)(
  // system signals
  input  logic           clk ,  // clock
  input  logic           rstn,  // reset
  // configuration
  input  logic [CCW-1:0] cfg ,  // 
  // PWM outputs
  output logic           pwm_o ,  // PWM output - driving RC
  output logic           pwm_s    // PWM synchronization
);

reg  [ 4-1: 0] bcnt  ;
reg  [16-1: 0] b     ;
reg  [ 8-1: 0] vcnt, vcnt_r;
reg  [ 8-1: 0] v   , v_r   ;
// add some registers to help timing closure:
reg [CCW-1:0] cfg_reg;
reg pwm_o_reg, pwm_o_reg2;

always @(posedge clk)
begin
	cfg_reg <= cfg;
end

always @(posedge clk)
begin
	if (~rstn) begin
	   vcnt      <=  8'h0;
	   bcnt      <=  4'h0;
	   //pwm_o_reg <=  1'b0;
	end else begin
	   vcnt   <= (vcnt == FULL) ? 8'h1 : (vcnt + 8'd1) ;
	   vcnt_r <= vcnt;
	   v_r    <= (v + b[0]) ; // add decimal bit to current value
	   if (vcnt == FULL) begin
		  bcnt <=  bcnt + 4'h1 ;
		  v    <= (bcnt == 4'hF) ? cfg_reg[24-1:16] : v ; // new value on 16*FULL
		  b    <= (bcnt == 4'hF) ? cfg_reg[16-1:0] : {1'b0,b[15:1]} ; // shift right
	   end

   end
   // JDD 2019-01-10: removed reset from pwm_o_reg to try to help timing.
   pwm_o_reg <= (vcnt_r <= v_r) ; // make PWM duty cycle
   pwm_o_reg2 <= pwm_o_reg; // another register layer to hopefully achieve timing closure
end

assign pwm_s = (bcnt == 4'hF) && (vcnt == (FULL-1)) ; // latch one before
assign pwm_o = pwm_o_reg2;

endmodule: red_pitaya_pwm
