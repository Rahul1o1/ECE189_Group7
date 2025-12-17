module lsu(
    input clk,
    input reset,
    input valid,
    input Mem_ctrl,           // commit signal for oldest store
    input ls,             // instruction type
    input [31:0] addr,          // from address generator
    input [31:0] store_data,    // data to store
    input reg [31:0] load_data,
    output write_data
);

    // Simple 4-entry store queue
    reg [31:0] sq_addr [0:7];
    reg [31:0] sq_data [0:7];
    reg [2:0] sq_head, sq_tail;
    reg [2:0] sq_count;

    integer i;

    always @(posedge clk) begin
        if(reset) begin
            sq_head <= 0; sq_tail <= 0; sq_count <= 0;
        end
        else begin
        if(Mem_Ctrl)
        begin
            if(ls)
            begin
                
            end
            else
            begin
                
            end
        end
        end
    end
endmodule
