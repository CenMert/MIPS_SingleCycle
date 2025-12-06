module alu_control(
input wire [1:0] alu_op,        // From Control Unit
input wire [5:0] funct,         // From instruction [5:0]
output wire [3:0] alu_control   // To ALU
);

reg alu_control_temp;

always@(*) begin  
    if (alu_op == 2'b00) begin
        alu_control_temp <= 4'b0010;
    end else if (alu_op == 2'b01) begin
        alu_control_temp <= 4'b0111;
    end else if (alu_op == 2'b10) begin
        
        case (funct)
            
            // ADD
            6'b100000: begin
                alu_control_temp <= 4'b0010;
            end

            // SUB
            6'b100010: begin
                alu_control_temp <= 4'b0110;
            end

            // AND
            6'b100100: begin
                alu_control_temp <= 4'b0000;
            end

            // OR
            6'b100101: begin
                alu_control_temp <= 4'b0001;
            end

            // XOR
            6'b100110: begin
                alu_control_temp <= 4'b0011;
            end
            
            6'b101010: begin
                alu_control_temp <= 4'b0111;
            end
        endcase
    end

    // bitwise operations
    else if (alu_op == 2'b11) begin
        alu_control_temp <= 4'bxxxx;
    end
end

assign alu_control = alu_control_temp;

endmodule