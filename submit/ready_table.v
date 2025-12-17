module ready_table #(
    parameter WIDTH = 128
)(
    input clk,
    input reset,
    input set_ready,
    input clear_ready,
    input [6:0] reg_set,    // register to set/clear
    input [6:0] reg_wb,
    input [6:0] rs1,        // source 1 query
    input [6:0] rs2,        // source 2 query
    output rs1_ready,
    output rs2_ready
);

    reg ready_table [WIDTH-1:0];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < WIDTH; i = i + 1)
                ready_table[i] <= 1'b1; // all ready at reset
        end else begin
            if (set_ready)
            begin
                ready_table[reg_wb] <= 1'b1;
            end
            if (clear_ready)
            begin
                ready_table[reg_set] <= 1'b0;
            end
            ready_table[0]<=1'b1;
        end
    end

    assign rs1_ready = ready_table[rs1];
    assign rs2_ready = ready_table[rs2];

endmodule
