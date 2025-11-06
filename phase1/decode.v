module decode(
input ready_o,
input [31:0] instruction,
input [11:0] PC,
input valid_i,
output valid_o,
output ready_i,
output [4:0] rs1,
output [4:0] rs2,
output [4:0] rd,
output [31:0] immediate,
output [2:0] ALUOp,
output [1:0] FUType, // 0 for ALU, 1 for Load/Store, 2 for Branch, 3 for Jump
output ALUSrc,
output LS,
output Branch,
output Jump
);

reg [31:0] imm_reg;
reg ALUSrc_reg, LS_reg, Branch_reg, Jump_reg, valid_oreg;
reg [1:0] FUType_reg;
reg [2:0] ALUOp_reg;

assign ALUSrc = ALUSrc_reg;
assign LS = LS_reg;
assign Branch = Branch_reg;
assign Jump = Jump_reg;
assign FUType = FUType_reg;
assign ALUOp = ALUOp_reg;
assign ready_i = ready_o;
assign valid_o = valid_oreg;
assign immediate = imm_reg;

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

always @(*)
begin
	if(valid_i)
	begin
		case(opcode)
		rtype:
			begin
				ALUSrc_reg = 0;
				LS_reg = 0;
				FUType_reg = 0;
				ALUOp_reg = 3'b100;
				Branch_reg = 0;
				Jump_reg = 0;
				imm_reg =0;
				valid_oreg = 1;	
			end
		itype:
			begin
				ALUSrc_reg = 1;
				LS_reg = 0;
				FUType_reg = 0;
				ALUOp_reg = 3'b110;
				Branch_reg = 0;
				Jump_reg = 0;
				imm_reg = {{20{instruction[31]}}, instruction[31:20]};	
				valid_oreg = 1;				
			end
		load:
			begin
				ALUSrc_reg = 1;
				LS_reg = 1;
				FUType_reg = 1;
				ALUOp_reg = 3'b000;
				Branch_reg = 0;
				Jump_reg = 0;	
				imm_reg = {{20{instruction[31]}}, instruction[31:20]};					
				valid_oreg = 1;				
			end		
		store:
			begin
				ALUSrc_reg = 1;
				LS_reg = 1;
				FUType_reg = 1;
				ALUOp_reg = 3'b110;
				Branch_reg = 0;
				Jump_reg = 0;	
				imm_reg = {{20{instruction[31]}}, instruction[31:25], instruction[12:7]};	
				valid_oreg = 1;				
			end
		branch:
			begin
				ALUSrc_reg = 0;
				LS_reg = 0;
				FUType_reg = 2'b10;
				ALUOp_reg = 3'b010;
				Branch_reg = 1;
				Jump_reg = 0;	
				imm_reg = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};	
				valid_oreg = 1;				
			end
		jump:
			begin
				ALUSrc_reg = 1;
				LS_reg = 0;
				FUType_reg = 2'b11;
				ALUOp_reg = 3'b000;
				Branch_reg = 0;
				Jump_reg = 1;
				imm_reg = {{20{instruction[31]}}, instruction[31:20]};	
				valid_oreg = 1;				
			end		
		lui:	// I noticed something. In CA1 I used ALU to shift 12, but I could have also done that in decode instead of sign extension.....
			begin
				ALUSrc_reg = 1;
				//I leave Ls and FU as 0 for now, will update once more details about further stages are known
				LS_reg = 0;
				FUType_reg = 2'b00;
				ALUOp_reg = 3'b111;
				Branch_reg = 0;
				Jump_reg = 0;	
				imm_reg = {{instruction[31:12], 12'b0};	
				valid_oreg = 1;			
			end
		default:
			begin
				ALUSrc_reg = 0;
				LS_reg = 0;
				FUType_reg = 2'b00;
				ALUOp_reg = 3'b000;
				Branch_reg = 0;
				Jump_reg = 0;	
				imm_reg =0;
				valid_oreg = 0;
			end
		endcase
	end
end

endmodule
