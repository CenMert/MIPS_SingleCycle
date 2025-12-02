module half_adder(
    input wire a, // First input bit
    input wire b, // Second input bit
    output wire sum, // Output for the sum bit
    output wire carry // Output for the carry bit
);

    xor sum_gate(sum, a, b); // The sum is the XOR of the two inputs
    and carry_gate(carry, a, b); // The carry is the AND of the two inputs

endmodule

module full_adder(
    input wire a, // First input bit
    input wire b, // Second input bit
    input wire carry_in, // Carry input from the previous stage
    output wire sum, // Output for the sum bit
    output wire carry_out // Output for the carry bit
);

    wire temp_out;

    xor sum_gate1(temp_out, a, b); // First stage XOR for sum
    xor sum_gate2(sum, temp_out, carry_in); // Final sum with carry

    wire temp_out_carry0, temp_out_carry1;
    and carry_gate1(temp_out_carry0, a, b); // Carry from a
    and carry_gate2(temp_out_carry1, temp_out, carry_in); // Carry from sum and carry_in
    or carry_gate(carry_out, temp_out_carry0, temp_out_carry1); // Final carry output
    
    // Modular and structural design of full adder. 

endmodule

// Ill use this CARRY_IN_0 for the sub and add operations.
// I dont want to use one more adder to get 2's comp, in order
// to get rid of that, Ill add 1 from the beginning
module adder_32bit
    parameter CARRY_IN_0 = 1'b0;
(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] sum,
    output wire carry_out
);
    
    // Wire for the carry chain: 32 bits for internal carry + 1 for Cin_0 (index 0)
    wire [32:0] carry_chain; 
    
    // Assign the initial carry-in from the parameter
    assign carry_chain[0] = CARRY_IN_0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i+1) : concat_full_adder
        begin
            
            full_adder generate_full_adder
            (
                .a(a[i]),
                .b(b[i]),
                .carry_in(carry_chain[i]),      // Carry-in from the previous stage
                .sum(sum[i]),
                .carry_out(carry_chain[i+1])    // Carry-out to the next stage
            );

        end
    endgenerate

    // Assign the final carry-out to the module output
    assign carry_out = carry_chain[32];

endmodule