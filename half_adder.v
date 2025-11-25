module half_adder(
    input wire a, // First input bit
    input wire b, // Second input bit
    output wire sum, // Output for the sum bit
    output wire carry // Output for the carry bit
);

    xor sum_gate(sum, a, b); // The sum is the XOR of the two inputs
    and carry_gate(carry, a, b); // The carry is the AND of the two inputs

endmodule