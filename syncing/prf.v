module prf (
    input clk,
    input reset,
    // Source read ports
    input [6:0] prs1,           // Source register 1 for issuing
    input [6:0] prs2,           // Source register 2 for issuing
    output reg [31:0] data1,    // Data from prs1
    output reg [31:0] data2,    // Data from prs2
    output reg ready1,          // Ready flag for prs1
    output reg ready2,          // Ready flag for prs2

    // Destination write port
    input write_en,		//should come from writeback?
    input [6:0] prd,            // Destination register
    input [31:0] write_data,
    input ready_en		
);

    // 128-entry register file
    reg [31:0] regfile [0:127];
    reg ready [0:127];

    integer i;

    // Reset logic
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 128; i = i + 1) begin
                regfile[i] <= 32'b0;
                ready[i] <= 1'b1;  // all registers start ready
            end
        end
        else begin
            if(write_en) begin
                regfile[prd] <= write_data;
                ready[prd] <= 1'b1;
            end
            if(ready_en)
            begin
            	ready[prd] <= 1'b0;
            end
		ready1 <= ready[prs1];
        	ready2 <= ready[prs2];
        end
    end

    // Combinational read logic
    always @(*) begin
        data1 = regfile[prs1];
        data2 = regfile[prs2];

    end

endmodule
