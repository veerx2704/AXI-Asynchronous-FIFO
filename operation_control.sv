module operation_control #(parameter N = 16, localparam ptr_width = $clog2(N))(
    input wire [ptr_width:0] in_addr,
    input wire clk,
    input wire rst,
    input wire en,
    input wire wr,
    output wire [ptr_width:0] out_addr,
    output wire [ptr_width:0] out_addr_gray,
    output wire fifo_status
    );
    
function automatic [ptr_width:0] B2G(
    input [ptr_width:0] in0);
    B2G = in0 ^ (in0 >> 1); 
endfunction
    reg [ptr_width:0] out_addr_reg;
    reg [ptr_width:0] gray_out;
    wire [ptr_width:0] next_out_addr;
    wire [ptr_width:0] out_addr_wire;
    reg fifo_status_reg;
    wire flag;

    always @(posedge clk) begin
        if (!rst) out_addr_reg <= '0;
        else out_addr_reg <= next_out_addr;
    end

    always @(posedge clk) begin
        if (!rst) fifo_status_reg <= '0;
        else fifo_status_reg <= flag;
    end
    
    always @(posedge clk) begin
        if (!rst) gray_out <= '0;
        else gray_out <= out_addr_wire;
    end
    assign flag = wr ? (out_addr_wire == in_addr ? '1 : '0) : (out_addr_wire == {~in_addr[ptr_width:ptr_width-1],in_addr[ptr_width-2:0]} ? '1 : '0);
    assign out_addr_wire = B2G(next_out_addr);
    assign out_addr_gray = gray_out;
    assign next_out_addr = (en && !fifo_status_reg) ? out_addr_reg + 1 : out_addr_reg;
    assign out_addr = out_addr_reg;
    assign fifo_status = fifo_status_reg;
    
    
    
endmodule
