module sign_extender(

    input wire [15:0] immediate_in,
    output wire [31:0] immediate_out

);

// copy the msb of the immd16 to the most significant bit of the immd32
// if the msb is 1, then extend the immediate with 1's
// if the msb is 0, then extend the immediate with 0's
always@(*) begin

    if (immediate_in[15] == 1'b1) begin
        immediate_out = 16'hffff_ffff & immediate_in;
    end else begin
        immediate_out = 32'h0000_0000 | immediate_in;
    end

end

endmodule
