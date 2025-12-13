module rsbranch(
input clk,
input reset,
input dispatch_flag,
input issue_flag,
input [6:0] prd_in,
input [6:0] prs1_in,
input prs1_readyin,
input [6:0] prs2_in,
input prs2_readyin,
input [31:0] IMM_in,
//input ALU_src_in,
input [2:0] ALU_op_in,
input [3:0] rob_tag_in,
output reg [6:0] prs1_out,
output reg [6:0] prs2_out,
output reg [31:0] IMM_out,
output reg ALU_src_out,
output reg br_out,
output reg [3:0] rob_tag_out,
output reg [6:0] prd_out,
output free_valid
);

reg [0:7] use_rg;	//8 rows
reg [6:0] prd [0:7];
reg [6:0] prs1 [0:7];
reg [0:7] prs1_ready;
reg [6:0] prs2 [0:7];
reg [0:7] prs2_ready;
reg [31:0] IMM [0:7];
reg [3:0] rob_tag [0:7];
reg [0:7] ALU_src;
// alu inst = addi, ori, sltiu, sra, sub, and, 


wire [2:0] free_index;
wire [2:0] ready_index;
wire free_valid;
wire ready_valid;
wire [7:0] pd_in;
wire [7:0] pi_in;
reg [0:7] br_rg;

//assign p_in =~{use_rg[0], use_rg[1], use_rg[2], use_rg[3], use_rg[4], use_rg[5], use_rg[6], use_rg[7]};
assign pd_in = ~use_rg[0:7];
assign pi_in = (use_rg & prs1_ready & !br_rg) | (use_rg & prs1_ready & prs2_ready & br_rg);  
// branch: br_rg is 1 check if rs1,rs2 ready for valid inst, else its jump check if rs1 ready

 priority_encoder #(.WIDTH(8)) dispe (
        .in(pd_in),
        .out(free_index),
        .valid(free_valid)
    );

 priority_encoder #(.WIDTH(8)) isspe (
        .in(pi_in),
        .out(ready_index),
        .valid(ready_valid)
    );

always @(posedge clk)
begin
	if(reset)
	begin
		use_rg[0:7] <= 8'b00000000;
		prd[0] <= 7'b0000000;
		prd[1] <= 7'b0000000;
		prd[2] <= 7'b0000000;
		prd[3] <= 7'b0000000;
		prd[4] <= 7'b0000000;
		prd[5] <= 7'b0000000;
		prd[6] <= 7'b0000000;
		prd[7] <= 7'b0000000;
		prd_out <= 7'b0000000;
		prs1[0] <= 7'b0000000;
		prs1[1] <= 7'b0000000;
		prs1[2] <= 7'b0000000;
		prs1[3] <= 7'b0000000;
		prs1[4] <= 7'b0000000;
		prs1[5] <= 7'b0000000;
		prs1[6] <= 7'b0000000;
		prs1[7] <= 7'b0000000;
		prs1_out <= 7'b0000000;
		prs1_ready[0:7] <= 8'b00000000;
		prs2[0] <= 7'b0000000;
		prs2[1] <= 7'b0000000;
		prs2[2] <= 7'b0000000;
		prs2[3] <= 7'b0000000;
		prs2[4] <= 7'b0000000;
		prs2[5] <= 7'b0000000;
		prs2[6] <= 7'b0000000;
		prs2[7] <= 7'b0000000;	
		prs2_out <= 7'b0000000;	
		prs2_ready[0:7] <= 8'b00000000;
		IMM[0] <= 8'h00000000;
		IMM[1] <= 8'h00000000;
		IMM[2] <= 8'h00000000;
		IMM[3] <= 8'h00000000;
		IMM[4] <= 8'h00000000;
		IMM[5] <= 8'h00000000;
		IMM[6] <= 8'h00000000;
		IMM[7] <= 8'h00000000;
		IMM_out <= 8'h00000000;
		rob_tag[0] <= 4'b0000;
		rob_tag[1] <= 4'b0000;
		rob_tag[2] <= 4'b0000;
		rob_tag[3] <= 4'b0000;
		rob_tag[4] <= 4'b0000;
		rob_tag[5] <= 4'b0000;
		rob_tag[6] <= 4'b0000;
		rob_tag[7] <= 4'b0000;
		rob_tag_out <= 4'b0000;
		ALU_src[0:7] <= 8'b00000000;
		ALU_src_out <= 0;
		br_rg[0:7] <= 8'b00000000;
		br_out <= 0;
	end
	else
	begin
		if(dispatch_flag) //dispatch
		begin
			if(free_valid)
			begin
				use_rg[free_index] <= 1;
				prd[free_index] <= prd_in;
				prs1[free_index] <= prs1_in;
				prs1_ready[free_index] <= prs1_readyin;
				prs2[free_index] <= prs2_in; // for load will be 0
				prs2_ready[free_index] <= prs2_readyin;
				IMM[free_index] <= IMM_in;
				rob_tag[free_index] <= rob_tag_in;
				br_rg[free_index] <= (ALU_op_in == 3'b010)? 1 : 0;
				//1 for load, 0 for store
			end
		end
		if(issue_flag) //issue
		begin
			//will update with issue logic later
			if(ready_valid)
			begin
				use_rg[ready_index] <= 0;
				prs1_out <= prs1[ready_index];
				prs2_out <= prs2[ready_index];
				IMM_out <= IMM[ready_index];
				br_out <= br_rg[ready_index];
				prd_out <= prd[ready_index];
				rob_tag_out <= rob_tag[ready_index];
			end
		end
	end
end
endmodule