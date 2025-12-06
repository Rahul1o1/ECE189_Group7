module rob_tag(
	input clk,
	input reset,
	input Branch,
	input [1:0] mispredict,
	output reg [3:0] rob_tag_out
);

reg [3:0] recovery;
reg checkpoint;

always @(posedge clk)
begin
	if(reset) begin
		rob_tag_out <= 0;
		recovery <= 0;
		checkpoint <= 0;
	end
	
	else begin
		
		rob_tag_out <= rob_tag_out + 1;
		
		if(Branch && (!checkpoint)) begin
			recovery <= rob_tag_out;
			checkpoint <= 1;
		end
		
		if(mispredict == 2'b01) begin
			rob_tag_out <= recovery;
			checkpoint <= 0;
		end
		
		if((mispredict == 2'b10) && checkpoint) begin
			checkpoint <= 0;
		end
	end
end

endmodule