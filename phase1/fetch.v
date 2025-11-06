module ifetch (

	input [11:0] next_pc, 	//4kb memory
	input ready,
	input clk,
	input reset,
	input pc_offset,
	output [11:0] current_pc,
	output [31:0] instruction,
	output valid
);

reg [11:0] current_pc;
reg valid;

always @(posedge clk)
begin
	if(reset)
	begin
		current_pc <=0;
		valid <=0;
	end
	else if(ready)
	begin
		if(pc_offset)
		begin
			current_pc <= next_pc;
			valid <=1;
		end
		else
		begin
			current_pc <= current_pc +4;
			valid <=1;
		end
	end
	else
	begin
		current_pc <= current_pc;
		valid <=valid;
	end
end
    // BRAM instance

    wire [31:0] bram_data_out;    
  

    blk_mem_gen_0 instr_mem (
        .clka(clk),
        .addra(current_pc),
        .douta(instruction)
    );
	
endmodule
