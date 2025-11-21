module circbuf #(
	parameter DEPTH = 8,
	parameter DATA_WIDTH = 32
) (

input clk,
input reset,
input write_en,
input [DATA_WIDTH-1:0] write_data,
input read_en,
output reg [DATA_WIDTH-1:0] read_data,
output reg full,
output reg empty
);

	reg [$clog2(DEPTH)-1 : 0] head = 0;
	reg [$clog2(DEPTH)-1 : 0] tail = 0;
	reg [$clog2(DEPTH) : 0] count = 0;

	reg [DATA_WIDTH-1:0] buffer [0:DEPTH-1];

	always @(posedge clk)
	begin
		if(reset)
		begin
			head <= 0;
			tail <= 0;
			read_data <= 0;
			full <= 0;
			empty <= 1;
			count <=0;
		end
		else
		begin
			if( write_en && !full)
			begin
				buffer[tail] <= write_data;
				tail <= tail + 1;
				count <= count + 1;
				empty <= 0;
				full <= (count == DEPTH - 1);
			end
			if( read_en && !empty)
			begin
				read_data <= buffer[head];
				head <= head + 1;
				count <= count - 1;
				empty <= (count == 1);
				full<= 0;
			end
		end
	end
endmodule
