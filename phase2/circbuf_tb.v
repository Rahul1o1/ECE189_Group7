`timescale 1ns/1ns

module tb_circbuf ();
    reg clk = 0;
    reg reset = 1;
    reg write_en = 0;
    reg read_en = 0;
    reg [31:0] write_data = 0;
    wire [31:0] read_data;
    wire full, empty;

    // Instantiate FIFO
    circbuf #(8,32) uut (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .write_data(write_data),
        .read_en(read_en),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );

    // Generate clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("circbuf.vcd");
        $dumpvars(0, tb_circbuf);
	clk =1;
        $display("Starting FIFO test...");
        reset <= 1;
        write_en <= 0;
        read_en <= 0;
        write_data <= 0;
        @(posedge clk);
        reset <= 0;

        // Step 1: Write until full
        while (!full) begin
            @(posedge clk);
            write_en <= 1;
            write_data <= write_data + 1;
            @(posedge clk);
            write_en <= 0; // pulse
        end

        $display("FIFO is full, starting to read 4 elements...");

        // Step 2: Read 4 elements
        repeat (4) begin
            @(posedge clk);
            if (!empty) begin
                read_en <= 1;
                @(posedge clk);
                read_en <= 0; // pulse
            end
        end

        $display("Step 2 complete, writing again until full...");

        // Step 3: Write until full again
        while (!full) begin
            @(posedge clk);
            write_en <= 1;
            write_data <= write_data + 1;
            @(posedge clk);
            write_en <= 0; // pulse
        end

        $display("Step 3 complete, reading remaining elements...");

        // Step 4: Read until empty
        while (!empty) begin
            @(posedge clk);
            read_en <= 1;
            @(posedge clk);
            read_en <= 0; // pulse
        end

        $display("FIFO read complete.");
        #10 $finish;
    end

    // Monitor signals
    always @(posedge clk) begin
        $display("Time=%0t | WriteEn=%b ReadEn=%b | WriteData=%0d ReadData=%0d | Full=%b Empty=%b",
                 $time, write_en, read_en, write_data, read_data, full, empty);
    end
endmodule

