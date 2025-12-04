`timescale 1ns/1ns

module tb_fifo ();
    reg clk = 0;
    reg reset = 1;
    reg write_en = 0;
    reg read_en = 0;
    reg [31:0] write_data = 0;
    wire [31:0] read_data;
    wire full, empty;

    // Instantiate FIFO
    fifo #(8,32) uut (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .write_data(write_data),
        .read_en(read_en),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );

    // Generate clock
    always #5 clk = ~clk;

    // Test sequence
  initial begin
    $dumpfile("fifo.vcd");   // output VCD file
    $dumpvars(0, tb_fifo);   // dump all signals in tb_fifo
  	clk =1;
  	reset =1;
    $display("Starting FIFO test...");
    #10 reset = 0; // release reset

    // Step 1: Write until full
    while (!full) begin
        @(posedge clk);
        write_en <= 1;
        write_data <= write_data + 1;
    end
    
    @(posedge clk);
    write_en <= 0;
    $display("FIFO is full, starting to read 4 elements...");

    // Step 2: Read 4 elements
    repeat (4) begin
        @(posedge clk);
        if (!empty) begin
            read_en <= 1;
        end else begin
            read_en <= 0;
        end
    end
    @(posedge clk);
    read_en <= 0;

    $display("Step 2 complete, writing again until full...");

    // Step 3: Write until full again
    while (!full) begin
        @(posedge clk);
        write_en <= 1;
        write_data <= write_data + 1;
    end
    @(posedge clk);
    write_en <= 0;

    $display("Step 3 complete, reading remaining elements...");

    // Step 4: Read until empty
    while (!empty) begin
        @(posedge clk);
        read_en <= 1;
    end
    @(posedge clk);
    read_en <= 0;

    $display("FIFO read complete.");
    #10 $finish;
end



    // Monitor
    always @(posedge clk) begin
        $display("Time=%0t | WriteEn=%b ReadEn=%b | WriteData=%0d ReadData=%0d | Full=%b Empty=%b",
                 $time, write_en, read_en, write_data, read_data, full, empty);
    end
endmodule

