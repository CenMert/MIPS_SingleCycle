module register_file(
	input wire clk,
	input wire reset,
	input wire reg_write,			// write enable
	input wire [4:0] read_reg1,	// rs
	input wire [4:0] read_reg2,	// rt
	input wire [4:0] write_reg,	// rd (R-type) - rt (I-type)
	input wire [31:0] write_data,
	
	output wire [31:0] read_data1,	// R[rs] - reg content of rs
	output wire [31:0] read_data2		// R[rt] - reg content of rt
);
// REQ:
// use always@(posedge clk)
// 32 bit X 32 regs

reg [31:0] register [0:31]; // 32 bit X 31 times reg

// to not see the X's on the graphs
// just initialize all of'em
integer k;
initial begin

	for (k = 0; k < 32; k = k+1) begin
		register[k] = 32'b0;
	end
	
end

always@(posedge clk) begin
	
	// it can't be the $zero register
	if (reg_write && (write_reg != 5'b0) ) begin
		register[write_reg] <= write_data;
	end
end

// if zero bit then return 0, else return the value of the register
assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];
assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];

endmodule