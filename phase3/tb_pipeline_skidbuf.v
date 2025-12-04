module tb_pipeline_skidbuf #(parameter width = 32);

	reg reset;
	reg clk;
	reg [width-1:0] data_in;
	reg valid_in;
	reg ready_out;
	wire [width-1:0] data_out;
	wire valid_out;
	wire ready_in;

	
	// Instantiate DUT
	pipeline_skidbuf #(.width(width)) dut(
		.reset(reset),
		.clk(clk),
		.data_in(data_in),
		.valid_in(valid_in),
		.ready_in(ready_in),
		.data_out(data_out),
		.valid_out(valid_out),
		.ready_out(ready_out)
	); 
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
		#30 valid_in = 0;
		#40 valid_in = 1;
		#30 $finish;
	end
	
	initial
		$monitor($time, "Outputs: data_out = %d, valid_out = %d, ready_out = %d", data_out, valid_out, ready_out);
		

endmodule
