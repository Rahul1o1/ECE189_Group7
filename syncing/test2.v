module test2(
	input clk,
	input reset,
	input ready_dp,
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
	output valid_pd,
	output [6:0] rs1_p_pd,
    output [6:0] rs2_p_pd,
    output [6:0] rd_p_pd,
    output [3:0] rob_tag_out_pd,
	output [31:0] pc_pd,
	output [31:0] immediate_pd,
	output [2:0] ALUOp_pd,
	output [1:0] FUType_pd, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
	output ALUSrc_pd,	
	output immused_pd,
	output rdused_pd,
	output LS_pd,
	output Branch_pd,
	output Jump_pd
    );

wire ready_pr;//
wire valid_rp;//
wire [6:0] rs1_p_rp;//
wire [6:0] rs2_p_rp;//
wire [6:0] rd_p_rp;//
wire [3:0] rob_tag_out_rp;//
wire [31:0] pc_rp;//
wire immediate_rp;//
wire [2:0] ALUOp_rp;//
wire [1:0] FUType_rp;//
wire ALUSrc_rp;//
wire immused_rp;//
wire rdused_rp;//
wire LS_rp;//
wire Branch_rp;//
wire Jump_rp;//

rename RENAME(
.clk(clk),
.reset(reset),
.ready_o(ready_pr),
.valid_i(valid_i),
.pc_in(pc_in),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.immediate_in(immediate_in),
.ALUOp_in(ALUOp_in),
.FUType_in(FUType_in),
.ALUSrc_in(ALUSrc_in),
.immused(immused),
.rdused(rdused),
.LS_in(LS_in),
.Branch(Branch),
.Jump_in(Jump_in),
.mispredict(mispredict),
.free_flag(free_flag),
.ready_i(ready_i),
.valid_o(valid_rp),
.rs1_p(rs1_p_rp),
.rs2_p(rs2_p_rp),
.rd_p(rd_p_rp),
.rob_tag_out(rob_tag_out_rp),
.pc_out(pc_rp),
.immediate_out(immediate_rp),
.ALUOp_out(ALUOp_rp),
.FUType_out(FUType_rp),
.ALUSrc_out(ALUSrc_rp),	
.immused_out(immused_rp),
.rdused_out(rdused_rp),
.LS_out(LS_rp),
.Branch_out(Branch_rp),
.Jump_out(Jump_rp)
);

pipeline_skidbuf #(.width(32)) RENAME_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(pc_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(7)) RENAME_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(rs1_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs1_p_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(7)) RENAME_PP3(
    .reset(reset),
    .clk(clk),
    .data_in(rs2_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs2_p_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(7)) RENAME_PP4(
    .reset(reset),
    .clk(clk),
    .data_in(rd_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rd_p_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(32)) RENAME_PP5(
    .reset(reset),
    .clk(clk),
    .data_in(immediate_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(immediate_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(3)) RENAME_PP6(
    .reset(reset),
    .clk(clk),
    .data_in(ALUOp_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(ALUOp_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(2)) RENAME_PP7(
    .reset(reset),
    .clk(clk),
    .data_in(FUType_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(FUType_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP8(
    .reset(reset),
    .clk(clk),
    .data_in(ALUSrc_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(ALUSrc_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP9(
    .reset(reset),
    .clk(clk),
    .data_in(immused_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(immused_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP10(
    .reset(reset),
    .clk(clk),
    .data_in(rdused_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rdused_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP11(
    .reset(reset),
    .clk(clk),
    .data_in(LS_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(LS_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP12(
    .reset(reset),
    .clk(clk),
    .data_in(Branch_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(Branch_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(1)) RENAME_PP13(
    .reset(reset),
    .clk(clk),
    .data_in(Jump_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(Jump_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);

pipeline_skidbuf #(.width(4)) RENAME_PP14(
    .reset(reset),
    .clk(clk),
    .data_in(rob_tag_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rob_tag_out_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
);
endmodule
