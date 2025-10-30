module fifo #(
	parameter DEPTH = 8
) (
	
	input clk,
	input reset,
	input write_en,
	input [31:0] write_data,
	input read_en,
	output [31:0] read_data,
	output full,
	output empty
);

	reg [$clog2(DEPTH)-1 : 0] write_ptr = 0;
	reg [$clog2(DEPTH)-1 : 0] read_ptr = 0;
	reg [31:0] read_data;
	reg full = 0;
	reg empty = 1;
	reg [31:0] buffer [0:DEPTH-1];
	
	always @(posedge clk)
	begin
		if(reset)
		begin
			write_ptr <= 0;
			read_ptr <= 0;
			read_data <= 0;
			full <= 0;
			empty <= 1;
		end
		else
		begin
			buffer[write_ptr] <= buffer[write_ptr];
			full <=full;
			write_ptr <= write_ptr;
			read_data <= 0;
			read_ptr <= read_ptr;
			empty <= empty;
			
			if( write_en && !full)
			begin
				buffer[write_ptr] <= write_data;
				empty<=0;
				if(write_ptr == DEPTH - 1)
				begin 
					full <=1;
					write_ptr <= write_ptr;
				end
				else
				begin
					full <=0;
					write_ptr <= write_ptr +1;
				end
			end
			if( read_en && !empty)
			begin
				read_data <= buffer[read_ptr];
				if(read_ptr == DEPTH -1)
				begin 
					empty<=1;
					read_ptr <= read_ptr;
				end				
				else
				begin
					empty<=0;
					read_ptr <= read_ptr +1;
				end
			end
		end
	end 

endmodule
