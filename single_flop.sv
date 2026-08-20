module single_flop #(parameter N = 1)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [N-1:0] d_in,
    output wire [N-1:0] d_out
    );
    reg [N-1:0] d_out_reg;
    always_ff @(posedge clk) begin
        if (!rst) d_out_reg <= '0;
        else if(en) d_out_reg <= d_in;
        else d_out_reg <= d_out_reg;
    end
    assign d_out = d_out_reg;
endmodule
