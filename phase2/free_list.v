module free_list(
	input clk,
	input reset,
	input rdused,
	input free_flag,
    output rd_p
    );
    
reg [6:0] ptr_head;
reg [6:0] ptr_tail;
reg full_flag;

assign rd_p = ptr_head;
always @(posedge clk) begin
	if(reset) begin
		ptr_head <= 7'b0000001;
		ptr_tail <= 7'b1111111;
		full_flag <= 0;
	end
	else begin
		if(rdused) begin
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
	end
end 
    
endmodule
