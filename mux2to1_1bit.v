module mux2to1 (
    input wire input0,   // Input 0
    input wire input1,   // Input 1
    input wire select,   // Select line
    output wire out      // Output
);

// so the equation is basicly
// y = (sel * i1) + (!sel * i0)
// y =      a     +     b

wire wSelNot;
wire firstOut;
wire secondOut;
// wire resOut;

not sel_not(wSelNot, select);

and first(firstOut, select, input1);
and second(secondOut, wSelNot, input0);

or result(out, firstOut, secondOut);

// or
// assign out = resOut;

endmodule