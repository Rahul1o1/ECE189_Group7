module tb_skid_buffer #(parameter width = 4);

	reg reset;
	reg clk;
	reg[width - 1:0] data_in;
	reg valid_in, ready_out;
	wire[width - 1:0] data_out;
	wire valid_out, ready_in;
	wire[width - 1:0] data_buffer;
	wire bypass_q;
	wire bypass_d;
	
	skid_buffer #(.width(32)) dut(.reset(reset), .clk(clk), .data_in(data_in),
	.valid_in(valid_in), .ready_in(ready_in), .data_out(data_out),
	.valid_out(valid_out), .ready_out(ready_out)); 
	
	initial begin
		clk = 1'b1;
		data_in = 1;
	end
	
	always
		#5 clk <= ~clk;
	always
		#10 if(ready_in) data_in <= data_in + 1;
			
	initial begin
		reset = 1;
		#10 reset = 0;
		ready_out = 1;
		valid_in = 1;
		#70 ready_out = 0;
			valid_in = 0;
		#10 valid_in = 1;
		#30 ready_out = 1;
			valid_in = 0;
		#10 ready_out = 0;
		#30 valid_in = 1;
		#10 ready_out = 1;
		#50 $finish;
	end
	
	initial
		$monitor($time, "Outputs: data_out = %d, valid_out = %d, ready_out = %d", data_out, valid_out, ready_out);
		

endmodule