module rsalu(
input clk,
input reset,
input stage,
input [6:0] prd_in,
input [6:0] prs1_in,
input prs1_readyin,
input [6:0] prs2_in,
input prs2_readyin,
input [31:0] IMM_in,
input ALU_src_in,
input [2:0] ALU_op_in,
input [3:0] rob_tag_in
output reg [6:0] prs1_out,
output reg [6:0] prs2_out,
output reg [31:0] IMM_out,
output reg ALU_src_out,
output reg [2:0] ALU_op_out,
output reg [3:0] rob_tag_out
);

reg [0:7] use_rg;	//8 rows
reg [6:0] prd [0:7];
reg [6:0] prs1 [0:7];
reg [0:7] prs1_ready;
reg [6:0] prs2 [0:7];
reg [0:7] prs2_ready;
reg [31:0] IMM [0:7];
reg [3:0] rob_tag [0:7];
reg [2:0] ALU_op [0:7];
reg [0:7] ALU_src;
// alu inst = addi, ori, sltiu, sra, sub, and, 

wire FU_ready;
wire [2:0] free_index;
wire [2:0] ready_index;
wire free_valid;
wire ready_valid;
wire [7:0] pd_in;
wire [7:0] pi_in;
//assign p_in =~{use_rg[0], use_rg[1], use_rg[2], use_rg[3], use_rg[4], use_rg[5], use_rg[6], use_rg[7]};
assign pd_in = ~use_rg[0:7];
assign pi_in = (use_rg & ALU_src & prs1_ready) | (use_rg & prs1_ready & prs2_ready);  
// if itype checks if rs1 is ready, else check if both rs1 and rs2 ready to issue

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
		use_rg[0:7] <= 0;
	end
	else
	begin
		if(stage == 0) //dispatch
		begin
			if(free_valid)
			begin
				use_rg[free_index] <= 1;
				prd[free_index] <= prd_in;
				prs1[free_index] <= prs1_in;
				prs1_ready[free_index] <= prs1_readyin;
				prs2[free_index] <= prs2_in;
				prs2_ready[free_index] <= prs2_readyin;
				IMM[free_index] <= IMM_in;
				ALU_op[free_index] <= ALU_op_in;
				ALU_src[free_index] <= ALU_src_in;
				rob_tag[free_index] <= rob_tag_in;
			end
		end
		else if(stage == 1) //issue
		begin
			//will update with issue logic later
			if(ready_valid)
			begin
				use_rg[ready_index] <= 0;
				prs1_out <= prs1[ready_index];
				prs2_out <= prs2[ready_index];
				IMM_out <= IMM[ready_index];
				ALU_op_out <= ALU_op[ready_index];
				ALU_src_out <= ALU_src[ready_index];
				rob_tag_out <= rob_tag[ready_index];
			end
		end
	end
end
endmodule
