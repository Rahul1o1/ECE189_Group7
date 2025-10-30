`timescale 1ns / 1ps

module skid_buffer
#(parameter width = 4)
(
    input clk,
    input reset,
    
    input valid_in,
    input[width - 1:0] data_in,
    output ready_in,
    
    input ready_out,
    output valid_out,
    output reg[width - 1:0] data_out
    );

reg[width - 1: 0] data_buffer;
reg bypass_q;
reg bypass_d;

assign valid_out = (bypass_q) ? (valid_in) : 1;
assign ready_in = bypass_q;

always @(posedge clk) begin
	bypass_q <= bypass_d;
	if(reset) begin
		data_buffer <= 0;
		data_out <= 0;
		bypass_d <= 1;
	end
	
	else begin
	
		if (bypass_q) begin
			if(valid_in && (!ready_out)) begin
				bypass_d <= 0;
			end
			else begin
				bypass_d <= bypass_q;
			end
		end
		else begin
			if(ready_out) begin
				bypass_d <= 1;
			end
			else begin
				bypass_d <= bypass_q;
			end
		end
		
		if (bypass_d) begin
		
			data_out <= data_in;
			
			if(valid_in && (!ready_out)) begin
				data_buffer <= data_in;
				//bypass_d <= 0;
			end
			else begin
				//bypass_d <= bypass_q;
				data_buffer <= data_buffer;
			end

		end
		
		else begin
			if(ready_out) begin
				data_out <= data_buffer;
				data_buffer <= 0;
				//bypass_d <= 1;
			end
			else begin
				data_out <= data_out;
				data_buffer <= data_buffer;
				//bypass_d <= bypass_q;
			end
		end
		
	end

end

endmodule