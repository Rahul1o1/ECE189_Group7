module rename (
    input  wire        clk,
    input  wire        reset,

    // from Decode
    input  wire [4:0]  a_rs1,
    input  wire [4:0]  a_rs2,
    input  wire [4:0]  a_rd,
    input  wire        branch,
    input valid_i,
    output valid_o,
    output ready_i,
    input ready_o,
    // from ROB when retiring a physical reg:
    input  wire        retire_valid,
    input  wire [6:0]  retire_preg,

    // outputs to Dispatch
    output wire [6:0]  p_rs1,
    output wire [6:0]  p_rs2,
    output wire [6:0]  p_rd,
    output wire [3:0]  rob_tag,
    output wire [6:0]  free_count
);

    wire [6:0] preg_assign;

    // -----------------------------
    // Free List
    // -----------------------------
    freelist FL (
        .clk(clk),
        .reset(reset),
        .checkpoint(branch),         // checkpoint on branch
        .operation(retire_valid),       // 0 = allocate, 1 = retire
        .preg_free(retire_preg),        // from ROB retire
        .preg_assign(preg_assign),      // new PRD
        .free_count(free_count)
    );

    assign p_rd = preg_assign;

    // -----------------------------
    // Register Map Table
    // -----------------------------
    regmap MAP (
        .clk(clk),
        .reset(reset),
        .a_rs1(a_rs1),
        .a_rs2(a_rs2),
        .a_rd(a_rd),
        .p_rd(preg_assign),
        .rename(valid_i),
        .checkpoint(branch),
        .p_rs1(p_rs1),
        .p_rs2(p_rs2)
    );

    // -----------------------------
    // ROB Tag allocator
    // -----------------------------
    robtag RT (
        .clk(clk),
        .reset(reset),
        .checkpoint(branch),
        .rob_tag(rob_tag)
    );

endmodule

