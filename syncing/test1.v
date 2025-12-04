module test1(
	input clk,
	input reset,
	input pc_offset,
	input [31:0] jump_pc,
	input ready_pr,
	output valid_pr,
	output [31:0] pc_pr,
	output [4:0] rs1_pr,
	output [4:0] rs2_pr,
	output [4:0] rd_pr,
	output [31:0] immediate_pr,
	output [2:0] ALUOp_pr,
	output [1:0] FUType_pr, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
	output ALUSrc_pr,	
	output immused_pr,
	output rdused_pr,
	output LS_pr,
	output Branch_pr,
	output Jump_pr
);

//connections between icache and fetch
wire [31:0] instruction_int;
wire [31:0] pc_int;

//connections between fetch and pipeline reg
wire [31:0] pc_fp;
wire [31:0] instruction_fp;
wire ready_fp;
wire valid_fp;

//connections between pipeline reg and decode
wire [31:0] pc_pd;
wire [31:0] instruction_pd;
wire ready_pd;
wire valid_pd;

//connections between decode and pipeline reg
wire ready_dp;
wire valid_dp;
wire [31:0] pc_dp;
wire [4:0] rs1_dp;
wire [4:0] rs2_dp;
wire [4:0] rd_dp;
wire [31:0] immediate_dp;
wire [2:0] ALUOp_dp;
wire [1:0] FUType_dp; // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
wire ALUSrc_dp;
wire immused_dp;
wire rdused_dp;
wire LS_dp;
wire Branch_dp;
wire Jump_dp;


pipeline_skidbuf #(.width(32)) FETCH_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_fp),
    .valid_in(valid_fp),
    .ready_in(ready_fp),
    .data_out(pc_pd),
    .valid_out(valid_pd),
    .ready_out(ready_pd)
); 

pipeline_skidbuf #(.width(32)) FETCH_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(instruction_fp),
    .valid_in(valid_fp),
    .ready_in(ready_fp),
    .data_out(instruction_pd),
    .valid_out(valid_pd),
    .ready_out(ready_pd)
); 

// BRAM instance
blk_mem_gen_0 ICACHE (
	.clka(clk),
	.addra(pc_int[11:2]),
	.douta(instruction_int)
);

ifetch FETCH (
	.jump_pc(jump_pc), 	
	.ready(ready_fp),
	.clk(clk),
	.reset(reset),
	.instruction_int(instruction_int),
	.pc_offset(pc_offset),	// control signal to know branch/jump
	.pc(pc_fp),
	.next_pc(pc_int),
	.instruction_out(instruction_fp),
	.valid(valid_fp)	

);

decode DECODE (

.ready_o(ready_o),
.instruction(instruction_pd),
.pc_in(pc_pd),
.valid_i(valid_pd),
.reset(reset),
.valid_o(valid_o),
.ready_i(ready_pd),
.pc_out(pc_dp),
.rs1(rs1_dp),
.rs2(rs2_dp),
.rd(rd_dp),
.immediate(immediate_dp),
.ALUOp(ALUOp_dp),
.FUType(FUType_dp), // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
.ALUSrc(ALUSrc_dp),	
.immused(immused_dp),
.rdused(rdused_dp),
.LS(LS_dp),
.Branch(Branch_dp),
.Jump(Jump_dp)


);

pipeline_skidbuf #(.width(32)) DECODE_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(pc_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(5)) DECODE_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(rs1_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(rs1_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
);
pipeline_skidbuf #(.width(5)) DECODE_PP3(
    .reset(reset),
    .clk(clk),
    .data_in(rs2_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(rs2_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(5)) DECODE_PP4(
    .reset(reset),
    .clk(clk),
    .data_in(rd_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(rd_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(32)) DECODE_PP5(
    .reset(reset),
    .clk(clk),
    .data_in(immediate_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(immediate_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(3)) DECODE_PP6(
    .reset(reset),
    .clk(clk),
    .data_in(ALUOp_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(ALUOp_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(2)) DECODE_PP7(
    .reset(reset),
    .clk(clk),
    .data_in(FUType_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(FUType_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP8(
    .reset(reset),
    .clk(clk),
    .data_in(ALUSrc_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(ALUSrc_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP9(
    .reset(reset),
    .clk(clk),
    .data_in(immused_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(immused_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP10(
    .reset(reset),
    .clk(clk),
    .data_in(rdused_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(rdused_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP11(
    .reset(reset),
    .clk(clk),
    .data_in(LS_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(LS_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP12(
    .reset(reset),
    .clk(clk),
    .data_in(Branch_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(Branch_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP13(
    .reset(reset),
    .clk(clk),
    .data_in(Jump_dp),
    .valid_in(valid_dp),
    .ready_in(ready_dp),
    .data_out(Jump_pr),
    .valid_out(valid_pr),
    .ready_out(ready_pr)
); 


endmodule
