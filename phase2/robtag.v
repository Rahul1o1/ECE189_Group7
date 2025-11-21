module robtag(
input clk,
input reset,
input checkpoint,
output reg [3:0] rob_tag
);

reg [3:0] counter;
reg [3:0] recovery;

always @(posedge clk)
begin
	if(reset)
	begin
		rob_tag <= 0;
		counter <= 0;
		recovery <=0;
	end
	else
	begin
		if(checkpoint)
		begin
			recovery <= counter;
		end
		
		rob_tag <= counter;
		counter <= counter + 1;
	end
end

endmodule
