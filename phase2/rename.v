module rename(
	input clk,
	input reset,
	input ready_o,
	input valid_i,
	input [31:0] pc_out,
	input [4:0] rs1,
	input [4:0] rs2,
	input [4:0] rd,
	input [31:0] immediate,
	input [2:0] ALUOp,
	input [1:0] FUType, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
	input ALUSrc,	
	input immused,
	input rdused,
	input LS,
	input Branch,
	input Jump,
	input [1:0] mispredict,
	input free_flag,
	output ready_i,
	output valid_o,
	output [6:0] rs1_p,
    output [6:0] rs2_p,
    output [6:0] rd_p,
	output [6:0] rd_p_old,
    output [3:0] rob_tag_out
);

wire rd_p_fm;
wire checkpoint_m;
wire full_flag_f;

map_table MAP_TABLE(
.clk(clk),
.reset(reset),
.rs1_a(rs1),
.rs2_a(rs2),
.rd_a(rd),
.rs1_p(rs1_p),
.rs2_p(rs2_p),
.rd_p(rd_p_fm),
.Branch(Branch),
.mispredict(mispredict),
.checkpoint(checkpoint_m)
);

free_list FREE_LIST(
.clk(clk),
.reset(reset),
.rdused(rdused),
.free_flag(free_flag),
.Branch(Branch),
.mispredict(mispredict),
.rd_p(rd_p_fm),
.full_flag(full_flag_f)
);

rob_tag ROB_TAG(
.clk(clk),
.reset(reset),
.Branch(Branch),
.mispredict(mispredict),
.rob_tag_out(rob_tag_out)
);

assign ready_i = !(checkpoint_m || full_flag_f);

endmodule
