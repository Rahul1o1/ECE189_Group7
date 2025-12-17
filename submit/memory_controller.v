module memory_controller(
    input F3,
    output reg MemCtrl
    );

always @(*) begin
	if(F3 == 3'b010) begin
		MemCtrl = 0;
	end
	else begin
		MemCtrl = 1;
	end
end

endmodule
