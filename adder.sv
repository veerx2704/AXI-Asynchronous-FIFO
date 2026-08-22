module adder #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] SrcA,
    input wire [WIDTH-1:0] SrcB,
    input wire Cin,
    output wire [WIDTH-1:0] Sum,
    output wire Cout
);

wire [WIDTH - 1:0] G;
wire [WIDTH - 1:0] P;
wire [WIDTH:0] C;
assign C[0] = Cin;
generate
    genvar i;
    for (i = 0; i < WIDTH; i++) begin : CARRY_LOOKAHEAD_STAGE
        assign G[i] = SrcA[i] & SrcB[i];
        assign P[i] = SrcA[i] ^ SrcB[i];
        assign C[i+1] = G[i] | (P[i] & C[i]);
        assign Sum[i] = P[i] ^ C[i];
    end : CARRY_LOOKAHEAD_STAGE
endgenerate
assign Cout = C[WIDTH];

//assign {Cout, Sum} = SrcA + SrcB + Cin;

endmodule