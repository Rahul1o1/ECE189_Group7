module pipe_buf
#(parameter width = 7) 
(
	
input clk,
input reset,
input [width-1:0] write_data, //data to be written into rs
input read_en,		      // 0 if rs is full
output reg [width-1:0] read_data
);

reg [width-1:0] buffer;
always @(posedge clk)
	begin
		if(reset)
		begin
			read_data <= 0;
			buffer <= 0;
		end
		else
		begin
			if(read_en)
			begin
				read_data <= buffer; //not sending anything to rs if not read_en
				buffer <= write_data; // not accepting anything from rename if read_en =0
			end
		end
	end 

endmodule