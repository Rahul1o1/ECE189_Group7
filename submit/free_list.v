module free_list(
	input clk,
	input reset,
	input ready,
	input rdused,
	input free_flag,
	input Branch,
	input [1:0] mispredict,
    output [6:0] rd_p,
    output reg full_flag
    );
    
reg [6:0] ptr_head;
reg [6:0] ptr_tail;
reg [6:0] ptr_recovery;
reg checkpoint;
assign rd_p = ptr_head;

always @(posedge clk) begin
	if(reset) begin
		ptr_head <= 7'b0000001;
		ptr_tail <= 7'b1111111;
		ptr_recovery <= 7'b0000001;
		full_flag <= 0;
		checkpoint <= 0;
	end
	else begin
	
		if(rdused && ready) begin
			if(ptr_head == 7'b1111111) begin
				ptr_head <= 7'b0000001; 
			end
			else begin
				ptr_head <= ptr_head + 1;
			end
			
			if(ptr_head == ptr_tail) begin
				full_flag <= 1;
			end
		end
		
		if(free_flag) begin
			if(ptr_tail == 7'b1111111) begin
				ptr_tail <= 7'b0000001; 
			end
			else begin
				ptr_tail <= ptr_tail + 1;
			end
			
			full_flag <= 0;
		end
		
		if(Branch && (!checkpoint)) begin
			ptr_recovery <= ptr_head;
			checkpoint <= 1;
		end
		
		if(mispredict == 2'b01) begin
			ptr_head <= ptr_recovery;
			checkpoint <= 0;
		end
		
		if((mispredict == 2'b10) && checkpoint) begin
			checkpoint <= 0;
		end
	end
end 
    
endmodule
