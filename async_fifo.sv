`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 04:09:09 PM
// Design Name: 
// Module Name: async_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifo #(parameter data_width = 32, 
                    parameter N = 16, 
                    parameter ptr_width = $clog2(N))(
    input wire [data_width - 1:0] wdata,
    input wire wen,
    input wire wclk,
    input wrst,
    input rrst,
    input wire rclk,
    input wire ren,
    output wire [data_width - 1:0] rdata,
    output wire fifo_full,
    output wire fifo_empty,
    output wire [ptr_width:0] wptr_out,
    output wire [ptr_width:0] rptr_out
    );
    
    
    wire [data_width-1:0] rdata_mem;
    wire [ptr_width:0] wptr, rptr;
  wire [ptr_width:0] rptr_0;
  wire [ptr_width:0] rptr_1;
  wire [ptr_width:0] wptr_0;
  wire [ptr_width:0] wptr_1;
  wire [ptr_width:0] wptr_bin;
  wire [ptr_width:0] rptr_bin;
    
    operation_control #(.N(N)) write_handler (.clk(wclk), 
                                              .in_addr(rptr_1),
                                              .rst(wrst),
                                              .wr('0),
                                              .en(wen),
                                              .out_addr(wptr_bin),
                                              .out_addr_gray(wptr),
                                              .fifo_status(fifo_full));
    operation_control #(.N(N)) read_handler (.clk(rclk), 
                                              .in_addr(wptr_1),
                                              .rst(rrst),
                                              .wr('1),
                                              .en(ren),
                                              .out_addr(rptr_bin),
                                              .out_addr_gray(rptr),
                                              .fifo_status(fifo_empty));
                                              

     
     single_flop #(.N(ptr_width+1)) W_CROSSED_0(.clk(rclk), .rst(rrst), .en('1), .d_in(wptr), .d_out(wptr_0));
     single_flop #(.N(ptr_width+1)) W_CROSSED_1(.clk(rclk), .rst(rrst), .en('1), .d_in(wptr_0), .d_out(wptr_1));

     single_flop #(.N(ptr_width+1)) R_CROSSED_0(.clk(wclk), .rst(wrst), .en('1), .d_in(rptr), .d_out(rptr_0));
     single_flop #(.N(ptr_width+1)) R_CROSSED_1(.clk(wclk), .rst(wrst), .en('1), .d_in(rptr_0), .d_out(rptr_1));
     
     
     assign wen_mem = wen & (~fifo_full);
     assign ren_mem = ren & (~fifo_empty);
     fifo_memory #(.N(N), .D(data_width)) FIFO (.clk(wclk),
                                                .rst(wrst),
                                                .waddr(wptr_bin[ptr_width-1:0]),
                                                .wen(wen_mem),
                                                .ren(ren_mem),
                                                .wdata(wdata),
                                                .raddr(rptr_bin[ptr_width-1:0]),
                                                .rdata(rdata_mem));
     
     assign rdata = rdata_mem;
     assign wptr_out = wptr_bin;
     assign rptr_out = rptr_bin;
endmodule
