module rob(
input clk,
input reset,
input [6:0] prd_new,
input [6:0] prd_old,
input [31:0] PC,
input dispatch_flag,
input complete_flag,
input retire_flag,
input [3:0] rob_tag,
input checkpoint,
output reg full,
output reg empty
);
 

reg [3:0] head = 0;		//head and tail of circ buf	
reg [3:0] tail = 0;
reg [4:0] count = 0;		//keeps track of number of entries in my rob 
reg [47:0] buffer [0:15];	// concatenated data with 16 entries
//concatenated data = {valid,prd_new,prd_old,PC,complete?}; 1 + 7 + 7 + 32 + 1 = 48bits

reg [3:0] recover;		//for recovery
reg [4:0] count_bkp;
//1. I stan Verilog and discovered that struct is only in SysVerilog
//2. I am implementing this by concatenating these values and remembering the bit mapping

always@ (posedge clk)
begin
	if(reset)
	begin
		full<=0;
		empty<=1;
		count<=0;
		head<=0;
		tail<=0;
		recover<=0;
		count_bkp<=0;
	end
	else
	begin
		if(dispatch_flag && !full)	//Dispatch : 
		begin
			if(checkpoint)
			begin
				count_bkp <= count + 1;
				recover <= tail + 1; // +1 since we shouldnt flush branch inst only inst after it
			end
			buffer[tail] <= {1'b1,prd_new,prd_old,PC,1'b0};
			tail <= tail + 1;
			count <= count + 1;
			full <= (count == 5'b01111);
			empty <= 0;
		end
		if(complete_flag)	//Complete
		begin
			buffer[rob_tag] <= {buffer[rob_tag][47:1], 1'b1}; //To mark Complete	
		end
		if(retire_flag && !empty)	//Retire
		begin
			buffer[head] <= {1'b0, buffer[head][46:0]}; // clear valid bit
			head <= head + 1;
			count <= count - 1;
			full<= 0;
			empty <= (count == 1);
		end
	end
end
endmodule
