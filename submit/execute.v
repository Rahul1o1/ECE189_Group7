`timescale 1ns / 1ps

module execute
(
input clk,
input reset,
input ready_pe,
input valid_pe,
input [31:0] Immediate_out_alu_dip,
input [31:0] Immediate_out_branch_dip,
input [31:0] Immediate_out_ls_dip,
input ALU_src_out_alu_dip,
input ALU_src_out_branch_dip,
input ALU_src_out_ls_dip,
input [2:0] ALU_op_out_dip,
input [3:0] rob_tag_out_dip,
input ls_out_dip,
input br_out_dip,
input [31:0] prs1_data_out_dip,
input [31:0] prs2_data_out_dip,
input [6:0] prd_out_dip,
input rob_full_dip,
input rob_empty_dip,
input [2:0] F3_dip,
input F7_dip,
input [2:0] F3_ls_dip,
input F7_ls_dip,
input [31:0] prs1_ls_data_out_dip,
input [31:0] prs2_ls_data_out_dip,
input [6:0] prd_ls_out_dip,
output signed [31:0] result,
output valid_o,
output ready_i,
output [6:0] prd,
output [3:0] rob_tag
);
reg [31:0] alu_in2;
wire [2:0] ALUCtrl;

assign rob_tag = rob_tag_out_dip;
assign prd = prd_out_dip;
// ALU Controller
alu_controller ALU_CTRL(
    .F7(F7_dip),
    .F3(F3_dip),
    .ALUOp(ALU_op_out_dip),
    .ALUCtrl(ALUCtrl)
);

// Select second ALU operand
always @(*) begin
    alu_in2 = (ALU_src_out_alu_dip) ? Immediate_out_alu_dip : prs2_data_out_dip;
end

// ALU instance
alu ALU_INST(
    .in1(prs1_data_out_dip),
    .in2(alu_in2),
    .ALUCtrl(ALUCtrl),
    .out(result)
);

wire MemCtrl_exec;  


memory_controller MEM_CTRL_INST (
    .F3(F3_ls_dip),
    .MemCtrl(MemCtrl_exec)
);

wire [31:0] mem_addr;

memory_generator ADDR_GEN (
    .base(prs1_ls_data_out_dip),   // e.g., the source register value
    .offset(Immediate_out_ls_dip),  // LS immediate
    .addr(mem_addr)
);


wire [31:0] lsu_load_data;
wire lsu_ready;

/*lsu LSU_INST (
    .clk(clk),
    .reset(reset),
    .valid(valid_pe),
    .retire_flag(retire_flag_from_rob), 
    .F3(F3_ls_dip),
    .addr(mem_addr),
    .store_data(prs2_ls_data_out_dip),
    .load_data(lsu_load_data),
    .mem_ready(lsu_ready)
);



*/
assign valid_o = valid_pe;
assign ready_i = ready_pe;
endmodule
