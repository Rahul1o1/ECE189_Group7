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
// data buffer is a register that stores the skidded data while the ready_out signal is deasserted
	
// bypass signal is high when the data buffer is empty and vice versa
reg bypass_q; // stores the old value of bypass
reg bypass_d; // new value of bypass at the positve clock edge

assign valid_out = (bypass_q) ? (valid_in) : 1;
assign ready_in = bypass_q;

always @(posedge clk) begin
	bypass_q <= bypass_d; // bypass flip flop updates the value of bypass_q
	
	if(reset) begin // data buffer is emptied and nothing is sent to receiver, on reset
		data_buffer <= 0;
		data_out <= 0;
		bypass_d <= 1;
	end
	
	else begin
	
		if (bypass_q) begin // previous value of bypass is used to update the bypass signal itself based on valid_in and ready_out signals
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
		
		if (bypass_d) begin // new value of bypass is used to update the data_out signal and contents of data_buffer
			data_out <= data_in;			
			if(valid_in && (!ready_out)) begin
				data_buffer <= data_in;
			end
			else begin
				data_buffer <= data_buffer;
			end
		end
		
		else begin
			if(ready_out) begin
				data_out <= data_buffer;
				data_buffer <= 0;
			end
			else begin
				data_out <= data_out;
				data_buffer <= data_buffer;
			end
		end
		
	end

end

endmodule
