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