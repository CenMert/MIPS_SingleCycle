module mux2to1_5bit(
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire sel,
    output wire [4:0] y
);

genvar i;
generate
    for (i = 0; i < 5; i = i + 1) begin : mux2to1_5bit
        mux2to1 base_mux (
            .input0(in0[i]),
            .input1(in1[i]),
            .select(sel),
            .out(y[i])
        );
    end
endgenerate

endmodule