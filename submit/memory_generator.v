module memory_generator(
    input signed [31:0] base,   // Base register value
    input signed [31:0] offset, // Immediate offset
    output reg [31:0] addr      // Generated memory address
);

always @(*) begin
    addr = base + offset;
end

endmodule
