`timescale 1ns / 1ps

module synch_fifo_tb;

parameter FIFO_WIDTH = 32;
parameter FIFO_DEPTH = 16;
parameter FIFO_PTR = 4;

// Inputs
reg clk;
reg rst_n;
reg fifo_wren;
reg fifo_rden;
reg [FIFO_WIDTH-1:0] fifo_wrdata;

// Outputs
wire [FIFO_WIDTH-1:0] fifo_rddata;
wire fifo_full;
wire fifo_empty;
wire [FIFO_PTR:0] fifo_room_avail;
wire [FIFO_PTR:0] fifo_data_avail;

// Instantiate the Unit Under Test (UUT)
synch_fifo #(
    .FIFO_WIDTH(FIFO_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_PTR(FIFO_PTR)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .fifo_wren(fifo_wren),
    .fifo_rden(fifo_rden),
    .fifo_wrdata(fifo_wrdata),
    .fifo_rddata(fifo_rddata),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .fifo_room_avail(fifo_room_avail),
    .fifo_data_avail(fifo_data_avail)
);

initial begin
    // Initialize Inputs
    clk = 0;
    rst_n = 0;
    fifo_wren = 0;
    fifo_rden = 0;
    fifo_wrdata = 0;

    // Wait 100 ns for global reset to finish
    #50;
    rst_n = 1;
    
    // Fill the FIFO and check for full condition
    repeat (FIFO_DEPTH) begin
        @(posedge clk);
        fifo_wren = 1;
        fifo_wrdata = $random;
    end

    @(posedge clk);
    fifo_wren = 0;

    // Check if FIFO is full
    @(posedge clk);
    if (!fifo_full) $display("Error: FIFO should be full!");

    // Read half of the FIFO
    repeat (FIFO_DEPTH / 2) begin
        @(posedge clk);
        fifo_rden = 1;
    end
@(posedge clk);
    fifo_rden = 0;

    // Write back to half full FIFO
    repeat (FIFO_DEPTH / 2) begin
        @(posedge clk);
        fifo_wren = 1;
        fifo_wrdata = $random;
    end
   @(posedge clk);
    fifo_wren = 0;

    // Completely empty the FIFO
    repeat (FIFO_DEPTH) begin
        @(posedge clk);
        fifo_rden = 1;
    end
@(posedge clk);
    fifo_rden = 0;

    // Check if FIFO is empty
    @(posedge clk);
    if (!fifo_empty) $display("Error: FIFO should be empty!");

    repeat (1000) begin
        @(posedge clk);
        fifo_wren = $random % 2;
        fifo_rden = $random % 2;
        fifo_wrdata = $random;
        // if (fifo_wren && !fifo_full) fifo_wrdata = $random;
        // fifo_wren = fifo_wren && !fifo_full;
        // fifo_rden = fifo_rden && !fifo_empty;
    end

    // Finish simulation
    $finish;
end

// Clock generation
always #5 clk = !clk;  // 100MHz Clock


`ifdef FSDB
initial begin
	$fsdbDumpfile("tb_counter.fsdb");
	$fsdbDumpvars;
end
`endif
endmodule
