`timescale 1ns / 1ps

module priority_encoder
#(
	parameter WIDTH = 4
)
(
    input wire [WIDTH - 1: 0] in,
    output wire [$clog2(WIDTH) - 1: 0] out,
    output wire valid
    );

assign valid = |in; // input signal is invalid if all the input bits are 0
integer i;
reg flag = 0;
reg[$clog2(WIDTH) - 1: 0] out_reg = WIDTH - 1;

	always @(*) begin // combinational circuit definition
	flag = 0;
	out_reg = 0;
	for(i = WIDTH - 1; i >= 0; i = i - 1) begin // loop begins from the MSB of the input to find which is the most significant bit that is set to 1
		if((in[i] == 1) && (!flag)) begin
			flag = 1;
			out_reg = i; // output is the binary equivalent of the value i (which is in decimal), that marks the first location from the MSB that has a bit 1
		end
		else begin
			flag = flag;
			out_reg = out_reg;
		end
	end
end

assign out = out_reg;

endmodule
