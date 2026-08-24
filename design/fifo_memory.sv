`timescale 1ns / 1ps
module fifo_memory #(parameter N = 16, parameter D = 32, localparam ptr_width = $clog2(N))(
    input wire [ptr_width-1:0] waddr,
    input wire [ptr_width-1:0] raddr,
    input wire clk,
    input wire rst,
    input wire wen,
    input wire ren,
    input wire [D-1:0] wdata,
    output wire [D-1:0] rdata
    );
    
    reg [D-1:0] mem [N-1:0];
    int i;
    always @(posedge clk) begin
        if(!rst) begin
            for (i = 0; i < N; i=i+1)
                mem[i] <= '0;
        end
        else begin
            if(wen) mem[waddr] <= wdata;
            else mem[waddr] <= mem[waddr];
        end
    end
    
    assign rdata = ren ? mem[raddr] : 'z;
endmodule
