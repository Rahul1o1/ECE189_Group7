module ifetch (

	input [31:0] jump_pc, 	
	input ready,
	input clk,
	input reset,
	input [31:0] instruction_int, //connection to icache
	input pc_offset,	// control signal to know branch/jump
	output reg [31:0] pc,
	output reg [31:0] next_pc,
	output [31:0] instruction_out,
	output reg valid
);

//assign valid = (reset)? 0 : 1;
assign instruction_out = (reset)? 0: instruction_int;

always @(*)
begin
	if(ready)
	begin
		next_pc = (pc_offset)? (jump_pc) : (pc +4) ;
	end
	else
	begin
		next_pc = pc;
	end
end


always @(posedge clk)
begin
	if(reset)
	begin
		valid <= 0;
		pc <= 0;
	end
	else
	begin
		valid <= 1;
		pc <= next_pc;
	end
end
endmodule
