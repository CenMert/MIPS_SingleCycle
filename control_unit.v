module control_unit(

    input wire [5:0] opcode,
    output wire reg_dst,        // 0: rt (I-type), 1: rd (R-type)
    output wire alu_src,        // 0: register, 1: immediate
    output wire reg_write,      // Enable register file write
    output wire [1:0] alu_op    // ALU operation type indicator

);

// bascly get the op code, and produce the the control signals based on the opcode.
// Ill use the case statement to produce the control signals.

always@(*) begin
    case (opcode)
    
        // R-type instructions
        6'b000000: begin 
            reg_dst <= 1'b1;
            alu_src <= 1'b0;
            reg_write <= 1'b1;
            alu_op <= 2'b10;
        end
        // I-types instructions

        // ADDI
        6'b001000: begin 
            reg_dst <= 1'b0;
            alu_src <= 1'b1;
            reg_write <= 1'b1;
            alu_op <= 2'b00;
        end

        // ANDI
        6'b001100: begin 
            reg_dst <= 1'b0;
            alu_src <= 1'b1;
            reg_write <= 1'b1;
            alu_op <= 2'b11;
        end

        // ORI
        6'b001101: begin 
            reg_dst <= 1'b0;
            alu_src <= 1'b1;
            reg_write <= 1'b1;
            alu_op <= 2'b11;
        end

        // XORI
        6'b001110: begin 
            reg_dst <= 1'b0;
            alu_src <= 1'b1;
            reg_write <= 1'b1;
            alu_op <= 2'b11;
        end

        // SLTI
        6'b001010: begin 
            reg_dst <= 1'b0;
            alu_src <= 1'b1;
            reg_write <= 1'b1;
            alu_op <= 2'b01;
        end

    endcase
end
endmodule