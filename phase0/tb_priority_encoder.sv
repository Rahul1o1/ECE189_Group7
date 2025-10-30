module tb_priority_encoder #(parameter width = 8, length = 256);

reg[width - 1: 0] in;
wire[$clog2(width) - 1: 0] out;
wire valid;

priority_encoder #(.WIDTH(width)) dut(.in(in), .out(out), .valid(valid));

initial begin
	in = 0;
	#length $finish;
end
always begin
	#1 in = in + 1;
end
endmodule
