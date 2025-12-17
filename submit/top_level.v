`timescale 1ns / 1ps
module top_level(
input clk,
input reset,
input [31:0] jump_pc,
input pc_offset,
input ready_pwb,
input [1:0] mispredict,
input free_flag,

//From issue module
input issue_flag,

input retire_flag,
// From retire module
input  retire_valid,
input  [6:0]  retire_preg,
//input [31:0] complete_data,
//input [6:0] prd_wb,

//output ready_ep,
output valid_ep,
output [31:0] result,
output [31:0] test,
output [31:0] testx,
output [31:0] test3
);
wire free_valid;
wire signed [31:0] write_data;
wire write_flag;
wire [6:0] prd_wb;
wire [3:0] rob_tag_wbp;

wire [31:0] instruction_int;
wire [31:0] pc_int;

// BRAM instance
blk_mem_gen_0 ICACHE (
	.clka(clk),
	.addra(pc_int[11:2]),
	.douta(instruction_int)
);

wire ready_pf,valid_fp;
wire [31:0] instruction_fp;

//Fetch module
ifetch FETCH (
	.jump_pc(jump_pc), 	
	.ready(ready_pf),  //readysignal from pipeline to fetch module
	.clk(clk),
	.reset(reset),
	.instruction_int(instruction_int),
	.pc_offset(pc_offset),	// control signal to know branch/jump
	.pc(pc_int),
	.instruction_out(instruction_fp),
	.valid(valid_fp)	
);

wire [31:0] pc_pd;
wire ready_dp, valid_pd;
wire [31:0] instruction_pd;

//Pipeline reg between Fetch and Decode
pipeline_skidbuf #(.width(32)) FETCH_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_int),
    .valid_in(valid_fp),
    .ready_in(ready_pf),
    .data_out(pc_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
); 

pipeline_skidbuf #(.width(32)) FETCH_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(instruction_fp),
    .valid_in(valid_fp),
    .ready_in(ready_pf),
    .data_out(instruction_pd),
    .valid_out(valid_pd),
    .ready_out(ready_dp)
); 

wire [31:0] pc_out_dp;
wire ready_pd,valid_dp;
wire [4:0] rs1_dp,rs2_dp,rd_dp;
wire [31:0] immediate_dp;
wire [2:0] ALUOp_dp;
wire [1:0] FUType_dp;
wire ALUSrc_dp,immused_dp,rdused_dp,LS_dp,Branch_dp,Jump_dp;
wire [2:0] F3_dp;
wire F7_dp;

//Decode module
decode DECODE (

.ready_o(ready_pd),
.instruction(instruction_pd),
.pc_in(pc_pd),
.valid_i(valid_pd),
.reset(reset),
.valid_o(valid_dp),
.ready_i(ready_dp),
.pc_out(pc_out_dp),
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
.Jump(Jump_dp),
.F3(F3_dp),
.F7(F7_dp)

);

wire [31:0] pc_out_pr;
wire valid_pr,ready_rp;
wire [4:0] rs1_pr;
wire [4:0] rs2_pr;
wire [4:0] rd_pr;
wire [31:0] immediate_pr;
wire [2:0] ALUOp_pr;
wire [1:0] FUType_pr;
wire immused_pr, ALUSrc_pr,rdused_pr,LS_pr,Branch_pr,Jump_pr,F7_pr;
wire [2:0] F3_pr;

pipeline_skidbuf #(.width(32)) DECODE_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_out_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(pc_out_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(5)) DECODE_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(rs1_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(rs1_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
);
pipeline_skidbuf #(.width(5)) DECODE_PP3(
    .reset(reset),
    .clk(clk),
    .data_in(rs2_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(rs2_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(5)) DECODE_PP4(
    .reset(reset),
    .clk(clk),
    .data_in(rd_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(rd_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(32)) DECODE_PP5(
    .reset(reset),
    .clk(clk),
    .data_in(immediate_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(immediate_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(3)) DECODE_PP6(
    .reset(reset),
    .clk(clk),
    .data_in(ALUOp_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(ALUOp_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(2)) DECODE_PP7(
    .reset(reset),
    .clk(clk),
    .data_in(FUType_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(FUType_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP8(
    .reset(reset),
    .clk(clk),
    .data_in(ALUSrc_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(ALUSrc_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP9(
    .reset(reset),
    .clk(clk),
    .data_in(immused_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(immused_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP10(
    .reset(reset),
    .clk(clk),
    .data_in(rdused_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(rdused_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP11(
    .reset(reset),
    .clk(clk),
    .data_in(LS_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(LS_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP12(
    .reset(reset),
    .clk(clk),
    .data_in(Branch_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(Branch_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 
pipeline_skidbuf #(.width(1)) DECODE_PP13(
    .reset(reset),
    .clk(clk),
    .data_in(Jump_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(Jump_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
); 

pipeline_skidbuf #(.width(1)) DECODE_PP14 (
    .reset(reset),
    .clk(clk),
    .data_in(F7_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(F7_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
);
pipeline_skidbuf #(.width(3)) DECODE_PP15 (
    .reset(reset),
    .clk(clk),
    .data_in(F3_dp),
    .valid_in(valid_dp),
    .ready_in(ready_pd),
    .data_out(F3_pr),
    .valid_out(valid_pr),
    .ready_out(ready_rp)
);

wire valid_rp,ready_pr;
wire [6:0] rs1_p_rp, rs2_p_rp, rd_p_rp;
wire [3:0] rob_tag_out_rp;
wire [31:0] pc_out_rp;
wire [31:0] immediate_out_rp;
wire [2:0] ALUOp_out_rp;
wire [1:0] FUType_out_rp;
wire ALUSrc_out_rp, immused_out_rp, rdused_out_rp, LS_out_rp,Branch_out_rp,Jump_out_rp, F7_out_rp;
wire [2:0] F3_out_rp;
wire [6:0] rd_p_old_rp;
wire rs1_ready_rp, rs2_ready_rp;



rename RENAME(
.clk(clk),
.reset(reset),
.ready_o(ready_pr),
.valid_i(valid_pr),
.pc_in(pc_out_pr),
.F3(F3_pr),
.F7(F7_pr),
.rs1(rs1_pr),
.rs2(rs2_pr),
.rd(rd_pr),
.immediate_in(immediate_pr),
.ALUOp_in(ALUOp_pr),
.FUType_in(FUType_pr),
.ALUSrc_in(ALUSrc_pr),
.immused(immused_pr),
.rdused(rdused_pr),
.LS_in(LS_pr),
.Branch(Branch_pr),
.Jump_in(Jump_pr),
.mispredict(mispredict),
.free_flag(free_flag),
.ready_i(ready_rp),
.valid_o(valid_rp),
.rs1_p(rs1_p_rp),
.rs2_p(rs2_p_rp),
.rd_p(rd_p_rp),
.rob_tag_out(rob_tag_out_rp),
.pc_out(pc_out_rp),
.immediate_out(immediate_out_rp),
.ALUOp_out(ALUOp_out_rp),
.FUType_out(FUType_out_rp),
.ALUSrc_out(ALUSrc_out_rp),	
.immused_out(immused_out_rp),
.rdused_out(rdused_out_rp),
.LS_out(LS_out_rp),
.Branch_out(Branch_out_rp),
.Jump_out(Jump_out_rp),
.F3_out(F3_out_rp),
.F7_out(F7_out_rp),
.rd_p_old(rd_p_old_rp),
.rs1_ready(rs1_ready_rp),
.rs2_ready(rs2_ready_rp),
.write_flag(write_flag),
.prd_wb(prd_wb),
.free_valid(free_valid)
);

wire [31:0] pc_pdi;
wire valid_pdi;
wire [6:0] rs1_p_pdi, rs2_p_pdi, rd_p_pdi;
wire [31:0] immediate_pdi;
wire [2:0] ALUOp_pdi;
wire [1:0] FUType_pdi;
wire ALUSrc_pdi,immused_pdi,rdused_pdi, LS_pdi, Branch_pdi, Jump_pdi;
wire [3:0] rob_tag_out_pdi;
wire [2:0] F3_pdi;
wire F7_pdi,rs1_ready_pdi,rs2_ready_pdi;
wire [6:0] rd_p_old_pdi;
wire ready_dip;

pipeline_skidbuf #(.width(32)) RENAME_PP1(
    .reset(reset),
    .clk(clk),
    .data_in(pc_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(pc_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(7)) RENAME_PP2(
    .reset(reset),
    .clk(clk),
    .data_in(rs1_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs1_p_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(7)) RENAME_PP3(
    .reset(reset),
    .clk(clk),
    .data_in(rs2_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs2_p_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(7)) RENAME_PP4(
    .reset(reset),
    .clk(clk),
    .data_in(rd_p_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rd_p_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(32)) RENAME_PP5(
    .reset(reset),
    .clk(clk),
    .data_in(immediate_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(immediate_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(3)) RENAME_PP6(
    .reset(reset),
    .clk(clk),
    .data_in(ALUOp_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(ALUOp_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(2)) RENAME_PP7(
    .reset(reset),
    .clk(clk),
    .data_in(FUType_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(FUType_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP8(
    .reset(reset),
    .clk(clk),
    .data_in(ALUSrc_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(ALUSrc_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP9(
    .reset(reset),
    .clk(clk),
    .data_in(immused_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(immused_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP10(
    .reset(reset),
    .clk(clk),
    .data_in(rdused_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rdused_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP11(
    .reset(reset),
    .clk(clk),
    .data_in(LS_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(LS_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP12(
    .reset(reset),
    .clk(clk),
    .data_in(Branch_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(Branch_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP13(
    .reset(reset),
    .clk(clk),
    .data_in(Jump_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(Jump_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(4)) RENAME_PP14(
    .reset(reset),
    .clk(clk),
    .data_in(rob_tag_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rob_tag_out_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(3)) RENAME_PP15(
    .reset(reset),
    .clk(clk),
    .data_in(F3_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(F3_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);
pipeline_skidbuf #(.width(1)) RENAME_PP16(
    .reset(reset),
    .clk(clk),
    .data_in(F7_out_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(F7_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(7)) RENAME_PP17(
    .reset(reset),
    .clk(clk),
    .data_in(rd_p_old_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rd_p_old_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP18(
    .reset(reset),
    .clk(clk),
    .data_in(rs1_ready_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs1_ready_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

pipeline_skidbuf #(.width(1)) RENAME_PP19(
    .reset(reset),
    .clk(clk),
    .data_in(rs2_ready_rp),
    .valid_in(valid_rp),
    .ready_in(ready_pr),
    .data_out(rs2_ready_pdi),
    .valid_out(valid_pdi),
    .ready_out(ready_dip)
);

wire valid_dip,ready_pdi;


wire [31:0] Immediate_out_alu_dip;
wire [31:0] Immediate_out_branch_dip;
wire [31:0] Immediate_out_ls_dip;
wire ALU_src_out_alu_dip;
wire ALU_src_out_branch_dip;
wire ALU_src_out_ls_dip;
wire [2:0] ALU_op_out_dip;
wire [3:0] rob_tag_out_dip;
wire ls_out_dip;
wire br_out_dip;
wire signed [31:0] prs1_data_out_dip;
wire signed [31:0] prs2_data_out_dip;
wire [6:0] prd_out_dip;
wire rob_full_dip;
wire rob_empty_dip;
wire [2:0] F3_dip;
wire F7_dip;

dispatch DISPATCH(
    .clk(clk),
    .reset(reset),
    .p_rs1(rs1_p_pdi),
    .p_rs2(rs2_p_pdi),
    .p_rd(rd_p_pdi),
    .rob_tag(rob_tag_out_pdi),
    .PC(pc_pdi),
    .F3_ls_out(F3_ls_out),
    .F7_ls_out(F7_ls_out),
    .Immediate(immediate_pdi),
    .ALUOp(ALUOp_pdi),
    .FUType(FUType_pdi),
    .ALUSrc(ALUSrc_pdi),
    .immused(immused_pdi),
    .rdused(rdused_pdi),
    .LS(LS_pdi),
    .Branch(Branch_pdi),
    .Jump(Jump_pdi),
    .valid_i(valid_pdi),
    .rd_p_old(rd_p_old_pdi),
    .valid_o(valid_dip),
    .ready_o(ready_pdi),
    //.ready_in(ready_dip),
    .issue_flag(issue_flag),
    //.free_valid(free_valid),
    .test(test),
    .testx(testx),
    .complete_flag(write_flag),
    .retire_flag(retire_flag),
    // From retire module
    .retire_valid(retire_valid),
    .retire_preg(retire_preg),
    .complete_data(write_data),
    .prd_wb(prd_wb),
    
    .Immediate_out_alu(Immediate_out_alu_dip),
    .Immediate_out_branch(Immediate_out_branch_dip),
    .Immediate_out_ls(Immediate_out_ls_dip),
    .ALU_src_out_alu(ALU_src_out_alu_dip),
    .ALU_src_out_branch(ALU_src_out_branch_dip),
    .ALU_src_out_ls(ALU_src_out_ls_dip),
    .ALU_op_out(ALU_op_out_dip),
    .rob_tag_out(rob_tag_out_dip),
    .ls_out(ls_out_dip),
    .br_out(br_out_dip),
    .prs1_data_out(prs1_data_out_dip),
    .prs2_data_out(prs2_data_out_dip),
    .prs1_ls_data_out(prs1_ls_data_out),
    .prs2_ls_data_out(prs2_ls_data_out),
    .prd_out(prd_out_dip),
    .prd_ls_out(prd_ls_out_dip),
    .rob_full(rob_full_dip),
    .rob_empty(rob_empty_dip),

    .F3_alu_b(F3_dip),
    .F7_alu_b(F7_dip), 
     .F3_in(F3_pdi),
    .F7_in(F7_pdi),    
    .rs1_ready(rs1_ready_pdi),
    .rs2_ready(rs2_ready_pdi)
);

wire valid_pe;


wire [31:0] Immediate_out_alu_pe;
wire [31:0] Immediate_out_branch_pe;
wire [31:0] Immediate_out_ls_pe;
wire ALU_src_out_alu_pe;
wire ALU_src_out_branch_pe;
wire ALU_src_out_ls_pe;
wire [2:0] ALU_op_out_pe;
wire [3:0] rob_tag_out_pe;
wire ls_out_pe;
wire br_out_pe;
wire signed [31:0] prs1_data_out_pe;
wire signed [31:0] prs2_data_out_pe;
wire signed [31:0] prs1_ls_data_out_pe;
wire signed [31:0] prs2_ls_data_out_pe;
wire [6:0] prd_out_pe;
wire rob_full_pe;
wire rob_empty_pe;
wire [2:0] F3_pe;
wire F7_pe;
wire [2:0] F3_ls_pe;
wire F7_ls_pe;

pipeline_skidbuf #(.width(32)) DISPATCH1(
    .reset(reset),
    .clk(clk),
    .data_in(Immediate_out_alu_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(Immediate_out_alu_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH2(
    .reset(reset),
    .clk(clk),
    .data_in(Immediate_out_branch_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(Immediate_out_branch_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH3(
    .reset(reset),
    .clk(clk),
    .data_in(Immediate_out_ls_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(Immediate_out_ls_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH4(
    .reset(reset),
    .clk(clk),
    .data_in(ALU_src_out_alu_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(ALU_src_out_alu_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH5(
    .reset(reset),
    .clk(clk),
    .data_in(ALU_src_out_branch_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(ALU_src_out_branch_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH6(
    .reset(reset),
    .clk(clk),
    .data_in(ALU_src_out_ls_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(ALU_src_out_ls_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(3)) DISPATCH7(
    .reset(reset),
    .clk(clk),
    .data_in(ALU_op_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(ALU_op_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(4)) DISPATCH8(
    .reset(reset),
    .clk(clk),
    .data_in(rob_tag_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(rob_tag_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH9(
    .reset(reset),
    .clk(clk),
    .data_in(ls_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(ls_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH10(
    .reset(reset),
    .clk(clk),
    .data_in(br_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(br_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH11(
    .reset(reset),
    .clk(clk),
    .data_in(prs1_data_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(prs1_data_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH12(
    .reset(reset),
    .clk(clk),
    .data_in(prs2_data_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(prs2_data_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(7)) DISPATCH13(
    .reset(reset),
    .clk(clk),
    .data_in(prd_out_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(prd_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH14(
    .reset(reset),
    .clk(clk),
    .data_in(rob_full_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(rob_full_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH15(
    .reset(reset),
    .clk(clk),
    .data_in(rob_empty_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(rob_empty_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(3)) DISPATCH16(
    .reset(reset),
    .clk(clk),
    .data_in(F3_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(F3_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH17(
    .reset(reset),
    .clk(clk),
    .data_in(F7_dip),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(F7_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(1)) DISPATCH18(
    .reset(reset),
    .clk(clk),
    .data_in(F7_ls_out),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(F7_ls_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(3)) DISPATCH19(
    .reset(reset),
    .clk(clk),
    .data_in(F3_ls_out),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(F3_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH20(
    .reset(reset),
    .clk(clk),
    .data_in(prs1_ls_data_out),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(prs1_ls_data_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);

pipeline_skidbuf #(.width(32)) DISPATCH21(
    .reset(reset),
    .clk(clk),
    .data_in(prs2_ls_data_out),
    .valid_in(valid_dip),
    .ready_in(ready_pdi),
    .data_out(prs2_ls_data_out_pe),
    .valid_out(valid_pe),
    .ready_out(ready_ep)
);


wire [6:0] prd_out_ep;
wire [3:0] rob_tag_ep;

execute EXECUTE
(
    .clk(clk),
    .reset(reset),
    .ready_pe(ready_pe),
    .valid_pe(valid_pe),
    .valid_o(valid_ep),
    .ready_i(ready_ep),
    .Immediate_out_alu_dip(Immediate_out_alu_pe),
    .Immediate_out_branch_dip(Immediate_out_branch_pe),
    .Immediate_out_ls_dip(Immediate_out_ls_pe),
    .ALU_src_out_alu_dip(ALU_src_out_alu_pe),
    .ALU_src_out_branch_dip(ALU_src_out_branch_pe),
    .ALU_src_out_ls_dip(ALU_src_out_ls_pe),
    .ALU_op_out_dip(ALU_op_out_pe),
    .rob_tag_out_dip(rob_tag_out_pe),
    .ls_out_dip(ls_out_pe),
    .br_out_dip(br_out_pe),
    .prs1_data_out_dip(prs1_data_out_pe),
    .prs2_data_out_dip(prs2_data_out_pe),
    .prs1_ls_data_out_dip(prs1_ls_data_out_pe),
    .prs2_ls_data_out_dip(prs2_ls_data_out_pe),
    .prd_out_dip(prd_out_pe),
    .prd_ls_out_dip(prd_ls_out_pe),
    .rob_full_dip(rob_full_pe),
    .rob_empty_dip(rob_empty_pe),
    .F3_dip(F3_pe),
    .F7_dip(F7_pe),
    .result(result),
    .prd(prd_out_ep),   
    .rob_tag(rob_tag_ep),
    .F3_ls_dip(F3_ls_pe),
    .F7_ls_dip(F7_ls_pe)
);

wire [31:0] result_pwb;
wire [6:0] prd_out_pwb;
wire [3:0] rob_tag_pwb;

pipeline_skidbuf #(.width(32)) EXECUTE1(
    .reset(reset),
    .clk(clk),
    .data_in(result),
    .valid_in(valid_ep),
    .ready_in(ready_pe),
    .data_out(result_pwb),
    .valid_out(valid_pwb),
    .ready_out(ready_wbp)
);


pipeline_skidbuf #(.width(7)) EXECUTE2(
    .reset(reset),
    .clk(clk),
    .data_in(prd_out_ep),
    .valid_in(valid_ep),
    .ready_in(ready_pe),
    .data_out(prd_out_pwb),
    .valid_out(valid_pwb),
    .ready_out(ready_wbp)
);


pipeline_skidbuf #(.width(4)) EXECUTE3(
    .reset(reset),
    .clk(clk),
    .data_in(rob_tag_ep),
    .valid_in(valid_ep),
    .ready_in(ready_pe),
    .data_out(rob_tag_pwb),
    .valid_out(valid_pwb),
    .ready_out(ready_wbp)
);




writeback WRITEBACK
(
    .clk(clk),
    .reset(reset),
    .valid_pwb(valid_pwb),
    .ready_pwb(ready_pwb),
    .prd_in(prd_out_pwb),
    .write_data(result_pwb),
    .rob_tag(rob_tag_pwb),
    
    .write_flag(write_flag),
    .prd_wb(prd_wb),
    .write_data_out(write_data),
    .ready_wbp(ready_wbp)
);




//assign test2 = prd_out_dip;
assign test3 = {25'b0,rd_p_pdi};
endmodule
