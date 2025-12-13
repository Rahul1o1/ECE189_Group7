module decode(
input ready_o,
input [31:0] instruction,
input [31:0] pc_in,
input valid_i,
input reset,
output reg valid_o,
output ready_i,
output [31:0] pc_out,
output [4:0] rs1,
output [4:0] rs2,
output [4:0] rd,
output reg [31:0] immediate,
output reg [2:0] ALUOp,
output F7,
output [2:0] F3,
output reg [1:0] FUType, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
output reg ALUSrc,	
output reg immused,
output reg rdused,
output reg LS,
output reg Branch,
output reg Jump
);

assign ready_i = ready_o;

parameter rtype = 7'b0110011,
	itype = 7'b0010011,
	load = 7'b0000011,
	store = 7'b0100011,
	branch = 7'b1100011,
	jump = 7'b1100111,
	lui = 7'b0110111;

wire [6:0] opcode;

assign	rs1 = instruction[19:15];
assign	rs2 = instruction[24:20];
assign	rd = instruction[11:7];
assign opcode = instruction[6:0];
assign F7 = instruction[30];
assign F3 = instruction[14:12];
assign pc_out = pc_in;

always @(*)
begin
	
	if(reset)
	begin
		ALUSrc = 0;
		LS = 0;
		FUType = 2'b00;
		ALUOp = 3'b000;
		Branch  = 0;
		Jump  = 0;	
		immediate = 0;
		rdused = 0;
		immused = 0;
		valid_o = 0;
	end
	else if(valid_i)
	begin
		case(opcode)
		rtype:
			begin
				ALUSrc = 0;
				LS = 0;
				FUType = 0;
				ALUOp = 3'b100;
				Branch  = 0;
				Jump  = 0;
				immediate =0;
				rdused = 1;
				immused = 0;
				valid_o = 1;	
			end
		itype:
			begin
				ALUSrc = 1;
				LS = 0;
				FUType = 0;
				ALUOp = 3'b110;
				Branch  = 0;
				Jump  = 0;
				immediate = {{20{instruction[31]}}, instruction[31:20]};
				rdused = 1;
				immused = 1;	
				valid_o = 1;				
			end
		load:
			begin
				ALUSrc = 1;
				LS = 1;
				FUType = 1;
				ALUOp = 3'b000;
				Branch  = 0;
				Jump  = 0;	
				immediate = {{20{instruction[31]}}, instruction[31:20]};
				rdused = 1;
				immused = 1;					
				valid_o = 1;				
			end		
		store:
			begin
				ALUSrc = 1;
				LS = 1;
				FUType = 1;
				ALUOp = 3'b110;
				Branch  = 0;
				Jump  = 0;	
				immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};	
				rdused = 0;
				immused = 1;
				valid_o = 1;				
			end
		branch:
			begin
				ALUSrc = 0;
				LS = 0;
				FUType = 2'b10;
				ALUOp = 3'b010;
				Branch  = 1;
				Jump  = 0;	
				immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
				rdused = 0;
				immused = 1;	
				valid_o = 1;				
			end
		jump:
			begin
				ALUSrc = 1;
				LS = 0;
				FUType = 2'b11;
				ALUOp = 3'b000;
				Branch  = 0;
				Jump  = 1;
				immediate = {{20{instruction[31]}}, instruction[31:20]};
				rdused = 1;
				immused = 1;	
				valid_o = 1;				
			end		
		lui:	// I noticed something. In CA1 I used ALU to shift 12, but I could have also done that in decode instead of sign extension.....
			begin
				ALUSrc = 1;
				//I leave Ls and FU as 0 for now, will update once more details about further stages are known
				LS = 0;
				FUType = 2'b00;
				ALUOp = 3'b111;
				Branch  = 0;
				Jump  = 0;	
				immediate = {instruction[31:12], 12'b0};	
				rdused = 1;
				immused = 1;
				valid_o = 1;			
			end
		default:
			begin
				ALUSrc = 0;
				LS = 0;
				FUType = 2'b00;
				ALUOp = 3'b000;
				Branch  = 0;
				Jump  = 0;	
				immediate =0;
				rdused = 0;
				immused = 0;
				valid_o = 0;
			end
		endcase
	end
	else
	begin
		ALUSrc = 0;
		LS = 0;
		FUType = 2'b00;
		ALUOp = 3'b000;
		Branch  = 0;
		Jump  = 0;	
		immediate =0;
		rdused = 0;
		immused = 0;
		valid_o = 0;
	end
end

endmodule