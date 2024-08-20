`timescale 1ns / 1ps

module synch_fifo_tb();

    parameter  FIFO_WIDTH  = 32;
    parameter  FIFO_DEEPTH = 16;
    parameter  FIFO_PTR    = 4;

    reg fifo_clk;
    reg rst;
    reg fifo_wren;
    reg fifo_rden;
    reg [FIFO_WIDTH - 1:0] fifo_wrdata;
    wire [FIFO_WIDTH - 1:0] fifo_rddata;
    wire fifo_full;
    wire fifo_empty;
    wire [FIFO_PTR:0] fifo_room_avail;
    wire [FIFO_PTR:0] fifo_data_avail;

    // Instantiate the Unit Under Test (UUT)
    synch_fifo #(
        .FIFO_WIDTH(FIFO_WIDTH),
        .FIFO_DEEPTH(FIFO_DEEPTH),
        .FIFO_PTR(FIFO_PTR)
    ) uut (
        .fifo_clk(fifo_clk),
        .rst(rst),
        .fifo_wren(fifo_wren),
        .fifo_rden(fifo_rden),
        .fifo_wrdata(fifo_wrdata),
        .fifo_rddata(fifo_rddata),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .fifo_room_avail(fifo_room_avail),
        .fifo_data_avail(fifo_data_avail)
    );

    // Clock generation
    always #10 fifo_clk = ~fifo_clk;

    // Initialize Inputs
    initial begin
        fifo_clk = 0;
        rst = 1;
        fifo_wren = 0;
        fifo_rden = 0;
        fifo_wrdata = 0;

        // Reset the FIFO
        #100;
        rst = 0;
        #100;
        rst = 1;
        #100;

        // Write to the FIFO
        repeat (5) begin
            @ (posedge fifo_clk);
            if (!fifo_full) begin
                fifo_wren = 1;
                fifo_wrdata = $random;
            end
            @ (posedge fifo_clk);
            fifo_wren = 0;
        end

        // Read from the FIFO
        repeat (3) begin
            @ (posedge fifo_clk);
            if (!fifo_empty) begin
                fifo_rden = 1;
            end
            @ (posedge fifo_clk);
            fifo_rden = 0;
        end

        // Additional writes and reads to test underflow and overflow
        repeat (20) begin
            @ (posedge fifo_clk);
            fifo_wren = $random & 1;
            fifo_rden = $random & 1;
            if (fifo_wren && !fifo_full)
                fifo_wrdata = $random;
        end

        // Finish the simulation
        #500;
        $finish;
    end

endmodule
