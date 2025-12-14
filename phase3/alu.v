module alu(
	input signed [31:0] in1,
	input signed [31:0] in2,
	input [2:0] ALUCtrl,
	output reg signed [31:0] out
);

parameter add_p = 3'b000,
		  sub_p = 3'b001,
		  or_p  = 3'b010,
		  and_p = 3'b011,
		  sra_p = 3'b100,
		  lui_p = 3'b101,
		  sltiu_p = 3'b110,
		  none_p = 3'b111;

always @(*) begin
	case(ALUCtrl)
		add_p: begin
			out = in1 + in2;
		end
		sub_p: begin
			out = in1 - in2;
		end
		or_p: begin
			out = in1 | in2;
		end
		and_p: begin
			out = in1 & in2;
		end
		sra_p: begin
			out = in1 >> in2;
		end
		lui_p: begin
			out = in2;
		end
		sltiu_p: begin
			out = ($unsigned(in1) < $unsigned(in2)) ? 8'h00000001: 8'h00000000;
		end
		default: begin
			out = 0;
		end
	endcase
end
    
endmodule
