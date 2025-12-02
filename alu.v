module alu(
    input wire [31:0] a,                // first operand (rs)
    input wire [31:0] b,                // second operand (rt or immediate)
    input wire [3:0] alu_control,       // selects the operation
    output wire [31:0] result,          // ALU output
    output wire zero                    // asserted when result == 0
);

// Operation    : AND
// ALU control  : 0000
wire [31:0] AND_result;
and ALU_and(AND_result, a, b);

// Operation    : OR
// ALU control  : 0001
wire [31:0] OR_result;
or ALU_or(OR_result, a, b);

// Operation    : ADD
// ALU control  : 0010
wire [31:0] ADD_result;
wire ADD_cout;
adder_32bit
    #(.CARRY_IN_0(1'b0))
ALU_adder
    (a, b, ADD_result, ADD_cout);

// Operation    : XOR
// ALU control  : 0011
wire [31:0] XOR_result;
xor ALU_xor(XOR_result, a, b);

// Operation    : SUB
// ALU control  : 0110
// use adder to achive this by 2's comp.
wire [31:0] SUB_result;
wire SUB_cout;
wire [31:0] ones_complement_result;
assign ones_complement_result = ~b;

adder_32bit
    #(.CARRY_IN_0(1'b1))
substractor_32bit
    (
        .a(a), 
        .b(ones_complement_result), 
        .sum(SUB_result), 
        .carry_out(SUB_cout)
    );

// Operation    : SLT (set less than)
// ALU control  : 0111
wire [31:0] SLT_result_muxed;
wire [31:0] SLT_A_is_Less = 32'd1;  // Result when A < B (SUB_result[31] = 1)
wire [31:0] SLT_A_is_Greater_Equal = 32'd0; // Result when A >= B (SUB_result[31] = 0)


assign SLT_MUX_SEL = SUB_result[31];

para_mux2to1
    #(.DATA_WIDTH(32))
SLT_mux
    (
        .inputA(SLT_A_is_Greater_Equal), 
        .inputB(SLT_A_is_Less),         
        .select(SLT_MUX_SEL),           
        .outputY(SLT_result_muxed)
    );

assign SLT_result = SLT_result_muxed;


wire [31:0] ZERO_32 = 32'b0;

wire [31:0] mux_L1_out0;
wire [31:0] mux_L1_out1;
wire [31:0] mux_L1_out2;
wire [31:0] mux_L1_out3;

para_mux2to1 mux_L1_0 (.inputA(AND_result), .inputB(OR_result), .select(alu_control[0]), .outputY(mux_L1_out0));
para_mux2to1 mux_L1_1 (.inputA(ADD_result), .inputB(XOR_result), .select(alu_control[0]), .outputY(mux_L1_out1));
para_mux2to1 mux_L1_2 (.inputA(ZERO_32), .inputB(ZERO_32), .select(alu_control[0]), .outputY(mux_L1_out2));
para_mux2to1 mux_L1_3 (.inputA(SUB_result), .inputB(SLT_result), .select(alu_control[0]), .outputY(mux_L1_out3));

wire [31:0] mux_L2_out0;
wire [31:0] mux_L2_out1;

para_mux2to1 mux_L2_0 (.inputA(mux_L1_out0), .inputB(mux_L1_out1), .select(alu_control[1]), .outputY(mux_L2_out0));
para_mux2to1 mux_L2_1 (.inputA(mux_L1_out2), .inputB(mux_L1_out3), .select(alu_control[1]), .outputY(mux_L2_out1));

para_mux2to1 mux_L3_FINAL (.inputA(mux_L2_out0), .inputB(mux_L2_out1), .select(alu_control[2]), .outputY(result));

endmodule