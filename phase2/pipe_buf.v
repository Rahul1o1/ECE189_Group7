module pipe_buf(
	
input clk,
input reset,
input [58:0] write_data,
input write_en,
input read_en,
output reg [58:0] read_data
);

reg [58:0] buffer;
always @(posedge clk)
	begin
		if(reset)
		begin
			read_data <= 0;
		end
		else
		begin
			if( write_en)
			begin
				buffer <= write_data;
			end
			if(read_en)
			begin
				read_data <= buffer;
			end
		end
	end 

endmodule
