module alu_controller(
    input F7,
    input F3,
    input [2:0] ALUOp,
    output reg [2:0] ALUCtrl
    );

always @(*) begin
	if(ALUOp == 3'b100) begin // rtype
		if((F7 == 0) && (F3 == 3'b000)) begin
		ALUCtrl = 3'b000; // add
		end
		else if((F7 == 1) && (F3 == 3'b000)) begin
		ALUCtrl = 3'b001; // sub
		end
		else if((F7 == 0) && (F3 == 3'b111)) begin
		ALUCtrl = 3'b011; // and
		end
		else if((F7 == 1) && (F3 == 3'b101)) begin
		ALUCtrl = 3'b100; // sra
		end
		else begin
		ALUCtrl = 3'b111; // none
		end
	end
	
	else if(ALUOp == 3'b110) begin // itype
		if(F3 == 3'b000) begin
		ALUCtrl = 3'b000; // addi
		end
		else if(F3 == 3'b110) begin
		ALUCtrl = 3'b010; // ori
		end
		else if(F3 == 3'b011) begin
		ALUCtrl = 3'b110; // sltiu
		end
		else begin
		ALUCtrl = 3'b111; // none
		end
	end
	
	else if(ALUOp == 3'b111) begin
		ALUCtrl = 3'b101; // lui
	end
	
	else begin
		ALUCtrl = 3'b111; // none
	end
end

endmodule
