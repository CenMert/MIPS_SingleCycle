module para_mux2to1
    # (parameter DATA_WIDTH = 32;) 
(
    // Input/Output ports are 5 bits wide
    input wire [DATA_WIDTH-1:0] inputA,    // 5-bit Input A (Selected when select=0)
    input wire [DATA_WIDTH-1:0] inputB,    // 5-bit Input B (Selected when select=1)
    input wire select,          // Shared Select Line (1-bit)
    output wire [DATA_WIDTH-1:0] outputY   // 5-bit Output
);

    // genvar: declaration for the structural loop variable 'i'
    genvar i;

    // The generate block creates physical copies of the hardware inside the loop
    generate
        // Loop 5 times (for bits 0 through 4)
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bit_slice
            
            // Instantiate one structural mux2to1 for each bit position 'i'.
            // This is equivalent to connecting 5 separate mux chips.
            mux2to1 u_mux (
                .input0(inputA[i]),    // Connect the i-th bit of Input A
                .input1(inputB[i]),    // Connect the i-th bit of Input B
                .select(select),       // Connect the common select line
                .out(outputY[i])       // Connect to the i-th bit of the Output Y
            );
            
        end
    endgenerate

endmodule