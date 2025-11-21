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
input FU_in,
input [3:0] rob_tag_in
);

reg [7:0] use_rg;
reg [6:0] prd [0:7];
reg [6:0] prs1 [0:7];
reg [7:0] prs1_ready;
reg [6:0] prs2 [0:7];
reg [7:0] prs2_ready;
reg [31:0] IMM [0:7];
reg [7:0] FU;
reg [3:0] rob_tag [0:7];


wire FU_ready;
wire [2:0] free_index;
wire free_valid;
wire [7:0] p_in;
assign p_in =~{use_rg[0], use_rg[1], use_rg[2], use_rg[3], use_rg[4], use_rg[5], use_rg[6], use_rg[7]};

 priority_encoder #(.WIDTH(8)) pe (
        .in(p_in),
        .out(free_index),
        .valid(free_valid)
    );

always @(posedge clk)
begin
	if(reset)
	begin
		use_rg[0] <=0;
		use_rg[1] <=0;
		use_rg[2] <=0;
		use_rg[3] <=0;
		use_rg[4] <=0;
		use_rg[5] <=0;
		use_rg[6] <=0;
		use_rg[7] <=0;	
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
				FU[free_index] <= FU_in;
				rob_tag[free_index] <= rob_tag_in;
			end
		end
		else if(stage == 1) //issue
		begin
			//will update with issue logic later
		end
	end
end
endmodule
