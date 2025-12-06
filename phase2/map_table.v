module map_table(
    input clk,
    input reset,
    input [4:0] rs1_a,
    input [4:0] rs2_a,
    input [4:0] rd_a,
	input [6:0] rd_p,
	input Branch, // assume Branch is not taken
	input [1:0] mispredict,// from execute stage
    output [6:0] rs1_p,
    output [6:0] rs2_p,
    output reg checkpoint
    );
    
reg [6:0] rat[0:31]; 
reg [6:0] cloned_rat[0:31];
// checkpoint tells us whether we have a valid clone

assign rs1_p = rat[rs1_a];
assign rs2_p = rat[rs2_a];

always @(posedge clk) begin
	if(reset) begin
		rat[0] <= 7'b0000000;
		rat[1] <= 7'b0000000;
		rat[2] <= 7'b0000000;
		rat[3] <= 7'b0000000;
		rat[4] <= 7'b0000000;
		rat[5] <= 7'b0000000;
		rat[6] <= 7'b0000000;
		rat[7] <= 7'b0000000;
		rat[8] <= 7'b0000000;
		rat[9] <= 7'b0000000;
		rat[10] <= 7'b0000000;
		rat[11] <= 7'b0000000;
		rat[12] <= 7'b0000000;
		rat[13] <= 7'b0000000;
		rat[14] <= 7'b0000000;
		rat[15] <= 7'b0000000;
		rat[16] <= 7'b0000000;
		rat[17] <= 7'b0000000;
		rat[18] <= 7'b0000000;
		rat[19] <= 7'b0000000;
		rat[20] <= 7'b0000000;
		rat[21] <= 7'b0000000;
		rat[22] <= 7'b0000000;
		rat[23] <= 7'b0000000;
		rat[24] <= 7'b0000000;
		rat[25] <= 7'b0000000;
		rat[26] <= 7'b0000000;
		rat[27] <= 7'b0000000;
		rat[28] <= 7'b0000000;
		rat[29] <= 7'b0000000;
		rat[30] <= 7'b0000000;
		rat[31] <= 7'b0000000;
		
		cloned_rat[0] <= 7'b0000000;
		cloned_rat[1] <= 7'b0000000;
		cloned_rat[2] <= 7'b0000000;
		cloned_rat[3] <= 7'b0000000;
		cloned_rat[4] <= 7'b0000000;
		cloned_rat[5] <= 7'b0000000;
		cloned_rat[6] <= 7'b0000000;
		cloned_rat[7] <= 7'b0000000;
		cloned_rat[8] <= 7'b0000000;
		cloned_rat[9] <= 7'b0000000;
		cloned_rat[10] <= 7'b0000000;
		cloned_rat[11] <= 7'b0000000;
		cloned_rat[12] <= 7'b0000000;
		cloned_rat[13] <= 7'b0000000;
		cloned_rat[14] <= 7'b0000000;
		cloned_rat[15] <= 7'b0000000;
		cloned_rat[16] <= 7'b0000000;
		cloned_rat[17] <= 7'b0000000;
		cloned_rat[18] <= 7'b0000000;
		cloned_rat[19] <= 7'b0000000;
		cloned_rat[20] <= 7'b0000000;
		cloned_rat[21] <= 7'b0000000;
		cloned_rat[22] <= 7'b0000000;
		cloned_rat[23] <= 7'b0000000;
		cloned_rat[24] <= 7'b0000000;
		cloned_rat[25] <= 7'b0000000;
		cloned_rat[26] <= 7'b0000000;
		cloned_rat[27] <= 7'b0000000;
		cloned_rat[28] <= 7'b0000000;
		cloned_rat[29] <= 7'b0000000;
		cloned_rat[30] <= 7'b0000000;
		cloned_rat[31] <= 7'b0000000;
		
		checkpoint <= 0;
	end
	else begin
		rat[rd_a] <= rd_p;
		
		if(mispredict == 2'b01) begin // branch assumption is wrong
			rat[0] <= cloned_rat[0];
			rat[1] <= cloned_rat[1];
			rat[2] <= cloned_rat[2];
			rat[3] <= cloned_rat[3];
			rat[4] <= cloned_rat[4];
			rat[5] <= cloned_rat[5];
			rat[6] <= cloned_rat[6];
			rat[7] <= cloned_rat[7];
			rat[8] <= cloned_rat[8];
			rat[9] <= cloned_rat[9];
			rat[10] <= cloned_rat[10];
			rat[11] <= cloned_rat[11];
			rat[12] <= cloned_rat[12];
			rat[13] <= cloned_rat[13];
			rat[14] <= cloned_rat[14];
			rat[15] <= cloned_rat[15];
			rat[16] <= cloned_rat[16];
			rat[17] <= cloned_rat[17];
			rat[18] <= cloned_rat[18];
			rat[19] <= cloned_rat[19];
			rat[20] <= cloned_rat[20];
			rat[21] <= cloned_rat[21];
			rat[22] <= cloned_rat[22];
			rat[23] <= cloned_rat[23];
			rat[24] <= cloned_rat[24];
			rat[25] <= cloned_rat[25];
			rat[26] <= cloned_rat[26];
			rat[27] <= cloned_rat[27];
			rat[28] <= cloned_rat[28];
			rat[29] <= cloned_rat[29];
			rat[30] <= cloned_rat[30];
			rat[31] <= cloned_rat[31];
			
			checkpoint <= 0;
		end
		
		if(mispredict == 2'b10 && checkpoint) begin // branch assumption is correct
			checkpoint <= 0;
		end
		
		if(Branch && (!checkpoint)) begin // backup
			cloned_rat[0] <= rat[0];
			cloned_rat[1] <= rat[1];
			cloned_rat[2] <= rat[2];
			cloned_rat[3] <= rat[3];
			cloned_rat[4] <= rat[4];
			cloned_rat[5] <= rat[5];
			cloned_rat[6] <= rat[6];
			cloned_rat[7] <= rat[7];
			cloned_rat[8] <= rat[8];
			cloned_rat[9] <= rat[9];
			cloned_rat[10] <= rat[10];
			cloned_rat[11] <= rat[11];
			cloned_rat[12] <= rat[12];
			cloned_rat[13] <= rat[13];
			cloned_rat[14] <= rat[14];
			cloned_rat[15] <= rat[15];
			cloned_rat[16] <= rat[16];
			cloned_rat[17] <= rat[17];
			cloned_rat[18] <= rat[18];
			cloned_rat[19] <= rat[19];
			cloned_rat[20] <= rat[20];
			cloned_rat[21] <= rat[21];
			cloned_rat[22] <= rat[22];
			cloned_rat[23] <= rat[23];
			cloned_rat[24] <= rat[24];
			cloned_rat[25] <= rat[25];
			cloned_rat[26] <= rat[26];
			cloned_rat[27] <= rat[27];
			cloned_rat[28] <= rat[28];
			cloned_rat[29] <= rat[29];
			cloned_rat[30] <= rat[30];
			cloned_rat[31] <= rat[31];
			
			checkpoint <= 1;
		end
		
		
	end
end
endmodule
