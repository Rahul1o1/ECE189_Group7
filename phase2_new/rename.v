module rename(
	input clk,
	input reset,
	input ready_o,
	input valid_i,
	input [31:0] pc_in,
	input [4:0] rs1,
	input [4:0] rs2,
	input [4:0] rd,
	input [31:0] immediate_in,
	input [2:0] ALUOp_in,
	input [1:0] FUType_in, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
	input ALUSrc_in,
	input immused,
	input rdused,
	input LS_in,
	input Branch,
	input Jump_in,
	input [1:0] mispredict,
	input free_flag,
	output ready_i,
	output valid_o,
	output [6:0] rs1_p,
    output [6:0] rs2_p,
    output [6:0] rd_p,
    output [3:0] rob_tag_out,
	output [31:0] pc_out,
	output [31:0] immediate_out,
	output [2:0] ALUOp_out,
	output [1:0] FUType_out, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
	output ALUSrc_out,	
	output immused_out,
	output rdused_out,
	output LS_out,
	output Branch_out,
	output Jump_out
);

wire [6:0] rd_p_fm;
wire [4:0] rs1_m;
wire [4:0] rs2_m;
wire [4:0] rd_m;
wire checkpoint_m;
wire full_flag_f;

assign rd_m = (rdused && valid_i) ? rd : 5'b00000;
assign rs1_m = (valid_i) ? rs1 : 5'b00000;
assign rs2_m = (valid_i && ((!immused) || (immused && Branch))) ? rs2 : 5'b00000;
assign rd_p = rd_p_fm;

assign pc_out = pc_in;
assign immediate_out = immediate_in;
assign ALUOp_out = ALUOp_in;
assign FUType_out = FUType_in;
assign ALUSrc_out = ALUSrc_in;
assign immused_out = immused;
assign rdused_out = rdused;
assign LS_out = LS_in;
assign Branch_out = Branch;
assign Jump_out = Jump_in;

map_table MAP_TABLE(
.clk(clk),
.reset(reset),
.rs1_a(rs1_m),
.rs2_a(rs2_m),
.rd_a(rd_m),
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
.rob_tag_out(rob_tag_out),
.valid(valid_i)
);

assign ready_i = (!(checkpoint_m || full_flag_f)) && ready_o;
assign valid_o = valid_i;

endmodule
