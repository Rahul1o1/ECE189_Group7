`timescale 1ns / 1ps
module writeback
(
    input clk,
    input reset,
    input valid_pwb,
    input ready_pwb,
    input [6:0] prd_in,
    input signed [31:0] write_data,
    input [3:0] rob_tag,
    
    output reg write_flag,
    output reg [6:0] prd_wb,
    output reg signed [31:0] write_data_out,
    output reg ready_wbp
);

always @(posedge clk) begin
    if(reset) begin
        write_flag <= 0;
        prd_wb <= 7'b0;
        write_data_out <= 32'b0;
        ready_wbp <= 1;
    end else begin
            write_flag <= 1;
            prd_wb <= prd_in;
            write_data_out <= write_data;
            ready_wbp <= 1;
    end
end

endmodule
