`timescale 1ns / 1ps
module synch_fifo #(
    parameter  FIFO_WIDTH  = 32,                    //fifo width
    parameter  FIFO_DEEPTH = 16,                    //fifo deepth
    parameter  FIFO_PTR    = 4 )                   //fifo pointer
   (input      fifo_clk,                           //clk
    input      rst,                                 //reset
    input      fifo_wren,                           //write enable
    input      fifo_rden,                          //read enable
    input      [FIFO_WIDTH - 1:0] fifo_wrdata,     //write data
    output reg [FIFO_WIDTH - 1:0] fifo_rddata,     //read data
    output reg fifo_full,                           //fifo full signal
    output reg fifo_empty,                         //fifo empty signal
    output reg [FIFO_PTR:0] fifo_room_avail,       //fifo avail entry
    output     [FIFO_PTR:0] fifo_data_avail       //fifo occupied entry
);

reg  [FIFO_PTR - 1:0] wr_ptr;
reg  [FIFO_PTR - 1:0] rd_ptr;
reg  [FIFO_PTR - 1:0] wr_ptr_nxt;
reg  [FIFO_PTR - 1:0] rd_ptr_nxt;
reg  [FIFO_PTR:0] num_entries;
reg  [FIFO_PTR:0] num_entries_nxt;
wire fifo_full_nxt;
wire fifo_empty_nxt;
wire [FIFO_PTR:0] fifo_room_avail_nxt;      
wire [FIFO_PTR:0] fifo_data_avail_nxt;

localparam FIFO_DEEPTH_MINUS = FIFO_DEEPTH - 1;

//write-pointer contrl logic
always@(wr_ptr or fifo_wren)
    begin
        wr_ptr_nxt = wr_ptr;
        if (fifo_wren) begin
                if (wr_ptr == FIFO_DEEPTH_MINUS) 
                    wr_ptr_nxt = 'd0;
                else
                    wr_ptr_nxt = wr_ptr + 1'b1;                                           
        end 
    end

//read-pointer contrl logic
always@(rd_ptr or fifo_rden)
    begin
        rd_ptr_nxt = rd_ptr;
        if (fifo_rden) begin
                if (rd_ptr == FIFO_DEEPTH_MINUS)
                    rd_ptr_nxt = 'd0;
                else
                    rd_ptr_nxt = rd_ptr + 1'b1;                                    
        end 
    end


//caclute number of occupied entried in the FIFI
always @(num_entries or fifo_rden or fifo_wren) begin
    num_entries_nxt = num_entries;
    if (fifo_wren && fifo_rden) 
        num_entries_nxt = num_entries;
    else if (fifo_wren)
        num_entries_nxt = num_entries + 1'b1;
    else if (fifo_rden) 
        num_entries_nxt = num_entries - 1'b1 ;
    
end

assign fifo_full_nxt = (num_entries_nxt == FIFO_DEEPTH);
assign fifo_empty_next = (num_entries_nxt == 1'd0);
assign fifo_data_avail = num_entries;
assign fifo_data_avail_nxt = FIFO_DEEPTH - num_entries_nxt;


always @(posedge fifo_clk or negedge rst) begin
   if (!rst) begin
    wr_ptr              <= 'd0;
    rd_ptr              <= 'd0;
    num_entries         <= 'd0;
    fifo_full           <= 1'b0;
    fifo_empty          <= 1'b1;
    fifo_room_avail     <= FIFO_DEEPTH;
   end else begin
    wr_ptr          <= wr_ptr_nxt;
    rd_ptr          <= rd_ptr_nxt;
    num_entries     <= num_entries_nxt;
    fifo_full       <= fifo_full_nxt;
    fifo_empty      <= fifo_empty_nxt;
    fifo_room_avail <= fifo_room_avail_nxt;    
   end 
end
    
endmodule