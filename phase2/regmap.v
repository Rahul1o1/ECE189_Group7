module regmap(
input clk,
input reset,
input [4:0] a_rs1,
input [4:0] a_rs2,
input [4:0] a_rd,
input [6:0] p_rd,
input rename,
input checkpoint,
output [6:0] p_rs1,
output [6:0] p_rs2
);

//32 architectural registers each mapped to a physical register out of 128(so 7 bits)
reg [6:0] map[0:31];
reg [6:0] map_chkpoint[0:31];

assign p_rs1 = map[a_rs1];
assign p_rs2 = map[a_rs2];

always @(posedge clk)
begin
	if(reset)
	begin
	//I know there's probably a for loop method for this but i have unrolled it
		map[0] <= 7'b0000000;
		map[1] <= 7'b0000001;
		map[2] <= 7'b0000010;
		map[3] <= 7'b0000011;
		map[4] <= 7'b0000100;
		map[5] <= 7'b0000101;
		map[6] <= 7'b0000110;
		map[7] <= 7'b0000111;
		map[8] <= 7'b0001000;
		map[9] <= 7'b0001001;
		map[10] <= 7'b0001010;
		map[11] <= 7'b0001011;
		map[12] <= 7'b0001100;
		map[13] <= 7'b0001101;
		map[14] <= 7'b0001110;
		map[15] <= 7'b0001111;
		map[16] <= 7'b0010000;
		map[17] <= 7'b0010001;
		map[18] <= 7'b0010010;
		map[19] <= 7'b0010011;
		map[20] <= 7'b0010100;
		map[21] <= 7'b0010101;
		map[22] <= 7'b0010110;
		map[23] <= 7'b0010111;
		map[24] <= 7'b0011000;
		map[25] <= 7'b0011001;
		map[26] <= 7'b0011010;
		map[27] <= 7'b0011011;
		map[28] <= 7'b0011100;
		map[29] <= 7'b0011101;
		map[30] <= 7'b0011110;
		map[31] <= 7'b0011111;
	end
	else
	begin
		if(rename)
		begin
			map[a_rd] <= p_rd;
		end
		if(checkpoint)
		begin
 			map_chkpoint[0]  <= map[0];
   			map_chkpoint[1]  <= map[1];
		    	map_chkpoint[2]  <= map[2];
		   	map_chkpoint[3]  <= map[3];
		    	map_chkpoint[4]  <= map[4];
		    	map_chkpoint[5]  <= map[5];
		    	map_chkpoint[6]  <= map[6];
		    	map_chkpoint[7]  <= map[7];
		    	map_chkpoint[8]  <= map[8];
		    	map_chkpoint[9]  <= map[9];
		    	map_chkpoint[10] <= map[10];
		    	map_chkpoint[11] <= map[11];
		    	map_chkpoint[12] <= map[12];
		   	map_chkpoint[13] <= map[13];
		   	map_chkpoint[14] <= map[14];
		    	map_chkpoint[15] <= map[15];
		    	map_chkpoint[16] <= map[16];
		    	map_chkpoint[17] <= map[17];
		    	map_chkpoint[18] <= map[18];
		    	map_chkpoint[19] <= map[19];
		    	map_chkpoint[20] <= map[20];
		    	map_chkpoint[21] <= map[21];
		    	map_chkpoint[22] <= map[22];
		    	map_chkpoint[23] <= map[23];
		    	map_chkpoint[24] <= map[24];
		    	map_chkpoint[25] <= map[25];
		   	map_chkpoint[26] <= map[26];
		    	map_chkpoint[27] <= map[27];
		    	map_chkpoint[28] <= map[28];
		    	map_chkpoint[29] <= map[29];
		    	map_chkpoint[30] <= map[30];
		    	map_chkpoint[31] <= map[31];
		end
	end
end

endmodule
