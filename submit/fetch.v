module ifetch (
    input [31:0] jump_pc,    
    input ready,
    input clk,
    input reset,
    input [31:0] instruction_int, // connection to icache
    input pc_offset,              // control signal to know branch/jump
    output reg [31:0] pc,
    output [31:0] instruction_out,
    output reg valid
);

// Instruction output directly from memory
assign instruction_out = (reset) ? 0 : instruction_int;

always @(posedge clk) 
begin
    if (reset) 
    begin
        valid <= 0;
        pc <= 0;
    end 
    else
    begin
        if(ready)
        begin
            pc<= (pc_offset) ? jump_pc : (pc + 4);
            valid <= 1;
        end
    end
end

endmodule
