module dispatch(
    input  wire        clk,
    input  wire        reset,

    // From Rename
    input  wire [6:0]  p_rs1,
    input  wire [6:0]  p_rs2,
    input  wire [6:0]  p_rd,
    input  wire [3:0]  rob_tag,
    input  wire        branch,
    input  wire        valid_i,
    output wire        valid_o,
    input  wire        ready_o,
    output wire        ready_i,

    // From ROB (retiring)
    input  wire        retire_valid,
    input  wire [6:0]  retire_preg
);

    // -----------------------------
    // Pipeline Buffer / FIFO (size 1)
    // -----------------------------
    wire [58:0] pipe_in, pipe_out;
    wire pipe_valid;
    
    assign pipe_in = {p_rd, p_rs1, p_rs2, rob_tag, branch}; 
    assign pipe_valid = valid_i;

    pipe_buf PIPE (
        .clk(clk),
        .reset(reset),
        .write_data(pipe_in),
        .write_en(valid_i),
        .read_en(ready_o), // only read if downstream RS can accept
        .read_data(pipe_out)
    );

    assign valid_o = pipe_valid;
    assign ready_i = ready_o;

    // -----------------------------
    // ROB
    // -----------------------------
    wire rob_full, rob_empty;
    rob ROB (
        .clk(clk),
        .reset(reset),
        .prd_new(p_rd),
        .prd_old(7'd0),   
        .PC(32'd0),       
        .stage(2'd0),     
        .rob_tag(rob_tag),
        .checkpoint(branch),
        .full(rob_full),
        .empty(rob_empty)
    );

    // -----------------------------
    // Reservation Stations
    // -----------------------------
    wire [6:0] alu_prd, alu_rs1, alu_rs2;
    wire alu_rs1_ready, alu_rs2_ready;
    wire [3:0] alu_rob_tag;

    rsalu RS_ALU (
        .clk(clk),
        .reset(reset),
        .stage(0),           // dispatch stage
        .prd_in(p_rd),
        .prs1_in(p_rs1),
        .prs1_readyin(1'b1), // read from PRF
        .prs2_in(p_rs2),
        .prs2_readyin(1'b1),
        .IMM_in(32'd0),
        .FU_in(1'b0),
        .rob_tag_in(rob_tag)
    );

    // Similarly for other RS will implemnt with issue

// Wires to connect PRF
wire [31:0] prs1_data, prs2_data;
wire prs1_ready, prs2_ready;

// Instantiate PRF
prf PRF (
    .clk(clk),
    .reset(reset),
    .prs1(0),      
    .prs2(0),
    .data1(prs1_data),
    .data2(prs2_data),
    .ready1(prs1_ready),
    .ready2(prs2_ready),
    .write_en(retire_valid),      // write back when ROB retires
    .prd(retire_preg),
    .write_data(32'd0)            // committed value from ROB
);

// Connect ready flags to reservation station
wire rs1_ready_to_rs = prs1_ready;
wire rs2_ready_to_rs = prs2_ready;




endmodule

