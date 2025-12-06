module control_unit(

    input wire [5:0] opcode,
    output wire reg_dst,        // 0: rt (I-type), 1: rd (R-type)
    output wire alu_src,        // 0: register, 1: immediate
    output wire reg_write,      // Enable register file write
    output wire [1:0] alu_op    // ALU operation type indicator

);

// bascly get the op code, and produce the the control signals based on the opcode.
// Ill use the case statement to produce the control signals.

reg tempRegD, tempAlu, tempRegW;
reg [1:0] tempAluOp; 

always@(*) begin
    case (opcode)
    
        // R-type instructions
        6'b000000: begin 
            tempRegD = 1'b1;
            tempAlu = 1'b0;
            tempRegW = 1'b1;
            tempAluOp = 2'b10;
        end
        // I-types instructions

        // ADDI
        6'b001000: begin 
            tempRegD <= 1'b0;
            tempAlu <= 1'b1;
            tempRegW <= 1'b1;
            tempAluOp <= 2'b00;
        end

        // ANDI
        6'b001100: begin 
            tempRegD <= 1'b0;
            tempAlu <= 1'b1;
            tempRegW <= 1'b1;
            tempAluOp <= 2'b11;
        end

        // ORI
        6'b001101: begin 
            tempRegD <= 1'b0;
            tempAlu <= 1'b1;
            tempRegW <= 1'b1;
            tempAluOp <= 2'b11;
        end

        // XORI
        6'b001110: begin 
            tempRegD <= 1'b0;
            tempAlu <= 1'b1;
            tempRegW <= 1'b1;
            tempAluOp <= 2'b11;
        end

        // SLTI
        6'b001010: begin 
            tempRegD <= 1'b0;
            tempAlu <= 1'b1;
            tempRegW <= 1'b1;
            tempAluOp <= 2'b01;
        end

    endcase

end

assign reg_dst = tempRegD;
assign alu_src = tempAlu;
assign reg_write = tempRegW;
assign alu_op = tempAluOp;
	 
endmodule