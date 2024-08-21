`timescale 1ns / 1ps

module synch_fifo #(
    parameter   FIFO_WIDTH = 32,                      // Data width of FIFO
    parameter   FIFO_DEPTH = 16,                      // Number of entries in FIFO
    parameter   FIFO_PTR = 4                          // Bit width of pointers
) (
    input       clk,                                  // Clock
    input       rst_n,                                // Active low reset
    input       fifo_wren,                            // Write enable
    input       fifo_rden,                            // Read enable
    input       [FIFO_WIDTH-1:0] fifo_wrdata,         // Data input for FIFO
    output reg  [FIFO_WIDTH-1:0] fifo_rddata,         // Data output from FIFO
    output      fifo_full,                            // FIFO full flag
    output      fifo_empty,                           // FIFO empty flag
    output      [FIFO_PTR:0] fifo_room_avail,         // Number of available spaces in FIFO
    output      [FIFO_PTR:0] fifo_data_avail          // Number of data items in FIFO
);

// Internal registers and wires
reg [FIFO_WIDTH-1:0] mem [0:FIFO_DEPTH-1];      // Memory array for FIFO
reg [FIFO_PTR-1:0] wr_ptr, rd_ptr;              // Write and read pointers
reg [FIFO_PTR:0] count;                         // Count of items in FIFO

assign fifo_data_avail = count;
assign fifo_full = (count == FIFO_DEPTH - 1);       // If full, keep 1
assign fifo_empty = (count == 0);               // If empty, keep 1
assign fifo_room_avail = FIFO_DEPTH - count;

// Handle reset, write and read operations
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
        
    end else begin
        // Write operation
        if (fifo_wren && !fifo_full && !fifo_rden) begin
            mem[wr_ptr] <= fifo_wrdata;
            wr_ptr <= (wr_ptr + 1) % FIFO_DEPTH;
            count <= count + 1;
        end

        // Read operation
        if (fifo_rden && !fifo_wren && !fifo_empty) begin
            fifo_rddata <= mem[rd_ptr];
            rd_ptr <= (rd_ptr + 1) % FIFO_DEPTH;
            count <= count - 1;
        end

        if (fifo_wren && fifo_rden && !fifo_full) begin
            if (fifo_empty)
                fifo_rddata <= fifo_wrdata;
            else begin
                mem[wr_ptr] <= fifo_wrdata;
                fifo_rddata <= mem[rd_ptr];
                wr_ptr <= wr_ptr + 1;
                rd_ptr <= rd_ptr + 1;
            end
            
        end
    end
end

endmodule
