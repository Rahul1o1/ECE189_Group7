module freelist(
input clk,
input reset,
input checkpoint,
input operation,	//0 for assigning and 1 for retiring
input [6:0] preg_free,
output reg [6:0] preg_assign,
output reg [6:0] free_count //if no free reg for next inst we need to stall
);

reg [6:0] head;
reg [6:0] recover;

always @(posedge clk)
begin
	if(reset)
	begin
		head <= 7'b0100000;
		free_count <= 7'b1100000;
		recover <= 7'b0100000;
		preg_assign <= 7'b0;
	end
	else
	begin
		preg_assign <= head;
		if(checkpoint)
		begin
			recover <= head;
		end
		if(!operation)
		begin
			free_count <= free_count - 1;	
			head <= (head == 7'b1111111) ? 7'b0100000: head + 1;
		end
		else
		begin
			free_count <= free_count + 1;
		end
	end
end 

endmodule
