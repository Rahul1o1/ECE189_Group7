module pipeline_skidbuf
#(parameter width = 4)
(
	input clk,
	input reset,
	input ready_out,
	input valid_in,
	input [width - 1:0] data_in,
	output reg ready_in,
	output reg valid_out,
	output reg [width - 1:0] data_out
);

	reg [width - 1: 0] skid_buf;
	//flag for skid buffer
	reg skid_buf_empty;
	//pipeline buffers
	reg [width - 1:0] data_buf;
	reg valid_buf;
	reg ready_buf;

	// if data is coming from skid buffer its always valid else valid out = valid in

	always @(posedge clk)
	begin
		if(reset)
		begin
			skid_buf_empty <= 1;
			skid_buf <= 0;
			data_buf <= 0;
			valid_buf <= 0;
			ready_buf <= 1;
			data_out<=0;
			valid_out<=0;
			ready_in<=1;
		end
		else 
		begin
			ready_in <= ready_buf;
			data_out <= data_buf;
			valid_out <= valid_buf;
			if(!ready_out)
			begin
				if(valid_in && skid_buf_empty)
				begin
					skid_buf <= data_in;
					skid_buf_empty <= 0;
					ready_buf <= 0;
					valid_buf <= 1;
				end
			end
			else
			begin
				if(!skid_buf_empty)
				begin
					data_buf <= skid_buf;
					skid_buf_empty <= 1;
					skid_buf <= 0;
					ready_buf <= 1;
				end
				else
				begin
					data_buf <= data_in;
					valid_buf <= valid_in;
				end
			end
		end
	end


/*
	always @(posedge clk)
	begin
		if(reset)
		begin
			skid_buf_empty <= 1;
			skid_buf <= 0;
			data_buf <= 0;
			valid_buf <= 0;
			ready_in <=0;
		end
		else 
		begin
			if(!ready_out)	//stall begins
			begin
				if(valid_in && skid_buf_empty)	//if the next input is valid and we are not already stalled
				begin
					//move that data into the skid buffer
					skid_buf <= data_in;
					//mark the buffer full
					skid_buf_empty <= 0;
				end
								
				// else if we have invalid data we can stall after receiving next valid input
				// if we are already stalled, we should not keep it there and not overwrite skid buffer
			end
			else 
			begin	//output is ready to receive
				if(!skid_buf_empty)
				begin	
					//move data from skid buffer to data buffer
					//mark skid buffer empty and from next cycle data can be received
					skid_buf_empty <= 1;
					data_buf<=skid_buf; 
				end
				else
				begin	//normal operation
					data_buf <= data_in;
					valid_buf <= valid_in;
				end
			end
		end		
	end
*/	
endmodule
