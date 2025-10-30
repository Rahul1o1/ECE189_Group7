module skid_buffer(
    input clk,
    input reset,
    
    input valid_in,
    input [3:0] data_in,
    output ready_in,// registered signals
    
    input ready_out,
    output valid_out,
    output [3:0] data_out// combinatorial signals
    );
    
    reg [3:0] data_out;
    reg ready_in, valid_out;
    
    always @(posedge clk)
    begin
    	if(reset)
    	begin
    		
    	end
    end
    
    
endmodule
