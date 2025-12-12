module dispatch(
    input clk,
    input reset,

    // From Rename
    input [6:0]  p_rs1,
    input [6:0]  p_rs2,
    input [6:0]  p_rd,
    input [3:0]  rob_tag,
    input [31:0] PC,
    input [31:0] Immediate,
    input [2:0] ALUOp,
    input [1:0] FUType,
    input ALUSrc,
    input Immused,
    input rdused,
    input LS,
    input Branch,
    input Jump,
    input valid_i,
    input rd_p_old,
    output valid_o,
    input  ready_o,
    output ready_i,

    //From issue module
    input issue_flag,
    
    input complete_flag,
    input retire_flag,
    // From retire module
    input  retire_valid,
    input  [6:0]  retire_preg,
    input complete_data,
    
    output Immediate_out,
    output ALU_src_out,
    output ALU_op_out,
    output rob_tag_out,
    output ls_out,
    output br_out,
    output prs1_data_out,
    output prs2_data_out,
    output prd_out
);

    wire [6:0] p_rs1_b;
    wire [6:0] p_rs2_b;
    wire [6:0] p_rd_b;
    wire [3:0] rob_tag_b;
    wire [31:0] Immediate_b;
    wire [2:0] ALUOp_b;
    wire ALUSrc_b;
    wire LS_b;
    wire Branch_b;
    wire Jump_b;
    wire free_valid_b;
    
    pipe_buf #(.width(7)) PIPE1 (
        .clk(clk),
        .reset(reset),
        .write_data(p_rs1),
        .read_en(free_valid_b), 
        .read_data(p_rs1_b)
    );
    
    pipe_buf #(.width(7)) PIPE2 (
        .clk(clk),
        .reset(reset),
        .write_data(p_rs2),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(p_rs2_b)
    );

    pipe_buf #(.width(7)) PIPE3 (
        .clk(clk),
        .reset(reset),
        .write_data(p_rd),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(p_rd_b)
    );
    
    pipe_buf #(.width(4)) PIPE4 (
        .clk(clk),
        .reset(reset),
        .write_data(rob_tag),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(rob_tag_b)
    );

    pipe_buf #(.width(32)) PIPE5 (
        .clk(clk),
        .reset(reset),
        .write_data(Immediate),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(Immediate_b)
    );
    pipe_buf #(.width(3)) PIPE6 (
        .clk(clk),
        .reset(reset),
        .write_data(ALUOp),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(ALUOp_b)
    );
    pipe_buf #(.width(1)) PIPE7 (
        .clk(clk),
        .reset(reset),
        .write_data(ALUSrc),
        .read_en(free_valid_b), // only read if downstream RS can accept
        .read_data(ALUSrc_b)
    );

    pipe_buf #(.width(1)) PIPE8 (
        .clk(clk),
        .reset(reset),
        .write_data(LS),
        .read_en(1'b1), // only read if downstream RS can accept
        .read_data(LS_b)
    );
    
    pipe_buf #(.width(1)) PIPE9 (
        .clk(clk),
        .reset(reset),
        .write_data(Branch),
        .read_en(1'b1), // only read if downstream RS can accept
        .read_data(Branch_b)
    );

    pipe_buf #(.width(1)) PIPE10 (
        .clk(clk),
        .reset(reset),
        .write_data(Jump),
        .read_en(1'b1), // only read if downstream RS can accept
        .read_data(Jump_b)
    );

    pipe_buf #(.width(1)) FUType (
        .clk(clk),
        .reset(reset),
        .write_data(FUType),
        .read_en(1'b1), // only read if downstream RS can accept
        .read_data(FUType_b)
    );

    wire free_valid_ls, free_valid_branch, free_valid_alu;   
    assign free_valid_b = (LS)? free_valid_ls : ((Branch || Jump)? free_valid_branch : free_valid_alu);
    
     // -----------------------------
    // Reservation Stations
    // -----------------------------
    wire rf_rs1_ready, rf_rs2_ready;
    wire rf_rs1_in, rf_rs2_in;

    rsalu RS_ALU (
        .clk(clk),
        .reset(reset),
        .dispatch_flag(!FUType_b),           // dispatch stage
        .issue_flag(issue_flag),
        .prd_in(p_rd_b),
        .prs1_in(p_rs1_b),
        .prs1_readyin(rf_rs1_ready), // read from PRF
        .prs2_in(p_rs2_b),
        .prs2_readyin(rf_rs2_ready),
        .prd_out(prd_out_rs),
        .IMM_in(Immediate_b),
        .ALU_src_in(ALUSrc_b),
        .ALU_op_in(ALUOp_b),
        .rob_tag_in(rob_tag_b),
	.prs1_out(rf_rs1_in),
	.prs2_out(rf_rs2_in),
	.IMM_out(Immediate_out),
	.ALU_src_out(ALU_src_out),
	.ALU_op_out(ALU_op_out),
	.rob_tag_out(rob_tag_out),
	.free_valid(free_valid_alu)       
    );

    rsls RS_ls (
        .clk(clk),
        .reset(reset),
        .dispatch_flag(FUType_b == 2'b1),           // dispatch stage
        .issue_flag(issue_flag),
        .prd_in(p_rd_b),
        .prs1_in(p_rs1_b),
        .prs1_readyin(rf_rs1_ready), // read from PRF
        .prs2_in(p_rs2_b),
        .prs2_readyin(rf_rs2_ready),
        .prd_out(prd_out_rs),
        .IMM_in(Immediate_b),
        .ALU_src_in(ALUSrc_b),
        .ALU_op_in(ALUOp_b),
        .rob_tag_in(rob_tag_b),
	.prs1_out(rf_rs1_in),
	.prs2_out(rf_rs2_in),
	.IMM_out(Immediate_out),
	.ALU_src_out(ALU_src_out),
	.ls_out(ls_out),
	.rob_tag_out(rob_tag_out),
	.free_valid(free_valid_ls)       
    );
    rsbranch RS_branch (
        .clk(clk),
        .reset(reset),
        .dispatch_flag(FUType_b == 2'b10 || FU_Type_b == 2'b11),           // dispatch stage
        .issue_flag(issue_flag),
        .prd_in(p_rd_b),
        .prd_out(prd_out_rs),
        .prs1_in(p_rs1_b),
        .prs1_readyin(rf_rs1_ready), // read from PRF
        .prs2_in(p_rs2_b),
        .prs2_readyin(rf_rs2_ready),
        .IMM_in(Immediate_b),
        .ALU_src_in(ALUSrc_b),
        .ALU_op_in(ALUOp_b),
        .rob_tag_in(rob_tag_b),
	.prs1_out(rf_rs1_in),
	.prs2_out(rf_rs2_in),
	.IMM_out(Immediate_out),
	.ALU_src_out(ALU_src_out),
	.br_out(br_out),
	.rob_tag_out(rob_tag_out),
	.free_valid(free_valid_branch)       
    );
    
    // -----------------------------
    // ROB
    // -----------------------------
    wire rob_full, rob_empty;
    rob ROB (
        .clk(clk),
        .reset(reset),
        .prd_new(p_rd_b),
        .prd_old(rd_p_old),   
        .PC(PC),       
        .dispatch_flag(ready_o),
        .complete_flag(complete_flag),
        .retire_flag(retire_flag),     
        .rob_tag(rob_tag),
        .checkpoint(Branch),
        .full(rob_full),
        .empty(rob_empty)
    );

// Wires to connect PRF
wire [31:0] prs1_data;
wire [31:0] prs2_data;
wire prs1_ready, prs2_ready;

// Instantiate PRF
prf PRF (
    .clk(clk),
    .reset(reset),
    .prs1(p_rs1),      
    .prs2(p_rs2),
    .data1(prs1_data_out),
    .data2(prs2_data_out),
    .ready1(rf_rs1_ready),
    .ready2(rf_rs2_ready),
    .write_en(retire_valid),      // write back when ROB retires
    .prd(prd_out_rs),
    .write_data(complete_data),
    .ready_en(issue_flag)            // committed value from ROB
);

assign prd_out = prd_out_rs;
endmodule
