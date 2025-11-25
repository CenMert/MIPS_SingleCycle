module alu(
    input wire [31:0] a,                // first operand (rs)
    input wire [31:0] b,                // second operand (rt or immediate)
    input wire [3:0] alu_control,       // selects the operation
    output wire [31:0] result,          // ALU output
    output wire zero                    // asserted when result == 0
);

wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] nor_result;
wire [31:0] add_result;
wire [31:0] sub_result;
wire [31:0] slt_result;
wire [31:0] zero_vector;
wire sub_overflow;
wire slt_bit;

assign zero_vector = 32'b0;

bitwise_and32 and_unit (
    .a(a),
    .b(b),
    .y(and_result)
);

bitwise_or32 or_unit (
    .a(a),
    .b(b),
    .y(or_result)
);

bitwise_nor32 nor_unit (
    .a(a),
    .b(b),
    .y(nor_result)
);

ripple_adder32 add_unit (
    .a(a),
    .b(b),
    .cin(1'b0),
    .sum(add_result),
    .cout(),
    .overflow()
);

wire [31:0] b_inverted;
bitwise_not32 invert_b (
    .a(b),
    .y(b_inverted)
);

ripple_adder32 sub_unit (
    .a(a),
    .b(b_inverted),
    .cin(1'b1),
    .sum(sub_result),
    .cout(),
    .overflow(sub_overflow)
);

slt_vector32 slt_vec (
    .lt(slt_bit),
    .result(slt_result)
);

slt_compare slt_cmp (
    .a(a),
    .b(b),
    .difference(sub_result),
    .overflow(sub_overflow),
    .lt(slt_bit)
);

mux16 #(32) result_mux (
    .in0(and_result),
    .in1(or_result),
    .in2(add_result),
    .in3(zero_vector),
    .in4(zero_vector),
    .in5(zero_vector),
    .in6(sub_result),
    .in7(slt_result),
    .in8(zero_vector),
    .in9(zero_vector),
    .in10(zero_vector),
    .in11(zero_vector),
    .in12(nor_result),
    .in13(zero_vector),
    .in14(zero_vector),
    .in15(zero_vector),
    .sel(alu_control),
    .y(result)
);

zero_detector32 zero_check (
    .value(result),
    .zero(zero)
);

endmodule

module full_adder (
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);

wire axorb;
wire and_ab;
wire and_ac;
wire and_bc;

xor (axorb, a, b);
xor (sum, axorb, cin);
and (and_ab, a, b);
and (and_ac, a, cin);
and (and_bc, b, cin);
or (cout, and_ab, and_ac, and_bc);

endmodule

module ripple_adder32 (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire cin,
    output wire [31:0] sum,
    output wire cout,
    output wire overflow
);

wire [31:0] carry;

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : add_stage
        if (i == 0) begin
            full_adder fa0 (
                .a(a[i]),
                .b(b[i]),
                .cin(cin),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end else begin
            full_adder faN (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    end
endgenerate

assign cout = carry[31];
assign overflow = carry[31] ^ carry[30];

endmodule

module bitwise_and32 (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] y
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : and_bits
        and (y[i], a[i], b[i]);
    end
endgenerate

endmodule

module bitwise_or32 (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] y
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : or_bits
        or (y[i], a[i], b[i]);
    end
endgenerate

endmodule

module bitwise_nor32 (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] y
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : nor_bits
        nor (y[i], a[i], b[i]);
    end
endgenerate

endmodule

module bitwise_not32 (
    input wire [31:0] a,
    output wire [31:0] y
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : not_bits
        not (y[i], a[i]);
    end
endgenerate

endmodule

module slt_compare (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] difference,
    input wire overflow,
    output wire lt
);

wire sign_a;
wire sign_b;
wire diff_sign;
wire sign_differs;
wire sign_same;
wire lt_when_diff;
wire lt_same_raw;
wire lt_same_masked;
wire not_sign_b;

assign sign_a = a[31];
assign sign_b = b[31];
assign diff_sign = difference[31];

not (not_sign_b, sign_b);
xor (sign_differs, sign_a, sign_b);
not (sign_same, sign_differs);
xor (lt_same_raw, diff_sign, overflow);
and (lt_same_masked, lt_same_raw, sign_same);
and (lt_when_diff, sign_a, not_sign_b);
or (lt, lt_when_diff, lt_same_masked);

endmodule

module slt_vector32 (
    input wire lt,
    output wire [31:0] result
);

assign result[0] = lt;

genvar i;
generate
    for (i = 1; i < 32; i = i + 1) begin : slt_bits
        assign result[i] = 1'b0;
    end
endgenerate

endmodule

module mux2 #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire sel,
    output wire [WIDTH-1:0] y
);

wire sel_n;
not (sel_n, sel);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : mux_bits
        wire a_sel;
        wire b_sel;
        and (a_sel, sel_n, a[i]);
        and (b_sel, sel, b[i]);
        or (y[i], a_sel, b_sel);
    end
endgenerate

endmodule

module mux16 #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire [WIDTH-1:0] in3,
    input wire [WIDTH-1:0] in4,
    input wire [WIDTH-1:0] in5,
    input wire [WIDTH-1:0] in6,
    input wire [WIDTH-1:0] in7,
    input wire [WIDTH-1:0] in8,
    input wire [WIDTH-1:0] in9,
    input wire [WIDTH-1:0] in10,
    input wire [WIDTH-1:0] in11,
    input wire [WIDTH-1:0] in12,
    input wire [WIDTH-1:0] in13,
    input wire [WIDTH-1:0] in14,
    input wire [WIDTH-1:0] in15,
    input wire [3:0] sel,
    output wire [WIDTH-1:0] y
);

wire [WIDTH-1:0] level1_0;
wire [WIDTH-1:0] level1_1;
wire [WIDTH-1:0] level1_2;
wire [WIDTH-1:0] level1_3;
wire [WIDTH-1:0] level1_4;
wire [WIDTH-1:0] level1_5;
wire [WIDTH-1:0] level1_6;
wire [WIDTH-1:0] level1_7;

mux2 #(WIDTH) mux_l1_0 (.a(in0),  .b(in1),  .sel(sel[0]), .y(level1_0));
mux2 #(WIDTH) mux_l1_1 (.a(in2),  .b(in3),  .sel(sel[0]), .y(level1_1));
mux2 #(WIDTH) mux_l1_2 (.a(in4),  .b(in5),  .sel(sel[0]), .y(level1_2));
mux2 #(WIDTH) mux_l1_3 (.a(in6),  .b(in7),  .sel(sel[0]), .y(level1_3));
mux2 #(WIDTH) mux_l1_4 (.a(in8),  .b(in9),  .sel(sel[0]), .y(level1_4));
mux2 #(WIDTH) mux_l1_5 (.a(in10), .b(in11), .sel(sel[0]), .y(level1_5));
mux2 #(WIDTH) mux_l1_6 (.a(in12), .b(in13), .sel(sel[0]), .y(level1_6));
mux2 #(WIDTH) mux_l1_7 (.a(in14), .b(in15), .sel(sel[0]), .y(level1_7));

wire [WIDTH-1:0] level2_0;
wire [WIDTH-1:0] level2_1;
wire [WIDTH-1:0] level2_2;
wire [WIDTH-1:0] level2_3;

mux2 #(WIDTH) mux_l2_0 (.a(level1_0), .b(level1_1), .sel(sel[1]), .y(level2_0));
mux2 #(WIDTH) mux_l2_1 (.a(level1_2), .b(level1_3), .sel(sel[1]), .y(level2_1));
mux2 #(WIDTH) mux_l2_2 (.a(level1_4), .b(level1_5), .sel(sel[1]), .y(level2_2));
mux2 #(WIDTH) mux_l2_3 (.a(level1_6), .b(level1_7), .sel(sel[1]), .y(level2_3));

wire [WIDTH-1:0] level3_0;
wire [WIDTH-1:0] level3_1;

mux2 #(WIDTH) mux_l3_0 (.a(level2_0), .b(level2_1), .sel(sel[2]), .y(level3_0));
mux2 #(WIDTH) mux_l3_1 (.a(level2_2), .b(level2_3), .sel(sel[2]), .y(level3_1));

mux2 #(WIDTH) mux_l4_0 (.a(level3_0), .b(level3_1), .sel(sel[3]), .y(y));

endmodule

module zero_detector32 (
    input wire [31:0] value,
    output wire zero
);

wire [15:0] level1;
wire [7:0] level2;
wire [3:0] level3;
wire [1:0] level4;
wire non_zero;

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : level1_gen
        or (level1[i], value[2*i], value[2*i+1]);
    end
endgenerate

generate
    for (i = 0; i < 8; i = i + 1) begin : level2_gen
        or (level2[i], level1[2*i], level1[2*i+1]);
    end
endgenerate

generate
    for (i = 0; i < 4; i = i + 1) begin : level3_gen
        or (level3[i], level2[2*i], level2[2*i+1]);
    end
endgenerate

generate
    for (i = 0; i < 2; i = i + 1) begin : level4_gen
        or (level4[i], level3[2*i], level3[2*i+1]);
    end
endgenerate

or (non_zero, level4[0], level4[1]);
not (zero, non_zero);

endmodule